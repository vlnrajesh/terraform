MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="//"

--//
Content-Type: text/x-shellscript; charset="us-ascii"
#!/bin/bash
set -x
TOKEN=$(curl --request PUT "http://169.254.169.254/latest/api/token" --header "X-aws-ec2-metadata-token-ttl-seconds: 3600")
IP_ADDRESS=$(curl http://169.254.169.254/latest/meta-data/local-ipv4 --header "X-aws-ec2-metadata-token: $TOKEN")
TAG_SUFFIX=$(echo $IP_ADDRESS | awk -F. '{print $3"_"$4}')
INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id --header "X-aws-ec2-metadata-token: $TOKEN")
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone  --header "X-aws-ec2-metadata-token: $TOKEN" | sed -e "s/.$//")
TAG_VALUE=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=NodeGroupName" --region=$REGION --output=text | cut -f5)
aws ec2 create-tags --resources ${INSTANCE_ID} --tags Key="Name,Value=${TAG_VALUE}_${TAG_SUFFIX}" --region=$REGION
