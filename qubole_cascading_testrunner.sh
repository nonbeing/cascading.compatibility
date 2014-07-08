#!/bin/bash

cd /home/ec2-user

# first get gradle:
if [[ ! -f /home/ec2-user/gradle-1.12/bin/gradle ]]; then
    echo -e "[INFO] Gradle not found, downloading and installing gradle 1.12"
    wget https://services.gradle.org/distributions/gradle-1.12-all.zip
    unzip -o gradle-1.12-all.zip
    sudo ln -s /home/ec2-user/gradle-1.12/bin/gradle /usr/bin/gradle
fi
# get our cascading-compatibility test suite to run against qubole-hadoop
#git clone https://github.com/nonbeing/cascading.compatibility.git;
cd cascading.compatibility

# launch all cascading-compatibility tests against qubole-hadoop:
# this is a darn INFINITE LOOP... don't ever run it :P
# /home/ec2-user/gradle-1.12/bin/gradle  :qubole-hadoop:test -i ;

# how to run a single test:
# time gradle -Dtest.single=EachEachPipeAssemblyPlatformTest :qubole-hadoop:test -i | tee /tmp/EachEachPipeAssemblyPlatformTest.log

mkdir -p ./logs

# the number of seconds after which the test case will be aborted
TESTCASE_TIMEOUT=3600

# timeout command error codes (http://www.gnu.org/software/coreutils/manual/html_node/timeout-invocation.html)
TIMEOUT_ERROR_CODES="124 125 126 127 137"

echo -e "[`date`] STARTING TEST\n\n"

while read testcase; do
    if [[ $testcase == *#* ]]; then
        echo -e "\n[INFO] Omitting test case: '$testcase' as it is commented out with a '#'";
    else
        echo -e "\n[INFO] Running test case: '${testcase}' with timeout of '${TESTCASE_TIMEOUT}' seconds"

        timeout ${TESTCASE_TIMEOUT} gradle -Dtest.single=${testcase} :qubole-hadoop:test -i  &> ./logs/${testcase}.log
        retcode=$?
        echo -e "[INFO] timeout-RETCODE for '${testcase}': $retcode";

        if [[ "${TIMEOUT_ERROR_CODES}" =~ $retcode ]]; then
            echo -e "[INFO] Test Case: '${testcase}' gave timeout-error '$retcode' after '${TESTCASE_TIMEOUT}' seconds\n\n"
        else
            echo -e "[INFO] Test Case: '${testcase}' completed within '${TESTCASE_TIMEOUT}' seconds\n\n"
        fi
    fi
done < cascading_all_testcases.txt


echo -e "[`date`] TEST FINISHED!"
