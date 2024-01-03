#!/bin/bash
#
# Bash Wget Downloader
#

# vars
set -u
list="";dest=""
red="\e[1;31m";green="\e[1;32m";blue="\e[1;34m";off="\e[0m"
ask=false;keep=false;limit=false;speed="";

# fonctions
show_help() {
    echo -e "\n ${blue}Bash Wget Downloader${off} usage : \n"
    echo -e "./$(basename "$0") -d [dir_destination] [-f [links_file]] [-a (ask confirmation)] [-k (keep list)] [-l (limit speed to 15MB/s)] \n"
    echo -e "Ex : ./$(basename "$0") -d /data/download/"
    echo -e "\nNB : links_file will be create if not exist\n"
    exit
}

test_dest() {
    if [ -z $dest ] ;then echo -e "\n...${red}No param for dest !${off} ...\n" && show_help;fi
    if [ ! -d "$dest" ];then echo -e "\n ...${red}Error destination : ${off} $dest doesn't exist !\n"  && show_help;fi 
}

test_list() {
    if [ -z $list ] ;then echo -e "\n...${red}No param for list !${off} ... use 'list'" && list="/tmp/list" ;fi
    if [ ! -f "$list" ] || [ "$keep" == false ];then
        echo -e "\n Create $list ...!"
	> $list
    fi
    vim $list
    # delete empty lines
    sed -i '/^$/d' $list
    nb_lines=$(wc -l < $list)
}

# get param
while getopts 'f:d:aklh' opts; do
   case ${opts} in
      f) list="${OPTARG}" ;;
      d) dest="${OPTARG}" ;;
      a) ask=true ;;
      k) keep=true ;;
      l) limit=true ;;
      h) show_help ;;
   esac
done

# main
echo -e "\n${blue}... Bash Downloader ...${off}"
test_dest
test_list

echo -e "\nDest : $dest"
echo -e "\nList : $list ($nb_lines lines)"

if [ $ask == true ];then echo -e "" && read -ep "....Press enter to continue....";fi


# download !
i=1
mylist=$(uniq $list)

echo -e "\n....Liste :"
echo -e "${blue}"
for f in $mylist;
do
 echo -e "$f"
done
echo -e "${off}"

if [ $limit == true ];then
    speed="--limit-rate=15m";
    echo -e "\n${blue}Limit speed to 15 MB/s ;)${off} ..."
else
    echo -e "\n${green}No speed limit !${off} ..."
fi

# clean list file
if [ $keep == false ];then
    echo -e "\n${blue}Clean${off} list : "
    rm -vf $list
fi

download_params="wget -c $speed --no-use-server-timestamps --show-progress --progress=bar:force"

cd $dest
for f in $mylist;
do
	   if [ $i -gt 1 ];then echo "sleep 2s" && sleep 2;fi
           echo -e "\n${blue}Link${off} $i of $nb_lines : $f \n"
	   #echo "$download_params "$f""
           $download_params "$f"
           ((i++))
done

