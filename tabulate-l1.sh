#gfortran -O3 -fbounds-check -o l1.exe ezcluster.f90
gfortran -O3 -fbounds-check -funroll-loops -mcmodel=large -o l1.exe ezcluster.f90
#note that this has to use -pv now
#for w in *-DB;do nam=`basename $w .bed-DB`;./l1.exe $w > l1-$nam;done
for w in *-pv;do nam=`basename $w .bed-pv`;./l1.exe $w > l1-$nam;done

#a=`echo ak27A12hi.bed ak27A12lo.bed ak27AMhi.bed ak27AMlo.bed ak27D2hi.bed ak27D2lo.bed ak27D3hi.bed ak27D3lo.bed ak27Dihi.bed ak27Dilo.bed rv27hi2.bed rv27hi3.bed rv27lo2.bed rv27lo3.bed DMSOK18a.bed DMSOK27a.bed CBPK18ac.bed CBPK27ac.bed A485K18a.bed A485K27a.bed rv14hi.bed rv14lo.bed rv9hi.bed rv9lo.bed ak9AMhi.bed ak9AMlo.bed ak9CSThi.bed ak9CSTlo.bed rv9in.bed rv14in.bed rv27in2.bed rv27in3.bed akDMin.bed`
a=`echo $@`
list=`for w in $a ; do basename $w .bed;done`
zist=`for w in $a ; do basename $w;done`
#echo $list

rm tmp #might error, no worries
for w in $list ; do
    declare -a bla; j=0;
    for z in $zist ; do
	bla[$j]=`grep ' '$z l1-$w|awk '{print $2}'`;
	j=$((j+1));
    done
    echo $w ${bla[@]} >> tmp
done

echo "name "$list > l1-Table
tac tmp >> l1-Table
