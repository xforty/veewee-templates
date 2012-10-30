
###############################
# PREPARE NEWLY INSTALLED OS
###############################

# So less doesn't cause any command to hang due to it being interactive
export PAGER=cat

date > /etc/vagrant_box_build_time

# Update and upgrade packages
echo "Updating and upgrading packages..."
apt-get -q -y update
apt-get -q -y upgrade

# Setup sudo to allow no-password sudo for "admin"
cp /etc/sudoers /etc/sudoers.orig
sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=admin' /etc/sudoers
sed -i -e 's/%admin ALL=(ALL) ALL/%admin ALL=NOPASSWD:ALL/g' /etc/sudoers

###############################
# INSTALL BASE SOFTWARE
###############################

echo "Installing other software"

apt-get -qy install \
  build-essential \
  openssl \
  libreadline6 \
  libreadline6-dev \
  curl \
  git-core \
  zlib1g \
  zlib1g-dev \
  libssl-dev \
  libyaml-dev \
  libsqlite3-dev \
  sqlite3 \
  libxml2-dev \
  libxslt-dev \
  autoconf \
  libc6-dev \
  ncurses-dev \
  automake \
  libtool \
  bison \
  subversion \
  dkms \
  nfs-common \
  vim

###############################
# INSTALL VBOX GUEST ADDITIONS
###############################

echo "Installing vbox guest additions"

VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
mount -o loop /home/vagrant/VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt
rm /home/vagrant/VBoxGuestAdditions_$VBOX_VERSION.iso

###############################
# INSTALL VAGRANT SSH KEYS
###############################

echo "Installing vagrant ssh keys"

mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh

###############################
# INSTALL RVM, RUBY, GEMS
###############################

echo "Installing rvm, ruby, and gems"

# Set ruby version to be installed
export INSTALL_RUBY_VERSION=1.9.2-p320

# Install RVM
curl -s -L get.rvm.io | bash -s stable

# Enable RVM for all users
(cat <<'EOP'
[[ -s "/usr/local/rvm/scripts/rvm" ]] && source "/usr/local/rvm/scripts/rvm"
EOP
) > /etc/profile.d/rvm.sh

# Don't install docs with gems (saves space)
echo "gem: --no-rdoc --no-ri" > /home/vagrant/.gemrc
chown vagrant:vagrant /home/vagrant/.gemrc

# Install Ruby using RVM
echo "Installing $INSTALL_RUBY_VERSION as default ruby"
bash -c '
 source /etc/profile
 # Use the builtin rvm script instead of the shell function to install
 /usr/local/rvm/bin/rvm install $INSTALL_RUBY_VERSION
 rvm alias create default ruby-$INSTALL_RUBY_VERSION
 rvm use $INSTALL_RUBY_VERSION --default

 echo "Installing chef and puppet gems"
 gem install --no-rdoc --no-ri chef puppet
 
 # Clean up rvm install
 rvm cleanup all'

# Add the vagrant user to the rvm group
usermod -a -G rvm vagrant

###############################
# CLEAN UP
###############################

echo "Cleaning up"

# Clean up packages that are no longer needed
apt-get -q -y autoremove
apt-get -q -y clean

# Clear out tmp
rm -rf /tmp/* /tmp/.??*

# Zero out the free space to save space in the final image:
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

# Removing leftover leases and persistent rules
echo "cleaning up dhcp leases"
rm /var/lib/dhcp/*

# Make sure Udev doesn't block our network. http://6.ptmc.org/?p=164
echo "cleaning up udev rules"
rm /etc/udev/rules.d/70-persistent-net.rules
mkdir /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
rm /lib/udev/rules.d/75-persistent-net-generator.rules

###############################
# FINISH
###############################

echo "Adding a 2 sec delay to the interface up, to make the dhclient happy"
echo "pre-up sleep 2" >> /etc/network/interfaces
exit
