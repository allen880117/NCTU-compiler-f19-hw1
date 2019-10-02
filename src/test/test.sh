#!/bin/bash

cyan=`tput setaf 51`
green=`tput setaf 46`
yellow=`tput setaf 226`
red=`tput setaf 196`

for filename in case1 case2 case3 case4 case5 error; 
do
    printf "${yellow}Running test case: ${cyan}$filename"
    ./$1 ./test/test-cases/$filename.p > $filename.result
    temp=`diff -u ./test/sample-solutions/$filename $filename.result`

    if [ $? -eq 0 ]
    then
        printf "  ==>  ${green}Pass!"
    else 
        printf "  ==>  ${red}Fail! Please check the diff output message below:\n"
    fi

    echo "$temp" | sed "s/^-/$(tput setaf 1)&/; s/^+/$(tput setaf 2)&/; s/^@/$(tput setaf 6)&/; s/$/$(tput sgr0)/"
    
    rm -f $filename.result
done