#!/bin/bash

function sysrest () {
	systemctl restart rinetd
	if [[ $? != 0 ]]; then
	systemctl status rinetd >> /var/log/rinetdauto.log
	printf "Error log = /var/log/rinetd.log"
	else 
	ss -tlupen | grep rinetd
	printf "\nSuccses\n"
	fi
}

function validate_addrs() {
    local addrs="$1"
    local regex="^([0-9]{1,3}\.){3}[0-9]{1,3}$"

    if [[ ! $addrs =~ $regex ]]; then
        echo "Invalid Ip addrs format"
        return 1
    fi

    IFS='.' read -r i1 i2 i3 i4 <<< "$addrs"

    if (( i1 > 255 || i2 > 255 || i3 > 255 || i4 > 255 )); then
        echo "Invalid IP address range"
        return 1
    fi

    return 0
}

function updateapt (){
	apt list rinetd
	sleep 30
	apt update
	sleep 30
	apt upgrade
	sleep 30
	apt install rinetd
	systemctl enable --now rinetd.service
}

function Addnewbind () {
	clear
	printf "Now we can add new binds\n"
	while true;do
	printf "I need now bind addres Example:68.129.200.1 \n{hint you can add address of interface or 0.0.0.0 for all ints}\n"
	read addrs
	validate_addrs "$addrs" && break
	printf "Invalid format"
	done
	printf "Good"
	printf "Now we need bindport(go to us)\n"
	read bindport
	printf "Ok now we need connect address {hit this address where we go [Example:201.211.192.1]\n"
	while true; do
	read connectaddr
	validate_addrs "$connectaddr" && break
	printf "Invalid format"
	done
	printf "Last what we need desport or connect port\n"
	read destport
	clear
	printf "Check all date: $addrs	 $bindport  $connectaddr  $destport \n If all correct type yes [yes/no]\n"
	printf "1)If you don't have int \n 2)Have 2 '0.0.0.0' binds \n 3)Port is used 4)port not correct \n !!!WARNING That may crash skript and rintd WARNING!!!\n"
	ip a | grep inet
	cat /etc/rinetd.conf
	while true ;
	do
		read answ
		case $answ in
			yes)echo "$addrs	$bindport	$connectaddr		$destport">> /etc/rinetd.conf ; sysrest ;  break;;
			no)printf "OK no updates" && break ;;
			*)printf 'Yes or no only';;
		esac
	done
}

function edit_bind(){
	clear
	printf "Creating backup...\n"	;cp /etc/rinetd.conf /var/backups/rinetd.conf
	printf "Let's edit binds \n ALL BINDS \n"
	file=`cat -n /etc/rinetd.conf | grep -v '#'` 
	echo "$file"
	printf "\nNow we need line that we edit. [Example:33]"
	read  numofgrep
	file_edit=`cat -n /etc/rinetd.conf | grep -v '#' | grep -vw $numofgrep`
	cat -n /etc/rinetd.conf | grep -v '#'| grep numofgrep 
	printf "What edit\n1)Bind addres[1]\n2)Bind port[2]\n3)Connection address[3]\n4)Destport[4]\n5)All[5]\n6)Delete Bind[6]"
	while true ;do
		read answofcase
		case $answofcase in
			1)echo 'sorry that app in beta';;
			2)echo 'sorry that app in beta';;
			3)echo 'sorry that app in beta';;
			4)echo 'sorry that app in beta';;
			5)while true;do
        			printf "I need now bind addres Example:68.129.200.1 \n{hint you can add address of interface or 0.0.0.0 for all ints}\n"
        			read addrs
        			validate_addrs "$addrs" && break
        			printf "Invalid format"
        		  done
        		 printf "Good"
        		 printf "Now we need bindport(go to us)\n"
        		 read bindport
        		 printf "Ok now we need connect address {hit this address where we go [Example:201.211.192.1]\n"
        		 while true; do
         		 	read connectaddr
        			validate_addrs "$connectaddr" && break
        			printf "Invalid format"
        		 done
        		printf "Last what we need desport or connect port\n"
       			read destport
        		clear
        		printf "Check all date: $addrs   $bindport  $connectaddr  $destport \n If all correct type yes [yes/no]\n"
        		printf "1)If you don't have int \n 2)Have 2 '0.0.0.0' binds \n 3)Port is used 4)port not correct \n !!!WARNING That may crash skript and rintd WARNING!!!\n"
        		ip a | grep inet
        		cat /etc/rinetd.conf
        		while true ;
        		do
                		read answ
                		case $answ in
                        		yes)cat -n /etc/rinetd.conf | grep -v '#'|grep -vw $numofgrep  |awk '{print $2"	"$3"	"$4"	"$5}' >/etc/rinetd.conf && echo "$addrs        $bindport       $connectaddr            $destport">> /etc/rinetd.conf ; sysrest ;  break ;;
                        		no)printf "OK no updates" && break ;;
                        		*)printf 'Yes or no only';;
                		esac
        		done
;;
			6) echo 'sorry that app in beta';;
			*)printf 'No options';;
		esac
	done

}


function sudouser () {

	clear
	printf "are you root or sudo [yes/no]?"
	while true;do
	read sudou
	case $sudou in
		yes)printf "good" && break;;
		no)printf "Let's restart me with sudo.\n" ; killa=`ps aux | grep addrinetd.sh | head -n 1 | awk '{print $2}'` ; kill $killa ; printf $killa;;
		*)printf "yes/no only";;
	esac
	done
}


function appcase () {
clear
printf "Wellcome to rinetd autoadd \n 1)Add new record (IPv4) \n 2)Edit records (IPv4) (this is beta option and it don't work pls edit it manualy\nPath /etc/rinetd.conf)\n 3)Update and install rinetd {Warning this may couse errors} \n 4)Exit app \n "
read operation
case $operation in
	1)Addnewbind;;
	2)printf "This is beta" echo"#edit_bind";;
	3)updateapt;;
	4)printf "end";;
	*)appcase;;
esac
}

sudouser
appcase
