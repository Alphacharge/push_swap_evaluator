#!/bin/bash
#Version 0 from 04.08.22 rbetz

workdir=".."
mandatory=push_swap
bonus=checker

#Colors
green='\033[0;32m'
white='\033[0m'
red='\033[1;31m'

#Internal Paths
results=results
tests=tests

#Folders
if [[ -d $results ]]
then
	rm -r $results
fi
mkdir $results

#Norm
echo -e "STEP_0/5: Checking Norm"
norminette $workdir > $results/norm
check=$(grep "KO!" $results/norm)
if [[ $check -ne "" ]]
then
	echo -e "$red KO. Normerror! $white"
else
	echo -e "$green OK.$white"
fi

#Compiling for Memorycheck
echo -e "STEP_1/5: Checking Memoryleaks."
mv $workdir/Makefile $workdir/mf
< $workdir/mf sed 's/-Werror/-Werror -fsanitize=address -g /g' > $workdir/Makefile
@make re -C $workdir
mv $workdir/mf $workdir/Makefile
if [[ ! -f $workdir/$mandatory ]]
then
	echo -e "$red Error. Couldn't compile to check Memoryleaks! $white"
else
	./$workdir/$mandatory 3 9 2 7 0 -5 4 1 > $results/memory
	check=$(grep "leaks" $results/memory)
	if [[ $check -ne "" ]]
        then
                echo "$red KO. Memoryleaks! $white"
        else
		echo -e "$green OK. $white"
	fi
fi

#Errorhandling
echo -e "STEP_2/5: Checking Errorhandlingcases with Error"
@make re -C $workdir
while read line
do
	./$workdir/$mandatory $line 2>&1>> $results/step2
done < $tests/step2
while read line
do
	if [[ $line -ne "Error" ]]
	then
		echo -e "$red Errorhandling wrong! $white"
	else
		echo -e "$green OK. $white"
	fi
done < $results/step2

#Semivalide Arguments
echo -e "STEP_3/5: Checking Errorhandlingcases without Error"
while read line
do
        ./$workdir/$mandatory $line 2>&1>> $results/step3
done < $tests/step3
while read line
do
        if [[ $line -ne "" ]]
        then
                echo -e "$red Errorhandling wrong! $white"
        else
                echo -e "$green OK. $white"
        fi
done < $results/step3

#Easy Stacks
echo -e "STEP_4/5: Checking Easy Stacks"
if [[ ! -f checker_Mac ]]
then
	curl -s https://projects.intra.42.fr/uploads/document/document/9217/checker_Mac --output checker_Mac
	chmod 777 checker_Mac
fi
while read line
do
        ./$workdir/$mandatory $line | ./checker_Mac $line 2>&1>> $results/step4
done < $tests/step4
while read line
do
        if [[ $line -ne "OK" ]]
        then
                echo -e "$red Stacks are not sorted! $white"
        else
                echo -e "$green OK. $white"
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
                echo -e "$red Too much Steps for Easy Stacks! $white"
        else
                echo -e "$green OK. $white"
        fi
done < $results/step4a

#Easy Stacks
echo -e "STEP_5/5: Checking more Easy Stacks"
while read line
do
        ./$workdir/$mandatory $line | ./checker_Mac $line >> $results/step5
done < $tests/step5
while read line
do
        if [[ $line -ne "OK" ]]
        then
                echo -e "$red Stacks are not sorted! $white"
        else
                echo -e "$green OK. $white"
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
                echo -e "$red Too much Steps for Easy Stacks! $white"
        else
                echo -e "$green OK. $white"
        fi
done < $results/step5a


