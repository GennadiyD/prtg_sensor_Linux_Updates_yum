
 Script for PRTG sensor 'Linux Updates' on yum-based Linux distributions.

 Return:
   Chanel1 - Days since last linux update (yum history)
   Chanel2 - Number of packages for update (yum update)
   Chanel3 - The age (in days) of the oldest package from the list for update (based on the file date of the RPM package in the repository)

 Sensor type is "sshscript".

 Script executed under user 'prtg'
 Script required sudo permissions to access yum history

 Sudo settings:
    prtg  ALL=(ALL) NOPASSWD:/usr/bin/yum history


