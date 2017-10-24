#!/bin/bash
#This version out put the result in CSV format

# Printing the first row (headline)
echo "APN Name,GDSP ENV,RADIUS Name, Ath. type,Accounting,IP Pool Name,IP pool conf,IP Pool range,MultiPool,IP Pool VRF,DNS 1,DNS 2,ACL IN Name,ACL OUT Name"

for var in "$@"
do

declare apn=$var
declare conf="amggsn"


# 0- APN Name
grep apn $apn | cut -d ' ' -f 6 | tr -d "\n"
printf ,


# 1- GDSP environement
if grep -wq "pp_gdsp_radius" $apn
then
	printf "Staging"
fi
if grep -wq "gdsp_radius" $apn
then
	printf "Production"
fi
printf ,


# 2- AAA name
grep aaa $apn | cut -d ' ' -f 9 | tr -d "\n"
printf ,


# 3- Authentication type
grep authentication $apn | cut -d ' ' -f 8,9,10,11 | tr -d "\n"
printf ,


# 4- Accounting Y/N
if grep -wq "mediation-device" $apn
then
	printf Yes
else
	printf No
fi
printf ,


# 5- IP Pool name
poolname=$(grep  "ip address pool name" $apn | cut -d ' ' -f 11)
echo $poolname | tr -d "\n"
printf ,

# 6- IP pool conf
poolconf=$(grep -w "$poolname" $conf | grep "group")
echo ${poolconf[*]} | tr -d "\n"
printf ,


# 7- IP pool range 
echo ${poolconf[*]} | cut -d ' ' -f 4,5 | tr -d "\n"
printf ,

#multipool
if [ $(grep -o "ip pool" <<< ${poolconf[*]} | wc -l) = 1 ]
then
printf N,
else
printf Y,
fi


# 8- VRF
VRF=$(echo ${poolconf[*]} | cut -d ' ' -f 12 | tr -d "\n")
echo $VRF | tr -d "\n"
printf ,


# 9- DSN
grep  "dns primary" $apn | cut -d ' ' -f 9 | tr -d "\n"
printf ,
grep  "dns secondary" $apn | cut -d ' ' -f 9 | tr -d "\n"
printf ,


# 10- ACLin
aclin=$(grep  "in$" $apn | cut -d ' ' -f 9)
echo $aclin | tr -d "\n"
l=$(grep -n -m1 "$aclin$" $conf | cut -f1 -d:)
printf ,

# 11- ACLout
grep  "out$" $apn | cut -d ' ' -f 9 | tr -d "\n"
printf ,
printf "\n"
#echo "${poolconf[12]}"


done

exit