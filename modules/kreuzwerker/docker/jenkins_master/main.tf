resource "docker_container" "jenkins_master" {
  name      = var.jenkins_container_name
  image     = "${var.jenkins_image_name}:${var.jenkins_image_tag}"
  restart   = "on-failure"
  must_run  = "true"
  user      = 0
  ports {
    internal = var.jenkins_port
    external = var.jenkins_port

  }
  volumes {
    container_path = "/var/jenkins_home"
    host_path = var.jenkins_local_path
    read_only = false
  }
}