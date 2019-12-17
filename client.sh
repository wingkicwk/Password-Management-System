#! /bin/bash

if [ "$#" -lt 2 ]; then
        echo "Error: parameters problem"
        exit 1
fi

echo "Welcome to the Client"
clientID=$1
request=$2
user=$3
service=$4
login=$5
password=$6
mkfifo "$clientID.pipe"

result=`ps aux | grep -i "server.sh" | grep -v "grep" | wc -l`
end=$((SECONDS+10))
if [[ ! $result -ge 1 ]];then
        echo "Waiting for server to respond..(will be timeout after 10 seconds)"
        while [[ ! $result -ge 1 ]] && [ $SECONDS -lt $end ];do
                result=`ps aux | grep -i "server.sh" | grep -v "grep" | wc -l`
        done
        if [[ ! $result -ge 1 ]];then
                echo "There was a problem connecting to the server - please contact an administrator for further support"
                rm -rf "$clientID.pipe"
                exit 1
        fi
fi

echo "Server connected!"

if [ $request = "init" ]; then
        if [[ ! "$#" -eq 3 ]];then
                echo 'Error: parameters problem'
        else
                inputt="$@"
                echo "$inputt" > server.pipe
                cat "$clientID.pipe" 
        fi
        rm -rf "$clientID.pipe"
        
elif [ $request = "insert" ]; then
        if [[ ! "$#" -eq 4 ]];then
                echo 'Error: parameters problem'
        else
                IFS=''
                echo "Please write login:"
                read -r login
                echo "Please write password:"
                read -r password 
                encryptedLogin=`./encrypt.sh $clientID $login`
                encryptedPW=`./encrypt.sh "2$clientID" $password`
                inputt="$@ "$encryptedLogin" "$encryptedPW""              
                echo "$inputt" > server.pipe
                cat "$clientID.pipe"
        fi
        rm -rf "$clientID.pipe"
        

elif [ $request = "show" ]; then
        if [[ ! "$#" -eq 4 ]];then
                echo 'Error: parameters problem'
        else
                inputt="$@"
                echo "$inputt" > server.pipe

                MY_TEMP_FILE_one=`mktemp /tmp/$0.XXXXXX.txt`
                cat "$clientID.pipe" > "$MY_TEMP_FILE_one"
                read line < "$MY_TEMP_FILE_one"
                if [[ "$line" == "Error: user does not exist" || "$line" == "Error: service does not exist" ]];then
                        echo "$line"
                else
                        Payload=`awk '{ print }' "$MY_TEMP_FILE_one"` 
                        LOGIN=`echo $Payload | cut -d' ' -f 2 `
                        PASSWORD=`echo $Payload | cut -d' ' -f 4 `
                        decryptedLogin=`./decrypt.sh $clientID "$LOGIN" `
                        decryptedPW=`./decrypt.sh "2$clientID" "$PASSWORD" `
                        echo ""$user"'s login for $service is: $decryptedLogin"
                        echo ""$user"'s password for $service is: $decryptedPW"
                fi
                rm "$MY_TEMP_FILE_one"
                rm -rf "$clientID.pipe"  
        fi
                                                


elif [ $request = "ls" ]; then
        if [[ "$#" -gt 4 || "$#" -lt 3 ]];then
                echo 'Error: parameters problem'
        else
                inputt="$@"
                echo "$inputt" > server.pipe
                cat "$clientID.pipe"
        fi
        rm -rf "$clientID.pipe"  
        


elif [ $request = "edit" ]; then
        if [[ ! "$#" -eq 4 ]];then
                echo 'Error: parameters problem'
        else
                inputt="$clientID show $user $service" 
                echo "$inputt" > server.pipe

                MY_TEMP_FILE=`mktemp /tmp/$1.XXXXXX.txt`
                cat "$clientID.pipe" > "$MY_TEMP_FILE"

                read line < "$MY_TEMP_FILE"
                if [ "$line" == "Error: user does not exist" ];then
                        echo "$line"
                else
                        Payload=`awk '{ print }' "$MY_TEMP_FILE"`
                        LOGIN=`echo $Payload | cut -d' ' -f 2 `
                        PASSWORD=`echo $Payload | cut -d' ' -f 4 `
                        decryptedLogin=`./decrypt.sh $clientID "$LOGIN" `
                        decryptedPW=`./decrypt.sh "2$clientID" "$PASSWORD" `
                        echo "#Please keep the 'login:'and 'password:'and the space after ':', otherwise errors will occur"> "$MY_TEMP_FILE"
                        echo "login: $decryptedLogin" >> "$MY_TEMP_FILE"
                        echo "password: $decryptedPW" >> "$MY_TEMP_FILE"
                        rm -f "$clientID.pipe" 
                        mkfifo "$clientID.pipe"
                        vim "$MY_TEMP_FILE"
                        LOGIN=`grep "^login:" "$MY_TEMP_FILE"`
                        PASSWORD=`grep "^password:" "$MY_TEMP_FILE"`
                        if ! grep -q "^login:" "$MY_TEMP_FILE" || ! grep -q "^password:" "$MY_TEMP_FILE"; then
                                echo "Error:Wrong input. Cannot detect keyword(login: /password: )"
                                echo "$clientID error" > server.pipe
                                cat "$clientID.pipe"
                                rm -rf "$clientID.pipe"
                                rm "$MY_TEMP_FILE"
                                exit 1
                        fi
                        EditedLOGIN=`echo $LOGIN | cut -d' ' -f 2- `
                        EditedPASSWORD=`echo $PASSWORD | cut -d' ' -f 2- `
                        IFS=''
                        encrypted_Edited_LOGIN=`./encrypt.sh $clientID $EditedLOGIN`
                        encrypted_Edited_PW=`./encrypt.sh "2$clientID" $EditedPASSWORD`
                        inputt="$clientID update $user $service $encrypted_Edited_LOGIN $encrypted_Edited_PW"
                        echo "$inputt" > server.pipe
                        cat "$clientID.pipe"
                fi
                rm "$MY_TEMP_FILE"
        fi
        rm -f "$clientID.pipe"  
                
        

elif [ $request = "rm" ]; then
        if [[ "$#" -gt 4 ]];then
                echo 'Error: parameters problem'
        else
                inputt="$@"
                echo "$inputt" > server.pipe
                cat "$clientID.pipe"
        fi
        rm -f "$clientID.pipe"
        

elif [ $request = "shutdown" ]; then
        inputt="$@"
        echo "$inputt" > server.pipe
        cat "$clientID.pipe"
        rm -rf "$clientID.pipe"
        echo "Client exiting.."
        exit 0

else
        inputt="$@"
        echo "$@" > server.pipe
        cat "$clientID.pipe"
        rm -rf "$clientID.pipe"
        exit 1
fi