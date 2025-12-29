#name a file of interest and a file containing scale-factors from siQ
declare -a line;line=( `head -1 $1-pv` )
k=`echo ${#line[@]}`
for((i=3;i<$((k-3));i++));do
    echo $i ${line[$i]}
done
keyb=0
declare -a keylist
read -n 3 -p "control-first? (type number, press enter):" keylist[0]
read -n 3 -p "control-second? (type number, press enter):" keylist[1]
read -n 3 -p "exp-first? (type number, press enter):" keylist[2]
read -n 3 -p "exp-second? (type number, press enter):" keylist[3]
read -n 3 -p "exp-third? (type number, press enter):" keylist[4]
keya=3 #this is actually inputfile position in -pv file


#echo
#echo $keya $keyb
echo "Processing samples:"
echo ${keylist[@]}

#echo ${line[$keya]} ${line[$keyb]}
#naa=`grep ${line[$keya]} $2 |awk '{print $3}'`
#nab=`grep ${line[$keyb]} $2 |awk '{print $3}'`
#scale=`echo $naa/$nab |bc -l`
#cmd=`echo "tail -n +2 "$1-pv"| awk -v sc=$scale '{if(\\$"$((keya+1))"/\\$"$((keyb+1))"<490) print \\$1,\\$2,\\$3,sc*\\$"$((keya+1))/"\\$"$((keyb+1))"}' "`


#cmd=`echo "tail -n +2 "$1-pv"| awk '{if(\\$"$((keya+1))"/\\$"$((keyb+1))"<490) print \\$1,\\$2,\\$3,sc*\\$"$((keya+1))/"\\$"$((keyb+1))"}' "`

cmd=`echo "tail -n +2 "$1-pv"|awk '{if(\\$"$((keya+1))"/\\$"$((keylist[2]+1))"<490 && \\$"$((keya+1))"/\\$"$((keylist[3]+1))"<490 && \\$"$((keya+1))"/\\$"$((keylist[4]+1))"<490 && \\$"$((keya+1))"/\\$"$((keylist[0]+1))">490 && \\$"$((keya+1))"/\\$"$((keylist[1]+1))">490 && \\$52==1) print \\$1,\\$2,\\$3,\\$"$((keya+1))"/\\$"$((keylist[2]+1))",\\$"$((keya+1))"/\\$"$((keylist[3]+1))",\\$"$((keya+1))"/\\$"$((keylist[4]+1))"}'"`
echo $cmd
eval $cmd | sort -n -k4 |tail -10
#cmd=`echo "tail -n +2 "$1-DB"| awk -v sc=$scale '{print \\$1,\\$2,\\$3,sc*\\$"$((keya+1))/"\\$"$((keyb+1))"}' "`
#echo "Run this command to list intervals and efficiency:"
#echo $cmd
#eval $cmd | sort -n -k4 |head
#eval $cmd | sort -n -k4 |tail
