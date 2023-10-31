#!/bin/bash
#Version 0 from 04.08.22 rbetz
#Version 1 from 31.10.23 rbetz

workdir=".."
mandatory=push_swap
bonus=checker
checker_link="https://cdn.intra.42.fr/document/document/21659/checker_Mac"

#Colors
green='\033[0;32m'
white='\033[0m'
red='\033[1;31m'
yell='\033[1;33m'

#Internal Paths
results=results
tests=tests

#Folders
if [[ -d $results ]]
then
	rm -r $results
fi
mkdir $results

#compile with fsanitize
if [[ ! -f $workdir/$mandatory ]]
then
	mv $workdir/Makefile $workdir/mf
	< $workdir/mf sed 's/-Werror/-Werror -fsanitize=address -g /g' > $workdir/Makefile
	mv $workdir/mf $workdir/Makefile
	make -s -C $workdir > /dev/null 2>&1
	clear
	if [[ ! -f $workdir/$mandatory ]]
	then
		echo -e "$red Error. Couldn't compile to check Memoryleaks! $white"
	fi
fi

clear

#Norm
echo -e "${yell}STEP_0/5: Checking Norm$white"
norminette $workdir > $results/norm
check=$(grep "Error!" $results/norm)
if [[ -z "$check" ]]
then
	echo -e "Norm:\t\t$green [OK]$white"
else
	echo -e "Normerror!\t$red [KO]  $white"
fi

#Compiling for Memorycheck
echo -e "${yell}STEP_1/5: Checking Memoryleaks.$white"
if [[ ! -f $workdir/$mandatory ]]
then
	echo -e "$red Error. $mandatory does not exist! $white"
else
	./$workdir/$mandatory 3 9 2 7 0 -5 4 1 > $results/memory
	check=$(grep "leaks" $results/memory)
	if [[ $check -ne "" ]]
		then
			echo "LEAKS:\t\t$red [KO]$white"
		else
			echo -e "LEAKS:\t\t$green [OK]$white"
	fi
fi

#Errorhandling
echo -e "${yell}STEP_2/5: Checking Errorhandlingcases with Error$white"

make -s re -C $workdir > /dev/null 2>&1

while read line
do
	./$workdir/$mandatory $line >> $results/step2 2>&1
done < $tests/step2

while read line
do
	if [[ $line -ne "Error" ]]
	then
		echo -e "Error:\t\t$red [KO] $white"
	else
		echo -e "Error:\t\t$green [OK] $white"
	fi
done < $results/step2

#Semivalide Arguments
echo -e "${yell}STEP_3/5: Checking Errorhandlingcases without Error$white"

while read line
do
	./$workdir/$mandatory $line >> $results/step3 2>&1
done < $tests/step3

while read line
do
	if [[ $line -ne "" ]]
	then
		echo -e "Error:\t$red [KO] $white"
	else
		echo -e "Error:\t$green [OK] $white"
	fi
done < $results/step3

#Easy Stacks
echo -e "${yell}STEP_4/5: Checking Easy Stacks$white"

if [[ ! -f checker_Mac ]]
then
	curl -A "Mozilla/5.0" -b .cookies.txt -s "$checker_link" --output checker_Mac
	chmod 777 checker_Mac
fi

while read line
do
	./$workdir/$mandatory $line | ./checker_Mac $line >> $results/step4 2>&1
done < $tests/step4

while read line
do
	if [[ $line -ne "OK" ]]
	then
			echo -e "Sorted:\t\t$red [KO] $white"
	else
			echo -e "Sorted:\t\t$green [OK] $white"
	fi
done < $results/step4

echo -e "-----"

while read line
do
	./$workdir/$mandatory $line | wc -l | xargs >> $results/step4a
done < $tests/step4

while read line
do
	if [[ $line -gt 3 ]]
	then
			echo -e "Steps:\t\t$red [KO] $white"
	else
			echo -e "Steps:\t\t$green [OK] $white"
	fi
done < $results/step4a

#Easy Stacks
echo -e "${yell}STEP_5/5: Checking more Easy Stacks$white"

while read line
do
	./$workdir/$mandatory $line | ./checker_Mac $line >> $results/step5
done < $tests/step5

while read line
do
	if [[ $line -ne "OK" ]]
	then
			echo -e "Sorted:\t\t$red [KO] $white"
	else
			echo -e "Sorted:\t\t$green [OK] $white"
	fi
done < $results/step5

echo -e "-----"

while read line
do
	./$workdir/$mandatory $line | wc -l | xargs >> $results/step5a
done < $tests/step5

while read line
do
	if [[ $line -gt 12 ]]
	then
			echo -e "Steps:\t\t$red [KO] $white"
	else
			echo -e "Steps:\t\t$green [OK] $white"
	fi
done < $results/step5a
