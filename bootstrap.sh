#AWS
confirm () {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [y/N]} " response
    case $response in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}


function which-aws {
    echo "You are on an AWS account with alias(es)" `aws iam list-account-aliases | jq '.AccountAliases | join(",")' -r` | cowsay
}

function cfn-describe {
   aws cloudformation describe-stacks --stack-name "$1" | jq .
}

function cfn-delete {
    confirm && aws cloudformation delete-stack --stack-name "$1"
}

function cfn-status {
    aws cloudformation list-stacks | jq ".StackSummaries | map(select(.StackName==\"$1\")) | map([.CreationTime,.StackStatus]) | map(join(\" \")) | join(\"\n\")" -r
}

function cfn-by-status {
    aws cloudformation list-stacks  --stack-status-filter $1 | jq .
}

function cfn-resources {
    aws cloudformation list-stack-resources --stack-name "$1" | jq .
}

function cfn-logs {
    aws cloudformation describe-stack-events --stack-name "$1" | jq '.StackEvents | map({Timestamp,ResourceType,ResourceStatus,ResourceStatusReason})'
}

function s3-bucket-policy {
    aws s3api get-bucket-policy --bucket "$1" | jq .Policy -r | jq .
}

function s3-put-something {
    fortune art > /tmp/something.txt
    aws s3 cp /tmp/something.txt $1
}

function cfn-grep {
    aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE | jq '.StackSummaries | map(select(.StackName | contains ($stackname)))' --arg stackname $1
}

function cfn-template {
    aws cloudformation get-template  --stack-name $1 | jq .
}

function cfn-endpoints {
    cfn-resources $1 | jq '.StackResourceSummaries | map(select(.ResourceType=="AWS::Route53::RecordSet")) | map(.PhysicalResourceId)[] ' -r 
}

function cfn-asg {
    cfn-resources $1 | jq '.StackResourceSummaries | map(select(.ResourceType=="AWS::AutoScaling::AutoScalingGroup")) | map(.PhysicalResourceId)[] ' -r     
}

function cfn-instance {

    aws ec2 describe-instances --filter Name=tag:aws:cloudformation:stack-name,Values=$1 | jq ".Reservations[].Instances[] | {State: .State.Name, PrivateIp: .NetworkInterfaces[].PrivateIpAddresses[].PrivateIpAddress, InstanceId: .InstanceId, ImageId: .ImageId}"
}


function asg-inc {
    aws autoscaling set-desired-capacity --desired-capacity 1 --auto-scaling-group-name $1
}

function asg-describe {
    aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $1 | jq .
}

function ec2-desc {
    aws ec2 describe-instances --instance-id $1
}

function asg-instances {
    aws ec2 describe-instances --filter Name=tag:aws:autoscaling:groupName,Values=$1 | jq ".Reservations[].Instances[] | {State: .State.Name, PrivateIp: .NetworkInterfaces[].PrivateIpAddresses[].PrivateIpAddress, InstanceId: .InstanceId, ImageId: .ImageId, SubnetId: .NetworkInterfaces[].SubnetId}"
}


function latest-metrics {
    start_time=`gdate +"%Y-%m-%dT%H:%M:%S.%3N%z" -d "80 minutes ago"`
    end_time=`gdate +"%Y-%m-%dT%H:%M:%S.%3N%z"`
    aws  cloudwatch  get-metric-statistics  --metric-name $2  --start-time  $start_time   --end-time   $end_time  --period 60 --namespace $1 --statistics Maximum | jq .
}

function vpc-subnets {
    aws ec2 describe-subnets --filter Name=vpc-id,Values="$1" | jq .
}

function cfn-params {
    cfn-describe $1 | jq .Stacks[].Parameters
}

function ami-describe {
    aws ec2 describe-images --image-ids $1 | jq .
}

function ami-tagged {
    aws ec2 describe-images --filter Name=tag:$1,Values=$2 | jq .
}

function ami-with-tag {
    aws ec2 describe-images --filter Name=tag-key,Values=$1 | jq .
}

function ami-with-tag {
    aws ec2 describe-images --filter Name=tag-key,Values=$1 | jq .
}

function ami-with-name {
    aws ec2 describe-images --filter Name=name,Values=$1 | jq .
}

function vpc-az-subnets {
   aws ec2 describe-subnets --filter Name=vpc-id,Values="$1" Name=availabilityZone,Values=$2 | jq .
}

function subnet-describe {
   aws ec2 describe-subnets --subnet-ids $1 | jq .
}

function asg-instance-terminate {
    confirm
    aws autoscaling terminate-instance-in-auto-scaling-group --instance-id $1 --no-should-decrement-desired-capacity
}

function s3-bucket-grep {
    aws s3 ls | grep $1
}

function emr-runtime {
     aws emr describe-cluster --cluster-id $1 | jq "(.Cluster.Status.Timeline.EndDateTime - .Cluster.Status.Timeline.ReadyDateTime) / 60 / 60"
}
