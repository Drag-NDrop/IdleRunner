
#!/bin/bash

# Define the PROMPT_COMMAND
PROMPT_COMMAND='PROMPT_COMMAND=date +"%F %T" > /tmp/IdleRunner_last_activity_timestamp'

# Backup the original configuration file, first.
sudo cp /etc/bash.bashrc /etc/bash.bashrc.bak

# Check if the configuration file exists
if [ -f /etc/bash.bashrc ]; then
    # Append the PROMPT_COMMAND to the configuration file with comments
    echo "The following was added to your global bashrc:"
    echo -e "# Added by IdleRunner\n$PROMPT_COMMAND" | sudo tee -a /etc/bash.bashrc
    echo "A backup was made of your global bashrc configuration beforehand. (/etc/bash.bashrc.bak)."
else
    echo "Global Bash configuration file not found."
fi
