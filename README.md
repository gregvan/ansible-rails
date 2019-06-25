# ansible-rails

This project is an Ansible playbook for provisioning and deploying a Rails/MySQL app to an Ubuntu server.  It is intended to be added to an existing Rails application folder.  Tested with: Rails 5.1.5, Ruby 2.4.3, Ubuntu 16.04 (Xenial).

## Setup

1. [Ansible](http://docs.ansible.com/ansible/latest/intro_installation.html) >= 2.4.1 must be installed
1. This playbook assumes you are targeting MySQL for your production database and have `gem 'mysql2'` included in your Gemfile.
1. From your Rails application folder run:
   
    ```shell
    \curl -sSL https://raw.githubusercontent.com/gregvan/ansible-rails/master/installer.sh | bash
    ```
 
   which will:
  
   1. Add this project to a new folder in your app called "ops"
   2. Initialize the config file
   3. Add 2 new rake tasks to your Rakefile: `provision` and `deploy`.

   If you would prefer, you can run the commands in this file manually.
1. Edit the `ops/config.yml` file and add your project configuration

## Before Provisioning

This Ansible recipe has been adapted to be used with any generic Ubuntu server.
to make it work ..
  1. Note the role: "base_installs" this is where i put any missing Ubuntu packages
  2. Use ssh-copy-id to copy over your credetials to the remote server befor you run 'provision rake'

## Provisioning

Provisioning is used to to setup the the server and initially deploy the application.

To provision your server, run: `rake provision`.  This will do the following:

- Install the following:
  - RVM
  - Nginx
  - Phusion passenger
  - MySQL
  - Libraries: libxslt-dev, libxml2-dev, libmysqlclient-dev, imagemagick, gnupg2, uuid-runtime, apt-transport-https
- Create a user with ssh access and sudo authorization
- Setup a daily backup job to backup MySQL database to S3
- Create an app directory with appropriate permissions where Nginx config is pointing to
- Configure TLS (https) via Let's Encrypt
- Define an environment variable named `SECRET_KEY_BASE` with a unique uuid value.
- Deploy the application:
  - Precompile assets locally with `rake assets:precompile`.
  - BUT then unlike the upstream ansible-rails.. leave the rest up to Capistrano 3 as a typical 'cap production deploy'. It is slower for initial deploy for sure! but you make it back with subsequent deployments IMHO.

## Deploying

If you have already provisioned your server and want to redeploy changes to your Rails app, run `rake deploy`.  This will only run the deploy tasks from the playbook and be much faster.
