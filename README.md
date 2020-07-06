Terraform AWS CodeBuild / CodePipeline (Firebreak Ticket: For POC / Investigation only)

Issue URL: https://github.com/ministryofjustice/cloud-platform/issues/1996
==========

Configuration in this directory creates a set of CodePipeline / CodeBuild resources.

Background of AWS CodeBuild / CodePipeline
=====


This module will create two key AWS terraform resources. (aws_codebuild_project and aws_codepipeline). 

AWS CodeBuild

Broadly speaking, 'CodeBuild' (created by the 'aws_codebuild_project' terraform resource) defines the environment of the pipeline such as the following:

* Executor - The docker image to be used by the pipeline

* Build specification location - This is a yaml file that defines the pipeline. It must be located somewhere in the soure GitHub repository

* Compute Type - AWS CodeBuild provides build environments wih varying degrees of memory, vCPU and disk space. These are categorised. For example 
                 if you specify 'BUILD_GENERAL1_SMALL' as the compute type value then this will provide you with 3 GB memory, 2 vCPUs and 64GB disk space.
                 for more on compute type values, visit: https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-compute-types.html


AWS CodePipeline

The AWS CodePipeline is created by the 'aws_codepipeline' terraform resource and consists of two stages (Source and Build). Below is a summary of these two stages:

Source:

* Provider - As the name implies the 'Source' stage defines the source of the build, which is defined by the 'provider' parameter. 
           For example if the provider is GitHub then the source is a GitHub repository. As well as GitHub there are a number of other 'providers' that AWS supports as well such as ECR and S3. For more on AWS source providers visit: https://docs.aws.amazon.com/codepipeline/latest/userguide/reference-pipeline-structure.html

* Configuration - The 'configuration' section are the arguments that define and validate the 'provider' and so they will vary depending upon what type of 'provider' is
                  specified. For example if 'GitHub' is chosen as the provider then the configuration will be as follows:

                  ```hcl
                        configuration = {
                            Owner                = var.github_org
                            Repo                 = var.project
                            PollForSourceChanges = "true"
                            Branch               = var.branch
                            OAuthToken           = var.github_token
                        }   
                   ```

Build:

* Input / Output Artefacts - The 'Build' stage of the CodePipeline is the stage that actually does the execution of the pipeline.
                            In AWS CodePipeline the stages (Source and Build) are able to reference each other by using output / input artefact arguments. 
                            For example the 'Source' stage will always provide an 'output_artifacts' argument for the 'Build' stage to reference as an 'input_artifact'. For more on the usage of Input / Output artefacts, visit: https://docs.aws.amazon.com/codepipeline/latest/userguide/welcome-introducing-artifacts.html

* Configuration - Just like the 'Source' stage has a 'Configuration' so to does the 'Build' stage. The configuration of the Build stage concerns the 'pipeline' itself such as allowing the ability to inject environment variables into the build specification pipeline. 

Deploy: 

There is also a third stage of 'Deploy', however this is usually required when the deployed target is an AWS resoure such as EC2. In most cases in particular when dealing 
with building from source code such as GitHub, going as far as the build stage suffices. 

Authentication against AWS / Kubernetes

Authentication for AWS CodeBuild / CodePipeline against AWS and a Kubernetes cluster (created either by EKS or KOPS) is simply done by assigning these resources to an 
appropriate IAM role that has the right permissions to deploy the AWS resources as defined in the terraform templates being executed by the pipeline. Likewise the appropriate permissions must be set to allow access to KOPS and EKS for the pipeline to interact with the kubernetes cluster as specified by the 'cluster_name' argument

Usage
==========

```hcl

module "example_codepipeline" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-codepipeline?ref=v1.0"
  artifact_store = "<S3_BUCKET_NAME>"
  cluster_name = "<CLUSTER_NAME>"
  cluster_state_bucket = "<CLUSTER_STATE_BUCKET>"
  kops_state_store = "<KOPS_STATE_STORE>"
  branch = "<BRANCH>"
  project = "<GITHUB_REPO_NAME>"
  app = "<APP_NAME>"
  image = "<DOCKER_IMAGE>
  spec_location = "<BUILD_SPEC_LOCATION>"
  github_token = "<GITHUB_TOKEN>"
  compute_type = "BUILD_GENERAL1_SMALL"

  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }
}

```

The above module, when run will provision both the 'CodeBuild' and 'CodePipeline' resources. Below is an explanation of the parameters passed into the module: 

  artifact_store - Bucket that is to store the output artefacts of the 'source' stage of the CodePipeline resource 

  cluster_name - Cluster to be used for any kubernetes resources created by the pipeline. Also used as the VPC ID for any AWS resources that require a VPC ID

  cluster_state_bucket - Location of the state file of the above 'cluster_name'. e.g "cloud-platform-terraform-state"

  kops_state_store = Applicable if the kubernetes cluster is created by KOPS. If so then the location of its state needs to be specified e.g "s3://cloud-platform-kops-state"

  branch - Branch that is to be checkout by the pipeline

  project - GitHub repository name

  app - This can be any value that appropriately defines the application created by the source code

  image - The docker image used as the executor by the pipeline e.g "ministryofjustice/cloud-platform-tools:1.18"

  spec_location - Location of the pipeline specification file that defines the pipeline. Must reside in the GitHub repository being checked out e.g 
                  if you locate this file in the root directory under a folder called 'build' then the value would be: 'build/buildspec.yml

  github_token - GitHub token to allow AWS to authenticate against GitHub to checkout the repo (for this reason the file calling this module should be git-crypted)

  compute_type - Size of the executor


To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Once executed as above you should see the CodeBuild and CodePipeline resources created in the AWS console. The output of the pipeline can be viewed in CodePipeline's details

