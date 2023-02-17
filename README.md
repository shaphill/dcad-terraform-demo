# Summary

This repository contains two Terraform demos automating Cisco ACI that were presented during the **Datacenter Automation Days** webinars in AMER. 
# Demos
### Demo 1
Extremely basic Terraform configuration file automating deployment of a basic 3-tier web application on Cisco ACI. No variables, flow control, nested loops, etc.




### Demo 2
Same ACI configuration as Demo 1 but showcases variables, flow control, etc.  

# Instructions
These playbooks have been tested with Terraform version 1.3.1 and Cisco ACI collection version 2.6.0

To run the demo, use the following commands:
```
$ terraform init
$ terraform plan
$ terraform apply
```

To undeploy configuration:
```
$ terraform destroy
```

