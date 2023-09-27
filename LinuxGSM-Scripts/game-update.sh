#!/bin/bash

##Script to Update All Game Servers

#Machine Updates
clear
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
sleep 3s
clear
#Updates Machine First
sudo apt update -y && sudo apt upgrade -y
sleep 3s
clear

#Turn Off Game Servers - REQUIRES stop.sh in /home
sudo ./stop.sh

#Update Game Servers

#CS:GO Server
echo "
   █████████  █████████    █████████     ███████   
  ███░░░░░██████░░░░░███  ███░░░░░███  ███░░░░░███ 
 ███     ░░░░███    ░░░  ███     ░░░  ███     ░░███
░███        ░░█████████ ░███         ░███      ░███
░███         ░░░░░░░░███░███    █████░███      ░███
░░███     ██████    ░███░░███  ░░███ ░░███     ███ 
 ░░█████████░░█████████  ░░█████████  ░░░███████░  
  ░░░░░░░░░  ░░░░░░░░░    ░░░░░░░░░     ░░░░░░░    
"
sleep 1s
# "csgo" is the user for the account. Replace with whatever you made it.
su - csgo -c "./csgoserver update"
sleep 2s
clear

echo "
 ██████████      ███████   █████
░░███░░░░███   ███░░░░░███░░███ 
 ░███   ░░███ ███     ░░███░███ 
 ░███    ░███░███      ░███░███ 
 ░███    ░███░███      ░███░███ 
 ░███    ███ ░░███     ███ ░███ 
 ██████████   ░░░███████░  █████
░░░░░░░░░░      ░░░░░░░   ░░░░░ 
"
sleep 1s
# "doi" is the user for the account. Replace with whatever you made it.
su - doi -c "./doiserver update"
sleep 2s
clear

echo "
 ███████████ █████████  ███████████ ███████████  
░░███░░░░░░████░░░░░███░█░░░███░░░█░░███░░░░░███ 
 ░███   █ ░███     ░░░ ░   ░███  ░  ░███    ░███ 
 ░███████ ░███             ░███     ░██████████  
 ░███░░░█ ░███             ░███     ░███░░░░░███ 
 ░███  ░  ░░███     ███    ░███     ░███    ░███ 
 █████     ░░█████████     █████    █████   █████
░░░░░       ░░░░░░░░░     ░░░░░    ░░░░░   ░░░░░ 
"
sleep 1s
# "fctr" is the user for the account. Replace with whatever you made it.
su - fctr -c "./fctrserver update"
sleep 2s
clear

#Garry's Mod Server
echo "
   █████████  ██████   ██████   ███████   ██████████  
  ███░░░░░███░░██████ ██████  ███░░░░░███░░███░░░░███ 
 ███     ░░░  ░███░█████░███ ███     ░░███░███   ░░███
░███          ░███░░███ ░███░███      ░███░███    ░███
░███    █████ ░███ ░░░  ░███░███      ░███░███    ░███
░░███  ░░███  ░███      ░███░░███     ███ ░███    ███ 
 ░░█████████  █████     █████░░░███████░  ██████████  
  ░░░░░░░░░  ░░░░░     ░░░░░   ░░░░░░░   ░░░░░░░░░░   
"
sleep 1s
# "gmod" is the user for the account. Replace with whatever you made it.
su - gmod -c "./gmod update"
sleep 2s
clear

#Insurgency: Sandstorm Server
echo "
  █████████                         █████       █████                                      
 ███░░░░░███                       ░░███       ░░███                                       
░███    ░░░  ██████  ████████    ███████  ████████████    ██████  ████████  █████████████  
░░█████████ ░░░░░███░░███░░███  ███░░███ ███░░░░░███░    ███░░███░░███░░███░░███░░███░░███ 
 ░░░░░░░░███ ███████ ░███ ░███ ░███ ░███░░█████ ░███    ░███ ░███ ░███ ░░░  ░███ ░███ ░███ 
 ███    ░██████░░███ ░███ ░███ ░███ ░███ ░░░░███░███ ███░███ ░███ ░███      ░███ ░███ ░███ 
░░█████████░░████████████ █████░░██████████████ ░░█████ ░░██████  █████     █████░███ █████
 ░░░░░░░░░  ░░░░░░░░░░░░ ░░░░░  ░░░░░░░░░░░░░░   ░░░░░   ░░░░░░  ░░░░░     ░░░░░ ░░░ ░░░░░ 
