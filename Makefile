include chain.mk

.DEFAULT_GOAL := plan

export TF_STATE_NAME ?= $(CLUSTER_PREFIX)-$(ITERATION)

include $(ROOTDIR)/shared.mk

PROXY_TARGETS := \
	apply \
	destroy \
	format \
	init \
	kubeconfig \
	lint \
	plan \
	refresh \
	terraform
$(PROXY_TARGETS):
	@$(MAKE) -s main/$(@F)

GROUP_NAME ?= k8s
USER_NAME ?= $(CLUSTER_PREFIX).$(DNS_ZONE)
.PHONY: prepare-aws
prepare-aws:
	@$(AWS) s3api create-bucket \
		--bucket $(BACKEND_S3_BUCKET) \
		--region $(AWS_REGION)
	@$(AWS) s3api put-bucket-versioning \
		--bucket $(BACKEND_S3_BUCKET) \
		--versioning-configuration Status=Enabled
	@$(AWS) dynamodb create-table \
		--table-name $(BACKEND_DYNAMODB_TABLE) \
		--attribute-definitions AttributeName=LockID,AttributeType=S \
		--key-schema AttributeName=LockID,KeyType=HASH \
		--provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
		--region $(AWS_REGION)
	@$(AWS) iam create-group --group-name $(GROUP_NAME)
	@$(AWS) iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AWSKeyManagementServicePowerUser --user-name $(GROUP_NAME)
	@$(AWS) iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess --group-name $(GROUP_NAME)
	@$(AWS) iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly --group-name $(GROUP_NAME)
	@$(AWS) iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess --group-name $(GROUP_NAME)
	@$(AWS) iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess --group-name $(GROUP_NAME)
	@$(AWS) iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonEventBridgeFullAccess --group-name $(GROUP_NAME)
	@$(AWS) iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonRoute53FullAccess --group-name $(GROUP_NAME)
	@$(AWS) iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess --group-name $(GROUP_NAME)
	@$(AWS) iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonSQSFullAccess --group-name $(GROUP_NAME)
	@$(AWS) iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonVPCFullAccess --group-name $(GROUP_NAME)
	@$(AWS) iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/CloudWatchLogsFullAccess --user-name $(GROUP_NAME)
	@$(AWS) iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/IAMFullAccess --group-name $(GROUP_NAME)
	@( $(AWS) route53 list-hosted-zones | grep -q $(DNS_ZONE) && $(TRUE) ) || \
		$(AWS) route53 create-hosted-zone --name $(DNS_ZONE) --caller-reference $(shell date '+%s%N') || $(TRUE)
	@$(AWS) iam create-user --user-name $(USER_NAME)
	@$(AWS) iam add-user-to-group --user-name $(USER_NAME) --group-name $(GROUP_NAME)
	@$(AWS) iam create-access-key --user-name $(USER_NAME)

.PHONY: main/%
main/%:
	@$(MAKE) -sC main $*

-include $(call chain)
