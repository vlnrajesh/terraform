resource "docker_container" "nginx" {
  name = var.nginx_container_name
  image = "${var.nginx_container_name}:${var.nginx_image_tag}"
  restart = "on-failure"
  must_run = "true"
  ports {
    internal = var.nginx_port
    external = var.nginx_port
  }
  volumes {
    container_path = "/etc/nginx/conf.d"
    host_path = var.nginx_config_path
    read_only = false
  }
  volumes {
    container_path = "/var/log/nginx"
    host_path = var.nginx_logs_directory
    read_only = false
  }
  volumes {
    container_path = "/etc/nginx/nginx.conf"
    host_path = var.nginx_conf_file
    read_only = true
  }
  volumes  {
    container_path = "/usr/local/nginx/html"
    host_path = var.nginx_default_site_path
    read_only = true
  }
}