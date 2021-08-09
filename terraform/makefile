# ?= sets default value
config ?= variables.tfvars.json
subscription_id := $(shell jq -r '.azure.subscription_id' $(config))

# without . azure would be executed as first if just executing make
.azure:
	$(eval subscription_name := $(shell az account show --subscription $(subscription_id) | jq -r '.name'))
	@echo "logging into $(subscription_name) with subscription_id: $(subscription_id)"
	@az account set --subscription "3b654f60-250b-4e4a-a64d-9af05160a324"
	@kubectl config set-cluster no-context

init: .azure
	terraform init

plan: .azure
	terraform plan --var-file=$(config) -out=terraform-plan

apply:
	terraform apply terraform-plan

destroy: .azure
	terraform destroy -var-file=$(config)
