#!/bin/bash
#
# Purpose: Remove leftover ControlTower resources in order to prepare Re-registration into the OU 
# Notice : WARNING this script will damage your account - use with care!
# Author : Leroy van Logchem
# Assumed: Can be used in the AWS CloudShell environment (no install requirements)
#

MASTERACCOUNT=888888888888 # <- CHANGE ME

for region in $(aws ec2 describe-regions | jq -r .Regions[].RegionName | grep -E -v "^(ap-)|(ca-)|(sa-)" | sort)
do
        export AWS_REGION=$region
        echo "Region = $region"
        for i in $(aws --region=$region cloudformation describe-stacks | jq -r '.Stacks[].StackName')
        do
                echo "Stack $i"; aws cloudformation delete-stack --stack-name $i;
        done
        echo "AWS Config = $region"
        aws --region=$region configservice describe-aggregation-authorizations
        aws --region=$region configservice delete-aggregation-authorization --authorized-account-id $MASTERACCOUNT --authorized-aws-region "$region"
        aws --region=$region events list-rules | jq -r .Rules[].Name
        echo "Events = $region"
        for rule in $(aws --region=$region events list-rules | jq -r .Rules[].Name)
        do
                aws --region=$region events delete-rule --name $rule
        done

done
