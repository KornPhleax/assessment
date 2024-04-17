# Terraform Assessment
## Task
This terraform program spawns between 2 and 100 virtual machines on google compute engine. (if your account allows that much vCPU Cores to be allocated)
Then the machines do one ping to their respective network neighbour e.g. vm0 pings vm1, vm1 pings vm2...

## Setup
### Prerequisites
You need a linux machine with internet access and admin rights.
first you should install the google cloud sdk and terraform.
Then login to your gcloud account.  
`gcloud auth login`  

Then create a new project and set it as your default project.  
`gcloud config set project <PROJECT-ID>`

Now some services need to be enabled and the billing for this project need to be enabled:  
HINT: make sure billing is enabled, otherwise this will not work.  
`gcloud services enable cloudresourcemanager.googleapis.com` 
`gcloud auth application-default set-quota-project <PROJECT-ID>`   
`gcloud services enable servicemanagement.googleapis.com`  
`gcloud services enable compute.googleapis.com`  

Now the terraform google-compute provider will automatically use the credentials created.  
Last create a ssh key pair with in the directory
`ssh-keygen -f ./terraform`  
with no passphrase. 

### Terraform
You should be able to clone this repository and execute  
`terraform init`  
to install all dependencies needed by terraform.

To start a default configuration of this deployment execute  
`terraform apply -var-file ./example.tfvars`  
with the vars provided you just need to provide your project-id interactively.  
Confirm the deployment with `yes`.

You should get output in the form of:  
```
Apply complete! Resources: 13 added, 0 changed, 0 destroyed.

Outputs:

ip = [
  "10.0.0.4",
  "10.0.0.2",
  "10.0.0.3",
]
ping = [
  tomap({
    "result" = "ping from vm0 to vm1 successful"
  }),
  tomap({
    "result" = "ping from vm1 to vm2 successful"
  }),
  tomap({
    "result" = "ping from vm2 to vm0 successful"
  }),
]
```

You can change the parameters in the example.tfvars file to your liking. 

## Explanation

There are three files at play, first the `vars.tf`.  
Here all variables that get used by the `network.tf` and the `main.tf` are defined.  

The `network.tf` is responsible to setup a internal network between the vms with a so called `google_compute_network` and a `google_compute_subnetwork`.  
Further there are two firewall rules added to allow icmp packets being sent between the vms and to allow ssh connections from the google ssh proxy. (will be explained later)  
To allow internet access a `google_compute_router` is created and configured to do NAT between the internal network and the internet.  

In the `main.tf` file the google provider is configured, so terraform can use the google cloud.  
All vms have a `admin` account with a random password. This is provided by the `random_password` terraform module.  

The `google_compute_instance` get initialized with a startup script, which adds the new admin user and grants sudo privileges.  

The ping test is performed via the `gcloud` utility and the created ssh key using the `ping_test.sh` script.  
It returns JSON to terraform on successful and failed pings. These results get printed by terraform to the console. 