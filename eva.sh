#!/bin/bash
#Version 0 from 04.08.22 rbetz

workdir=".."
mandatory=push_swap
bonus=checker

#Colors
green='\e\033[0;32m'
white='\e\033[0m'
red='\e\033[1;31m'

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
echo -e "STEP_0/: Checking Norm"
if [[ $input == "y" ]]
then
	norminette $workdir > $results/norm
	check=$(grep "KO!" $results/norm)
	if [[ $check <> "" ]]
	then
		echo -e "$redKO. Normerror!$white"
	else
		echo -e "$greenOK."
	fi
fi

#Compiling for Memorycheck
echo -e "STEP_1/: Checking Memoryleaks."
gcc -Wall -Wextra -Werror -fsanitize=address -I $(find $workdir -type f -name *.h) $(find $workdir -type f -name *.c) -o a.out
if [[ ! -f a.out ]]
then
	echo -e "$redError. Couldn't compile to check Memoryleaks!$white"
else
	./a.out 3 9 2 7 0 -5 4 1 > $results/memory
	check=$(grep "leaks" $results/memory)
	if [[ $check <> "" ]]
        then
                echo "$redKO. Memoryleaks!$white"
        else
		echo -e "$greenOK."
	fi
fi

#Errorhandling
echo -e "STEP_2/: Checking Errorhandlingcases with Error"
make -C $workdir
while read line
do
	./$mandatory $line >> $results/step2
done < $tests/step2
while read line
do
	if [[ $line <> "Error" ]]
	then
		echo -e "$redErrorhandling wrong!$white"
	else
		echo -e "$greenOK:"
	fi
done < $results/step2

#Semivalide Arguments
echo -e "STEP_3/: Checking Errorhandlingcases without Error"
while read line
do
        ./$mandatory $line >> $results/step3
done < $tests/step3
while read line
do
        if [[ $line <> "" ]]
        then
                echo -e "$redErrorhandling wrong!$white"
        else
                echo -e "$greenOK:"
        fi
done < $results/step3

#Easy Stacks
echo -e "STEP_4/: Checking Easy Stacks"
if [[ ! -f checker_Mac ]]
then
	wget -q https://projects.intra.42.fr/uploads/document/document/9217/checker_Mac
fi
while read line
do
        ./$mandatory $line | ./checker_Mac $line >> $results/step4
done < $tests/step4
while read line
do
        if [[ $line <> "OK" ]]
        then
                echo -e "$redStacks are not sorted!$white"
        else
                echo -e "$greenOK:"
        fi
done < $results/step4
while read line
do
        ./$mandatory $line | wc -l >> $results/step4a
done < $tests/step4
while read line
do
        if [[ $line -gt 3 ]]
        then
                echo -e "$redToo much Steps for Easy Stacks!$white"
        else
                echo -e "$greenOK:"
        fi
done < $results/step4a

#Easy Stacks
echo -e "STEP_5/: Checking more Easy Stacks"
while read line
do
        ./$mandatory $line | ./checker_Mac $line >> $results/step5
done < $tests/step5
while read line
do
        if [[ $line <> "OK" ]]
        then
                echo -e "$redStacks are not sorted!$white"
        else
                echo -e "$greenOK:"
        fi
done < $results/step5
while read line
do
        ./$mandatory $line | wc -l >> $results/step5a
done < $tests/step5
while read line
do
        if [[ $line -gt 12 ]]
        then
                echo -e "$redToo much Steps for Easy Stacks!$white"
        else
                echo -e "$greenOK:"
        fi
done < $results/step5a


