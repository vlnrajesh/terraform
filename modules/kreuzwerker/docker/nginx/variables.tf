variable "nginx_container_name" {
  type      = string
  default   = "nginx"
}
variable "nginx_image_name" {
  type      = string
  default   = "nginx"
}
variable "nginx_image_tag" {
  type      = string
  default   = "latest"
}
variable "nginx_port" {
  type      = number
  default   = 80
}

variable "nginx_config_path" {
  description       = "Nginx configuration directory"
  type              = string
  default           = "/opt/data/nginx/conf.d"
}

variable "nginx_logs_directory" {
  description       = "Nginx Logs directory"
  type              = string
  default           = "/opt/data/nginx/logs"
}
variable "nginx_conf_file" {
  description       = ""
  type              = string
  default           = "/opt/data/nginx/nginx.conf"
}
variable "nginx_default_site_path" {
  description       = ""
  type              = string
  default           = "/opt/data/nginx/test_site/html"
}