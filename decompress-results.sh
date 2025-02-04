#! /usr/bin/bash


res_file=results.zip

function decompress_file() {
	unzip $res_file
}

if [ -z "$1" ]; then
	echo "Please give me a result directory..."
	exit 1
else
	res_dir=$1
fi

cd $res_dir

# Decompress server data
echo "Decompress server data..."
cd server
decompress_file
cd ../
echo "Done!"

# Decompress client data
echo "Decompress clients data"
cd clients;
for node in `ls`; do
	cd $node
	decompress_file
	cd ../;
done
cd ../
echo "Done!"

