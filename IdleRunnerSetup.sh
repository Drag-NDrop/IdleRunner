#!/bin/bash
#Config file location
config_file="/home/debian/IdleRunner/.IdleRunner.config"


if ! dpkg -l | grep -q cron; then
  # Install cron
  sudo apt-get install cron --assume-yes
fi

# Start the cron service
sudo systemctl start cron

sudo usermod -aG sudo "$(whoami)"

# Define the path to the config file (assuming the config file is located in the user's home directory)


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
       Debug)
            Debug="$value"
          ;;
        PathToActivityFile)
            PathToActivityFile="$value"
          ;;
        ConsiderMeIdleAfterMinutes)
            ConsiderMeIdleAfterMinutes="$value"
          ;;
        FireThisWhenIdle)
            FireThisWhenIdle="$value"
          ;;
        FireThisWhenNotIdle)
            FireThisWhenNotIdle="$value"
          ;;
        CronFrequencyInMinutes)
            CronFrequencyInMinutes="$value"
          ;;
        # Add more key cases as needed
        *)
            if [ -f "$config_file" ]; then
            echo "Unknown setting: $key"
            fi
          ;;
      esac
    fi
  done < "$config_file"
else
  echo "Config file not found: $config_file"
fi

### // Done loading config file ###
if [ -f "$config_file" ]; then
  echo "Debug: $Debug"
  echo "PathToActivityFile: $PathToActivityFile"
  echo "Idle timeout(minutes): $ConsiderMeIdleAfterMinutes" # Debug
  echo "Command while idle: $FireThisWhenIdle" # Debug
  echo "Command while not: $FireThisWhenNotIdle" # Debug
  echo "Cron frequency: $CronFrequencyInMinutes" # Debug
fi
# Define the script and its path
script_path="/home/debian/IdleRunner/IdleRunner.sh"

# Define the cron schedule (every 5 minutes)
cron_schedule="*/$CronFrequencyInMinutes * * * *"

# Check if the cron job already exists for the user - Send to null to avoid the errormessage about the current user having no cron
if sudo -u debian crontab -l 2>/dev/null | grep -q "$script_path"; then
  echo "Cron job already exists. Updating..."
  # Remove the existing cron job - Send to null to avoid the errormessage about the current user having no cron
  (sudo -u debian crontab -l 2>/dev/null | grep -v "$script_path") | sudo -u debian crontab - 2>/dev/null
fi

# Add the new cron job for the user - Send to null to avoid the errormessage about the current user having no cron
(sudo -u debian crontab -l 2>/dev/null; echo "$cron_schedule $script_path") | sudo -u debian crontab - 2>/dev/null

echo "Cron job created or updated to run $script_path every $CronFrequencyInMinutes minutes."

############ ***************************** #################

# Define the PROMPT_COMMAND
#PROMPT_COMMAND="PROMPT_COMMAND=\"date '+%F %T' > \"$PathToActivityFile\"\" && /home/debian/IdleRunner/IdleRunner.sh > /dev/null"

PROMPT_COMMAND=$(cat <<EOF
# Added by IdleRunner
Update_ActivityLog_And_Run_IdleRunner() {
    local timestamp=\$(date '+%F %T')
    echo "\$timestamp" > "$PathToActivityFile"
    /home/debian/IdleRunner/IdleRunner.sh > /dev/null
}
PROMPT_COMMAND="Update_ActivityLog_And_Run_IdleRunner"
# /Added by IdleRunner
EOF
)




# Backup the original configuration file, first.
sudo cp /etc/bash.bashrc /etc/bash.bashrc.bak

# Check if the configuration file exists
if [ -f /etc/bash.bashrc ]; then
  # Append the PROMPT_COMMAND to the configuration file with comments
  echo "The following was added to your global bashrc:"
  #echo -e "# Added by IdleRunner\n$PROMPT_COMMAND" | sudo tee -a /etc/bash.bashrc
   echo -e "$PROMPT_COMMAND" | sudo tee -a /etc/bash.bashrc

  echo "A backup was made of your global bashrc configuration beforehand. (/etc/bash.bashrc.bak)."
else
  echo "Global Bash configuration file not found."
fi

#Reload the global bash rc..
echo "Completed installation of IdleRunner. Please make sure to do the following:"
echo "1) Re-Source your bash configuration. Use this command: source /etc/bash.bashrc"
echo "2) Configure IdleRunner's config file, to your preferences."
echo "You'll find the config file here(fired with nano): nano /home/debian/IdleRunner/.IdleRunner.config"