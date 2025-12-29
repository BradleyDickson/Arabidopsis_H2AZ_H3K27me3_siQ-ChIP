#pval estimate here
#https://www.bmj.com/content/343/bmj.d2304
#the 36 needs to be adjusted automat...
edg=`echo $2`
cmd=`echo "head -1 $1 | cut -d ' ' -f4-"$((edg+3))`
#list=`head -1 $1 | cut -d ' ' -f4-36`
list=`eval $cmd`
rm linescounts
for w in $list; do name=`basename $w -DB`;nl=`wc -l $name |awk '{print $1}'`;echo $nl>> linescounts;done

pname=`basename $1 -DB`

#gfortran -O3 -fbounds-check -o katz.exe katz-bh.f90
gfortran -O3 -fbounds-check -funroll-loops -mcmodel=large -o katz.exe katz-bh.f90
#for instance:
./katz.exe $1 > $pname-pv

#histogram of differences
#words=`grep ' '1'$' offndrs.VAL1ac.bed-DB |awk '{print $4}'|sed -e 's/,/ /g'`
#for w in $words ; do echo $w;done |sort |uniq -c |awk '{print $1/16557, $2}' |grep ac
#16557 = grep ' '1'$' offndrs.VAL1ac.bed-DB |wc -l , which is number of peaks

#old katz.f90 code, not current:
#in gnuplot you can plot the intervals for a peak like
#set xtics rotate 90;plot'error-datas'u (0):xtic(5),'error-datas'u 0:3:2:4 w e
