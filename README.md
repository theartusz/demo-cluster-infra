# Intro
Repository which holds configuration for demo kubernetes cluster. The configuration is trying to be modular with vision to reuse modules for different cloud providers. Main configuration is located in `terraform` folder and each cloud provider has it's subfolders. To deploy the configuration navigate to the cloud provider of your choice and execute terraform from there.

# Notes
- when creating new `dns_zone` paste nameserver addresses to your domain registrar
- setup env var for terraform as `set -x TF_VAR_GITHUB_TOKEN xxxx`
