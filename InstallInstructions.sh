#!/bin/bash

sudo apt-get update
sudo apt-get install git --assume-yes
git clone https://github.com/Drag-NDrop/IdleRunner
cd IdleRunner
chmod +x IdleRunner.sh
chmod +x IdleRunnerSetup.sh
./IdleRunnerSetup.sh
cd Boinc
chmod +x BoincInstaller.sh
chmod +x TrackBoincWork_Realtime.sh
./BoincInstaller.sh

alias Boinc_track='$HOME/IdleRunner/Boinc/TrackBoincWork_Realtime.sh'
alias Boinc_update_CPU_Settings='boinccmd --project https://universeathome.pl/universe/ update'

source /etc/bash.bashrc
Boinc_track

# For installing Oracle OCI Management agent
#sudo apt install snapd --assume-yes
#sudo snap install oracle-cloud-agent --classic --assume-yes
