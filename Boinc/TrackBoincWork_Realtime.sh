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
echo "::: Contents of ActivityFile ::: "
file="/tmp/IdleRunnerActivityTracker.log"  # Replace with the path to your file

if [[ -f "$file" ]]; then
    content=$(<"$file")  # Read the file content into a variable
    if [[ "$content" == "1" ]]; then
        echo "IdleRunner detected user activity. Boinc progress should be suspended..."
    elif [[ "$content" == "0" ]]; then
    echo "IdleRunner detected no user activity. Boinc progress should be resumed..."
    else
        echo "The file does not contain 1 or 0."
    fi
else
    echo "The file does not exist."
fi


    sleep 10
done
