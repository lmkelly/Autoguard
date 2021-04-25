### Autoguard: Wireguard Automated

Autoguard is a fiarly lightweight solution created to make Wireguard function within an enterprise without the end user having direct access to the server in an easy and user-friendly way.

#### How does it work?

In addition to Wireguard, the server is also running an osTicket webserver, which is integrated with the file-system so email attachments are readily available. When Autoguard_Client.ps1 is executed on the cleint side a public/private keypair is generated and the public key is sent in addition to some other data through email to an inbox being watched by osTicket, which will dump the file into a specified output directory on the server. This file is then noticed by Autoguard_BE.bash which should be running as a linux service and is processed allong with a number of variables in /vars which will create a nearly ready to use config file for the client. The backend script also creates new lines in the wireguard config file, and then sends an email containing the new config file as an attachment to the original email sender. Upon recieving this email the user can then execute Autoguard_Client2.ps1 which will prompt them to select the attachemtn they recieved and will enter the previously generated private key and move the file to the wireguard config dump directory before cleaning up the old temporary key files.

#### See the Wiki for resources to help building your enviroment

[Installing osTicket](https://github.com/lmkelly/Autoguard/wiki/Installing-OSTicket), [Email monitoring with osTicket](https://github.com/lmkelly/Autoguard/wiki/Configuring-Email-monitoring-on-OSTicket) and [osTicket storage-fs plugin](https://github.com/lmkelly/Autoguard/wiki/Installing-and-Configuring-storage-fs-plugin-on-osTicket)

### Disclaimer: This software has NOT been properly secured and is rather a proof of concept. Be sure to look into adding a layer of authentication before adding this to a production enviroment


