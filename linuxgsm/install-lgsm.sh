#!/bin/bash

wget -O hills-scripts/lgsm/serverlist.csv https://raw.githubusercontent.com/GameServerManagers/LinuxGSM/master/lgsm/data/serverlist.csv
clear

servers=()
declare -A server_info  # Associative array to store shortname and gamename

while IFS="," read -r shortname gameservername gamename os; do 
    servers+=("$gamename")
    server_info["$gamename"]=$shortname
done < <(tail -n +2 hills-scripts/lgsm/serverlist.csv)

exit_script=false

while [ "$exit_script" != true ]; do
    PS3='Press Ctl+C when you are finished... 
    Please enter your choice: '
    select opt in "${servers[@]}" "quit";
    do
        case $opt in 
            "quit")
                echo "Exiting the script."
                exit_script=true
                break
                ;;
            *)
                clear
                echo "$opt <-- Selected"
                # Add your custom actions based on the selected server here

                # echo "Installing Dependencies"
                # sleep 3s
                # # Download the CSV file
                # wget -O hills-scripts/lgsm/dependencies.csv https://raw.githubusercontent.com/GameServerManagers/LinuxGSM/master/lgsm/data/ubuntu-22.04.csv
                # sudo dpkg --add-architecture i386
                # sudo apt update
                # clear
                # # Use awk to remove the first field from each line and store it in a variable
                # result=$(awk -F',' '{ for(i=2;i<=NF;++i) printf "%s ", $i; print "" }' hills-scripts/lgsm/dependencies.csv)
                # # Replace newlines with spaces
                # result=$(echo "$result" | tr -d '\n')
                # # Trim trailing space
                # result="${result%" "}"
                # # Print the final result
                # echo "Resulting variable: $result"
                # # Create an array from the space-separated string
                # IFS=' ' read -ra packages <<< "$result"
                # # Install packages individually, ignoring errors
                # for package in "${packages[@]}"; do
                #     sudo apt install -y "$package" 2>/dev/null
                # done
                # echo "Dependencies Updated"
                # sleep 3s
                # clear
                echo "Installing '$opt'"
                sleep 3s
                clear
                username="${server_info["$opt"]}"
                
                while true; do
                    read -s -p "Choose a Password for '$username': " password
                    echo # Print a newline after password input
                    
                    read -s -p "Confirm Password: " password_confirm
                    echo # Print a newline after password confirmation
                    
                    if [ "$password" == "$password_confirm" ]; then
                        break
                    else
                        echo "Passwords do not match. Please try again."
                    fi
                done
                
                sudo adduser --gecos "'$username'" --disabled-password "$username"
                sudo chpasswd <<<"$username:$password"
                su - "$username" -c "wget -O linuxgsm.sh https://linuxgsm.sh && chmod +x linuxgsm.sh && bash linuxgsm.sh '$username'server"
                su - "$username" -c "./'$username'server update-lgsm"
                clear
                echo "PLEASE READ CAREFULLY"
                echo
                echo "Some Game Servers require Steam Authentication.
                
                "
                echo "If you know this one doesn't, simply press enter when prompted to enter Steam Credentials."
                echo "If this server requires authentication, type in your steam user and pass when prompted.
                
                "
                echo "When the Game Server is installing, you will need to enter your Steam Guard Code when the installation says:"
                echo ""Installing "$opt" Server""
                echo "Type your Steam Guard Code and press ENTER when you see this happening."
                echo "--sometimes putting it in twice gets it working, don't be afraid--"
                echo "
                
                MORE INFO:
                Go to https://linuxgsm.com/servers/"$username"server/
                
                "

                while true; do
                    read -p "Do you understand how it works? (yes/no/quit): " user_input

                    # Convert user_input to lowercase for case-insensitive comparison
                    user_input_lower=$(echo "$user_input" | tr '[:upper:]' '[:lower:]')

                    if [ "$user_input_lower" == "yes" ]; then
                        echo "Goodluck!"
                        # Add your script logic here
                        break
                    elif [ "$user_input_lower" == "quit" ]; then
                        echo "Exiting the script."
                        exit
                    else
                        echo "Try going to the MORE INFO link."
                    fi
                done
                sleep 2s
                clear
                read -p "Enter your Steam Username: " steamusername
                clear
                
                while true; do
                    read -s -p "Enter your Steam Password: " steampassword
                    echo # Print a newline after Steam password input
                    
                    read -s -p "Confirm Steam Password: " steampassword_confirm
                    echo # Print a newline after Steam password confirmation
                    
                    if [ "$steampassword" == "$steampassword_confirm" ]; then
                        break
                    else
                        echo "Steam Passwords do not match. Please try again."
                    fi
                done
                
                echo -e "steamuser='$steamusername'\nsteampass='$steampassword'" >> "/home/$username/lgsm/config-lgsm/"$username"server/common.cfg"
                
                su - "$username" -c "./'$username'server auto-install"

                # Update package lists
                sudo apt update

                # Upgrade installed packages
                sudo apt upgrade -y

                # Upgrade the distribution (including the OS)
                sudo apt dist-upgrade -y

                # Remove unnecessary files
                sudo apt autoremove -y
                sudo apt clean
                break
                ;;
        esac
    done
done

#Feel free to remove this if you edit the script.
echo "Script By: "
echo "
 █████   █████ ███ ████ ████ █████      ███ ████ ████                             
░░███   ░░███ ░░░ ░░███░░███░░███      ░░░ ░░███░░███                             
 ░███    ░███ ████ ░███ ░███ ░███████  ████ ░███ ░███ █████ ████ ██████  ████████ 
 ░███████████░░███ ░███ ░███ ░███░░███░░███ ░███ ░███░░███ ░███ ███░░███░░███░░███
 ░███░░░░░███ ░███ ░███ ░███ ░███ ░███ ░███ ░███ ░███ ░███ ░███░███████  ░███ ░░░ 
 ░███    ░███ ░███ ░███ ░███ ░███ ░███ ░███ ░███ ░███ ░███ ░███░███░░░   ░███     
 █████   ████████████████████████████  ███████████████░░███████░░██████  █████    
░░░░░   ░░░░░░░░░░░░░░░░░░░░░░░░░░░░  ░░░░░░░░░░░░░░░  ░░░░░███ ░░░░░░  ░░░░░     
                                                       ███ ░███                   
                                                      ░░██████                    
                                                       ░░░░░░                     
"
echo "https://hillbillyer.net"
echo "contact@hillbillyer.net"
sleep 3s
clear