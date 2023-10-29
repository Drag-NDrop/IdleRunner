#!/bin/bash
while [[ 1 -eq 1 ]]
do
        clear
    #./IdleRunner.sh

# Run boinccmd and store the output
tasks_output=$(boinccmd --get_tasks)

# Define variables to store task information
active_task_state=""
fraction_done=""

# Process the output line by line
while read -r line; do
    if [[ $line == *"active_task_state: "* ]]; then
        active_task_state=$(echo "$line" | awk -F ": " '{print $2}')
    elif [[ $line == *"fraction done: "* ]]; then
        fraction_done=$(echo "$line" | awk -F ": " '{print $2}')
        echo "Active Task State: $active_task_state, Fraction Done: $fraction_done"
        active_task_state=""
        fraction_done=""
    fi
done <<< "$tasks_output"

    sleep 10
done
