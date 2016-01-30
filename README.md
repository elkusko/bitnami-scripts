# bitnami-scripts
some scripts to help me do the job with bitnami AWS 


##Deploy New Bitnami Custom PHP Application

Helps deploying the steps at:

https://wiki.bitnami.com/Applications/BitNami_Custom_PHP_application

Steps to do:
~~~bash
sudo wget https://raw.githubusercontent.com/elkusko/bitnami-scripts/master/newApp.sh
sudo chmod +x newApp.sh
sudo ./newApp.sh your_custom_app_name
~~~

Goto your new app url.
ec2-your-instance.compute.amazonaws.com/your_custom_app_name/

if you can see the index content, it's done
