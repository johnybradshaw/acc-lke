## Usage

Sample usage of this module is as shown below. For detailed info, look at inputs and outputs.

### Step 1

In your main.tf, add the following code:
<!-- NOTE: The package-source and version x.x.x will be auto populated by the ci job. You do not need to change anything here. -->
```hcl

# Create the LKE cluster
module "lke" {
  source = "./modules/lke"
  providers = {
    linode.default      = linode
  }

  linode_config = var.linode_config # Pass the Linode configuration to the module
  lke_cluster   = var.lke_cluster # Pass the LKE cluster configuration to the module
}

output "lke" {
  description = "Important outputs from LKE cluster."
  value = module.lke # Output from the lke module
}

```

#### Note

- **lke** is the name of the module. You can use any name you want.

### Step 2

In your provider.tf, add the following code, if it doesn't exist already:

```hcl

terraform {
    required_version = ">= 1.5.7"

    required_providers {
        linode = {
            source = "linode/linode"
            version = ">= 2.9.3"
            configuration_aliases = [ linode.default ]
        }
    }
}

provider "linode" {
    alias = "alternative"
    token = var.linode_config.api_token
}

```

### Step 3

Verify your settings using the following command:

``` bash
terraform init
terraform plan
```

### Step 4

Apply the changes

``` bash
terraform apply
```
