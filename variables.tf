
variable "github_org" {
  default = "ministryofjustice"
}

variable "image" {}

variable "artifact_store" {}

variable "branch" {}

variable "github_token" {
  default = ""
}

variable "project" {}

variable "spec_location" {}

variable "app" {}

variable "docker_build_image" {
  default = "ubuntu"
}
