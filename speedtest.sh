#!/bin/sh
# Licensed under GPLv3
# created by "black" on LET
# please give credit if you plan on using this for your own projects 

fileName="10mb.test";
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

# TODO: test connectivity using /dev/tcp

timeout='2'
fifo='yourfile'

do_dd() {
  dd if='/dev/urandom' bs=1M count=10 2>/dev/null > "$fifo"
}

timeout() {
local timeout_secs=${1:-10}
shift

# subshell
( 
  "$@" &
  child=$!     #trap - '' SIGTERM #why would we need this?
  (       
	sleep $timeout_secs
	kill $child 2> /dev/null # TODO returns 143 instead of "real" timeout's 124
  ) &
  wait $child
)
}
export timeout

#TODO: select on best ping

get_sites() {
  sort -R<<EOM
100.42.19.110;Speedtest from Portland, Oregon, USA [ generously donated by http://bonevm.com ] on a shared 100 Mbps port
23.226.231.112;Speedtest from Seattle, Washington, USA [ generously donated by http://ramnode.com ] on on a shared 1 Gbps port
107.150.31.36;Speedtest from Los Angeles, CA, USA [ generously donated by http://maximumvps.net ] on a shared 1 Gbps port
208.67.5.186:10420;Speedtest from Kansas City, MO, USA [ generously donated by http://megavz.com ] on a shared 1 Gbps port
198.50.209.250;Speedtest from Beauharnois, Quebec, Canada [ generously donated by http://mycustomhosting.net ] on a shared 1000 Mbps port in / 500 Mbps port out
168.235.78.99;Speedtest from Los Angeles, [California], USA, generously donated by http://ramnode.com on on a shared 1 Gbps port
192.210.229.206;Speedtest from Chicago, IL, USA, generously donated by http://vortexservers.com on a shared 1 Gbps port
167.114.135.10;Speedtest from Beauharnois, Quebec, Canada [ generously donated by http://hostnun.net/ ] on a shared 500 Mbps port
192.111.152.114:2020;Speedtest from Lenoir, NC, USA, generously donated by http://megavz.com on a shared 1 Gbps port
aj1dddzidccbez4i9fh3evs0tyj.getipaddr.net;Speedtest from Denver, CO, USA on a shared 100 Mbps port
162.220.26.107;Speedtest from Dallas, TX, USA, generously donated by http://cloudshards.com on a shared 1 Gbps port
168.235.81.120;Speedtest from New York City, New York, USA generously donated by http://ramnode.com on on a shared 1 Gbps port
192.73.235.56;Speedtest from Atlanta, Georgia, USA [ generously donated by http://ramnode.com ] on on a shared 1 Gbps port
162.219.26.75:12320;Speedtest from  Asheville, NC, USA on a shared 1 Gbps port
107.155.187.129;Speedtest from Jacksonville, FL, USA [ generously donated by http://maximumvps.net ] on a shared 1 Gbps port
EOM
}

##need sed now because some european versions of curl insert a , in the speed results
test_speed () {
  local _PROTO _NOPROTO _SRVPORT _SRV _PORT _PATH _ADDR _COMMENT
  
  _ADDR=${1%%;*}
  _COMMENT=${1##*;}
  
  _PROTO=${_ADDR=%%:*}
  _NOPROTO=${_ADDR=#*//}
  _SRVPORT=${_NOPROTO%%/*}
  _SRV=${_SRVPORT%%:*}
  
  if [ $(echo $_SRVPORT | grep ':') ]; then
    _PORT=${_SRVPORT##*:}
  else
    _PORT=80
  fi
  
  echo -n "Testing connection to $_SRV $_PORT"
  echo " "| timeout 2 nc $_SRV $_PORT >/dev/null 2>&1 || { echo "...failure"; return 1; }
  echo "...success"
  
  dlspeed="$(curl --connect-timeout $timeout "http://${_SRV}:${_PORT}/$fileName" -w "%{speed_download}" -o /dev/null -s| sed "s/\,/\./g" && echo "/131072")"
  echo "$dlspeed" | bc -q | sed "s/$/ Mbit\/sec/;s/^/\tDownload Speed\: /"
	
  do_dd&
  ulspeed="$(curl --connect-timeout $timeout -d @$fifo "http://${_SRV}:${_PORT}/webtests/ul.php" -w "%{speed_upload}" -s -o /dev/null | sed "s/\,/\./g" && echo "/131072")"
	echo "$ulspeed" | bc -q | sed "s/$/ Mbit\/sec/;s/^/\tUpload speed\: /"
  
  # empty the fifo?
}

PING_DCS="speedtest.atlanta.linode.com speedtest-sfo1.digitalocean.com speedtest.newark.linode.com speedtest-nyc2.digitalocean.com speedtest.fremont.linode.com"

# prereq testing
for which_cmd in curl bc nc; do
  if ! [ $(which "$which_cmd") ]; then
    echo "This script requires $which_cmd"
    exit 1
  fi
done

# PATTERN="\([0-9.]\+ [KMG]B/s\)"

test_latency() {
  for dc in $PING_DCS; do
    PING=$(ping -c4 $dc | awk -F\/ '/^(rtt|round-trip)/ {print $5}')
    echo "${dc}: Latency: $PING ms"
  done
}


cputest() {
  cpuName=$(cat /proc/cpuinfo | grep "model name" | cut -d ":" -f2 | tr -s " " | head -n 1)
  cpuCount=$(cat /proc/cpuinfo | grep "model name" | cut -d ":" -f2 | wc -l)
  echo "CPU: $cpuCount x$cpuName"
  echo -n "Time taken to generate PI to 5000 decimal places with a single thread: "
  time echo "scale=5000; 4*a(1)" | bc -lq 2>&1 | grep real |  cut -f2
}

disktest() {
  size=5
  echo "Writing $size file to disk"
  dd if=/dev/zero of=$$.disktest bs=1M count=$size conv=fdatasync 2>&1 | tail -n 1 | cut -d " " -f3-
  rm $$.disktest
}

main() {
  [ -e "$fifo" ] && rm -f "$fifo"
  
  for func in $queue; do
    $func
  done

  mkfifo "$fifo"
  ## start speed test
  echo "-------------Speed test $(date)--------------------"

  get_sites | while read site; do
    test_speed "$site"
  done

  rm -f "$fifo"
}

queue=''
while getopts "lcdv" OPT; do
  case "$OPT" in
    'l')
      queue="$queue test_latency "
      ;;
    'c')                                                                                           
      queue="$queue test_cpu "                                                                       
      ;;
    'd')                                                                                           
      queue="$queue test_disk "                                                                       
      ;;
    'v')
      VERBOSE='true'
      ;;
    esac
  done
  
echo $queue

main

##hints
#echo -e "If you need to speedtest in a specific region:
#http://dl.getipaddr.net/speedtest.NA.sh for North America
#http://dl.getipaddr.net/speedtest.EU.sh for Europe
#http://dl.getipaddr.net/speedtest.Asia.sh for Asia
#http://dl.getipaddr.net/speedtest.AU.sh for Australia";

#echo -e "\nTesting EU locations";

### Paris, France
#echo "Speedtest from Paris, France on a shared 1 Gbps port";
#speedtest "4iil8b4g67f03cdecaw9nusv.getipaddr.net";

## Alblasserdam, Netherlands (donated by http://ramnode.com)
#echo "Speedtest from Alblasserdam, Netherlands [ generously donated by http://ramnode.com ] on on a shared 1 Gbps port";
#speedtest 185.52.0.68;

### Dusseldorf, Germany (donated by http://megavz.com)
#echo "Speedtest from Dusseldorf, Germany [ generously donated by http://megavz.com ] on a shared 1 Gbps port";
#speedtest 130.255.188.37:7020;

### Falkenstein, Germany (donated by http://megavz.com)
#echo "Speedtest from Falkenstein, Germany [ generously donated by http://megavz.com ] on a shared 1 Gbps port";
#speedtest 5.9.2.36:12120;

### Bucharest, Romania
#echo "Speedtest from Bucharest, Romania [ generously donated by http://www.prometeus.net ] on a semi-dedicated 1 Gbps port";
#speedtest "servoni.eu/webtests";

#echo -e "\nTesting Asian locations";

### Singapore
#echo "Speedtest from Singapore on a shared 1 Gbps port";
#speedtest 128.199.65.191;


### Tokyo, Japan
#echo "Speedtest from Tokyo, Japan on a shared 1 Gbps port";
#speedtest 108.61.200.70:12601;

#echo -e "\nTesting Australian locations";

### Sydney, Australia
#echo "Speedtest from Sydney, Australia on a shared 1 Gbps port";
#speedtest 103.25.58.8:3310;
