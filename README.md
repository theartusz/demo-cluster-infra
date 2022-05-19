# Intro
The terraform script is configured to be executed with `make`. Possible `make` commands are:
- init
- plan
- apply
- destroy
- aks-cred

# User guide
- fill variables`variables.tfvars.json` marked as `<your-value>` with, you guessed it, your values
- create github token with read and write rights to repo and use it when executing `make plan/apply`
- when creating new `dns_zone` paste nameserver addresses to your domain host
