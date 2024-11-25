# EKS Cluster Terraform Configuration

This directory contains Terraform configurations for provisioning and managing an Amazon Elastic Kubernetes Service (EKS) cluster on AWS. The configurations are organized into modules and main files to ensure modularity and maintainability.

## Abstraction modules
In terraform "wrapper" is a colloquialism that refers to modules that don't actually create or manage any infrastructure resources. Instead, they often provide a higher-level abstraction, customization, or extension of an existing module or resource.

### addons.tf

Installs AWS provided Addons on top of the EKS cluster.

1. Fetch list of add-ons to be added from a map variable `addons` pinned to a specific version, and install them recursively
2. Install **EFS-CSI-Driver** by importing `./modules/efs-csi-driver` submodule if `var.efs_csi_driver` is set to true
   1. Creates IAM role for with STSAssumeRoleWebIdentity
   2. Attaches EFSCSIDriverPolicy managed policy to the above role
   3. Install `aws-efs-csi-driver` add-on to the current cluster
3. Install **Secrets-store-csi** by importing `./modules/secrets-store-csi` submodule
   1. Create IAM role for Secret store csi driver
   2. Create a custom policy for accessing secrets and ssm parameters 
   3. Attach the above created custom policy(step-2) to iam role(step-1)
   4. Install secrets-store-csi-driver helm chart by setting cluster name and sync secrets
   5. Install secrets-provider-aws helm chart by setting cluster name and toleration operator
4. Install **Ingress controllers** by import `./modules/ingress-controllers` submodule if `alb_ingress_controller` option is set to true
   1. Create IAM role for ingress controllers
   2. Create IAM policy with access to elasticloadbalancing resource access
   3. Create a service account `alb-ingress-controller` in the current cluster under `kube-system` namespace and attach the IAM role create at step-1.
   4. Install `aws-load-balancer-controller` community helm chart by setting cluster name
   5. Install `ingress-nginx` community helm chart by setting `controller.service.type` as `ClusterIP` 
5. Create a **GP3** storage class for persistence volumes with fs-type as ext4 and throughput as 500 

### cluster.tf

Defines the primary resources for provisioning an EKS cluster, including IAM roles, CloudWatch logs, VPC configurations, and more.

1. Create IAM role for EKS cluster
2. Attach various managed IAM policies for the cluster such as EKSService, EKSCluster and EFS policy
3. Create a Cloudwatch log group for the cluster to save access logs and audit logs with fixed retention period
4. Create a security group for the cluster with all egress is opened
5. Create a eks-cluster in public subnet(s) in a given VPC and attach the IAM role and log group created above
6. Update Ec2 tags with `internal-elb` as _**1**_ ELB provision for all private load balancers 
7. Update EC2 tags with `cluster_name` as _**shared**_ to be identified by the node provisioners for creating instances under private subnets
8. Update EC2 tags with `cluster_name` as _**shared**_ to be identified by the node provisioners for creating instances under public subnets
9. Fetch TLS certificate from the cluster and openid provider

### fargate_profile.tf

Defines resources to set up an AWS Fargate profile for an Amazon EKS cluster. Fargate profiles allow you to run Kubernetes pods on Fargate, a serverless compute engine for containers.

1. Creates an IAM role for the Fargate profile.
2. Attaches the Amazon EKS Worker Node Policy to the Fargate profile's IAM role
3. Attaches the Amazon EKS CNI Policy to the Fargate profile's IAM role
4. Tags the private subnets with the Kubernetes.io/cluster tag set to the cluster name.
5. For each Fargate Profile specified in the Profiles list, `fargate_profile` will create an AWS EKS Fargate Profile resource with a unique name and corresponding selectors.

### helm_installations.tf

Installs third-party helm charts in a given cluster

1. Installs metrics-server helm-chart by setting `apiService.create` to `true`
2. Install cluster-autoscaler helm-chart by setting the `awsRegion` and `autoDiscovery` enabled

### karpenter.tf

Creates in-time auto-scaler node configuration for EKS cluster

