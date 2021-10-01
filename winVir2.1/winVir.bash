#!/bin/env bash
#####################################
# author:	"ZhouYuXing"                                                           #
# copyright:	"Copyright 2021, Southwest Minzu University"  #
# version:	"2.1"                                                                           #
# maintainer: "Zhouyuxing"                                                       #
# email: "1037782920@qq.com"                                                #
#####################################


while getopts 'i:c:h' arg
do
	case $arg in
		i)
			inFile="$OPTARG";;
		c)
			cutOff="$OPTARG";;
		h)
			echo "Usage: `basename $0`  -i inFile.fastq.gz"
			echo "This script is to convert format, conducting blastn, count up reads number for each species and extract reads sequences for each species."
			exit
	esac
done
flag=0
if [ "$inFile" = "" ];
then
	echo "Usage: `basename $0`  -i inFile.fastq.gz"
	flag=1
fi
if [ "$cutOff" = "" ];
then
	$cutOff=80
	echo "The cutOff alignment length was set to 80 as default"
	echo "Usage: `basename $0`  -i inFile.fas -c cutOff_alignment_length"
fi
if [ "$flag" = 1 ];
then
	echo  "Usage: `basename $0`  -i inFile.fastq.gz -c cutOff_alignment_length"
	exit
fi

###############          get bin and base          #################
bin="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" && \
dirname="$( cd "$( dirname "$inFile" )" && pwd )" && \
basename=`basename  ${inFile%.*}` && \
################################################

#############    check the existence of the database     #############
if [ ! -f $bin/databases/RefVir2020noPhageAddCorona/RefVir2020noPhageAddCorona.fasta ];then
    echo "Start installing winVir..."
	sh $bin/install.bash
else
    echo ""
fi && \
################################################
if [ ! -d $dirname/${basename%.*}_res ];then
    mkdir $dirname/${basename%.*}_res && \
    echo -e "Directory $dirname/${basename%.*}_res was made!\nStarting winVir..." && \
    echo "It will take total 70 min for 1.4Gb fastq.gz... start at `date`" && \
    echo "Start converting fastq to fasta..." && \
    zcat  $inFile | awk '{getline seq;getline plus;getline qual;sub("@",">",$0);print $0 "\n"seq}' | tr -s ' ' '_'> ${inFile}.fasta && \
    echo "Start reads_blast..." && \
    time $bin/programs/blast-2.11.0+/bin/blastn.exe  -num_threads 4 -outfmt 7 -db $bin/databases/RefVir2020noPhageAddCorona/RefVir2020noPhageAddCorona -query ${inFile}.fasta  -out ${inFile%.*}_blastRes.xls
    echo "Start sorting by bit score..." && \
    sort -nrk 12 ${inFile%.*}_blastRes.xls | awk '$4>80{print $0}' > ${inFile%.*}_blastResSorted.xls && \
    awk '{if (!keys[$1]) print $0; keys[$1] = 1;}'  ${inFile%.*}_blastResSorted.xls > ${inFile%.*}_blastResSortedUniq.xls && \
    perl $bin/programs/reads_blast_Add_idName.pl   $bin/databases/RefVir2020noPhageAddCorona/RefVir2020noPhageAddCorona_idName   ${inFile%.*}_blastResSortedUniq.xls > ${inFile%.*}_blastResSortedUniqAddidName.xls && \
    rm ${inFile%.*}_blastRes.xls ${inFile%.*}_blastResSorted.xls && \
    awk '{sum[$2]+=1}END{for(i in sum)print i"\t"sum[i]}'   ${inFile%.*}_blastResSortedUniq.xls | awk '/gi/{print}' |sort -nrk 2 >  ${inFile%.*}_readsStat.xls && \
    perl $bin/programs/reads_blast_Add_idName.pl   $bin/databases/RefVir2020noPhageAddCorona/RefVir2020noPhageAddCorona_idName   ${inFile%.*}_readsStat.xls > ${inFile%.*}_readsStatAddidName.xls && \
    rm ${inFile%.*}_readsStat.xls && \
    echo "Species table was generated at `date`!" && \

