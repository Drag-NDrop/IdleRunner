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
    echo "$content"
    if [[ "$content" == "1" ]]; then
        echo "IdleRunner detected user activity. Boinc progress should be suspended..."
    elif [[ "$content" == "0" ]]; then
    echo "IdleRunner detected no user activity. Boinc progress should be resumed..."
    else
        echo "The file does not contain 1 or 0. It should be evaluated by IdleRunner shortly."
    fi
else
    echo "The file does not exist."
fi

cat <<EOF

::: Task States Description :::

READY: Tasks in the "READY" state are waiting to be executed. They are queued up and ready to run, but they have not started execution yet.
IN_PROGRESS: This state indicates that a task is currently being executed on a host.
SUSPENDED: You mentioned this state earlier. A "SUSPENDED" task is temporarily paused and not actively running. This state is often used when the user or the BOINC manager has suspended the task's execution.
UNINITIALIZED: You mentioned this state as well. An "UNINITIALIZED" state might be used to describe a task that hasn't been properly initialized or started yet.
ERROR: This state is assigned to tasks that encountered an error during execution. The error can be due to various reasons, such as a computational issue, missing input data, or a system-related problem.
UPLOADING/SENDING: These states indicate that a task is in the process of sending its results back to the project's servers.
DOWNLOADING/RECEIVING: These states indicate that a task is in the process of downloading input data or receiving new work units from the project's servers.
EOF



    sleep 10
done
