#!/bin/bash

# # Prompt the user for the type of upgrade
# current_version=$(sw_vers -productVersion)
# echo "The current macOS version installed is: $current_version"
# read -p "Is the macOS version currently >=15.0 (yes/no): " response
# if [[ "$response" == "yes" ]]; then
#     echo "You are running a version greater than or equal to 15.0."
#     echo "Performing a minor upgrades..."
#     sleep 3
#     sudo softwareupdate --list
#     sudo softwareupdate --install --all --force --restart
# elif [[ "$response" == "no" ]]; then
#     echo "You are running a version less than 15.0."
#     echo "Performing a major upgrade..."
#     sudo softwareupdate --fetch-full-installer --full-installer-version 15.4.1
#     sudo /Applications/Install\ macOS\ Sequoia.app/Contents/Resources/startosinstall --agreetolicense --nointeraction --rebootdelay 10 --forcequitapps --user dadmin --passprompt
# else
#     echo "Invalid response. Please run the script again and answer with 'yes' or 'no'."
#     exit 1
# fi


# Get and print the current macOS version
current_version=$(sw_vers -productVersion)
echo "The current macOS version installed is: $current_version"

# Extract the major version number
major_version=$(echo "$current_version" | cut -d '.' -f 1)

# Determine the type of upgrade based on the version
if (( major_version >= 15 )); then
    echo "The macOS version is greater than or equal to 15.0."
    echo "Performing a minor upgrade..."
    sleep 3
    sudo softwareupdate --list
    sudo softwareupdate --install --all --force --restart
else
    echo "The macOS version is less than 15.0."
    echo "Performing a major upgrade..."
    sudo softwareupdate --fetch-full-installer --full-installer-version 15.4.1
    sudo /Applications/Install\ macOS\ Sequoia.app/Contents/Resources/startosinstall --agreetolicense --nointeraction --rebootdelay 10 --forcequitapps --user dadmin --passprompt
fi