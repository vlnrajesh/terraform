SHELL := /bin/bash
provisioner = scripts/provisioner.sh
app ?= ALL
#.HELP:		terraform-bootstrap   	Bootstrap terraform setup
terraform-bootstrap:
	$(provisioner) terraform-bootstrap
#.HELP:		terraform-init 		env=<ENVNAME> 	 app=<APPNAME:-ALL>		Initialize terraform with backend
terraform-init:
	$(provisioner) terraform-init $(env) $(app)

#.HELP:		terraform-verify 	env=<ENVNAME>  app=<APPNAME:-ALL> 		perform validation stages
terraform-verify: terraform-init
	$(provisioner) terraform-verify $(env) $(app)

#.HELP:		terraform-plan 		env=<ENVNAME> 	app=<APPNAME:-ALL>  		perform terraform plan stage
terraform-plan: terraform-verify
	$(provisioner) terraform-plan $(env) $(app)

#.HELP:		terraform-apply 	env=<ENVNAME> 	app=<APPNAME:-ALL> 		perform terraform apply stage
terraform-apply:
	$(provisioner) terraform-apply $(env) $(app)

#.HELP:		terraform-destroy 	env=<ENVNAME>  app=<APPNAME:-ALL>		perform terraform destroy stage
terraform-destroy: terraform-init
	$(provisioner) terraform-destroy $(env) $(app)
#.HELP:		help			Display this help message
help:
	@grep -E "^\#.HELP:" Makefile | grep -v ":default" | sed "s/#.HELP:/ /" | grep -v -E "^[[:space:]]*_" | sort