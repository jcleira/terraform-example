AWS_ACCOUNT=017128164736
TERRAFORM_SHARED:=terraform/environments/shared
TERRAFORM_PATH:=terraform/environments/dev
PACKER_PATH:=packer

requirements:
ifndef name
	@echo A name is needed for the environment Ex: make provision name=wordpress
	exit 1
endif

ecr-login:
	eval $(aws ecr get-login --no-include-email)

provision: requirements provision-ecr ecr-login build-image provision-all

destroy: requirements destroy-ecr destroy-all

provision-ecr:
	cd $(TERRAFORM_SHARED) \
		&& terraform init \
		&& terraform apply -var 'name=$(name)'

destroy-ecr:
	cd $(TERRAFORM_SHARED) \
		&& terraform init \
		&& terraform destroy -var 'name=$(name)'

build-image:
	cd $(PACKER_PATH) \
		&& packer build \
		-var 'aws_account=$(AWS_ACCOUNT)' \
		-var 'name=$(name)' \
		wordpress.json

provision-all:
	cd $(TERRAFORM_PATH) \
		&& terraform init \
		&& terraform apply \
		-var 'aws_account=$(AWS_ACCOUNT)' \
		-var 'name=$(name)'

destroy-all:
	cd $(TERRAFORM_PATH) \
		&& terraform init \
		&& terraform destroy \
		-var 'aws_account=$(AWS_ACCOUNT)' \
		-var 'name=$(name)'
