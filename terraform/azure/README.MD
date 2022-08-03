# Prerequisits
- azure subscription
- github token - set as TF_VAR_GITHUB_TOKEN env variable

# Notes
To be able to create resources in azure account make sure to be logged in the right azure account and subscription with `az login` and `az account set --subscription <subscription id>`

Alternativly `az login` and `az account set` are included in make file.

# Usage

`make init` - login to azure + initialize terraform\
`make plan` - create terraform plan and save it as `terraform-plan`\
`make apply` - apply the created plan\
`make aks-cred` - update kube_config with context from the newly created cluster\
`make destroy` - destroy all resources created