
resource "docker_container" "nginx-service" {
  name = "nginx-server-1"
  image = "nginx:latest"
  ports {
    internal = 80
    external = 80
  }
  volumes {
    container_path  = "/usr/share/nginx/html"
    host_path = "/tmp/tutorial/www"
    read_only = true
  }
}