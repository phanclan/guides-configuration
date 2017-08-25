# Intro
This repo contains Packer templates used for modules in hashicorp-modules

These images are generally built through an internal CI System. Versions need to be updated manually, and generally there is a new release (using the latest patched images from upstream vendors).
---

## HashiStack  
Contains provider specific templates that installs HashiCorp software on a single node (Consul, Nomad, Vault, consul-template and envconsul).

Example HashiStack build command:

```
AWS_REGION="us-west-1" PACKER_ENVIRONMENT="production" CONSUL_VERSION="0.9.2" NOMAD_VERSION="0.5.6" VAULT_VERSION="0.7.3" packer build hashistack.json
```

---

## Consul
Contains Consul specific installation scripts, configuration files.  Also has Packer templates specific to Consul usage.

Example Consul build command (AWS):

```
AWS_REGION="us-west-1" PACKER_ENVIRONMENT="production" CONSUL_VERSION="0.9.2" packer build consul-aws.json
```

Example Consul build command (Azure):

```
AZURE_RESOURCE_GROUP="PackerImages" AZURE_LOCATION="West US" PACKER_ENVIRONMENT="dev" CONSUL_VERSION="0.9.2" packer build consul-azure.json
```

---

## Nomad  
Contains Nomad specific installation scripts, configuration files.  Also has Packer templates specific to Nomad usage.


Example Nomad (including Consul) build command:

```
AWS_REGION="us-west-1" PACKER_ENVIRONMENT="production" NOMAD_VERSION="0.5.6" CONSUL_VERSION="0.9.2" packer build nomad.json
```

---

## Vault    
Contains Vault specific installation scripts, configuration files.  Also has Packer templates specific to Vault usage.

Example Vault (including Consul) build command:

```
AWS_REGION="us-west-1" PACKER_ENVIRONMENT="production" VAULT_VERSION="0.7.3" CONSUL_VERSION="0.9.2" packer build vault.json
```
