#! /bin/perl -w
#####################################
# author:	"ZhouYuXing"                                                           
# copyright:	"Copyright 2021, Southwest Minzu University"  
# version:	"2.1"                                                                           
# maintainer: "Zhouyuxing"                                                       
# email: "1037782920@qq.com"                                                
#####################################

my $file1=shift;
my $file2=shift;

open IN1,$file1;
<IN1>; 
while(<IN1>){
        chomp;

        @a=split /\s/,$_;
      
        $hash{$a[0]}=1;
}

open IN2,$file2;
$/=">";
<IN2>;
$/="\n";
while(<IN2>){
chomp;
@a=split/\s/,$_;
my $name=$a[0];
$/=">";
my $seq=<IN2>;
$/="\n";
$seq=~s/[\n]//g;
$seq=~s/>//g;
       	if (exists $hash{$a[0]}){
               	print ">$a[0]\n$seq\n";
       	 } 
}                                 