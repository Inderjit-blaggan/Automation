#!/bin/bash
Tag_key="Application"
Tag_Value="jasper"
erp_accounts=("630034004811")
for (( n=0; n<=0; n++ ))
do
    echo "Instances in account number: ${erp_accounts[$n]} "
    instance_id=$(aws ec2 describe-instances  --region us-east-2  --profile ${erp_accounts[$n]} \
    --query "Reservations[*].Instances[*].{Instance:InstanceId,Instace_type:InstanceType,AZ:Placement.AvailabilityZone,Name:Tags[?Key=='Name']|[0].Value}"  --output json \
    --filters "Name=tag:Name,Values=*-jasper"   | grep 'i-' |  awk '{print $2}' | tr -d '"' | tr -d ',')
    echo "${instance_id}"
    aws ec2 create-tags  --resources  ${instance_id} --tags Key=$Tag_key,Value=$Tag_Value  --profile ${erp_accounts[$n]}   --region us-east-2   
    aws ec2 describe-tags     --filters "Name=resource-id,Values=${instance_id}"  --region us-east-2  --output table --profile ${erp_accounts[$n]} # | grep Application
done
#aws ec2 create-tags  --resources  ${instance_id[$n]} --tags Key=$Tag_key,Value=$Tag_Value  --profile ${erp_accounts[$n]}   --region us-east-2