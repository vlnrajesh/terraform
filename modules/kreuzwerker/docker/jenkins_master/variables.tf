variable "jenkins_container_name" {
  type      = string
  default   = "jenkins-master"
}
variable "jenkins_image_name" {
  type      = string
  default   = "vlnrajesh/jenkins"
}
variable "jenkins_image_tag" {
  type      = string
  default   = "latest"
}
variable "jenkins_port" {
  type      = number
  default   = 8080
}

variable "jenkins_local_path" {
  description       = "Local directory defined for jenkins files"
  type              = string
  default           = "/opt/data/jenkins/master"
}
