#  Дипломная работа по профессии «Системный администратор» SYS-47 Сафронов Алексей

[Задание к дипломной работе:](https://github.com/netology-code/sys-diplom/tree/diplom-zabbix) 


- Ansible и Tearrform:

![Terraform_vers](img/ter_ans_vers.png)

```bash
cd terraform && terraform init
```

![Terraform_init](img/terraform_init.png)



```bash
terraform plan
```

![terrafom_plan](img/terrafom_plan.png)

```bash
terraform apply
```

![terrafom_apply0](img/terraform_apply0.png)
![terrafom_apply1](img/terraform_apply1.png)

- Так же создаётся inventory.ini и ansible.cfg

[inventori.ini](./ansible/inventory.ini)

[ansible.cfg](./ansible/ansible.cfg)

- Все ВМ:

![yandex_vm](img/yandex_vm.png)

- Instance group:

![yandex_inst_group](img/yandex_inst_group.png)

- cloud network:

![yandex_cloud_network](img/yandex_cloud_network.png)

- Security group:

![yandex_security_group](img/yandex_security_group.png)

- Route table:

![yandex_route_table](/img/yandex_route_table.png)

- Nat gateway:

![yandex_nat_gateway](img/yandex_nat_gateway.png)

- Backend group:

![yandex_backend_group](img/yandex_backend_group.png)

- ALB:

![yandex_alb_target_group](img/yandex_alb_target_group.png)
![yandex_alb](img/yandex_alb.png)

- Snapshots:

![terraform_snapshots](img/terraform_snapshots.png)

# Ansible:

- ping всех ВМ:

```bash
cd ../ansible/ && ansible -i inventory.ini all --vault-password-file ./.vault_pass -m ping
```

![ansible_ping](img/ansible_ping.png)

- Обновление и установка пакетов:

```bash
ansible-playbook -i inventory.ini update.yml --vault-password-file ./.vault_pass
```

![ansible_update](img/ansible_update.png)

- Установка и настройка nginx:

```bash
ansible-playbook -i inventory.ini nginx_setup.yml --vault-password-file ./.vault_pass
```

![nginx_setup](img/nginx_setup.png)

- Проверка сайта через балансировщик:

```bash 
curl -v 158.160.225.99
```
- Web 1:

![curl_alb0](img/curl_alb0.png)

- Web 2:

![curl_alb1](img/curl_alb1.png)


- Установка Zabbix server:

```bash
ansible-playbook -i inventory.ini zabbix_server.yml --vault-password-file ./.vault_pass
```

![zabbix_server_install](img/zabbix_server_install.png)

```bash
curl -v 89.169.128.213/zabbix
```

![curl_zabbix](img/curl_zabbix.png)

- веб:

# [zabbix](89.169.128.213/zabbix)

- Логин: Admin 
- Пароль (сменил вручную): sfaq657!kfkbo12ds

![browser_zabbix](img/browser_zabbix.png)

- регистрация хостов в заббикс:

```bash
ansible-playbook -i inventory.ini zabbix_register_hosts.yml --vault-password-file ./.vault_pass
```


![browser_zabbix_reg](img/browser_zabbix_reg.png)

- установка агентов:

```bash
ansible-playbook -i inventory.ini zabbix_agents.yml --vault-password-file ./.vault_pass
```

![zabbix_agent](img/zabbix_agent.png)

![browser_zabbix_agent](img/browser_zabbix_agent.png)

- Подключение шаблонов:

```
ansible-playbook -i inventory.ini zabbix_templates.yml --vault-password-file ./.vault_pass
```

![browser_zabbix_templates](img/browser_zabbix_templates.png)

- Смена часового пояса:

![browser_zabbix_timezone](img/browser_zabbix_timezone.png)

- На этом этапе хотелось сделать копирование дашборда по API, попыток было много, но заббикс не такой гибкий оказался.
Пришлось делать вручную уже по месту:

- web1:

![browser_zabbix_metrics0](img/browser_zabbix_metrics0.png)

- web2:

![browser_zabbix_metrics1](img/browser_zabbix_metrics1.png)

```bash
ansible-playbook -i inventory.ini elk_docker.yml --vault-password-file ./.vault_pass
```

![ansible_elk](img/ansible_elk.png)

# [kibana](http://89.169.148.12:5601)

- kibana_stream:

![elk_stream](img/elk_stream.png)

- kibana dashboard:

![elk_dashboard](img/elk_dashboard.png)


## Ссылки:

# [Сайт](http://158.160.225.99/)

# [kibana](http://89.169.148.12:5601)

# [zabbix:](http://89.169.128.213/zabbix)

- Логин: Admin 
- Пароль: sfaq657!kfkbo12ds


