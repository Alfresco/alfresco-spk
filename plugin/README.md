SPK plugin
===============================

SPK plugin is a little utility that provide a good interface to alfresco-spk.
It consists of 2 main actions:
 - spk-build : creates a vagrantbox with the latest Alfresco installation
 - spk-run : creates a Vagrantfile that is automatically run to create a live Alfresco installation

# How to test
1. cd in this folder
2. bundle install
3. bundle exec vagrant spk-build if you want to build a box
4. bundle exec vagrant spk-run if you want to run a live Alfresco installation


# TODOS
Needs test coverage
Needs more structure
Needs more generalization (lots of hardcoded stuff)
Needs to display more info up in the console
Needs to run with some other custom template and inside a Vagrant file as plugin
