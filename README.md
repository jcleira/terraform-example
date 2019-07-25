# Provision Wordpress environments using Terraform on AWS

This repository contains the resources and rationale about provisioning Wordpress environments on AWS using Terraform.

# What you have done?

I've used Terraform to provision all AWS resources needed to run Wordpress on an ECS cluster. I've used Terraform verified modules when available, but not un-verified or copied (forked) code.

I've added comments on the files. the following docs add more context but basically the same information would be on the project files, I'm adding it also here due the nature of this repository.

Despite that this README.md has an [Improvements section] (#share-with-us-any-ideas-you-have-in-mind-to-improve-this-kind-of-infrastructure.), I've added some minor TODO for uncompleted tasks on each component.

### VPC

For the VPC I used "terraform-aws-modules/vpc/aws" module, creating the following subnet configuration:

Subnets:
- `private_subnets`: For the wordpress instances, we don't want EC2 instances accesible from the internet.
- `database_subnets`: For the RDS instance, also non accesible from the internet.
- `public_subnets`: For the ELB/ALB.

One NAT Gateway will be created per subnet, this configuration has become a standard. While probably one NAT Gateway per AZ is enough as you get redundancy within the zone, this setting doesn't add extra overhead.

Using no internet access subnets for `Wordpress` has been discarded as that configuration might prevent tipical Wordpress actions like:

- Plugin updating.
- Email sending. 

TODO: 

- [ ] We should make AWS region and AZs configurable.

### ECR

An ECR repository would be created to push the Wordpress docker images.

Configure an ECR policy to keep just the last 20 images. ECR disk usage might become wild with Wordpress images This policy will keep an eye on that.

TODO: 

- [ ] If current's running image gets deleted with this policy we might have problems on auto-scaling.

As Wordpress images are everything but light (probably even > 1GB), I've set an ECR policy to keep just the 20 last images attached to the ECR repository.

# Share with us any ideas you have in mind to improve this kind of infrastructure

In order to create a "real" Wordpress provisioner there are some details that should be improved:

### Adding a troubleshooting instance 

In order to provide support while on-call with incidents I would add an troubleshooting instance (probably not an instance but a running docker image) with some tooling like:

- [`innotop`](https://github.com/innotop/innotop) for database monitoring. 
- Wordpress CLI 
- Custom scripts

### S3 & Cloudfront

On this example we are using an EFS volume to enable "asset sharing" in case of auto-scaling, needed as "uploading" assets is a common task on Wordpress, but that EFS volume adds complexity to the deployment.

### RDS

Production RDS environments are supposed to use Multi-AZ configurations, but also this provisioning might include other production related settings like:

- Enable RDS enhanced monitoring
- Enable deletion protection

Also, there are some settings that should be parametrized/provided while provisioning, either on basic settings like:

- Instance type (currently only db.t2.micro)
- Instance disk size.
- Configure maintenance & backup windows with proper settings for the customer.

But also on the mariadb params, starting with the basics:

- `innodb_buffer_pool_size`
- `innodb_log_file_size`
- `max_connections`
- `query_cache_size`
