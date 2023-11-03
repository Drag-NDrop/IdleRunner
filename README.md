# IdleRunner

> *When I work, you stop. When I don't, you run.*

IdleRunner is a utility designed to manage and optimize system workloads based on user activity. It allows you to run scripts when no users are actively interacting with the server and pause heavy workloads when users are active.

## Table of Contents
- [IdleRunner](#idlerunner)
	- [Table of Contents](#table-of-contents)
	- [Why IdleRunner?](#why-idlerunner)
	- [Design](#design)
		- [The BASH PROMPT\_COMMAND Flag](#the-bash-prompt_command-flag)
		- [Dependencies](#dependencies)
	- [Setup](#setup)
		- [Setup - BashRC Configuration](#setup---bashrc-configuration)
		- [Setup - IdleRunner Configuration](#setup---idlerunner-configuration)
		- [Setup - Cron](#setup---cron)
		- [Setup - Paths of interest](#setup---paths-of-interest)
		- [Setup - Commands of interest](#setup---commands-of-interest)
	- [Entering and Exiting Idle State](#entering-and-exiting-idle-state)
	- [Acknowledgements](#acknowledgements)
	- [Project prospects](#project-prospects)

## Why IdleRunner?
IdleRunner's primary purpose is to provide a way to manage server workloads efficiently. It ensures that the system administrator or user can work without being interrupted by high workloads that could otherwise be paused. The aim is to maintain a responsive and efficient system.

## Design
For a while, InsidiousFiddler and i contemplated to write this in C++. We went away from that, as it seemed like overkill.
I've stuck with Bash, to make it as accessible and readable as possible, for the larger userbase that uses Debian.

In its current condition, it's set up to do a testdrive of a distributed computing client, named Boinc. The main purpose of this, is to see how reliable we can make IdleRunner work.
Boinc is created by developers from Berkeley University.

Once opinions and inputs has been gathered, it will be stripped down to its minimum components, and will be offered as a stand-alone tool.

### The BASH PROMPT_COMMAND Flag
IdleRunner leverages the `PROMPT_COMMAND` flag, which runs a command just before the prompt is displayed to the user. This allows IdleRunner to measure idle time accurately by recording timestamps. Privacy is of primary concern. I've kept the data it records, as anonymous and "to the point" as possible.
Which is why you will not be able to see which user last updated the timestamp. You will only see a timestamp, or a zero.

### Dependencies
I've tried to keep the amount of dependencies on as low a level as possible.
Currently, of dependencies the project needs to work, is:

<u>IdleRunner</u>
* Package: `sudo` - This is the only dependency, the commands in this repo, will not set up for you. Please do so manually.
* Package: `cron`

<u>Boinc</u><br>
* Repository: `universe`
* Package: `boinc-client`

<u>Oracle Cloud Agent</u>
* Package: `snapd`
* Package: `oracle-cloud-agent`

## Setup
To get started, i recommend using the Community image: "Debian AMD64".
That's where i've performed all the testing i have done.

The file: `Git pull.txt` - contains all the command you would need, to set up IdleRunner.
The configuration file should be editted, before proceeding to launch the IdleRunnerSetup.sh.

Remember to re-source bashrc, once IdleRunnerSetup.sh has run. Otherwise, the solution will not work as expected.
A workaround to re-source, could be a simple re-log. 
Re-source command: `source /etc/bash.bashrc`

*The Git pull.txt also installs and activates the Oracle Cloud Agent. This is done to enable proper metrics collection for the OCI management plane. Which was necesary at the time of writing. If you wish to prevent this, remove the specified lines from the script.*



### Setup - BashRC Configuration
The setup script modifies the global BashRC by adding a line to set `PROMPT_COMMAND`, which records timestamps in `/tmp/IdleRunnerActivityTracker.log`. This timestamp is used to determine idle time.
The logic that is fired, when PROMPT_COMMAND condition is triggered, is stored in the function: `Update_ActivityLog_And_Run_IdleRunner`
To make sure everything is as reversible as possible, a backup of BashRC is is created, during the IdleRunner setup.

### Setup - IdleRunner Configuration
IdleRunner's configuration includes the following flags:
- **Debug**: Set to 1 for debugging.
  - Changing value does not require `IdleRunnerSetup.sh` to be run again.
  
- **PathToActivityFile**: The path to the activity log file.
  - Changing this setting, requires a manual cleanup of the `/etc/bash.bashrc`. And to run `IdleRunnerSetup.sh` again.
- **ConsiderMeIdleAfterMinutes**: The duration of idle time before the system is considered idle.
  - Changing value does not require IdleRunnerSetup.sh to be run again.
  
- **FireThisWhenIdle**: Commands to execute when the system is idle.
  - Changing value does not require IdleRunnerSetup.sh to be run again.
  
- **FireThisWhenNotIdle**: Commands to execute when the system is no longer idle.
  - Changing value does not require IdleRunnerSetup.sh to be run again.
  
- **CronFrequencyInMinutes**: The frequency of the Cron job in minutes.
  - Changing this setting, requires `IdleRunnerSetup.sh` to be run again. After that, you have to do a manual cleanup of the `/etc/bash.bashrc`
  - In the bashrc, you'd see 2 blocks added to it, by IdleRunner. You only need one of the blocks. In anticipation that this might be needed, I've added a comment `#Added by IdleRunner`, to make it easier for you to spot where IdleRunner operates in your BashRC.

### Setup - Cron
The Cron job runs IdleRunner at a specified frequency to evaluate whether the system's interactive sessions are idle. It checks user connections and the `IdleRunnerActivityTracker.log` file. If the system is idle, it executes the defined commandline; otherwise, it executes a different commandline.

### Setup - Paths of interest
Global Bash configuration file:   `/etc/bash/bash.rc`
The backup file created, before `IdleRunnerSetup.sh` added changes to the global BashRC:  `/etc/bash.bashrc.bak`

IdleRunner activity tracker file: `/tmp/IdleRunnerActivityTracker.log`(Or whatever you wrote into the IdleRunner config, before installing)
Boinc client configuration file:  `/etc/boinc-client/cc_config.xml`
IdleRunner configuration file:    `~/IdleRunner/.IdleRunner.config`


### Setup - Commands of interest
See currently active Boinc work(developer debug script): `~/IdleRunner/Boinc/TrackBoincWork_Realtime.sh`
See content of users crontab:	 						 `crontab -u $(whoami) -l`


## Entering and Exiting Idle State
The `PROMPT_COMMAND` flag ensures that ongoing work is paused immediately after login, running IdleRunner and recording a timestamp in the activity file.
That is, as long as the user is using Bash. If the user is not, IdleRunner no longer work as intended.


## Acknowledgements
Along the way of developing this solution, i've come across quite a few people, who helped push the project in a better direction
- Acknowledgment 1: ssb22 @ Github
  - For suggesting Folding@Home might be a viable alternative
- Acknowledgment 2: largeknotsbro @ Folding@Home Comunity Discord
  - For suggesting alternative routes than Folding@Home, and providing vital sparring, to understand how distributed computing works in practise. Also for suggesting the Universe platform for this project.
- Acknowledgment 3: InsidiousFiddler @ Github
  - For being a great sparring partner, and hosting the OCISCripts Community Discord
- Acknowledgment 4: Vitalii Koshura @ Berkeley University - Boinc project development
  - For being open to queries, and suggesting that a solution as IdleRunner might be worth it, to look into.


## Project prospects
If you develop a cool mod for IdleRunner that you feel like sharing, please, do send a pull request :)

If you experience an issue with IdleRunner, please do let me know on the community discord

---

*IdleRunner is maintained by OCI Script Community. For usage outside of OCI, please feel free to adapt and use it. Our priority is to assist OCI users.*
*While we can do our best to help you, the Boinc software is ultimately supported by Boinc's own community*


For additional details, visit the OCI Script Community on Discord: https://discord.gg/8eNtPhvhkz

