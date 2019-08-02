# Provision Wordpress environments using Terraform on AWS
This repository contains the resources and rationale about provisioning Wordpress applications on AWS using Terraform & Packer.

# What you have done?

## Short description
I've used Terraform to provision an ECS cluster and a RDS database in order to run a Docker image built with Packer and configured with Packer's Ansible provisioner.

## How
I've used Terraform to provision all AWS resources needed to run Wordpress on an ECS cluster. I've used Terraform verified modules when available, but not un-verified or copied (forked) code.

I've added as many docs ass possible on project's files. This README.md add context but the same facts are explained on the files (I'm duplicating them due the nature of this repository).

I'm not 100% happy with the results. My first intention was to create a near production ready environment, but all the configurable settings involved soon started to add to much complexity for that goal. 

## Detailed description for the AWS parts

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
An ECR repository would be created to host our Wordpress docker images.

Configure an ECR policy to keep just the last 20 images. ECR disk usage might become wild with Wordpress images This policy will keep an eye on that.

TODO: 
- [ ] If current's running image gets deleted with this policy we might have problems on auto-scaling.

As Wordpress images are everything but light (probably even > 1GB), I've set an ECR policy to keep just the 20 last images attached to the ECR repository.

### ECS
An ECS cluster ready to run our Wordpress jobs, the ECS cluster will use the [ECS linux optimized AMI](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html).

Within the ECS cluster a task definition defines the Wordpress application deployment, with the following settings: 

- Docker Image & Tag to run on the task.
- Amount of CPU & memory to allocate.
- Port mappings.
- Environment variable configuration, (database configuration)
- EFS volume that contains Wordpress customized files.

TODO:
- [ ] Configurable instance type
- [ ] Configurable min, max & desired capacity.

### EFS
EFS is used to maintain customized Wordpress files uploads, plugins and themes.

NOTE: 
Mounting EFS as R+W for every running instance might sound scary but actually performs very well.

TODO:
- [ ] Using S3 / Cloudfront for assets & uploads would be a better solution.
- [ ] We might also mount EFS volumes on an instance responsible for the backups.
- [ ] Does EFS generalPurpose performance mode meet all use cases requirements?
- [ ] VPC's default Security Group is used to match ECS cluster's instances but it should have its own, properly grained.

### RDS
An RDS (mariadb) instance will be created as wordpress provisioned database

TODO:
- [ ] There is no database's special params configuration, we are using defaults.
- [ ] Many RDS options should be configurable: Instance type, Storage size, Maintenance & Backup windows.
- [ ] Hashicorp vault deployment to store secrets (database password)

# How did you run your project?
Actually I've been trying to leverage the usual approach of using a bash file or make, etc. to run both build & provisioning. I ran into some open issues like [this](https://github.com/hashicorp/terraform/issues/2789) and [this](https://github.com/hashicorp/terraform/issues/1586) found out that there is nothing better at the moment.

### Requirements
```
Terraform v0.12.5
Packer v1.4.1
aws-cli v1.16.200
```

### Usage
To provision all the infrastructure & resources, run the following command on the repository root:
```
make provision name=<wordpress_name>
```

To destroy all the infrastructure created run:

```
make destroy name=<wordpress_name>
```

# What are the components interacting with each other?
There is an issue described on the following section "What problems did you encounter", related to components interaction:

### Egg & chicken problem with packer builds vs terraform provisioning 
The ECS task needs a built docker image to run, and you need an ECR repository to hold the Docker image

My first intention was to provision all the infrastructure at once (Including the ECR repository), but ended up spliting the terraform provision in two steps:

- ECR provisioning.
- Packer docker image & push to the ECR repository.
- Provision ECS cluster, RDS, etc. 

I'm using the ansible provisioner to "configure" the docker image, but I wouldn't use ansible and I would perform a docker build (alone)

### Wordpress application configuration
The configuration for Wordpress is provided either by the ansible provisioner or ENV VAR configuration available on the official Wordpress docker image.

### Wordpress application plugins (and uploads)
This requires a special metion as Wordpress needs to change its own files, when updating plugins, this could be done on the building side (but Wordpress users use the plugin section to perform updates), so I've provided an EFS filesystem for the deployment that keeps Wordpress "customized" files. This component relation is commented later as it does have possibl enhacenments and its suitable for a more advanced strategy.
 
# What problems did you encounter?
### Terraform complexity
The whole terraform file structure has quickly become complex to maintain & document due the number of moving parts needed for the project. 

### Egg & chicken problem with packer builds vs terraform provisioning 
We would need the ECR repository to push the image built on packer and we need the image to provision the ECS task.

# How would you have done things to have the best HA/automated architecture?
Wordpress has its own tricks (and pains) for HA / automation, taking into account some of the problems described on "What problems did you encounter?", I would add the following things:

### Wordpress plugin & upload file stratetgy 
As mentioned earlier, on this example I'm using a EFS volumen mounted to all the running instances (as R+W) to provision wordpress files.

This was needed for uploads, plugins, assets, etc files. But more work needs to be done to meet requirements for HA/automation.
- Using S3 / Cloudfront for assets & uploads would work perfectly.
- Mounting EFS as R+W for every running instance might sound scary but I've used it performing nice on a similar use case (wordpress perform the uploads on a single request).
- We might also mount EFS volumes on an instance responsible for the backups. 

### Using ElastiCache to keep PHP sessions
We would have to use Redis to keep the PHP sessions when running multiple instances of the Wordpress application.

### Use databases on HA
Primarily use Multi-AZ deployments for the RDS instance, but also the previously mentioned ElastiCache instance.

### Use a different tool than ECS
Personally I feel more confortable using Kubernetes over ECS, although both share almost the same characteristics / issues for this use case.

# Share with us any ideas you have in mind to improve this kind of infrastructure
In order to create a "real" Wordpress provisioner there are some details that should be improved:

### Configure Amazon WAF
Enable [Amazon WAF](https://aws.amazon.com/marketplace/solutions/security/waf-managed-rules) for enhanced protection.

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

### Hashicorp Vault
Use Hashicorp vault for secrets storing and retrieval within the ECS instance & provisioning.

### Use FPM instead of Apache
I'm using Apache deployment as it does simplifies my configuration, but FPM has a lower memmory footprint and improved CPU usage.

### Give the option to enable / use NewRelic or any other APM tool
Probably a little bit complex to provision as it requires API Keys, etc. but It would be a nice tool for application monitoring.

### Adding a troubleshooting instance 
In order to provide support while on-call with incidents I would add an troubleshooting instance (probably not an instance but a running docker image) with some tooling like:

- [`innotop`](https://github.com/innotop/innotop) for database monitoring. 
- Wordpress CLI 
- Custom scripts
