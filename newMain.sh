#get the following from user input

#a=`echo ak2lo.bed ak2hi.bed ak3lo.bed ak3hi.bed rv2lo.bed rv2hi.bed rv3lo.bed rv3hi.bed akDMin.bed rv2in.bed rv3in.bed`



#a=`echo ak27A12hi.bed ak27A12lo.bed ak27AMhi.bed ak27AMlo.bed ak27D2hi.bed ak27D2lo.bed ak27D3hi.bed ak27D3lo.bed ak27Dihi.bed ak27Dilo.bed rv27hi2.bed rv27hi3.bed rv27lo2.bed rv27lo3.bed DMSOK18a.bed DMSOK27a.bed CBPK18ac.bed CBPK27ac.bed A485K18a.bed A485K27a.bed rv14hi.bed rv14lo.bed rv9hi.bed rv9lo.bed ak9AMhi.bed ak9AMlo.bed ak9CSThi.bed ak9CSTlo.bed rv9in.bed rv14in.bed rv27in2.bed rv27in3.bed akDMin.bed`

a=`echo $@`
if [ 1 -eq 1 ] ; then
#do the work of compiling the scale factors
echo "BELOW ARE YOUR SCALE FACTORS FOR SIQ CHIP!!!!!!!!!!!!!!!!"
declare -a lengs
j=0
#for w in $a ; do
for w in ../*.params.in ; do
#    name=`basename $w .bed`
    name=`basename $w .params.in`    
    FILE=`echo $name`
    declare -a pars=( `cat ../$name.params.in` ) #Sampl_m,Sampl_V
    if [ -f "$FILE" ]; then
    lengs[$j]=`awk '{sum+=$4} END {print sum/NR}' $FILE`        
    else
	lengs[$j]=0.0 #throw a flag
    fi
    #assumed mass is in ng units!!!!! volume in uL!!!!
#output is in Molar
    ss=`echo 10^\(-9\)*${pars[0]}/660/${lengs[$j]}/\(${pars[1]}*10^\(-6\)\) | bc -l`
    sp=`echo 6.022*10^\(23\)*${pars[2]}*$ss*\(${pars[1]}*10^\(-6\)\) | bc -l`    
    echo $name $ss $sp #need to spit this in a file for keeping
    j=$((j+1))
done
#### hopefully that went ok.
echo "ABOVE ARE YOUR SCALE FACTORS FOR SIQ CHIP!!!!!!!!!!!!!!!!"
fi
#exit

if [ 1 -eq 1 ] ; then
gfortran -O3 -fbounds-check reg_track.f90
declare -a ncstatus
declare -a ncfiles
j=0
for w in $a ; do
    ncstatus[$j]=0
    echo $w;
    nl=`wc -l $w |awk '{print $1}'`
    name=`basename $w`
#    name=`echo $w | sed -e 's/..\///g'`    
    ncfiles[$j]=`echo NC.$name`;
    nohup ./a.out $w $name 30 30 $nl > outs.$j &
    j=`echo $j+1|bc`
done

#allow script to end when files are complete
echo "going to sleep now " $j
sum=0
while [ $sum -ne $j ] ; do
    sleep 60;    
    sum=0
    for((i=0;i<$j;i++)); do
	bng=`ls -l ${ncfiles[$i]} | awk '{print $6}'`
	if [ $bng -eq ${ncstatus[$i]} ] && [ $bng -ne 0 ] ; then
	    sum=`echo $sum+1|bc`
	fi
	ncstatus[$i]=$bng
    done
done

declare -a ij=( `for w in $a;do basename $w;done` )
a=`echo ${ij[@]}`
#a had name change here that cuts out paths

#a=`ls NC*bed`
j=0
declare -a ncstatus
declare -a ncfiles
gfortran -O3 signalpro.f90
for w in $a ; do
    ncstatus[$j]=0
    ncfiles[$j]=`echo sgnls.NC.$w`;
    nohup ./a.out NC.$w > signl.outs.$j &
    j=`echo $j+1|bc`
done
echo "going to sleep in sgnl- " $j
sum=0
while [ $sum -ne $j ] ; do
    sleep 60;    
    sum=0
    for((i=0;i<$j;i++)); do
	bng=`ls -l ${ncfiles[$i]} | awk '{print $6}'`
	if [ $bng -eq ${ncstatus[$i]} ] && [ $bng -ne 0 ] ; then
	    sum=`echo $sum+1|bc`
	fi
	ncstatus[$i]=$bng
    done
done

#sleep 30

j=0
declare -a ncstatus
declare -a ncfiles
gfortran -O3 smplcaller.f90

for w in $a ; do
    echo $w
    nl=`wc -l $w |awk '{print $1}'` #this has hardcoded path now. need a solution.
    ncstatus[$j]=0
    ncfiles[$j]=`echo peaks.NC.$w`;
#    echo "launched peaks on " NC.$w sgnls.NC.$w
#    nohup ./a.out NC.$w sgnls.NC.$w 3.0 > smpl.outs.$j &
    nohup ./a.out NC.$w sgnls.NC.$w $nl > smpl.outs.$j &    
    j=`echo $j+1|bc`
done

echo "going to sleep in peaks- " $j
sum=0
while [ $sum -ne $j ] ; do
    sleep 60;    
    sum=0
    for((i=0;i<$j;i++)); do
	bng=`ls -l ${ncfiles[$i]} | awk '{print $6}'`
	if [ $bng -eq ${ncstatus[$i]} ] && [ $bng -ne 0 ] ; then
	    sum=`echo $sum+1|bc`
	fi
	ncstatus[$i]=$bng
    done
done


gfortran -O3 -fbounds-check accumEff.f90
echo $a
declare -a ij=( `echo $a` )
for((j=0;j<$((${#ij[@]}));j++));do
#for((j=0;j<1;j++));do    
k=0
declare -a ncstatus
declare -a ncfiles

ncstatus[$k]=0
ncfiles[$k]=`echo blocks.NC.${ij[$j]}`;
nohup ./a.out peaks.NC.${ij[$j]} NC.${ij[$j]} > blocks.outs.$j &
k=`echo $k+1|bc`
for((i=0;i<${#ij[@]};i++));do
	if [ $i -ne $j ] ; then
	    ncstatus[$k]=0
	    ncfiles[$k]=`echo blocks.NC.${ij[$i]}`;
#	    echo $j $i ${ij[$j]} ${ij[$i]}
	    nohup ./a.out peaks.NC.${ij[$j]} NC.${ij[$i]} > blocks.outs.$j.$i &
#switch from accum to new function thats fed blocks ij[j] rather than peaks.
	    k=`echo $k+1|bc`
	fi
    done;
#wait here for the ij set to finish, then combin into one big database
    echo "going to sleep in Resp- " $j
    sum=0
    while [ $sum -ne $k ] ; do
	sleep 60;    
	sum=0
	for((l=0;l<$k;l++)); do
	    bng=`ls -l ${ncfiles[$l]} | awk '{print $6}'`
	    if [ $bng -eq ${ncstatus[$l]} ] && [ $bng -ne 0 ] ; then
		sum=`echo $sum+1|bc`
	    fi
	    ncstatus[$l]=$bng
	done
    done
#    n=0;
#    declare -a newname
#    for w in ${ncfiles[@]} ; do awk '{print $4}' $w > c4-$w;newname[$n]=c4-$w;n=$((n+1));done
#    awk '{print $1,$2,$3}' ${ncfiles[0]} > nchead
#    awk '{print $5,$6,$7}' ${ncfiles[0]} > nctail
     declare -a heads=( `echo ${ncfiles[@]} | sed -e 's/blocks\.NC\.//g'` )
     echo "chr str stp "${heads[@]}" io lbg rbg" > ${ij[$j]}-DB
#    echo "chr str stp "${heads[@]}" io lbg rbg" > ${ij[$j]}-DB2
#    paste nchead ${newname[@]} nctail >> ${ij[$j]}-DB2

    #need to automate this, maybe via fortran combine?
#    paste ${ncfiles[@]} |awk '{print $1,$2,$3,$4,$11,$18,$25,$32,$39,$46,$53,$60,$5,$6,$7}' >> ${ij[$j]}-DB

     #4+7*(n-1) with n=number of files
     #also add sanity check to confirm linecounts in files...
     tc=`wc -l ${ncfiles[0]} |awk '{print $1}'`
     flag=0
     for w in ${ncfiles[@]} ; do
     tct=`wc -l $w |awk '{print $1}'`	 
     if [ $tct -ne $tc ] ; then flag=1 ; echo $w $flag ; fi
     done
     if [ $flag -eq 1 ] ; then echo "Stop: a file in this list is truncated." ${ncfiles[@]}; exit; fi
     nfil=`echo ${#ncfiles[@]}`
     declare -a disps
     for((l=0;l<$nfil;l++)); do 
	 disps[$l]=`echo 4+7*$l|bc`
     done
     rang=`echo "$"${disps[@]} |sed -e 's/ / \$/g' |sed -e 's/ /,/g'`
     cmd=`echo "paste "${ncfiles[@]}" |awk '{print "'$1,$2,$3,'$rang',$5,$6,$7'"}'"`
     echo $cmd
     eval $cmd >> ${ij[$j]}-DB 
#     paste ${ncfiles[@]} |awk '{print $1,$2,$3,$4,$11,$18,$25,$32,$39,$46,$53,$60,$67,$74,$81,$5,$6,$7}' >> ${ij[$j]}-DB  
    rm blocks.* 
done
   
fi

if [ 1 -eq 1 ] ; then
#these steps can fail if there are more peaks than expected.
#comment this out for now and check how many peaks turn up
echo "getting stats"
nf=`echo $@ |wc |awk '{print $2}'`
for w in *.bed-DB;do ./getStats.sh $w $nf;done
./tabulate-l1.sh $@
#only links if you are me
#gfortran -O3 -funroll-loops -fbounds-check -fcray-pointer -g -fcheck=all -ffpe-trap=invalid -mcmodel=large diffmap.f90 /home/bradley.dickson/16o-BRD4bd2/DiffMap/lapack-3.12.1/liblapack.a  /home/bradley.dickson/16o-BRD4bd2/DiffMap/lapack-3.12.1/librefblas.a
#./a.out
fi
