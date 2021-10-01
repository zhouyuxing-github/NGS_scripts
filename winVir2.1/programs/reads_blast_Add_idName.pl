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
while(<IN1>){
	chomp;
	@a=split/\s/,$_,2;
  $a[0]=~s/>//g;
$hash{$a[0]}=$a[1];
}
open IN2,$file2;
while(<IN2>){
	chomp;
	@b=split/\t/,$_,2;
  
 if (exists $hash{$b[0]}){
 	print "$b[0]\t$hash{$b[0]}\t$b[1]\n";
}
 else {
 	print "$b[0]\t-\t$b[1]\n";
}
}
