# IdleRunner

> *When i work, you stop. When i don't, you run.*

IdleRunner's main purpose, is to offer the option to fire scripts(compute units and other busywork) when no users are actively interacting with the box.
And to halt heavy workloads, when users **are** interacting with the box.

## But why?
It's an attempt to make sure that the system administrator - or user, can work without being hamered down by a high workload, which could be paused if you wanted to. A snappy box, is a happy box.

On standard-nonheadless servers, we have a lot of information we can pull, through X. But on headless servers, we can't.
Why? Because we are missing the X Window System.
We simply don't have a need for it on headless operating systems.
So, we need another way, to reliably figure out, when a user is active, and when the user is not.

The task of figuring this out, were suggested to us by a developer from Berkeley University., while discussing the internal workings of their BOINC project. Happily. We accept the challenge.

## Design
For IdleRunner to work properly, we need a number of things setup first.
* The BashRC
* The config file
* The config updater
* The Cronjob
* The IdleRunner


### The PROMPT_COMMAND flag
The way you usually interact with shells like Bash, is via. a prompt.
What this prompt_command flag does, is to fire a command, just before the prompt is presented to you.
In other words, When you log on, and whenever you type a command.

Utilizing the above, enables us to figure out, when the shell is being used by users.
It allows us to figure out how much time has passed, since last time a user used bash on the server. Which takes us quite a long way.

### Setup - BashRC config
The first thing the setup script does, is to create a backup of the global BashRC.
The backup will be put here: /etc/bash.bashrc.bak
The user running the setup script will be informed of this. 
After that, it proceeds to alter the working copy of /etc/bash.bashrc.
Adding this line: 
'PROMPT_COMMAND=date +"%F %T" > /tmp/IdleRunner_last_activity_timestamp'
Then it proceeds to source the global bashrc file again. And now we're live.

From now on, every time a prompt is displayed, the command overwrites the content of /tmp/IdleRunner_last_activity_timestamp, with a new timestamp.

This timestamp is what we use to measure idle time.
Adding it to the global bashrc, allows for us to make sure all users on the box, are taken into account.
Writing to /tmp is the best fit for the usecase, as data here is temporary.

To avoid tampering issues, as /tmp is world-readable, the reader-part(IdleRunner) of the project, validates the timestamp with a regex, before acting on it.

### Setup - IdleRunner Config
<u>Config flags</u>

**ConsiderMeIdleAfterMinutes**
The integer amount of minutes elapsed, before the IdleRunner considers the box to be idle of active user interaction
Please note, this regards all user activity across the box. Not just the currently logged-in user.

**FireThisWhenIdle**
The string of commands to fire, when IdleRunner determines the system is idle of user interaction.

**FireThisWhenNotIdle**
The string of commands to fire, when IdleRunner determines the system is no longer idle of user interaction.

**CronFrequency**
The integer value of the desired cronjob frequency, in minutes.

### Setup - IdleRunner Config-Updater
The tool re-interprets the config file, and applies the intended settings to:
* The crontab.
* The PROMPT_COMMAND flag in BashRC

### Setup - Cron
To avoid needless firing of a larger round of scripts, the Crontab is used, when evaluating whether the live, interactive sessions on the system, is idle or not.

Per default, the cronjob is set up to run once per minute.
It fires the IdleRunner, which does the following, in order:
* Checks the output of "w", to ascertain if any users are actively connected to the host
	* If no users are listed, it exits.
* Checks the /tmp/IdleRunner_last_activity_timestamp for insight, to when a command was last entered. 
* If the idle conditions are met, it fires the defined commandline.
	* And change the contents of /tmp/IdleRunner_last_activity_timestamp, to "1".
* If the idle conditions are no longer met, it fires the defined commandline.




Entering idle state

Exitting idle state
The Prompt_command flag ensures, that ongoing work is paused immediately, after your login. It does so by running the IdleRunner, after writing a timestamp to the activity-file.






# Other words
IdleRunner is a shellscript solution, intended to be used for headless servers, on a Debian OS. It might work for Redhat distributions to - but it's not tested for it.

We wrote this primarily for OCIScript's community.
If you want to use it outside of OCI, please, do so. It would only make the time we spent, worth more. Unfortunately, our time, ressources and willingness, ends at the border of OCI. You're always welcome to ask your questions, but we reserve our priorities to help OCI users.



# TODO
Adjust the PROMPT_COMMAND to include IdleRunner, to make sure commands are fired, as soon as a user logs in
