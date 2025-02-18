Cryptonce

1. Contexte
Question: Est-ce qu'en désactivant le double chiffrement on gagne quelque chose?

A. Motivation (PoC):

1. Temps CPU de chiffrement en fonction de la taille des messages
ici, on benchmark les fonctions de chiffrement vs déchiffrement.
On calcule le temps pris par ces fonctions avec des payloads de taille variable.
On fait varier la payload de 50 à 2000 bytes.
On écrit les fonctions en C++, on utilise les librairies libssl et libcrypto, et on
utilise google benchmark\ref{ici}.
On suppose que les temps de chiffrement/déchiffrement mesurés en C++ sont équivalents 
à C. 

La courbe montre que le temps de chiffrement évolue proportionnelement à la taille des paquets.
De façon générale, le MTU est fixé à 1500.
Et l'entête TCP/IP prends entre 40 bytes et 120 bytes, en fonction des options ajoutée aux headers.
On observe que le temps de chiffrement et de déchiffrement d'un message de taille MTU, i.e 1500 bytes 
est ~2 fois moins long que celui d'un message de la taille des headers.
Avec le chiffrement partiel, on espère donc diviser de moitié le temps CPU utilisé pour effectuer
le chiffrement et le déchiffrement.

2. Temps CPU de chiffrement dans Wireguard.
La question ici est de mesurer la proportion de CPU dans Wireguard utilisé
pour effectuer le chiffrement. En effet, c'est ce temps CPU là qu'on espère réduire
en faisant du chiffrement partiel.
On utilise perf pour tracer les fonctions exécutées par le kernel,
et on calcule le temps CPU correspondant au chiffrement+déchiffrement.
On mesure en même temps l'utilisation globale du CPU pour déduire l'utilisation CPU de Wireguard.
On rapporte donc le temps CPU du chiffrement au temps CPU de Wireguard pour estimer
la proportion du temps pris pour effectuer le chiffrement dans le temps de Wireguard.
On fait l'eval en faisant varier le nombre de clients qui génèrent une load, jusqu'à 15Gbps pour ne pas 
surcharger la carte réseau.

On mesure ainsi que le temps de chiffrement représente 20-30% du temps de Wireguard.

Ainsi, en évitant le double chiffrement et en chiffrant uniquement l'en-tête de Wireguard, on peut
atteindre une amélioration de 40% du temps CPU.

B. Implémentation.
i. Partial encryption
ii. Lockless

C. Evaluation
La(es) question(s) qu'on se pose:
- Est-ce qu'en faisant du chiffrement partiel on peut gagner en temps CPU?
- En Latence?

C1. Testbed:
- 18 coeurs, 25 Gbps NIC, Debian 12, Linux 6.1.112
- Hyperthreading désactivé.


C2. Versions de Wireguard:
- Wireguard Linux Kernel Module builtin Linux 6.1.112
- 03 versions:
	- La version A, vanilla, sans modifs
	- La version N, sans echiffrement: On commente les lignes chacha20poly1305 dans le code
	- La version P, avc chiffrement partiel: On applique les modifications présentées dans la section précédente.

C3. Métriques:
- Global CPU usage: avec sar: CPU = 100 - Idle
Chaque mesure est faite toutes les 1 seconde pendant 60 sencondes, et on garde la médiane.
std_dev ne dépasse pas 5% de la médiane.
- Latency: avec netperf TCP_RR 1500/1500
Chaque mesure est faite pendant 60 sencondes, et on garde la médiane.
std_dev ne dépasse pas 5% de la médiane.
- Decrypt Time: Perf
perf record -g pendant 5 secondes.
On compte le nombre de samples correspondant aux fonctions encrypt_packet et decrypt_packet 
où se déroulent respectivement le chiffrement et le déchiffrement.
On divise avec le nombre de samples total pour déduire le pourcentage de temps 
correspondant au temps de chiffrement/déchiffrement sur les 5 secondes de mesure.

Toutes les évals ont été faites 10 fois.
On prends la valeur médiane des 10 runs.
Dans toutes les évals, std_dev ne dépasse pas 5% de la valeur médiane.


C4. Mono Core case
En fait, Wireguard est multithreadé: il initialise plusieurs workers en fonction du nombre
de clients et du nombre de coeurs disponibles sur la machine.
Du coup il y a un coup de scheduling qui peut être non-négligeable, surtout en prenant
en compte le fait que la machine possède 18 coeurs.

Du coup, dans un premier temps, nous voulons faire les évaluations en réduisant le bruit
lié au multithreading au maximum.
Nous utilisons donc 1 seul client qui génère 2.7 Gbps qui correspond à 100% d'utilisation du CPU
dans la version non modifiée.

1. Decrypt Time
On observe que le chiffrement partiel réduit de moitié le temps CPU.
CQFD

2. Latency
On observe que sans le chiffrement, on diminue la latence de XX%,
et avec le chiffrement partiel, on gagne YY%.
Conclusion: Le chiffrement partiel permet de gagner en latence.

3. CPU usage
On observe que sans le chiffrement, on utilise XX% du CPU,
et avec le chiffrement partiel, on utilise YY% du CPU.
On gagne donc XX% sans chiffrement, et YY% avec le chiffrement partiel.


C5. Multi Core case
Ici, on fait varier le nombre de CPU et le nombre de clients alike:
avec 1 coeur, on a 1 client, 2 coeurs 2 clients jusqu'à 18 coeurs 18 clients.
Chaque client dans tous les cas génère 700 Mbps, pour qu'à 18 clients on ait 13Gbps, 
point jusqu'auquel Wireguard est capable de scaler.

1. Decrypt Time
Le chiffrement partiel réduit bien de moitié le temps de déchiffrement

2. Latency
On observe que sans le chiffrement, on diminue la latence de XX%,
et avec le chiffrement partiel, on gagne YY%.
Conclusion: Le chiffrement partiel permet de gagner en latence.

3. CPU usage.
On observe que le gain en CPU usage n'est pas significatif lorsqu'on augmente le nombre de coeurs.
En fait, en regardant de plus près le temps CPU de toutes les fonctions Wireguard,
on observe que le temps CPU qu'on gagne en decrypt, on le perd en spin lock.
(Tracer le flamegraph ici).
Lorsqu'on cummulent le temps passé à attendre de tous les workers, on remarque que...
L'explication est qu'en désactivant le chiffrement, les workers finissent plus vite leur
traitement et donc retournent plus vite attendre le lock.
En clair, Ils vont attendre plus longtemps parce qu'il y a d'autres workers qui vont
utiliser le lock.


C6. Multi Core Sequential encrypt/decrypt