#############     extract reads from blastn_res      ##############
    awk 'NR==FNR{a[$1]=$0;next}{if ($2 in a) print  $0 "\t" a[$2]}'  ${inFile%.*}_readsStatAddidName.xls  ${inFile%.*}_blastResSortedUniq.xls |tr -s ',/\ '  '_' | sort -rk 14   > ${inFile%.*}_eachReadDetail.xls
    echo "Start extracting fasta from each_read_detail..." && \
    sed -i '1i\SouthWestMinzuUniversity_ZhouYuxing_1037782920@qq.com'  ${inFile%.*}_eachReadDetail.xls && \
    perl $bin/programs/fromContigsNameGetFasta.pl   ${inFile%.*}_eachReadDetail.xls   ${inFile}.fasta > ${inFile}_matched.fa && \
    rm ${inFile}.fasta && \

    echo "File ${inFile}.fasta was removed..." && \

    sed -i "s/\t/_/14" ${inFile%.*}_eachReadDetail.xls && \

    for x in `awk '{print $14}'  ${inFile%.*}_eachReadDetail.xls | uniq `
    do
    grep  $x ${inFile%.*}_eachReadDetail.xls >> $dirname/${basename%.*}_res/${x}.xls
    done
    echo " $dirname/${basename%.*}_res/excels were generated, start extracting reads..." && \

    for file in `ls $dirname/${basename%.*}_res/*.xls`
    do
            if [ ! -f $file ];then
                    echo "$file not exsist..."
            else
                    for j in  `awk '{print $1}' $file`
                    do
                         grep -A 1 $j ${inFile}_matched.fa >> ${file%.*}.fas
                    done
                    echo "Start extracting reads of ${file%.*}..."
            fi
    done
###############     Std. Dev of Reads     #################
    for i in `ls $dirname/${basename%.*}_res/*xls`
    do
        species=`basename  $i`
        avr3=`cat $i|awk '{sum+=$3} END {print sum/NR}' `
        avr4=`cat $i|awk '{sum+=$4} END {print sum/NR}' `
        readsNum=`wc -l $i`
        sd=`awk '{print $9}'  $i | awk '{x[NR]=$0; s+=$0; n++} END{a=s/n; for (i in x){ss += (x[i]-a)^2} sd = sqrt(ss/n); print sd}' `
        printf "${species%.*}\t%f\t%f\t%d\t%f\n " "$avr3" "$avr4" "$readsNum" "$sd" >> $dirname/${basename%.*}_res/STDEVP.xls
    done
    sort -nrk 4 $dirname/${basename%.*}_res/STDEVP.xls > $dirname/${basename%.*}_res/Std_Dev_of_Reads.xls && \
    sed -i '1i\Species\tMeanIdentity\tMeanQueryCover\tReadsNum\tSt_Dev_of_Reads_Location'  $dirname/${basename%.*}_res/Std_Dev_of_Reads.xls && \
    echo "Standard deviation of reads location was generated!" && \
    rm $dirname/${basename%.*}_res/STDEVP.xls  ${inFile%.*}_readsStatAddidName.xls  ${inFile%.*}_blastResSortedUniq.xls ${inFile%.*}_eachReadDetail.xls  ${inFile}_matched.fa ${inFile%.*}_blastResSortedUniqAddidName.xls && \

    echo -e "\n\nConguratulation! Reads corresponding to each species were extracted, you can assemble them using SeqMan..." && \
    echo "Low \"MeanQueryCover\" and \"St_Dev_of_Reads_Location\" suggests the result might be a false possitive..." && \
    echo "All done at `date`, Bye Bye~" 

else
    rm ${inFile}_matched.fa ${inFile%.*}_readsStatAddidName.xls  ${inFile%.*}_eachReadDetail.xls  ${inFile%.*}_blastResSortedUniq.xls  ${inFile%.*}_blastResSortedUniqAddidName.xls
	echo -e "\nwinVir:\n       File \"$dirname/${basename%.*}_res\" already exists...\n       Please remove it and try again..."
fi 
