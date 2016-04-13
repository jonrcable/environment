{\rtf1\ansi\ansicpg1252\cocoartf1404\cocoasubrtf460
{\fonttbl\f0\fmodern\fcharset0 Courier;\f1\fnil\fcharset0 Menlo-Regular;\f2\fnil\fcharset0 Consolas;
}
{\colortbl;\red255\green255\blue255;\red0\green0\blue0;\red234\green234\blue234;\red135\green135\blue135;
}
\margl1440\margr1440\vieww26660\viewh19980\viewkind0
\deftab720
\pard\pardeftab720\sl280\partightenfactor0

\f0\fs24 \cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec2 Development Environment v1.0\
===========\
\
A sensible, organized vagrant installation that works for me. Makes it easy to maintain separate projects and control the VMs directly in PHPStorm. Although this uses the homestead/laravel virtual box as a base; it covers most of the needs for most modern web development. \
\
\pard\pardeftab720\sl280\partightenfactor0
\cf0 \outl0\strokewidth0 https://laravel.com/docs/5.2/homestead\cf2 \outl0\strokewidth0 \strokec2 \
\pard\pardeftab720\sl280\partightenfactor0
\cf2 \
## Persistent Databases\
At first one of the things that irritated me about using Vagrant in development was blowing away my testing data for that day, week\'85 Sure in Laravel we have Database Migrations and Seeding but sometimes you just want to hold on to that testing data for a little while, ya know?!\
\
After a recent OS format I decided to give vagrant another try and discovered the Vagrant Trigger extension which allows you to work a little magic on both Up/Destroy. A couple of bash scripts to import and export the current mysql database and store them in a Share folder for each project should not be rocket science, so here we are\'85  \
\
I will likely build onto this including the instructions on how to do a basic installation. I know a few of you out there that have been asking me about better enviroments, here is one of many!\
\
\pard\pardeftab720\sl280\partightenfactor0
\cf0 \outl0\strokewidth0 note(s)\
- PHPstorm is not required here but we love it, its awesome and you should totally try it out right meow.\
\pard\pardeftab720\sl280\partightenfactor0
{\field{\*\fldinst{HYPERLINK "https://www.jetbrains.com/phpstorm/"}}{\fldrslt \cf0 https://www.jetbrains.com/phpstorm/}}\
\
- Laravel is not required here but we love it too, it rocks and you should totally try it out right meow.\
https://laravel.com\
\
## Required \cf2 \outl0\strokewidth0 \strokec2 \
\pard\pardeftab720\sl280\partightenfactor0
\cf2 The easy part. Download and install the following tools, follow the defaults.\
\
Virtual Box\
{\field{\*\fldinst{HYPERLINK "https://www.virtualbox.org/wiki/Downloads"}}{\fldrslt https://www.virtualbox.org/wiki/Downloads}}\
Vagrant\
{\field{\*\fldinst{HYPERLINK "https://www.vagrantup.com/downloads.html"}}{\fldrslt https://www.vagrantup.com/downloads.html}}\
Sequel Pro\
{\field{\*\fldinst{HYPERLINK "http://www.sequelpro.com/download"}}{\fldrslt http://www.sequelpro.com/download}}\
\
## Usage\
\pard\pardeftab720\sl280\partightenfactor0
\cf0 \outl0\strokewidth0 - install vagrant triggers so we can use callbacks and save our database on up/destroy\
	!# 
\f1\fs22 \kerning1\expnd0\expndtw0 \CocoaLigature0 vagrant plugin install vagrant-triggers
\f0\fs24 \expnd0\expndtw0\kerning0
\CocoaLigature1 \
\cf2 \outl0\strokewidth0 \strokec2 \
\pard\pardeftab720\sl280\partightenfactor0
\cf2 - create a new folder in the root of your home folder called Development\
	!# cd ~/\
	!# mkdir Development\
\
- download the homestead package into a folder called Homestead in the root of your home folder\
\pard\pardeftab720\sl280\partightenfactor0
\cf0 \outl0\strokewidth0 	!# cd ~/\
	!# 
\f1\fs22 \kerning1\expnd0\expndtw0 \CocoaLigature0 git clone https://github.com/laravel/homestead.git Homestead\
	!# cd Homestead\
	!# 
\f2 \cf2 \cb3 \expnd0\expndtw0\kerning0
\CocoaLigature1 \outl0\strokewidth0 \strokec2 \shad\shadx0\shady-20\shadr0\shado255 \shadc0 bash init\cf4 \strokec4 \shad\shadx0\shady-20\shadr0\shado255 \shadc0 .\cf2 \strokec2 \shad\shadx0\shady-20\shadr0\shado255 \shadc0 sh\
	(note: this will create an folder called .homestead in your home directory with a file called Homestead.yaml)
\f0\fs24 \cb1 \shad0 \
\pard\pardeftab720\sl280\partightenfactor0
\cf2 \
- clone this repository into a folder called Code in the root of your home folder\
\pard\pardeftab720\sl280\partightenfactor0
\cf0 \outl0\strokewidth0 	!# cd ~/\
	!# 
\f1\fs22 \kerning1\expnd0\expndtw0 \CocoaLigature0 git clone https://github.com/jonrcable/enviroment.git Code
\f0\fs24 \cf2 \expnd0\expndtw0\kerning0
\CocoaLigature1 \outl0\strokewidth0 \strokec2 \
\pard\pardeftab720\sl280\partightenfactor0
\cf2 \
- edit the local Homestead.yaml config file and change the 1st folder in the list to the following \
 !# sudo nano ~/.homestead/Homestead.yaml\
 + edit\
	folders:\
		- map: ~/Development/Code\
		  to:  /home/vagrant/Code\
\pard\pardeftab720\sl280\partightenfactor0
\cf0 \outl0\strokewidth0  (note e.g.)\
	sites:\
		- map: code.dev\
		  to:  /home/vagrant/Code/Sites/Base/public\
\pard\pardeftab720\sl280\partightenfactor0
\cf0 		- map: next.dev\
		  to:  /home/vagrant/Code/Sites/Next/public\cf2 \outl0\strokewidth0 \strokec2 \
\pard\pardeftab720\sl280\partightenfactor0
\cf2 \
\pard\pardeftab720\sl280\partightenfactor0
\cf0 \outl0\strokewidth0 - edit the local hosts config file \
 !# sudo nano /etc/hosts\
 + edit (one the last blank line enter each domain, one line each repeat the same IP)\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\pardirnatural\partightenfactor0

\f1\fs22 \cf0 \kerning1\expnd0\expndtw0 \CocoaLigature0 	192.168.10.10 code.dev\
\
\pard\pardeftab720\sl280\partightenfactor0

\f0\fs24 \cf0 \expnd0\expndtw0\kerning0
\CocoaLigature1 - flush the DNS system cache, just in case you encounter issues)\
!# 
\f1\fs22 \kerning1\expnd0\expndtw0 \CocoaLigature0 sudo dscacheutil -flushcache\
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\pardirnatural\partightenfactor0
\cf0 \
- test the hosts file fix works\
 !# ping code.dev\
 (should return 192.168.10.10) ctrl+c to exit\
\
- goto your web browser\
http://code.dev\
\
- Open Sequel Pro and import the sequelpro.plist configuration in ~/Code/Share/Configs\
(if a password is required on the first connection, see account information below)\
\
\pard\pardeftab720\sl280\partightenfactor0

\f0\fs24 \cf0 \expnd0\expndtw0\kerning0
\CocoaLigature1 ## Testing in PHPStorm\
- open PHPStorm, create a new project and map it to a folder in ~/Development/Code/Sites/\{ NEW \}\
- goto Tools -> Vagrant -> Init in Project Root\
- copy the Vagrantfile from ~/Development/Code/Sites/Base into the root of your \{ NEW \} project\
- edit the Vagrantfile in PHPStorm and change the following\
  + edit\
	projectDir=\'93\{ NEW \}\'94\
- goto Tools -> Vagrant -> Up\
- goto Tools -> Vagrant -> Destroy\
- check your work, goto 
\f1\fs22 \kerning1\expnd0\expndtw0 \CocoaLigature0 ~/Code/Share/Databases\
	(note: you should see a single folder for any project in which a Vagrant box has been started. In each folder you should find the latest sql dump for each database)
\f0\fs24 \expnd0\expndtw0\kerning0
\CocoaLigature1 \
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\pardirnatural\partightenfactor0

\f1\fs22 \cf0 \kerning1\expnd0\expndtw0 \CocoaLigature0 \
Does it work? \
Magic!
\f0\fs24 \cf2 \expnd0\expndtw0\kerning0
\CocoaLigature1 \outl0\strokewidth0 \strokec2 \
\pard\pardeftab720\sl280\partightenfactor0
\cf2 \
\pard\pardeftab720\sl280\partightenfactor0
\cf0 \outl0\strokewidth0 ## Important Details\
\pard\pardeftab720\sl280\partightenfactor0
\cf2 \outl0\strokewidth0 \strokec2 **Database User**\
user:homestead\
pass:secret\
}