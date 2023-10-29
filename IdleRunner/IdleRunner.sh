#!/bin/bash


# Define the path to the config file
config_file=".IdleRunner.config"
recentActivityTimestamp=$(</tmp/IdleRunner_last_activity_timestamp)
# Regular expression pattern
pattern="^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$"

# Check if the date and time string matches the pattern.
# If the value is invalid, or equal to 1, there's no need to proceed.

if [[ $recentActivityTimestamp =~ $pattern ]]; then
  echo "Date and time format is valid." #Debug

elif [[ $recentActivityTimestamp == 1 ]]; then
  echo "No need to run again. Exitting..."
  exit 0
else
  echo "Invalid date and time format. Exitting..."
  exit 1
fi

### Load config file ###
# Check if the config file exists
if [ -f "$config_file" ]; then
  # Read and process each line in the config file
  while IFS= read -r line; do
    # Ignore lines starting with "#" (comments)
    if [[ "$line" != \#* ]]; then
      # Split the line into key and value
      key=$(echo "$line" | cut -d'=' -f1)
      value=$(echo "$line" | cut -d'=' -f2)

      # Use the key and value as needed
      case "$key" in
        ConsiderMeIdleAfterMinutes)
          ConsiderMeIdleAfterMinutes="$value"
          ;;
        FireThisWhenIdle)
          FireThisWhenIdle="$value"
          ;;
        FireThisWhenNotIdle)
          FireThisWhenNotIdle="$value"
          ;;
        CronFrequency)
          CronFrequency="$value"
          ;;
        # Add more key cases as needed
        *)
          echo "Unknown setting: $key"
          ;;
      esac
    fi
  done < "$config_file"
else
  echo "Config file not found: $config_file"
fi

### // Done loading config file ###

echo "Setting 1: $ConsiderMeIdleAfterMinutes" #Debug
echo "Setting 2: $FireThisWhenIdle" #Debug
echo "Setting 3: $FireThisWhenNotIdle" #Debug
echo "Setting 4: $CronFrequency" #Debug
echo "Most recent activity timestamp: $recentActivityTimestamp" #Debug





# Convert recentActivityTimestamp to a Unix timestamp
  # Get the current Unix timestamp
  datetime_timestamp=$(date -d "$recentActivityTimestamp" +"%s")
  current_timestamp=$(date +"%s")
  # Calculate the threshold (5 minutes in the past)
  threshold=$((current_timestamp - (ConsiderMeIdleAfterMinutes*60)))

  if [ "$datetime_timestamp" -lt "$threshold" ]; then
    echo "The datetime is more than 5 minutes in the past." #Debug
        #Fire command here
         eval "$FireThisWhenIdle"
        #Clear the activity file, so the script does not fire again, if the user is running a longer task.
        echo "1" > /tmp/IdleRunner_last_activity_timestamp

         exit 0
  else
    echo "The datetime is within the last 5 minutes or in the future." #Debug
        #Fire command here
        eval "$FireThisWhenNotIdle"
  fi
