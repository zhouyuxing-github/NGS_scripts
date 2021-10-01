#!/bin/env bash
#####################################
# author:	"ZhouYuXing"                                                           
# copyright:	"Copyright 2021, Southwest Minzu University"  
# version:	"2.1"                                                                           
# maintainer: "Zhouyuxing"                                                       
# email: "1037782920@qq.com"                                                
#####################################

######     get bin directory    ######
SOURCE="$0"
while [ -h "$SOURCE"  ]; do # resolve $SOURCE until the file is no longer a symlink
    bin="$( cd -P "$( dirname "$SOURCE"  )" && pwd  )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /*  ]] && SOURCE="$bin/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
bin="$( cd -P "$( dirname "$SOURCE"  )" && pwd  )"
#######         finished         #######


cat $bin/databases/RefVir2020noPhageAddCorona/RefVir2020noPhageAddCorona_cut1 $bin/databases/RefVir2020noPhageAddCorona/RefVir2020noPhageAddCorona_cut2 > $bin/databases/RefVir2020noPhageAddCorona/RefVir2020noPhageAddCorona.fasta && \
time $bin/programs/blast-2.11.0+/bin/makeblastdb.exe  -dbtype nucl  -in $bin/databases/RefVir2020noPhageAddCorona/RefVir2020noPhageAddCorona.fasta -out $bin/databases/RefVir2020noPhageAddCorona/RefVir2020noPhageAddCorona && \
flag=0 && \
echo "blastdb was generated at `date`" && \
echo "All done... Remove this script plz..."

if [ "$flag" != 0 ];
then
	echo  -e "\n\nwinVir installation failed. The path of the program must be in English with no blank space (use uderline but not space!)"
	echo  -e "such as \"/d/bio soft/winVir2.0/\" is incorrect; \"/d/bio_soft/winVir2.0/\" is correct"
	echo  -e "And make sure you didn't delete anything."
	exit
fi
