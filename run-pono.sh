#!/bin/bash

if [ -f ./log.txt ]; then
    rm log.txt
fi

if [ -f ./fsm.btor2 ]; then
    rm fsm.btor2
fi

# generate the btor
echo "Generating BTOR2 using yosys"
# prefer local version
if [ -f ../../../utils/yosys-0.9/yosys ]; then
    YOSYS=../../../utils/yosys-0.9/yosys
# if [ -f ../../../utils/oss-cad-suite/bin/yosys ]; then
#     YOSYS=../../../utils/oss-cad-suite/bin/yosys
elif [ `which yosys` ]; then
    YOSYS=yosys
else
    echo "Could not find Yosys. Needed to generate BTOR2"
    exit 1
fi

$YOSYS -q -s gen-btor.ys

# run pono
echo ""
echo "Running pono"
# prefer local version
if [ -f ../../../utils/oss-cad-suite/bin/pono ]; then
    PONO=../../../utils/oss-cad-suite/bin/pono
elif [ `which pono` ]; then
    PONO=pono
else
    echo "Could not find Pono."
    exit 1
fi

$PONO -v 1 -k 50 --print-wall-time --vcd counterexample.vcd ./fsm.btor2 | tee log.txt
# MAX_TIME=$((60*60*2)) # In seconds
# timeout=0
# max_mem=0
# start_time=$(date +%s%N)
# $PONO -v 1 -k 50 --print-wall-time --vcd ./log/counterexample.vcd ./fsm.btor2 >> log.txt &
# pid=$!
# while [ $timeout -eq 0 ] && ps -p $pid > /dev/null; do
#     # Check if there is a timeout
#     now=$(date +%s%N)
#     elapsed_time=$(expr $now - $start_time)
#     if [[ $elapsed_time -ge $MAX_TIME*1000000000 ]]; then
#         echo "Timeout, killing process $pid!"
#         timeout=1
#         kill $pid
#         break
#     fi

#     # To calculate the memory consumption of a program
#     mem_info=$(ps -o rss= -p $pid)
#     mem=$(expr $mem_info / 1024) # Convert to MB
#     # Update max memory value if current memory usage is greater than previously recorded value
#     if [[ $mem -gt $max_mem ]]; then
#         max_mem=$mem
#     fi

#     sleep 0.1
# done
# end_time=$(date +%s%N)
# run_time=$(echo "$end_time - $start_time" | bc -l)
# run_time_sec=$(echo "scale=3;$run_time/1000000000" | bc)
# echo "The amount of time consumed during pono execution is: $run_time_sec sec" >> log.txt
# echo "The amount of memory consumed during pono execution is: $max_mem MB" >> log.txt
# wait