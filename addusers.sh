#!/bin/bash

clear
echo "Adding new users:"
echo "Press enter to continue..."

while [ true ]; do
  clear
  echo "Enter username:"
  read username
  
  sudo adduser $username
  sudo chage -d 0 $username
  
  echo "Press enter to continue..."
  read
  
  while [ true ]; do
    clear
    echo "Add another user? (y/n)"
    read choice
  
    case $choice in
      y)
	break;
      ;;
      n)
	exit 0;
      ;;
      *)
	echo "Invalid choice"
      ;;
    esac
  done
done
    