#!/usr/bin/env bash

if [[ ! -f config.ru ]] ; then
    echo 'It appears the current working directory is not a Rails application.'
    exit 1
fi

# Clone ansible-rails into a folder called ops/
git clone https://github.com/gregvan/ansible-rails.git ops && \

# Remove the installer file because it is not needed
rm ./ops/installer.sh

# Remove ops/.git folder to make the clone part of the Rails app itself
rm -rf ./ops/.git && \

# Initial the config file using the template
mv ops/config.yml.example ops/config.yml

# Add ops/config.yml to .gitignore
echo "ops/config.yml" >> .gitignore

# Add new tasks to Rakefile
cat <<EOT >> ./Rakefile

task :provision do
  sh "ansible-playbook -i ./ops/config.yml ./ops/playbook.yml"
end

task :deploy do
  sh "ansible-playbook -i ./ops/config.yml ./ops/playbook.yml --tags 'deploy'"
end
EOT