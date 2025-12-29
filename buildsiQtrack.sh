#run like: ./buildsiQtrack.sh IP.bed input.bed
#TESTrun1-scales.tx is the file where the output of the run was collected.
#adjust names as required.

num=`grep $1 TESTrun1-scales.tx |awk '{print $3}'`
den=`grep $2 TESTrun1-scales.tx |awk '{print $3}'`
a=`echo $num/$den | bc -l`

#nin=`wc -l $2 |awk '{print $1}'`
nin=1 #no longer part of calcs
widths=30
#this is genome length, change this for your particular case.
genl=119668634
dep=`echo $nin*$widths/$genl/\(1-$widths/$genl\) |bc -l` #average layer on input

echo $dep " is dep"
echo $a " is alpha"
gfortran -O3 -fbounds-check mergetracks.f90
./a.out NC.$1 NC.$2 $a $dep 
mv mergedSIQ.data siq.$1
