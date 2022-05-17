#!/bin/bash
# FUNCTION TO GET "ROLE" BY USING EC2 INSTANCES WITH CUSTOM TAG
get_instances_with_tag(){
    
    res=$(aws ec2 describe-instances --region us-east-2 --filters Name=tag:$1,Values=$2 --profile $3)
    
    #echo "res value: ${res}"
    roleARN=$(echo $res \
    | python3 -c "import sys, json; print(json.load(sys.stdin)['Reservations'][0]['Instances'][0]['IamInstanceProfile']['Arn'])")
    
    # echo $iamProfile
    
    roleName=${roleARN:43}
    echo $roleName
    #echo Role ARN is $roleARN
    
}

# FUNCTION TO GET "ROLE" BY USING EC2 INSTANCES WITH CUSTOM TAG

####### here key is tagtest and value is searchrolebythis

#get_instances_with_tag "Application" "jasper" 688162211510


# FUNCTION TO "ATTACH POLICY" TO A ROLE
attach_policy_to_role(){
    
    aws iam put-role-policy --role-name $1 --policy-name $2 --policy-document file://$3 --profile $4
    
}
# attach_policy_to_role $roleName  demopolicy "policy.json" 000699977340


# ADDS A CUSTOM ARN TO TRUST RELATIONSHIP OF THE ROLE
add_arn_in_trustrelationship(){
    
    part1='{ "Version": "2012-10-17", "Statement": [ { "Effect": "Deny", "Principal": { "Service": "ec2.amazonaws.com"'
    
    part2=',"AWS":["'
    
    randomARN=$1
    
    part3='"]'
    
    part4='}, "Action": "sts:AssumeRole" } ] }'
    
    finalPolicy=$part1$part2$randomARN$part3$part4
    echo $finalPolicy | jq "." > trustRelAcc1.json
    
    aws iam update-assume-role-policy --role-name $2 --policy-document file://trustRelAcc1.json --profile $3
    
    
    #To check if trust rel policy is added or not to role
    roleDetails=$(aws iam get-role --role-name $2 --profile $3)
    trustRelJSON=$(echo $roleDetails | jq ".Role.AssumeRolePolicyDocument")
    echo $trustRelJSON
    
}

inputarn="arn:aws:iam::000699977340:role/AmazonSSMRoleForInstancesQuickSetup"
# add_arn_in_trustrelationship $inputarn demoskp 000699977340


#jasper_working_Accouts=( "980758408536" "509704156812"    "263975693283"  "416029571919"  "23061712707"   "447378552641"  "867907917890"  "630034004811"  "804596621126"  "263975693283" "381188050020"  "975746488271"  "160513558103" )
# "261390753486"  "176309687584"  "99188235737"  "369556419013"  "27512332805"  "237840073416"  "744382122683"  "301465073021"  "594504648029" )
erp_accounts=(    "452460757919"  "281882301406"  "633759717959"  "312308075865"  "170895530469"  "898321658754"  "744028557743"  "404067826977"  "574828499418"  "391767297048"  "220632944928"  "520345425786"  "148656707384"  "259987506714"  "44647457783"  "848557332205"  "669223117140"  "246782364422"  "863095730804"  "458970401082"  "485312260899"  "657681547968"  "216191278443"  "819398422556"  "304851017013"  "545701820261"  "295494579406"  "741547339323"  "666717213534"  "664353777389"  "846016091089"  "781300432669"  "432062541160"  "897561502983"  "591212346577"  "554938577517"  "367276040723"  "288276583063"  "768545751310"  "404738986417"  "307762127893"  "445516054113"  "134284705459"  "928734777579"  "230999311295"  "171749804602"  "655091057032"  "688162211510"  "869562651934"  "562557054605"  "104837470211"  "661664821915"  "373275528530"  "395392661826"  "632294257753"  "116300961321"  "288053755200"  "883080883690"  "532781312430" )
function old_trust_policy_file_output {
python - <<END
import os
import json
import sys
old_policy=os.environ['PYTHON_ARG']
print("OLD Policy:")
print(old_policy)
END
}


function create_trust_policy {
python - <<END
import os
import json
import sys
os.environ['new_policy'] = ""
old_policy=os.environ['PYTHON_ARG']
#print(old_policy)


new_policy={
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::381203884180:role/snowflake_assume_role_for_multiaccount",
                    "arn:aws:iam::575672604269:role/envPage"
                ],
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
value="arn:aws:iam::381203884180:role/snowflake_assume_role_for_multiaccount"
value="jai mata di"
#print(int(len(new_policy["Statement"])))
"""
for i1 in range(int(len(new_policy["Statement"]))):
    #print(new_policy["Statement"][i1]["Principal"]["AWS"])
    if "AWS" in old_policy["Statement"][i1]["Principal"]:
        new_policy["Statement"][i1]["Principal"]["AWS"]=old_policy["Statement"][i1]["Principal"]["AWS"]
        new_policy["Statement"][i1]["Principal"]["AWS"].append(value)
    else:    
        new_policy=new_policy
        #print(new_policy)
"""
print(new_policy)    
     
END
}

for (( n=0; n<=63; n++ ))
do  
    echo "$(date)"
    echo "Code is getting applied on account:${erp_accounts[$n]} "
    role_name=$(get_instances_with_tag "Application" "jasper" "${erp_accounts[$n]}" | awk "{print $2}"  )
    echo "Role name for instance: ${role_name}"
    echo "Adding snowflake_prod_s3_policy"
    
    aws iam put-role-policy --role-name ${role_name} --policy-name snowflake_prod_S3_policy --policy-document file://jasper_s3_snowflake_policy.json --profile ${erp_accounts[$n]}
    trust_relationship_policy=$(aws iam get-role --role-name   EC2_servers --profile ${erp_accounts[$n]}) 
    trust_relationship_policy_temp=$(echo $trust_relationship_policy \
        | python3 -c "import sys, json; print(json.load(sys.stdin)['Role']['AssumeRolePolicyDocument'])")
    export PYTHON_ARG=$trust_relationship_policy_temp 
    old_trust_policy_file_output
    echo "Adding the new trust relatioship Policy:"
     #trust_relationship_final_policy=$(create_trust_policy)  
     #echo $trust_relationship_final_policy  | jq "." 
    echo "Applying new trust Policy:"
    aws iam update-assume-role-policy --role-name ${role_name} --policy-document file://jasper_trust_policy.json --profile  ${erp_accounts[$n]}
    instance_id=$(aws ec2 describe-instances  --region us-east-2  --profile ${erp_accounts[$n]} \
    --query "Reservations[*].Instances[*].{Instance:InstanceId,Instace_type:InstanceType,AZ:Placement.AvailabilityZone,Name:Tags[?Key=='Name']|[0].Value}"  --output json \
    --filters "Name=tag:Name,Values=*-jasper"   | grep 'i-' |  awk '{print $2}' | tr -d '"' | tr -d ',')
    echo "Adding config file to ${instance_id}"
    aws ssm send-command  --document-name "AWS-RunShellScript" \
    --parameters "commands=['wget https://ferp-build.s3.amazonaws.com/jasper_config_awscli.sh','sh jasper_config_awscli.sh']" \
    --profile  ${erp_accounts[$n]}  --region us-east-2 --targets "Key=instanceids,Values=${instance_id}"     --comment "Adding config file" > /dev/null
    iam=$(aws iam get-role     --role-name ${role_name}  --profile ${erp_accounts[$n]} | grep Arn  | awk "{print $2}" | tr -d '"')
    echo "${iam:13}"   >> arn.json

    echo " "
    echo "----------------------------------------------------------------------------------------------------------------------------------"
done
