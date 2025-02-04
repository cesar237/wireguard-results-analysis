. helpers.sh
. helpers-trace-cmd.sh


folder=cryptonce-trace-v2

scp -r nancy.g5k:wireguard-experiment/results/$folder .
decompress_folder $folder
extract_data_csv $folder