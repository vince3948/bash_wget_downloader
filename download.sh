#!/bin/bash
#
# Bash Wget Downloader
#

# vars
set -u
list="";dest=""
red="\e[1;31m";green="\e[1;32m";blue="\e[1;34m";off="\e[0m"
wget_params="-cN --no-use-server-timestamps"
quiet=false;
clean=false;

# fonctions
show_help() {
    echo -e "\n ${blue}Bash Wget Downloader${off} usage : \n"
    echo -e "./$(basename "$0") -l|-f [links_file] -d [dir_destination] [-q (quiet)] [-c (clean list)] \n"
    echo -e "Ex : ./$(basename "$0") -l link.txt -d /data/download/"
    echo -e "\nNB : links_file will be create with vim if not exist\n"
    exit
}

test_dest() {
    if [ -z $dest ] ;then echo -e "\n...${red}No param for dest !${off} ...\n" && show_help;fi
    if [ ! -d "$dest" ];then echo -e "\n ...${red}Error destination : ${off} $dest doesn't exist !\n"  && show_help;fi 
}

test_list() {
    if [ -z $list ] ;then echo -e "\n...${red}No param for list !${off} ...\n" && show_help;fi
    if [ ! -f "$list" ];then 
        echo -e "\n Create $list ...!"
        vim $list 
    fi
    nb_lines=$(wc -l < $list)
}

# get param
while getopts 'l:f:d:qrch' opts; do
   case ${opts} in
      l|f) list="${OPTARG}" ;;
      d) dest="${OPTARG}" ;;
      q) quiet=true ;;
      c) clean=true ;;
      h) show_help ;;
   esac
done

# main
echo -e "\n${blue}... Bash Downloader ...${off}"
test_dest
test_list

echo -e "\nDest : $dest"
echo -e "\nList : $list ($nb_lines lines)"

if [ $quiet == false ];then echo -e "" && read -ep "....Press enter to continue....";fi


# download !
i=1
cd $dest
for f in $(cat $list);
do
           echo -e "\n${blue}Link${off} $i of $nb_lines : $f \n"
           wget $wget_params $f
           ((i++))
done

# clean list file
if [ $clean == true ];then
    echo -en "\n${blue}Clean${off} list : "
    rm -vf $list
    echo -e ""
fi

