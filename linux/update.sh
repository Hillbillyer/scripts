#!/bin/sh

##Script to Update Server
sleep 2s
#Update 
echo "
 ██████   ██████                   █████      ███                    
░░██████ ██████                   ░░███      ░░░                     
 ░███░█████░███   ██████    ██████ ░███████  ████ ████████    ██████ 
 ░███░░███ ░███  ░░░░░███  ███░░███░███░░███░░███░░███░░███  ███░░███
 ░███ ░░░  ░███   ███████ ░███ ░░░ ░███ ░███ ░███ ░███ ░███ ░███████ 
 ░███      ░███  ███░░███ ░███  ███░███ ░███ ░███ ░███ ░███ ░███░░░  
 █████     █████░░████████░░██████ ████ ██████████████ █████░░██████ 
░░░░░     ░░░░░  ░░░░░░░░  ░░░░░░ ░░░░ ░░░░░░░░░░░░░░ ░░░░░  ░░░░░░  
                                                                     
                                                                     
                                                                     
 █████  █████              █████           █████                     
░░███  ░░███              ░░███           ░░███                      
 ░███   ░███ ████████   ███████   ██████  ███████    ██████          
 ░███   ░███░░███░░███ ███░░███  ░░░░░███░░░███░    ███░░███         
 ░███   ░███ ░███ ░███░███ ░███   ███████  ░███    ░███████          
 ░███   ░███ ░███ ░███░███ ░███  ███░░███  ░███ ███░███░░░           
 ░░████████  ░███████ ░░████████░░████████ ░░█████ ░░██████          
  ░░░░░░░░   ░███░░░   ░░░░░░░░  ░░░░░░░░   ░░░░░   ░░░░░░           
             ░███                                                    
             █████                                                   
            ░░░░░                                                    
"
sleep 2s
clear
    # Update package lists
    sudo NEEDRESTART_MODE=a apt update

    # Upgrade installed packages
    sudo NEEDRESTART_MODE=a apt upgrade -y

    # Upgrade the distribution (including the OS)
    sudo NEEDRESTART_MODE=a apt dist-upgrade -y

    # Remove unnecessary files
    sudo NEEDRESTART_MODE=a apt autoremove -y
    sudo NEEDRESTART_MODE=a apt clean
    sleep 2s
    clear

#Feel free to remove this if you modify the script.
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