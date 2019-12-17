#! /bin/bash

user=$1
service=$2

if [ "$#" -ne 2 ]; then
        echo "Error: parameters problem"
        exit 1
fi

if [ ! -d "$user" ];then
        echo "Error: user does not exist"
        exit 1

elif [ ! -f "$user"/"$service" ];then
        echo "Error: service does not exist"
        exit 1


elif [  -f "$user"/"$service" ];then
        ./P.sh "$user"
        rm "$user"/"$service"
        echo "OK: service removed"
        ./V.sh "$user"
        exit 0
fi