#!/bin/bash
# Boinc project graphs
#https://grafana.kiska.pw/d/boinc/boinc?orgId=1&from=now-30d&to=now&var-project=Universe@Home

#https://github.com/BOINC/boinc/issues/5226

#### Install BOINC
## https://boinc.berkeley.edu/wiki/Installing_BOINC_on_Debian_or_Ubuntu

### Universe, master url: https://universeathome.pl/universe/



InstallBoincClient(){
    cc_config_path = '/etc/boinc-client/cc_config.xml'


    mkdir ~/boinc
    cd ~/boinc
    
    sudo add-apt-repository --remove ppa:costamagnagianfranco/boinc
    sudo add-apt-repository universe
    sudo apt update
    sudo apt-get install boinc-client --assume-yes
    sudo usermod -aG boinc "$(whoami)"
    


config_xml=$(cat <<'EOF'
<!--
This is a minimal configuration file cc_config.xml of the BOINC core client.
For a complete list of all available options and logging flags and their
meaning see: https://boinc.berkeley.edu/wiki/client_configuration
-->
<cc_config>
  <fetch_minimal_work>1</fetch_minimal_work>
  <log_flags>
    <task>1</task>
    <file_xfer>1</file_xfer>
    <sched_ops>1</sched_ops>
  </log_flags>
</cc_config>
EOF
)
sudo echo "$config_xml" | sudo tee "/etc/boinc-client/cc_config.xml" > /dev/null

    # Check write permissions and use sudo if necessary
    if [ ! -w "/etc/boinc-client/cc_config.xml" ]; then
        echo "You don't have write permissions for /etc/boinc-client/cc_config.xml."
        echo "Attempting to write using sudo..."
        sudo echo "$config_xml" | sudo tee "/etc/boinc-client/cc_config.xml" > /dev/null
        if [ "$?" -ne 0 ]; then
            echo "Writing with sudo failed. Please check your permissions."
        else
            echo "Write with sudo succeeded."
        fi
    else
        echo "$config_xml" | tee "/etc/boinc-client/cc_config.xml" > /dev/null
        echo "Operation complete."
    fi

    # Start Boinc
    sudo systemctl enable --now boinc-client
}





BoincTools(){
#Validate Boinc is running
ps aux | grep boinc

#Kill boinc
sudo systemctl stop boinc-client
sudo systemctl start boinc-client
pkill boinc


# Interact with boinc
boinccmd --get_project_config
boinccmd --get_state


# Pause Boinc
boinccmd --project http://project_url suspend
boinccmd --project https://universeathome.pl/universe/ suspend

# Resume Boinc
boinccmd --project http://project_url resume
boinccmd --project https://universeathome.pl/universe/ resume


# Get client version
sudo boinccmd --client_version

#Get Project status
sudo boinccmd --get_project_status

#See location of data dir
cat /etc/boinc-client/config.properties

#Location of data dir: /var/lib/boinc-client


}







# Where to create a user:
#https://universeathome.pl/universe/create_account_form.php?next_url=

SetUpBoincAccount() {
    clear
    echo "Now proceeding to set up your Boinc account."
    echo "Please navigate to the URL below in a browser and complete the setup of a user account:"
    echo -e "\e[36mhttps://universeathome.pl/universe/create_account_form.php\e[0m"
    echo ""
    echo "Once done, return here, and then please press ENTER..."
    read
    clear
    echo "Proceed to this page..."
    echo ""
    echo -e "\e[36mhttps://universeathome.pl/universe/weak_auth.php\e[0m"
    echo ""
    echo "You will need the information in the XML-tags (in the example below, it's the yellow parts):"
    echo "<account>"
    echo -e "\e[97m <master_url> \e[0m   \e[93m https://universeathome.pl/universe/     \e[0m  \e[97m</master_url>\e[0m"
    echo -e "\e[97m <authenticator>\e[0m \e[93m 269743_b07fa38391b24e8456dffca1ea488179 \e[0m  \e[97m</authenticator>\e[0m"
    echo "</account>"
    echo ""
    echo "Be advised - no checks on the validity of the information you input will be made. Make sure you're careful."
    echo "Copy the lines, one line at a time, and input it below."

    read -rp "Master URL: " boinc_masterUrl
    read -rp "Authenticator: " boinc_authenticator

    clear
    echo "Proceeding to set up BOINC with your account information..."
    echo "The following XML will be added to a config file."
    account_config_xml=$(cat <<EOF
<account>
 <master_url>$boinc_masterUrl</master_url>
 <authenticator>$boinc_authenticator</authenticator>
</account>
EOF
)
    echo "$account_config_xml"
    echo "---------------------------------------------"
    configfilepath='/var/lib/boinc-client/account_universeathome.pl_universe.xml'
    echo "Full path to the config file: $configfilepath"
    echo "---------------------------------------------"

    if [ ! -e "$configfilepath" ]; then
        echo "File does not exist. Creating it..."
        
        # Use sudo to create the file with appropriate permissions
        sudo touch "$configfilepath"
        
        # Check if the file was created successfully
        if [ "$?" -eq 0 ]; then
            echo "File created successfully."
        else
            echo "Failed to create the file. Check your permissions."
        fi
    fi

    # Check write permissions and use sudo if necessary
    if [ ! -w "$configfilepath" ]; then
        echo "You don't have write permissions for $configfilepath."
        echo "Attempting to write using sudo..."
        sudo echo "$account_config_xml" | tee "$configfilepath" > /dev/null
        if [ "$?" -ne 0 ]; then
            echo "Writing with sudo failed. Please check your permissions."
        else
            echo "Write with sudo succeeded."
        fi
    else
        echo "$account_config_xml" | tee "$configfilepath" > /dev/null
        echo "Operation complete."
    fi

    echo "Press ENTER to continue..."
    read -n 1 -s

    clear
    echo "The BOINC client is now configured with the details you entered."
    echo "If you wish to see how much work you've contributed using this solution, visit:"
    echo -e "\e[36mhttps://universeathome.pl/universe/home.php\e[0m"
    echo "Make a note of it if needed, as this information will not be shown again."
}

BoincMonitor(){
    while [[ 1 -eq 1 ]]
    do
            clear

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

        sleep 2
    done


}


UninstallBoinc() {
    sudo systemctl disable boinc-client
    sudo systemctl stop boinc-client 
    sudo apt purge --auto-remove -y boinc-client boinc-manager 
    sudo apt purge boinc*
    sudo rm ~/client_state.xml
    sudo rm ~/coproc_info.xml
    sudo rm ~/gui_rpc_auth.cfg
    sudo rm ~/stderrgpudetect.txt
    sudo rm ~/stdoutgpudetect.txt
    sudo rm ~/time_stats_log
    sudo rm ~/lockfile
}



#UninstallBoinc
# Add apt repo
# Install Boinc 
# Add current user, to boinc
InstallBoincClient
# copy Universe login info xml to: /var/lib/boinc-client
SetUpBoincAccount
sudo systemctl stop boinc-client
sudo systemctl start boinc-client
# Edit cc_config.conf til at fetche minimal work
# test-start the Boinc client. Grep to see if tasks get loaded and begin executing
# Setup IdleRunner
# Verify IdleRunner works


