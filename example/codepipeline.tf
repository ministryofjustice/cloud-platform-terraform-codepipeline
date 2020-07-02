/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "example_codepipeline" {
  #source = "github.com/ministryofjustice/cloud-platform-terraform-codepipeline?ref=v1.0"
  source = "../"
  artifact_store = "cloud-platform-75a32f02f75ca295a03251328669dc68"
  cluster_name = "jb-test-2"
  cluster_state_bucket = "cloud-platform-terraform-state"
  kops_state_store = "s3://cloud-platform-kops-state"
  branch = "pipeline"
  project = "cloud-platform-imran-test"
  app = "demo"
  image = "ministryofjustice/cloud-platform-tools:1.15"
  spec_location = "build/buildspec.yml"

  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }
}