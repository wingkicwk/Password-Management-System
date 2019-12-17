#! /bin/bash

user=$1
service=$2
dir_name=`dirname "$service"`
base_name=`basename "$service"`
override=$3
payload=$4

if [ "$#" -ne 4 ]; then
        echo "Error: parameters problem"
        exit 1
fi

if [ ! -d "$user" ];then
        echo "Error: user does not exist"
        exit 1

elif [ ! -d "$user"/"$dir_name" ];then
        ./P.sh "$user"
        mkdir "$user"/"$dir_name"
        ./V.sh "$user"
fi

./P.sh "$user"
if [ ! -f "$user"/"$dir_name"/"$base_name" ] && [ "$override" = "f" ];then
        touch "$user"/"$dir_name"/"$base_name"
        echo -e "$payload">>"$user"/"$dir_name"/"$base_name"
        echo "OK: service created"
        ./V.sh "$user"
        exit 0

elif [ -f "$user"/"$dir_name"/"$base_name" ] && [ "$override" != "f" ];then
        echo "Error: service already exist"
        ./V.sh "$user"
        exit 1

elif [ ! -f "$user"/"$dir_name"/"$base_name" ] && [ "$override" != "f" ];then
        touch "$user"/"$dir_name"/"$base_name"
        echo -e "$payload" > "$user"/"$dir_name"/"$base_name"
        echo "OK: service created" 
        ./V.sh "$user"
        exit 0

elif [ -f "$user"/"$dir_name"/"$base_name" ] && [ "$override" = "f" ];then
        echo -e "$payload">"$user"/"$dir_name"/"$base_name"
        echo "OK: service updated"
        ./V.sh "$user"
        exit 0

fi

