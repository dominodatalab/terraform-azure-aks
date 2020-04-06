# terraform-azure-aks
Terraform module for deploying a Domino on AKS

## Use

### Create a Domino development AKS cluster
```hcl
module "gke_cluster" {
  source  = "github.com/cerebrotech/terraform-azure-aks"

  cluster = "cluster-name"
}
```

## Manual Deploy
For new projects, the following needs to be done only once for the workspace.
1. `az login`
1. `terraform init`
1. `terraform workspace new [cluster-name]`

Run the Terraform deployment
1. `export TF_VAR_service_principal_name=<service-principal-appid>`
1. `export TF_VAR_service_principal_secret=<service-principal-password>`
1. `terraform apply -auto-approve`

Access AKS cluster
1. `az aks get-credentials --resource-group [cluster-name] --name [cluster-name]`

## Development

Please submit any feature enhancements, bug fixes, or ideas via pull requests or issues.