terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = ">= 2.0.0" // Specify the version or version constraint here
    }
    
    // If you are using the Kong provider, you should also specify it here
    kong = {
      source  = "kevholditch/kong"
      version = ">= 0.14.0" // Specify the version or version constraint for the Kong provider
    }

    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 2.13.0"
    }
  }
}

provider "local" {
  // Configuration options for the local provider (if any)
}

resource "docker_image" "kong" {
  name = "kong:latest" // You can specify a specific version instead of "latest"
}

resource "docker_container" "kong" {
  image = docker_image.kong.image_id

  name  = "kong"

  ports {
    internal = 8000
    external = 8000
  }

  ports {
    internal = 8443
    external = 8443
  }

  ports {
    internal = 8001
    external = 8001
  }

  ports {
    internal = 8444
    external = 8444
  }

   env = [
    "KONG_DATABASE=off",
    "KONG_PROXY_ACCESS_LOG=/dev/stdout",
    "KONG_ADMIN_ACCESS_LOG=/dev/stdout",
    "KONG_PROXY_ERROR_LOG=/dev/stderr",
    "KONG_ADMIN_ERROR_LOG=/dev/stderr",
    "KONG_ADMIN_LISTEN=0.0.0.0:8001, 0.0.0.0:8444 ssl",
    "KONG_PLUGINS=my-plugin",
    "KONG_DECLARATIVE_CONFIG=/config/kong.yml",
  ]
  
  // Mound plugin code
  volumes {
    host_path      = "/${abspath(path.module)}/../../kong/plugins/my-plugin"
    container_path = "/usr/local/share/lua/5.1/kong/plugins/my-plugin"
  }
  // Mount a volume if you have a local declarative configuration file for Kong
  volumes  {
    host_path      = "${abspath(path.module)}/kong.yml"
    container_path = "/config/kong.yml"
  }

  command = ["/bin/sh", "-c", "kong start -c /config/kong.yml"]
    
}

