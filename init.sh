#! /bin/bash

user=$1
if [ "$#" -ne 1 ]; then
        echo "Error: parameters problem"
        exit 1
fi

if [ ! -d "$user" ];then
        ./P.sh "$user"
        mkdir "$user"
        echo "OK: user created"
        ./V.sh "$user"
        exit 0
else

       echo "Error: user already exist"
        exit 1
fi