"
sleep 1s
# "inss" is the user for the account. Replace with whatever you made it.
su - inss -c "./inssserver update"
sleep 2s
clear

#Left 4 Dead 2 Server
echo "
 ██████████ █████ ██████████    ████████ 
░░███░░███ ░░███ ░░███░░░░███  ███░░░░███
 ░███ ░███  ░███ █░███   ░░███░░░    ░███
 ░███ ░███████████░███    ░███   ███████ 
 ░███ ░░░░░░░███░█░███    ░███  ███░░░░  
 ░███      █░███░ ░███    ███  ███      █
 ████████████████ ██████████  ░██████████
░░░░░░░░░░░░░░░░ ░░░░░░░░░░   ░░░░░░░░░░ 
"
sleep 1s
# "l4d2" is the user for the account. Replace with whatever you made it.
su - l4d2 -c "./l4d2server update"
sleep 2s
clear

#Minecraft Server
echo "
 ██████   ██████ ███                                                  ██████  █████   
░░██████ ██████ ░░░                                                  ███░░███░░███    
 ░███░█████░███ ████ ████████    ██████  ██████  ████████  ██████   ░███ ░░░ ███████  
 ░███░░███ ░███░░███░░███░░███  ███░░██████░░███░░███░░███░░░░░███ ███████  ░░░███░   
 ░███ ░░░  ░███ ░███ ░███ ░███ ░███████░███ ░░░  ░███ ░░░  ███████░░░███░     ░███    
 ░███      ░███ ░███ ░███ ░███ ░███░░░ ░███  ███ ░███     ███░░███  ░███      ░███ ███
 █████     ██████████████ █████░░██████░░██████  █████   ░░████████ █████     ░░█████ 
░░░░░     ░░░░░░░░░░░░░░ ░░░░░  ░░░░░░  ░░░░░░  ░░░░░     ░░░░░░░░ ░░░░░       ░░░░░  
"
sleep 1s
# "mc" is the user for the account. Replace with whatever you made it.
su - mc -c "./mcserver update"
sleep 2s
clear

#Natural Selection 2 Server
echo "
 ██████   █████  █████████  ████████ 
░░██████ ░░███  ███░░░░░██████░░░░███
 ░███░███ ░███ ░███    ░░░░░░    ░███
 ░███░░███░███ ░░█████████   ███████ 
 ░███ ░░██████  ░░░░░░░░███ ███░░░░  
 ░███  ░░█████  ███    ░██████      █
 █████  ░░█████░░█████████░██████████
░░░░░    ░░░░░  ░░░░░░░░░ ░░░░░░░░░░ 
"
sleep 1s
# "ns2" is the user for the account. Replace with whatever you made it.
su - ns2 -c "./ns2server update"
sleep 2s
clear

#TeamSpeak Server
echo "
 ████████████████████  ████████ 
░█░░░███░░░███░░░░░██████░░░░███
░   ░███  ░███    ░░░░░░    ░███
    ░███  ░░█████████   ██████░ 
    ░███   ░░░░░░░░███ ░░░░░░███
    ░███   ███    ░██████   ░███
    █████ ░░█████████░░████████ 
   ░░░░░   ░░░░░░░░░  ░░░░░░░░  
"
sleep 1s
# "ts3" is the user for the account. Replace with whatever you made it.
su - ts3 -c "./ts3server update"
sleep 2s
clear

#Finished
echo "
  █████████                                                          
 ███░░░░░███                                                         
░███    ░░░   ██████  ████████  █████ █████ ██████  ████████ █████   
░░█████████  ███░░███░░███░░███░░███ ░░███ ███░░███░░███░░█████░░    
 ░░░░░░░░███░███████  ░███ ░░░  ░███  ░███░███████  ░███ ░░░░█████   
 ███    ░███░███░░░   ░███      ░░███ ███ ░███░░░   ░███    ░░░░███  
░░█████████ ░░██████  █████      ░░█████  ░░██████  █████   ██████   
 ░░░░░░░░░   ░░░░░░  ░░░░░        ░░░░░    ░░░░░░  ░░░░░   ░░░░░░    
 █████  █████              █████           █████                █████
