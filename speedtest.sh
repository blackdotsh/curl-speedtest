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
	dlspeed=$(echo -n "scale=2; " && curl http://$1/$fileName -w "%{speed_download}" -o $fileName -s | sed "s/\,/\./g" && echo "/1048576");
	echo "$dlspeed" | bc -q | sed "s/$/ MB\/sec/;s/^/\tDownload Speed\: /";
	ulspeed=$(echo -n "scale=2; " && curl -F "file=@$fileName" http://$1/webtests/ul.php -w "%{speed_upload}" -s -o /dev/null | sed "s/\,/\./g" && echo "/1048576");
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

### Los Angeles, CA, USA (donated by http://maximumvps.net)
echo "Speedtest from Los Angeles, CA, USA [ generously donated by http://maximumvps.net ] on a shared 1 Gbps port";
speedtest 107.150.31.36;

### LA, CA, USA (donated by http://terafire.net)
echo "Speedtest from Los Angeles, CA, USA [ generously donated by TeraFire, LLC ] on a shared 1 Gbps port";
speedtest 162.216.226.220;

### South Bend, Indiana, USA (donated by Nodebytes)
#echo "Speedtest from South Bend, Indiana, USA [ generously donated by NodeBytes ] on a shared 100 Mbps port";
#speedtest 67.214.183.244;

##Phoenix, AZ, USA (donated by hostnun)
echo "Speedtest from Las Vegas, NV, USA [ generously donated by http://hostnun.net/ ] on a shared 200 Mbps port";
speedtest 76.164.207.156;

### Dallas, TX, USA (donated by http://cloudshards.com)
echo "Speedtest from Dallas, TX, USA [ generously donated by http://cloudshards.com ] on a shared 1 Gbps port";
speedtest 162.220.26.107;

### Chicago, IL, USA (donated by http://vortexservers.com)
echo "Speedtest from Chicago, IL, USA [ generously donated by http://vortexservers.com ] on a shared 1 Gbps port";
speedtest 192.210.229.206;

##Beauharnois, Quebec, Canada (donated by http://http://mycustomhosting.net)
echo "Speedtest from Beauharnois, Quebec, Canada [ generously donated by http://mycustomhosting.net ] on a shared 1000 Mbps port in / 500 Mbps port out";
speedtest 198.50.209.250;

## Buffalo, NY, USA
echo "Speedtest from Buffalo, NY, USA on a shared 1 Gpbs port":
speedtest 23.94.28.158;

## Atlanta, GA, USA (donated by  http://hostus.us)
echo "Speedtest from Atlanta, GA, USA [ generously donated by http://hostus.us ] on a shared 1 Gbps port";
speedtest 162.245.216.241;

#server is down
## Clifton, NJ, USA (donated by  http://dedicatedminds.com)
#echo "Speedtest from Clifton, NJ, USA [ generously donated by http://dedicatedminds.com ] on a shared 1 Gbps port";
#speedtest 199.36.221.36;

##Jacksonville, FL, USA (donated by http://maximumvps.net)
echo "Speedtest from Jacksonville, FL, USA [ generously donated by http://maximumvps.net ] on a shared 1 Gbps port";
speedtest 107.155.187.129;


echo -e "\nTesting EU locations";
### Tallinn, Estonia
echo "Speedtest from Tallinn, Estonia on a shared 1 Gbps port";
speedtest 46.22.208.190;

### Milan, Italy
echo "Speedtest from Milan, Italy [ generously donated by http://www.prometeus.net ] on a shared 1 Gbps port";
speedtest webtests.100percent.info; 

### Frankfurt am Main, Germany
echo "Speedtest from Frankfurt am Main, Germany [ generously donated by http://www.prometeus.net ] on a shared 1 Gbps port";
speedtest black.100percent.info;

### Bucharest, Romania
echo "Speedtest from Bucharest, Romania [ generously donated by http://www.prometeus.net ] on a semi-dedicated 1 Gbps port";
speedtest "servoni.eu/webtests";

### Amsterdam, NL
echo "Speedtest from Amsterdam, Netherlands on a shared 100 Mbps port";
speedtest 91.215.156.65;

unlink $fileName;

### Due to expensive bandwidth, use the 10MB test file instead
fileName="10mb.test";

ls "$fileName" 1>/dev/null 2>/dev/null;
if [ $? -eq 0 ]
then
        echo "$fileName already exists, remove it or rename it";
        exit 1;
fi

echo -e "\nTesting Asian locations";

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

