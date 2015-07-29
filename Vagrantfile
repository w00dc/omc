# -*- mode: ruby -*-
# vi: set ft=ruby :

#
# omc Development Environment
#
# Note: You need to have these two Vagrant plug-ins installed
#
# vagrant plugin install vagrant-vbguest
#
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Use Ubuntu 14.04 Trusty Tahr 64-bit as our operating system
  config.vm.box = "ubuntu/trusty64"

  # share the current folder as /vagrant in the vm
  config.vm.synced_folder ".", "/vagrant"
  # share your entire HOME folder
  #config.vm.synced_folder ENV['HOME'], '/mnt'

  # Configurate the virtual machine to use 1GB of RAM and 1 CPU
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "1024"]
    vb.customize ["modifyvm", :id, "--cpus", "1"]
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  end

  # To get rid of Vagrant insecure key warning
  config.ssh.insert_key = false

  # Forward the web server default port to the host (does not work) 
  #config.vm.network :forwarded_port, guest: 80, host: 80, auto_correct: true 
  
  # Forward NGINX port
  config.vm.network :forwarded_port, guest: 8080, host: 8080, auto_correct: true 
  
  # Forward RAILS Unicorn port
  config.vm.network :forwarded_port, guest: 3000, host: 3000, auto_correct: true 

  # Forward PostgreSQL port
  config.vm.network :forwarded_port, guest: 5432, host: 5432, auto_correct: true 
  
  config.vm.network :private_network, ip: "192.168.56.102"
  config.vm.hostname = "omc"

  # Create a Ruby on Rails environment
  config.vm.provision :shell, privileged: false, inline: <<-SHELL
    sudo ln -s /vagrant /omc
    sudo apt-get update
    sudo apt-get -y install git
    sudo apt-get -y install libpq-dev
    echo "gem: --no-document" >> ~/.gemrc
    gem update --no-rdoc --no-ri
    gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
    curl -sSL https://get.rvm.io | bash -s stable --rails

    # Install Ruby 2.1.6 and make it the default for Heroku
    source /home/vagrant/.rvm/scripts/rvm
    rvm install ruby-2.1.6
    rvm --default use 2.1.6

    # Apparently bundle isn't part of Ruby 2.1.6 -- install it seperately
    gem install bundle
    echo "colorscheme desert" > ~/.vimrc
    
    # Prepare PostgreSQL data share
    sudo mkdir -p /var/lib/postgresql/data
    sudo chown vagrant:vagrant /var/lib/postgresql/data

    # PhantomJS for JS Simulation ???
  SHELL

  # Add PostgreSQL docker container
  config.vm.provision "docker" do |d|
    d.pull_images "postgres"
    d.run "postgres",
      args: "--restart=always -d --name postgres -h db -p 5432:5432 -v /var/lib/postgresql/data:/var/lib/postgresql/data -e POSTGRES_USER=omc -e POSTGRES_PASSWORD=passw0rd"
  end

  # Add NGINX docker container for web assets
  config.vm.provision "docker" do |d|
    d.pull_images "nginx"
    d.run "nginx",
      args: "--restart=always -d --name nginx -h web -p 8080:80 -v /omc/config/deploy/conf.d:/etc/nginx/conf.d:ro -v /omc/public:/usr/share/nginx/html:ro"
  end

  # Set up Rails application
  config.vm.provision :shell, privileged: false, inline: <<-SHELL
    source /home/vagrant/.rvm/scripts/rvm
    cd /omc
    bundle install
    rake db:setup
    #RAILS_ENV=production bundle exec rake assets:precompile
  SHELL
end
