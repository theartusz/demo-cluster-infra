# ?= sets default value
config ?= variables.tfvars.json
subscription_id := $(shell jq -r '.azure.subscription_id' $(config))
app_name := $(shell jq -r '.app_name' $(config))

# without . azure would be executed as first if just executing make
.azure:
	$(eval subscription_name := $(shell az account show --subscription $(subscription_id) | jq -r '.name'))
	echo "logging into $(subscription_name) with subscription_id: $(subscription_id)"
	@az account show > /dev/null || \
	az login > /dev/null && \
	az account set --subscription $(subscription_id)

init: .azure
ifdef upgrade
	terraform init \
		-var-file=$(config) \
		-upgrade
else
	terraform init \
		-var-file=$(config)
endif

plan: .azure
	@terraform fmt
	terraform plan \
		-var-file=$(config) \
		-out=terraform-plan

apply:
	terraform apply terraform-plan
	@kubectl config set-cluster no-context

destroy: .azure
	terraform plan -destroy -var-file=$(config) -out=terraform-plan

aks-cred: .azure
	az aks get-credentials \
		--resource-group $(app_name) \
		--name $(app_name)
