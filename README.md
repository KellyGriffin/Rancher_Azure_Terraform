# Rancher deployment on Azure

Leveraging Terraform to deploy a non-HA Rancher Server within Azure.

> Architecture

Terraform scripts will deploy:
* A virtual network
    * A frontend subnet with its security group
    * A dynamic Public IP Address assigned to the Rancher Server
* Rancher server (using Stable version of Rancher)

<p align="center">
  <img src="https://github.com/KellyGriffin/Azure_Rancher_Terraform/blob/master/docs/assets/RancherAzure.png" width="350" title="Rancher Azure Architecture">
</p>

This deployment will expose your Rancher server to the internet.  Modify the Terraform environment if you don't want this to occur.  It also provides a Dynamic Public IP Address - caution should be expressed when using a dynamic address for your Rancher server.  It is recommended a static address be used and/or a DNS entry for the Rancher URL.

> Getting started

The following assumes:
* You have necessary connection to Azure which will be explained further below
* You have terrform installed and have a basic understanding of how to leverage it
* You have an Azure account with sufficient credit on it. And you have clear understanding on how Azure charges you.
* You have SSH keys on your machine, otherwise check [here](https://confluence.atlassian.com/bitbucketserver/creating-ssh-keys-776639788.html)
* You know which Region to implement your Rancher server and which image you would like to utilise

> **Please note the configuration deployed will use resources that you/your organisation will be charged for.**

> Create service principal on Azure

This creates an access to Azure APIs that terraform will use to create the resources.

1. [Create a service principal to provide authentication](https://www.terraform.io/docs/providers/azurerm/authenticating_via_service_principal.html)
2. Create a file named "secret.tfvars" and populate the following variables - you will use this file during the terraform apply section below:
```INI
client_id       = "XXXX"
client_secret   = "XXXX"
tenant_id       = "XXXX"
subscription_id = "XXXX"
```

*Please note - do not copy your secret.tfvars file anywhere outside of your Organisation as it contains very sensitive information about your Azure environment.*

> Execute terraform

1. [Install terraform](https://www.terraform.io/intro/getting-started/install.html)
2. Initialise Terraform by running `terraform init`
3. Check what Terraform plans to do `terraform plan -var "ssh_public_key_file_path=$HOME/.ssh/id_rsa.pub" -var "ssh_private_key_file_path=$HOME/.ssh/id_rsa" -var-file="secret.tfvars"`
4. Apply changes `terraform apply -var "ssh_public_key_file_path=$HOME/.ssh/id_rsa.pub" -var "ssh_private_key_file_path=$HOME/.ssh/id_rsa" -var-file="secret.tfvars"`

You should get the following result:
```
Outputs:

]
Rancher Server IP address = [
    Rancher server: x.x.x.x
]
```

To ensure you can get access to your Rancher server - use the IP Address shown above with HTTPS.

*Note: Check troubleshooting to understand why there is an unsecure warning.*

## What to do next


> Configure Rancher

Follow the details found on our Website to configure Rancher as found [here](https://rancher.com/docs/rancher/v2.x/en/admin-settings/)

Once complete - sit back and enjoy!!
