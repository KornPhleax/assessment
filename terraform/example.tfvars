# default configuration spawning 3 vms
vm_count = 3
# project_id = "assessment-420408"
region = "us-east1"
zone = "us-east1-b"
private_key_file = "./terraform"
public_key_file = "./terraform.pub"
vm_image = [
    "debian-cloud/debian-11", 
    "debian-cloud/debian-11", 
    "debian-cloud/debian-11"]
vm_flavor = [
    "e2-micro", 
    "e2-micro", 
    "e2-micro"]
