AWX and Ansible Tower Try Out
=============================

A repository to try out ansible tower in virtualbox vm with vagrant (official vagrant image from RedHat)
and awx local docker on __*AWS*__ with terraform and ansible deployed

* The `vagrant` directory contains the `Vagrantfile` for Ansible Tower
* The `terraform_awx_host` directory contains the awx terraform example to create a instance on aws for awx under `docker`
* The `terraform_awx_host/ansible` directory contains a ansible playbook, role and inventory to deploy the awx software too the aws instance

Ansible Tower
-------------

You need a try license from RedHat to use the Tower

AWX
---

**Pre requirements:** 

You need follow software local:
* [terraform](https://terraform.io)
* [ansible](http://docs.ansible.com/ansible/latest/intro_installation.html)

You need a AWS access (access and secret key) with follow existing setups:
* A Route53 DNS Zone
* A existing ssh access key

The instance will be a ubuntu 16.04 LTS

**Prepare:**
* Copy `terraform_awx_host/terraform.tfvars_template` to `terraform_awx_host/terraform.tfvars` and fill out the variables with your data
* Change the hostname from awx.example.com to `awx.YOUR_ROUTE53_ZONE` in `terraform_awx_host/ansible/inventory`

**Tearup**
1. Run Terraform. `cd terraform_awx_host` 
    1. Normal you run one time `terraform init` and than `terraform plan` to see what terraform will do
    2. Than run `terraform apply` to create the instance with DNS entry and security role
2. Run Ansilbe. `cd ansible`
    1. Run `ansible-playbook -i inventory -e awx_dns_name=awx.YOUR_ROUTE53_ZONE certbot_registry_email=YOUR_EMAIL main.yml`

Now you need to wait until the awx finish to create the database (needs ~1,5min) and you can access awx with the default user _admin_ and password _password_

**ATTENTION**

This is only to tryout the sample security group is world open!!! So everyone can access your awx instance!!!
 
