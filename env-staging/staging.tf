provider "aws" {
    region = "us-east-1"
}

data "aws_availability_zone" "staging" {
    name = "us-east-1a" 
}

# variable "environment" {}

module "kafka" {
    source = "../modules/kafka"

    availability_zone = "${data.aws_availability_zone.staging.name}"

    # Network and User configuration
    environment = "fruit-loops"
    app_name = "kafka"

    iam_instance_profile = "OpsTools"
    subnet_ids = ["subnet-c19f3bee"]
    static_subnet_ids = ["subnet-c19f3bee"]
    security_group_ids = ["sg-8ca35bc5"]

    # Bastion machine information where the SSH can happen
    bastion_ip = "35.171.26.242"
    bastion_private_key = "~/Downloads/keylimepie.pem"
    bastion_user = "ec2-user"
    private_key = "~/Downloads/keylimepie.pem"

    # Kafka cluster configuration
    key_name = "keylimepie"
    kafka_ami = "ami-1853ac65"
    kafka_instance_type = "m5.large"
    kafka_version = "1.1.0"
    kafka_user = "ec2-user"
    log_retention = "10"  # in hours
    num_partitions = 30
    brokers_per_az = 3

    # Zookeeper configuration
    zookeeper_instance_type = "t2.medium"
    zookeeper_addr = 50                 //// <--- need to figure out a way to change dynamically
    zookeeper_ami = "ami-1853ac65"
    zookeeper_user = "ec2-user"

    # Cloudwatch SNS Topic Notification
    cloudwatch_alarm_arn = "arn:aws:sns:us-east-1:489114792760:Kafka"
}

module "nrc" {
    source = "../modules/nrc"

    environment = "staging"

    nrc_instance_count = 1
    docker_image_tag = "staging"
    kafka_brokers = "${module.kafka.first_kafka_broker}"
}