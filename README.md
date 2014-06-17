curl-speedtest
==============

A simple speedtest script that shows download and <b>upload</b> speed, CPU speed, and I/O write speed.

wget dl.getipaddr.net/speedtest.sh 2>/dev/null -O- | bash <br>
or <br>
curl -s dl.getipaddr.net/speedtest.sh -o- | bash <br>
or <br>
wget https://raw.github.com/blackdotsh/curl-speedtest/master/speedtest.sh && bash speedtest.sh

Note: A 100MB test file is used by default to test the download and upload speeds, however, in some "exotic" locations, a 10MB file is used to save bandwidth.

SHA-1 sums are posted on http://dl.getipaddr.net feel free to check if that's the official release.

