Development Environment v1.0
===========

A sensible, organized vagrant workflow using Homestead that works for me. Makes it easy to maintain separate projects, control the VMs directly in PHPStorm and maintain persistent MySQL databases by project on each build. Although this uses the laravel/homestead virtual box as a base; it covers most of the needs for any modern web development.

https://laravel.com/docs/5.2/homestead

## Persistent Databases
At first one of the things that irritated me about using Vagrant in development was blowing away my testing data for that day, week… Sure in Laravel we have Database Migrations and Seeding but sometimes you just want to hold on to that testing data for a little while, ya know?!

After a recent OS format I decided to dive a bit deeper into vagrant and discovered the Vagrant Trigger extension which allows you to work a little magic on both Up/Destroy. A couple of bash scripts to import and export the current mysql database(s) for each project is not rocket science, so combine the two and… magic!

I will likely build onto this but its mostly here to share and archive.

A few of you have been asking me about building better environments, here is one of many ways to go about it!

## My Development System (tested using)
- OSX 10.11.4 El Capitan
- PHPStorm 2016.1
- Virtual Box 5.0.16
- Sequel Pro 1.1.2
- Vagrant 1.8.1

note(s)
- PHPstorm is not required here but we love it, its awesome and you should totally try it out right meow.

   https://www.jetbrains.com/phpstorm/

- Laravel is not required here but we love it too, it rocks and you should totally try it out right meow.

   https://laravel.com


## Required Dependencies
The easy part. Download and install the following tools, follow the defaults.

Virtual Box
https://www.virtualbox.org/wiki/Downloads


Vagrant
https://www.vagrantup.com/downloads.html


Sequel Pro
http://www.sequelpro.com/download

## Installation & Usage
- install vagrant triggers so we can use callbacks and save our database on up/destroy

	!# vagrant plugin install vagrant-triggers

- create a new folder in the root of your home folder called Development

	!# cd ~/

	!# mkdir Development

- download the homestead package into a folder called Homestead in the root of your home folder

	!# cd ~/

	!# git clone https://github.com/laravel/homestead.git Homestead

	!# cd Homestead

	!# bash init.sh

	(note: this will create an folder called .homestead in your home directory with a file called Homestead.yaml)

- clone this repository into the Development folder in a new folder called Code

	!# cd ~/Development

	!# git clone https://github.com/jonrcable/enviroment.git Code


- edit the local Homestead.yaml config file and change the 1st folder in the list to the following

 !# sudo nano ~/.homestead/Homestead.yaml

 + edit  (note e.g. you can add more site like so, be careful make sure the folder exists!)

	folders:

		- map: ~/Development/Code

		  to:  /home/vagrant/Code

	sites:

		- map: code.dev

		  to:  /home/vagrant/Code/Sites/Base/public

		- map: next.dev

		  to:  /home/vagrant/Code/Sites/Next/public


- edit the local hosts config file

 !# sudo nano /etc/hosts

 + edit (on the last blank line enter each domain, one line each repeat the same IP)

	192.168.10.10 code.dev

- flush the DNS system cache, just in case you encounter issues)

    !# sudo dscacheutil -flushcache


- test the hosts file fix works

 !# ping code.dev

 (should return 192.168.10.10) ctrl+c to exit


- goto your web browser

    http://code.dev


- Open Sequel Pro and import the sequelpro.plist configuration in ~/Code/Share/Configs
(if a password is required on the first connection, see account information below)


## Testing in PHPStorm & SequelPro
- open PHPStorm, create a new project and map it to a folder in ~/Development/Code/Sites/{ NEW }

- goto Tools -> Vagrant -> Init in Project Root

- copy the Vagrantfile from ~/Development/Code/Sites/Base into the root of your { NEW } project

- edit the Vagrantfile in PHPStorm and change the following

  + edit

	projectDir=“{ NEW }”
- goto Tools -> Vagrant -> Up

- open Sequel Pro and change the homestead database, create a new database you get the idea...

- goto Tools -> Vagrant -> Destroy

- check your work, goto ~/Code/Share/Databases

	(note: you should see a single folder for any project in which a Vagrant box has been started. In each folder you should find the latest sql dump for each database)

- goto Tools -> Vagrant -> Up

- open Sequel Pro, all database changes should be preserved	from the last Destroy

Does it work?

Magic!

## Important Details
**Database User**:

user:homestead / pass:secret
