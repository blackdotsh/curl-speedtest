#!/bin/bash
# Licensed under GPLv3
# created by "black" on LET
# please give credit if you plan on using this for your own projects 

fileName="100mb.test";
#check if user wants 100MB files instead
##NOTE: testing with 100MB by default
ls "FORCE100MBFILESPEEDTEST" 2>/dev/null 1>/dev/null;
if [ $? -eq 0 ]
then
	#echo "Forcing 100MB speed test";
	fileName="100mb.test";
	#remove this file after filename variable as been set
	rm FORCE100MBFILESPEEDTEST;
fi

speedtest () {
	dlspeed=$(echo -n "scale=2; " && curl http://$1/$fileName -w "%{speed_download}" -o $fileName -s && echo "/1048576");
	echo "$dlspeed" | bc -q | sed "s/$/ MB\/sec/;s/^/\tDownload Speed\: /";
	ulspeed=$(echo -n "scale=2; " && curl -F "file=@$fileName" http://$1/webtests/ul.php -w "%{speed_upload}" -s -o /dev/null && echo "/1048576");
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
echo "Speedtest from Phoenix, AZ, USA [ generously donated by http://hostnun.net/ ] on a shared 1 Gbps port";
speedtest 184.95.37.105;

##Phoenix, AZ, USA (donated by http://goodhosting.co/)
echo "Speedtest from Phoenix, AZ, USA [ generously donated by http://goodhosting.co/ ] on a shared unmetered 1 Gbps port";
speedtest 198.20.92.32;

### Dallas, TX, USA
echo "Speedtest from Dallas, TX, USA on a shared 1 Gbps port";
speedtest 198.52.198.248;

### Dallas, TX, USA (donated by http://cloudshards.com)
echo "Speedtest from Dallas, TX, USA [ generously donated by http://cloudshards.com ] on a shared 1 Gbps port";
speedtest 162.220.26.107;


### Chicago, IL, USA (donated by http://vortexservers.com)
echo "Speedtest from Chicago, IL, USA [ generously donated by http://vortexservers.com ] on a shared 1 Gbps port";
speedtest 192.210.229.206;

### Chicago, IL, USA (donated by http://goodhosting.co/)
echo "Speedtest from Chicago, IL, USA [ generously donated by http://goodhosting.co/ ] on a shared unmetered 1 Gbps port";
speedtest 184.154.113.30;

## Buffalo, NY, USA
echo "Speedtest from Buffalo, NY, USA on a shared 1 Gbps port";
speedtest 192.3.201.19;

##Beauharnois, Quebec, Canada (donated by http://http://mycustomhosting.net)
echo "Speedtest from Beauharnois, Quebec, Canada [ generously donated by http://mycustomhosting.net ] on a shared 1000 Mbps port in / 500 Mbps port out";
speedtest 198.50.209.250;

## Atlanta, GA, USA (donated by  http://hostus.us)
echo "Speedtest from Atlanta, GA, USA [ generously donated by http://hostus.us ] on a shared 1 Gbps port";
speedtest 107.161.112.217;

## Clifton, NJ, USA (donated by  http://dedicatedminds.com)
echo "Speedtest from Clifton, NJ, USA [ generously donated by http://dedicatedminds.com ] on a shared 1 Gbps port";
speedtest 199.36.221.36;

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

## start CPU test
echo "---------------CPU test--------------------";
cputest;

## start disk test
echo "----------------IO test-------------------";
disktest;
