# Ansible & Kubernetes Assessment

This ansible playbook and its roles deploy a kubernetes single node 'cluster' with ingress controller and letsencrypt certificate provider onto a Debian 11 host.  
## System prerequisites
Install ansible on your local machine to start. Also provide a remote server with internet access and a DNS A record pointing to it.  
Make sure Debian 11 is installed and openssh is running, __also install python3, ansible depends on it__.  

The hostname of the server should be the sub domain pointing to the server, e.g.   
`hostname of server -> kube`,  
`DNS record -> kube.ffhartmann.de`  
Please add your server to your ssh config and create a ssh-key pair.  
`ssh-keygen -f ~/.ssh/<keyfile>`  

`~/.ssh/config:`   
```
host <full domain>
    hostname <full domain> 
    IdentityFile ~/.ssh/<keyfile>
    User <user>
    Port 22
```  
__Copy your public key to the remote server.__

## Ansible Setup
First add your servers hostname to the `prod/hosts.yml` inventory file.
You can replace my server with yours, also replace your user with your ssh user.  
Make sure the user is able to use sudo on the remote server.  

Now create a ansible vault with  
`ansible vault create vault.yml`  
and add these three variables to it:
```
mysql_root_password: <CHANGE ME>
mysql_user: todo
mysql_user_password: <CHANGE ME>
```

Now everything should be ready to run the playbook against the server.

## Running the playbook
To run the playbook run this command:  
`ansible-playbook ./k8s.yml -i ./prod/hosts.yml --ask-vault-pass`  
__HINT:__ If your sudo requires a interactive password prompt add this flag:  
`--ask-become-pass` and ansible will ask for your sudo password before running.

## Explanation
### prerequisites role
This playbook consists of three roles, first the `prerequisites` role:  

This role creates groups, installs dependencies, adds apt repositories and enables kernel modules necessary to run kubernetes.  
It configures docker as a build tool and containerd as a container runtime.  

### install_kubernetes role
The second role runs the kubernetes installation steps:  

It adds the official kubernetes apt repositories, installs kubeadm and kubelet, then runs the `kubeadm init` installer. 

__HINT:__ as this is a single node cluster, a load balancer doesn't make much sense, so I wanted to expose the ingress controller directly. Therefore I have overwritten the `kubeadm.yml` config to enable `nodePorts` as low as 80.  
__THIS IS NOT FOR PRODUCTION USE!__  

After installing the with kubeadm ansible sets up kubectl for the user on the remote host. 
(also for the root user, for ansible orchestration of k8s objects later)

Now we need to remove `NoSchedule` taints from the controlplane node, our only node, to be able to schedule pods later. Also the Network plugin weave is installed to enable the pod network.  

The last step is to install the nginx ingress controller and the cert-manager directly from github.  
Now our cluster is ready to use and we can deploy to it.

### deploy_todo role
Now all we need to do is to deploy the [`todo-app`](https://github.com/docker/getting-started-app.git) project.  
It gets built on the remote host via docker and the resulting image exported from docker to containerd, to make it available to kubernetes.

The deployment consists of one or more pods (depending on how much replicas you defined in the `k8s.yaml` playbook) with the `todo-app`, a mysql deployment with local-storage persistent-volume claim and a letsencrypt issuer to generate valid ssl certificates for the ingress controller. 

After a successfull deployment the app should be reachable under the hostname of the server.