░░███  ░░███              ░░███           ░░███                ░░███ 
 ░███   ░███ ████████   ███████   ██████  ███████    ██████  ███████ 
 ░███   ░███░░███░░███ ███░░███  ░░░░░███░░░███░    ███░░██████░░███ 
 ░███   ░███ ░███ ░███░███ ░███   ███████  ░███    ░███████░███ ░███ 
 ░███   ░███ ░███ ░███░███ ░███  ███░░███  ░███ ███░███░░░ ░███ ░███ 
 ░░████████  ░███████ ░░████████░░████████ ░░█████ ░░██████░░████████
  ░░░░░░░░   ░███░░░   ░░░░░░░░  ░░░░░░░░   ░░░░░   ░░░░░░  ░░░░░░░░ 
             ░███                                                    
             █████                                                   
            ░░░░░                                                    
"
sudo sleep 3s
clear

# Feel free to remove if you have modified the script.
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

#Reboot Machine
echo "----Machine will Reboot in 10s!----"
sleep 1s
clear
echo "
 ████    █████   
░░███  ███░░░███ 
 ░███ ███   ░░███
 ░███░███    ░███
 ░███░███    ░███
 ░███░░███   ███ 
 █████░░░█████░  
░░░░░   ░░░░░░   
"
sleep 1s
clear
echo "
  ████████ 
 ███░░░░███
░███   ░███
░░█████████
 ░░░░░░░███
 ███   ░███
░░████████ 
 ░░░░░░░░  
"
sleep 1s
clear
echo "
  ████████ 
 ███░░░░███
░███   ░███
░░████████ 
 ███░░░░███
░███   ░███
░░████████ 
 ░░░░░░░░  
"
sleep 1s
clear
echo "
 ██████████
░███░░░░███
░░░    ███ 
      ███  
     ███   
    ███    
   ███     
  ░░░      
"
sleep 1s
clear
echo "
  ████████ 
 ███░░░░███
░███   ░░░ 
░█████████ 
░███░░░░███
░███   ░███
░░████████ 
 ░░░░░░░░  
"
sleep 1s
clear
echo "
 ██████████
░███░░░░░░█
░███     ░ 
░█████████ 
░░░░░░░░███
 ███   ░███
░░████████ 
 ░░░░░░░░  
"
sleep 1s
clear
echo "
 █████ █████ 
░░███ ░░███  
 ░███  ░███ █
 ░███████████
 ░░░░░░░███░█
       ░███░ 
       █████ 
      ░░░░░  
"
sleep 1s
clear
echo "
  ████████ 
 ███░░░░███
░░░    ░███
   ██████░ 
  ░░░░░░███
 ███   ░███
░░████████ 
 ░░░░░░░░  
"
sleep 1s
clear
echo "
  ████████ 
 ███░░░░███
░░░    ░███
   ███████ 
  ███░░░░  
 ███      █
░██████████
░░░░░░░░░░ 
"
sleep 1s
clear
echo "
 ████ 
░░███ 
 ░███ 
 ░███ 
 ░███ 
 ░███ 
 █████
░░░░░ 
"
sleep 1s
clear
echo "
 ███████████           █████                        █████    ███                     ███
░░███░░░░░███         ░░███                        ░░███    ░░░                     ░███
 ░███    ░███   ██████ ░███████   ██████   ██████  ███████  ████ ████████    ███████░███
 ░██████████   ███░░███░███░░███ ███░░███ ███░░███░░░███░  ░░███░░███░░███  ███░░███░███
 ░███░░░░░███ ░███████ ░███ ░███░███ ░███░███ ░███  ░███    ░███ ░███ ░███ ░███ ░███░███
 ░███    ░███ ░███░░░  ░███ ░███░███ ░███░███ ░███  ░███ ███░███ ░███ ░███ ░███ ░███░░░ 
 █████   █████░░██████ ████████ ░░██████ ░░██████   ░░█████ █████████ █████░░███████ ███
░░░░░   ░░░░░  ░░░░░░ ░░░░░░░░   ░░░░░░   ░░░░░░     ░░░░░ ░░░░░░░░░ ░░░░░  ░░░░░███░░░ 
                                                                            ███ ░███    
                                                                           ░░██████     
                                                                            ░░░░░░      
"
sleep 2s
sudo reboot