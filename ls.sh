#! /bin/bash


if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
        echo "Error: parameters problem"
        exit 1
else
    user="$1"
    folder="$2"

if [ ! -d "$user" ];then
        echo "Error: user does not exist"
        exit 1

elif [ ! -d "$user"/"$folder" ];then

        echo "Error: folder does not exist"
        exit 1

else    
        ./P.sh "$user" 
        if [ -z "$folder" ]; then
                echo "OK:"
                tree "$user"
                ./V.sh "$user"
                exit 0
        else
                echo "OK:"
                cd $user
                tree "$folder"
                cd ..
                ./V.sh "$user"
                exit 0
        fi
fi
fi