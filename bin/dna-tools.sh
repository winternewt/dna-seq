#!/bin/bash
if ! [ $(id -u) = 0 ]; then
   echo "Must be root!"
   exit 1
fi
apt-get update
#transport
apt-get install rsync tree snap libarchive-tools
#code 
apt-get install gdb openjdk-8-jre-headless openjdk-8-jdk gnutls-bin
#libs
apt-get install libncurses-dev libbz2-dev liblzma-dev libcurl4-openssl-dev libidn11-dev libkrb5-dev libldap2-dev librtmp-dev libssh2-1-dev libssl-dev libmpfr-dev libpng-dev uuid-dev
#genetic
apt-get install bwa samtools bcftools bioperl 

if ! [ -d "/data/sources/kent" ]; then
	mkdir -p /data/sources/
	pip3 install git+https://github.com/PyMySQL/mysqlclient-python.git
	wget -qO- --timestamping http://hgdownload.soe.ucsc.edu/admin/jksrc.zip | bsdtar -xvf- -C /data/sources/
	cd /data/sources/kent/src/lib
	make all
	cd -
fi

if ! [ -f "/usr/local/bin/sambamba" ]; then
	mkdir -p /data/sources/sambamba
	wget -qO- https://github.com/biod/sambamba/releases/download/v0.8.0/sambamba-0.8.0-linux-amd64-static.gz | zcat > /usr/local/bin/sambamba
	chmod a+x /usr/local/bin/sambamba
fi
sambamba --version

if ! [ -f "/usr/local/bin/samtools" ]; then
	mkdir -p /data/sources/samtools
	cd /data/sources/samtools
	wget -qO- https://github.com/samtools/samtools/releases/download/1.11/samtools-1.11.tar.bz2 | tar jxvf - --strip-components 1
	./configure --prefix=/usr/local/
	make && make install
	cd -
fi
samtools --version

if ! [ -f "/usr/local/bin/bcftools" ]; then
	mkdir -p /data/sources/bcftools
	cd /data/sources/bcftools
	wget -qO- https://github.com/samtools/bcftools/releases/download/1.11/bcftools-1.11.tar.bz2 | tar jxvf - --strip-components 1
	./configure --prefix=/usr/local/
	make && make install
	cd -
fi
bcftools --version
if ! [ -f "/usr/local/bin/bam2fastq" ]; then
	mkdir -p /data/sources/bam2fastq
	git clone --recursive https://github.com/jts/bam2fastq /data/sources/bam2fastq
	cd /data/sources/bam2fastq
	make && mv ./bam2fastq /usr/local/bin/bam2fastq
	cd -
fi
bam2fastq --version
if ! [ -f "/usr/local/bin/picard.jar" ]; then
	mkdir -p /data/sources/picard 
	git clone https://github.com/broadinstitute/picard.git /data/sources/picard
	cd /data/sources/picard
	./gradlew shadowJar && mv /data/sources/picard/build/libs/picard.jar /usr/local/bin/picard.jar
	cd -
fi
java -jar /usr/local/bin/picard.jar CreateSequenceDictionary --version
