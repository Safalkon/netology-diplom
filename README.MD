



ansible -i inventory.ini all -m ping

ansible-galaxy collection install git+https://github.com/netways/ansible-collection-elasticstack.git

ansible-galaxy collection install -r requirements.yml

ansible-galaxy role install -r requirements.yml


ansible-playbook -i inventory.ini nginx_setup.yml

ansible-playbook -i inventory.ini zabbix_server.yml

