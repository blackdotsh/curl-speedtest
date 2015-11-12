#!/bin/bash
# Licensed under GPLv3
# created by "black" on LET
# please give credit if you plan on using this for your own projects 

fileName="100mb.test";
#check if user wants 100MB files instead
##NOTE: testing with 100MB by default
#ls "FORCE100MBFILESPEEDTEST" 2>/dev/null 1>/dev/null;
#if [ $? -eq 0 ]
#then
#	#echo "Forcing 100MB speed test";
#	fileName="100mb.test";
#	#remove this file after filename variable as been set
#	rm FORCE100MBFILESPEEDTEST;
#fi

##need sed now because some european versions of curl insert a , in the speed results
speedtest () {
	dlspeed=$(echo -n "scale=2; " && curl --connect-timeout 8 http://$1/$fileName -w "%{speed_download}" -o $fileName -s | sed "s/\,/\./g" && echo "/1048576");
	echo "$dlspeed" | bc -q | sed "s/$/ MB\/sec/;s/^/\tDownload Speed\: /";
	ulspeed=$(echo -n "scale=2; " && curl --connect-timeout 8 -F "file=@$fileName" http://$1/webtests/ul.php -w "%{speed_upload}" -s -o /dev/null | sed "s/\,/\./g" && echo "/1048576");
	echo "$ulspeed" | bc -q | sed "s/$/ MB\/sec/;s/^/\tUpload speed\: /";
}

ls "$fileName" 1>/dev/null 2>/dev/null;
if [ $? -eq 0 ]
then
	echo "$fileName already exists, remove it or rename it";
	exit 1;
fi

cputest () {
	cpuName=$(cat /proc/cpuinfo | grep "model name" | cut -d ":" -f2 | tr -s " " | head -n 1);
	cpuCount=$(cat /proc/cpuinfo | grep "model name" | cut -d ":" -f2 | wc -l);
	echo "CPU: $cpuCount x$cpuName";
	echo -n "Time taken to generate PI to 5000 decimal places with a single thread: ";
	(time echo "scale=5000; 4*a(1)" | bc -lq) 2>&1 | grep real |  cut -f2
}

disktest () {
	echo "Writing 1000MB file to disk"
	dd if=/dev/zero of=$$.disktest bs=64k count=16k conv=fdatasync 2>&1 | tail -n 1 | cut -d " " -f3-;
	rm $$.disktest;
}

#check dependencies
metDependencies=1;
#check if curl is installed
type curl 1>/dev/null 2>/dev/null;
if [ $? -ne 0 ]
then
	echo "curl is not installed, install it to continue, typically you can install it by typing"
	echo "apt-get install curl"
	echo "yum install curl"
	echo "depending on your OS";
	metDependencies=0 ;
fi
#check if bc is installed
type bc 1>/dev/null 2>/dev/null;
if [ $? -ne 0 ]
then
	echo "bc is not installed, install it to continue, typically you can install it by typing"
	echo "apt-get install bc"
	echo "yum install bc"
	echo "depending on your OS";
	metDependencies=0;
fi
if [ $metDependencies -eq 0 ]
then
	exit 1;
fi


## start speed test
echo "-------------Speed test--------------------";

echo "Testing North America locations";

### Portland, Oregon, USA (donated by http://bonevm.com)
echo "Speedtest from Portland, Oregon, USA [ generously donated by http://bonevm.com ] on a shared 100 Mbps port";
speedtest 100.42.19.110;

## Seattle, Washington, USA (donated by http://ramnode.com)
echo "Speedtest from Seattle, Washington, USA [ generously donated by http://ramnode.com ] on on a shared 1 Gbps port";
speedtest 23.226.231.112;

### Los Angeles, CA, USA (donated by http://maximumvps.net)
echo "Speedtest from Los Angeles, CA, USA [ generously donated by http://maximumvps.net ] on a shared 1 Gbps port";
speedtest 107.150.31.36;

### LA, CA, USA (donated by http://terafire.net)
#echo "Speedtest from Los Angeles, CA, USA [ generously donated by TeraFire, LLC ] on a shared 1 Gbps port";
#speedtest 162.216.226.220;

## Los Angeles, California, USA (donated by http://ramnode.com)
echo "Speedtest from Los Angeles, California, USA [ generously donated by http://ramnode.com ] on on a shared 1 Gbps port";
speedtest 168.235.78.99;

##Denver, CO, USA
echo "Speedtest from Denver, CO, USA on a shared 100 Mbps port";
speedtest aj1dddzidccbez4i9fh3evs0tyj.getipaddr.net;

##Kansas City, MO, USA
echo "Speedtest from Kansas City, MO, USA [ generously donated by http://megavz.com ] on a shared 1 Gbps port";
speedtest 208.67.5.186:10420;

### Dallas, TX, USA (donated by http://cloudshards.com)
echo "Speedtest from Dallas, TX, USA [ generously donated by http://cloudshards.com ] on a shared 1 Gbps port";
speedtest 162.220.26.107;

### Chicago, IL, USA (donated by http://vortexservers.com)
echo "Speedtest from Chicago, IL, USA [ generously donated by http://vortexservers.com ] on a shared 1 Gbps port";
speedtest 192.210.229.206;

##Beauharnois, Quebec, Canada (donated by http://http://mycustomhosting.net)
echo "Speedtest from Beauharnois, Quebec, Canada [ generously donated by http://mycustomhosting.net ] on a shared 1000 Mbps port in / 500 Mbps port out";
speedtest 198.50.209.250;

##Beauharnois, Quebec, Canada (donated by hostnun)
echo "Speedtest from Beauharnois, Quebec, Canada [ generously donated by http://hostnun.net/ ] on a shared 500 Mbps port";
speedtest 167.114.135.10;

## New York City, New York, USA (donated by http://ramnode.com)
echo "Speedtest from New York City, New York, USA [ generously donated by http://ramnode.com ] on on a shared 1 Gbps port";
speedtest 168.235.81.120;

## Buffalo, NY, USA
#echo "Speedtest from Buffalo, NY, USA on a shared 1 Gpbs port (location may be slow)":
#speedtest 23.94.28.158;

## Atlanta, Georgia, USA (donated by http://ramnode.com)
echo "Speedtest from Atlanta, Georgia, USA [ generously donated by http://ramnode.com ] on on a shared 1 Gbps port";
speedtest 192.73.235.56;

## Atlanta, GA, USA (donated by  http://hostus.us)
#echo "Speedtest from Atlanta, GA, USA [ generously donated by http://hostus.us ] on a shared 1 Gbps port";
#speedtest 162.245.216.241;

## Lenoir, NC, USA (donated by http://megavz.com
echo "Speedtest from Lenoir, NC, USA [ generously donated by http://megavz.com ] on a shared 1 Gbps port";
speedtest 192.111.152.114:2020;

## Asheville, NC, USA
echo "Speedtest from  Asheville, NC, USA on a shared 1 Gbps port";
speedtest 162.219.26.75:12320;

##Jacksonville, FL, USA (donated by http://maximumvps.net)
echo "Speedtest from Jacksonville, FL, USA [ generously donated by http://maximumvps.net ] on a shared 1 Gbps port";
speedtest 107.155.187.129;


echo -e "\nTesting EU locations";

### Paris, France
echo "Speedtest from Paris, France on a shared 1 Gbps port";
speedtest "4iil8b4g67f03cdecaw9nusv.getipaddr.net";

## Alblasserdam, Netherlands (donated by http://ramnode.com)
echo "Speedtest from Alblasserdam, Netherlands [ generously donated by http://ramnode.com ] on on a shared 1 Gbps port";
speedtest 185.52.0.68;

### Dusseldorf, Germany (donated by http://megavz.com)
echo "Speedtest from Dusseldorf, Germany [ generously donated by http://megavz.com ] on a shared 1 Gbps port";
speedtest 130.255.188.37:7020;

### Falkenstein, Germany (donated by http://megavz.com)
echo "Speedtest from Falkenstein, Germany [ generously donated by http://megavz.com ] on a shared 1 Gbps port";
speedtest 5.9.2.36:12120;

### Bucharest, Romania
echo "Speedtest from Bucharest, Romania [ generously donated by http://www.prometeus.net ] on a semi-dedicated 1 Gbps port";
speedtest "servoni.eu/webtests";

echo -e "\nTesting Asian locations";

### Singapore
echo "Speedtest from Singapore on a shared 1 Gbps port";
speedtest 128.199.65.191;

unlink $fileName;

### Due to expensive bandwidth, use the 10MB test file instead
fileName="10mb.test";

ls "$fileName" 1>/dev/null 2>/dev/null;
if [ $? -eq 0 ]
then
        echo "$fileName already exists, remove it or rename it";
        exit 1;
fi

### Tokyo, Japan
echo "Speedtest from Tokyo, Japan on a shared 1 Gbps port";
speedtest 108.61.200.70:12601;

echo -e "\nTesting Australian locations";

### Sydney, Australia
echo "Speedtest from Sydney, Australia on a shared 1 Gbps port";
speedtest 103.25.58.8:3310;

unlink $fileName;

## start CPU test
echo "---------------CPU test--------------------";
cputest;

## start disk test
echo "----------------IO test-------------------";
disktest;

##hints
echo -e "If you need to speedtest in a specific region:
http://dl.getipaddr.net/speedtest.NA.sh for North America
http://dl.getipaddr.net/speedtest.EU.sh for Europe
http://dl.getipaddr.net/speedtest.Asia.sh for Asia
http://dl.getipaddr.net/speedtest.AU.sh for Australia";

