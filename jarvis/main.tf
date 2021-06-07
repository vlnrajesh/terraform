//module "nginx_deploy" {
//  source = "./infrastructure/nginx"
//}

module "postgres_deploy" {
  source = "./infrastructure/postgres"
}


//resource "docker_container" "nginx-server" {
//  name = "nginx-server-1"
//  image = "nginx:latest"
//  ports {
//    internal = 80
//    external = 80
//  }
//  volumes {
//    container_path  = "/usr/share/nginx/html"
//    host_path = "/tmp/tutorial/www"
//    read_only = true
//  }
//}