/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "example_codepipeline" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-codepipeline?ref=v1.0"
  artifact_store = "<S3_BUCKET_NAME>"
  cluster_name = "<CLUSTER_NAME>"
  cluster_state_bucket = "<CLUSTER_STATE_BUCKET>"
  kops_state_store = "<KOPS_STATE_STORE>"
  branch = "<BRANCH>"
  project = "<GITHUB_REPO_NAME>"
  app = "<APP_NAME>"
  image = "<DOCKER_IMAGE>"
  spec_location = "<BUILD_SPEC_LOCATION>"
  github_token = "<GITHUB_TOKEN>"
  compute_type = "BUILD_GENERAL1_SMALL"

  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }
}