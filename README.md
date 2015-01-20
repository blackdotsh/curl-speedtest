# curl speedtest - A nimble benchmark tool

A simple benchmark script that shows download and <b>upload</b> speed for multiple locations around the world, CPU speed, and I/O write speed.

## Purpose

The motivation behind this speedtest project is to give you a full picture of your network capabilities. A server serves content, which means the upload speed is extremely important and should not be neglected in a network benchmark test. Using standard utilities in Linux that people are familiar with, this network speed test should be a good base line and works well on minimalistic systems. <br>


# Usage
You can run the benchmark script using one of the following commands:
```
wget dl.getipaddr.net/speedtest.sh -q -O- | bash 
```
or
```
curl -s dl.getipaddr.net/speedtest.sh -o- | bash
```
or
```
wget https://raw.github.com/blackdotsh/curl-speedtest/master/speedtest.sh && chmod u+x speedtest.sh && bash speedtest.sh
```
Note: A 100MB test file is used by default to test the download and upload speeds, however, in some "exotic" locations, a 10MB file is used to save bandwidth.

# How to interprete the results
Since most of these test servers are on a shared port, one of the servers in a certain location might not produce accurate results. However, if the speedtest script shows lower than expected values from a few of the speedtest servers, then it's more than likely that your server has slow download / upload speed. Running it a few times helps too (but running it 10 consecutive times will not). 

# Checksums
SHA-1 sums are posted on http://dl.getipaddr.net feel free to check if that's the official release.