1. Define provider of for `us-east-1`
2. Create ECR public authorization token for `us-east-1`
3. Create kubernetes namespace for karpenter resources
4. Create kubernetes service account 
5. Installation of karpenter helm chart and overwrite default values such as service account name, enable service monitor, and controller resources

### locals.tf

Defines local variables and data sources used across the Terraform configurations, including AWS caller identity, current region, and availability zones.

### nodes.tf

Contains configurations to manage the AWS EKS worker nodes, associated IAM roles and policies, security groups, and Kubernetes environment variables.

1. Create an IAM role for  worker nodes 
2. Attach managed iam policies for worker node role
3. Create custom iam policy for CAS node group
4. Create custom iam policy for Karpenter node group
5. Attach custom iam policies created above worker nodegroup
6. Create a security group for nodes to get attached to nodes
7. Allow ingress traffic from all un-privileged ports between nodes
8. Allow all egress traffic from nodes
9. Upsert the SSM parameter with the node iam role
10. Update kubernetes environment variable `aws-node` to allow K8s CNI SNAT for allowing internal pods to access internet via NAT gateway
11. Create CAS nodes based on each section of data dictionary `cas_groups` by importing a sub-module `./modules/cluster-auto-scaler`
    1. Create custom cloud-init script to set the custom hostname such as cas-group-name+ last two octate of primary ip address
    2. Create AWS Launch templates for the node group with given specifications and attach the cloud-init
    3. Creates AWS eks node group with the launch template provided along with taint, instance class  and auto-scaling capabilities 
12. Updated all private subnets tags with essential karpenter discovery keys 
13. Create Karpenter nodepool and node classes for each section of data dictionary `karpenter_pools` 
    1. Create a kubernetes manifest for each node_class with essential details such as AMI family, cluster details
    2. Create a kubernetes manifest for each node_pools with essential details such as instance type and CPU and memory limits

### outputs.tf

Specifies outputs to display after applying the Terraform configurations, such as cluster details, IAM roles, and SSM parameter values.

1. `cluster_role_arn`: Outputs the ARN (Amazon Resource Name) of the IAM role associated with the EKS cluster.
2. `security_group_id`: Outputs the ID of the security group created for the EKS cluster.
3. `endpoint`: Outputs the endpoint URL of the EKS cluster's Kubernetes API server.
4. `cluster_name`: Outputs the name of the EKS cluster.
5. `openid_connector_provider`: Outputs the OpenID Connect (OIDC) provider URL associated with the EKS cluster.
6. `version`: Outputs the Kubernetes version of the EKS cluster.
7. Upsert SSM parameters with oidc_provider and cluster names 


## Deployment Instructions:


### Environment specific variables
Please confirm yourself, before proceeding with deployment these values are set and available for the respective environment
Here is a rephrased version of the sentence:
It's recommended to use a separate tfvars under `env-tfvars` directory to store and manage your variable sets in an organized and easily accessible manner

| **Name**               | **Value**  | **Default** | **Description**                  |
|------------------------|------------|-------------|----------------------------------|
| create_fargate_profile | false/true | False       | For enabling Fargate deployments |
| fargate_profile        | Map        | N/A         | Define the fargate profile(s)    |
| efs_csi_driver         | false/true | False       | For enabling EFS storage class   |
| cas_groups             | Map        | N/A         | Define CAS node groups           |
| karpenter_pools        | Map        | N/A         | Define karpenter node groups     |

### Operator console/terminal

For any given environment such as beta, dev, uat and so on please run the `Make` targets in the below order

**Note:** If any application suite is missing please contact [DevOPS Team](mailto:devops@prismforce.in?subject=[Terraform]%20Missing%20Application%20Target)  

1. Ensure `networking` target executed successfully before proceeding with `eks-cluster` 

```commandline
make terraform-plan  'env=<ENV>' 'app=networking'
make terraform-apply 'env=<ENV>' 'app=networking'
```
2. Ensure `eks-cluster` target executed successfully before proceeding with `common` 

```commandline
make terraform-plan  'env=<ENV>' 'app=eks-cluster'
make terraform-apply 'env=<ENV>' 'app=eks-cluster'
```