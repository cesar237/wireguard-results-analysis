. helpers.sh
. helpers-trace-cmd.sh


#folder=gonogo-5
folder=$1

scp -r nancy.g5k:wireguard-experiment/results/$folder .
decompress_folder $folder
#extract_data_csv $folder
# draw_flamegraph_folder $folder
# ./extract_decrypt.sh $folder
