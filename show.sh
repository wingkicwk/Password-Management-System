#! /bin/bash




service=$2
user=$1
dir_name=`dirname "$service"`
base_name=`basename  "$service"`

if [ "$#" -ne 2 ]; then
        echo "Error: parameters problem"
        exit 1
fi

if [ ! -d "$user" ];then
        echo "Error: user does not exist"
        exit 1
fi

if [ ! -f "$user"/"$dir_name"/"$base_name" ];then
        echo "Error: service does not exist"
        exit 1
else
        ./P.sh "$user"
        cat "$user"/"$dir_name"/"$base_name"
        ./V.sh "$user"
        exit 0
fi
