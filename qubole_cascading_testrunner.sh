#!/bin/bash

cd /home/ec2-user

# first get gradle:
wget https://services.gradle.org/distributions/gradle-1.12-all.zip;
unzip -o gradle-1.12-all.zip ;

sudo ln -s /home/ec2-user/gradle-1.12/bin/gradle /usr/bin/gradle

# get our cascading-compatibility test suite to run against qubole-hadoop
#git clone https://github.com/nonbeing/cascading.compatibility.git;
cd cascading.compatibility;

# launch all cascading-compatibility tests against qubole-hadoop:
# this is a darn INFINITE LOOP... don't ever run it :P
# /home/ec2-user/gradle-1.12/bin/gradle  :qubole-hadoop:test -i ;

# how to run a single test:
# time gradle -Dtest.single=EachEachPipeAssemblyPlatformTest :qubole-hadoop:test -i | tee /tmp/EachEachPipeAssemblyPlatformTest.log

mkdir -p ./logs

while read testcase; do
    if [[ $testcase == *#* ]]; then 
        echo "[INFO] Omitting $testcase as it is commented out with a '#'";
    else
        echo -e "\n\n\n\n\n[INFO] Running test case: ${testcase}"
        time gradle -Dtest.single=${testcase} :qubole-hadoop:test -i | tee "./logs/${testcase}.log"
    fi
done < cascading_all_testcases.txt

echo -e "\n\n\n\n[INFO] Finished!"
