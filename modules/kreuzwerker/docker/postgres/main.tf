resource "docker_container" "postgres" {
  name = "${var.postgres_container_name}"
  image = "${var.postgres_image_name}:${var.postgres_image_tag}"
  restart = "on-failure"
  must_run = "true"
  ports {
    internal = "${var.postgres_db_port}"
    external = "${var.postgres_db_port}"

  }
  volumes {
    container_path = "${var.pgdata_container_path}"
    host_path = "${var.pgdata_local_path}"
    read_only = false
  }
  env = [
    "POSTGRES_USER=${var.postgres_username}" ,
    "POSTGRES_PASSWORD=${var.postgres_password}"
  ]
}
