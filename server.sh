#!/bin/bash


if [ ! -e server.pipe ]; then
       mkfifo server.pipe
fi

while true; do
        read inputt < server.pipe
        echo "Received: $inputt"
        input=($inputt)
        clientID="${input[0]}"
        request="${input[1]}"
        user="${input[2]}"
        service="${input[3]}"
        login="${input[4]}"
        password="${input[5]}"
        dir_name=`dirname "$service"`
        base_name=`basename "$service"`
        case "$request" in
                init)
                        ./init.sh "$user" > "$clientID.pipe" &
                        ;;
                insert)  
                       
                        ./insert.sh "$user" "$service" "" "login: ${login}\npassword: ${password}" > "$clientID.pipe" &
                        ;;
                show)
                        ./show.sh "$user" "$service" > "$clientID.pipe" &
                        ;;
                update)

                        ./insert.sh "$user" "$service" f "login: ${login}\npassword: ${password}" > "$clientID.pipe" &
                        ;;
                rm)
                        ./rm.sh "$user" "$service" > "$clientID.pipe" &
                        ;;
                ls)
                        ./ls.sh "$user" "$service" > "$clientID.pipe" &
                        ;;
                shutdown)
                        echo "Server shuting down.."  > "$clientID.pipe"
                        rm -rf server.pipe
                        exit 0
                        ;;
                *)
                        echo "Error: bad request"
                        echo "Error: bad request" > "$clientID.pipe"
                        rm -rf server.pipe
                        exit 1
        esac
done