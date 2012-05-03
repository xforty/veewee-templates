veewee-templates
================

Repository of veewee templates to build base boxes for a VirtualBox
and Vagrant environment.  This project also includes simplified
instructions for building a base box and making it available for use
with Vagrant.

### Install Required Software ###

* [VirtualBox](http://www.virtualbox.org) >= 4.1.0
* [Vagrant gem](http://www.vagrantup.com) >= 1.0
    * `gem install vagrant`
* [Veewee gem](https://github.com/jedi4ever/veewee) >= 0.3.0 (currently, it's in prerelease)
    * `gem install veewee --pre`

### Build New Base Box ###

1. `git clone git://github.com/xforty/veewee-templates.git` (read-only clone)
2. `cd veewee-templates`
3. If you have the iso files for the OS and/or VirtualBox guest additions, add them to the iso/ folder now to save time.  Otherwise, veewee will download these automatically...it just might take a little longer.
4. Build the new box
    * Names of the templates are the folder names under the definitions/ folder.
    * `veewee vbox build [template_name]`
5. ...wait...
    * The time it takes to build a box depends on many different factors.  For us, with all the iso files in place, a fast internet connection, and compiling ruby on a MacBook Pro dual core i7, it takes about 15 minutes.
6. Validate the vm
    * `veewee vbox validate [template_name]`
7. Export the vm to a .box file
    * `vagrant basebox export [template_name]`

### Add Base Box to Vagrant ###

1. `vagrant box add [my_box_name] [url_or_filepath_to_basebox]`
    * [More documentation for vagrant boxes](http://vagrantup.com/docs/boxes.html)

### Example ###

    git clone git://github.com/xforty/veewee-templates.git
    cd veewee-templates
    veewee vbox build ubuntu-10.04.4-server-amd64
    veewee vbox validate ubuntu-10.04.4-server-amd64
    vagrant basebox export ubuntu-10.04.4-server-amd64
    vagrant box add ubuntu-10.04.4-server-amd64 ubuntu-10.04.4-server-amd64.box
