provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# Define Docker volumes
resource "docker_volume" "ollama" {

}

resource "docker_volume" "open_webui" {

}

# Ollama service
resource "docker_image" "ollama" {
  name         = "ollama/ollama:${var.OLLAMA_DOCKER_TAG}"
  pull_trigger = always
}

resource "docker_container" "ollama" {
  name  = "ollama"
  image = docker_image.ollama.latest
  tty   = true

  volumes {
    host_path      = "ollama"
    container_path = "/root/.ollama"
  }

  restart = "unless-stopped"
}

# Oepen WebUI service
resource "docker_image" "open_webui" {
  name = "ghcr.io/open-webui/open-webui:${var.WEBUI_DOCKER_TAG}"
}

resource "docker_container" "open_webui" {
  depends_on = [docker_container.ollama]
  name       = "open-webui"
  image      = docker_image.open_webui.latest
  ports {
    internal = 8080
    external = var.OPEN_WEBUI_PORT
  }
  
  environment = {
    "OLLAMA_BASE_URL"   = "http://ollama:11434"
    "WEBUI_SECRET_KEY"  = ""
  }

  volumes {
    host_path      = "open-webui"
    container_path = "/app/backend/data"
  }

  restart     = "unless-stopped"
  extra_hosts = ["host.docker.internal:host-gateway"]
}

# Apache Tika service
resource "docker_image" "tika" {
  name = "apache/tika:latest-full"
}

resource "docker_container" "tika" {
  name  = "tika"
  image = docker_image.tika.latest

  ports {
    internal = 9998
    external = 9998
    address  = "127.0.0.1"
  }

  volumes = [
    "${var.CONFIG_LOCATION}/tika-config.xml:/tika-config.xml",
    "${var.STORAGE_LOCATION}/tika:/tika-server/data"
  ]

  command = ["--config", "/tika-config.xml"]
  restart = "unless-stopped"
}

# Anything LLM service
resource "docker_image" "anythingllm" {
  name = "mintplexlabs/anythingllm"
}

resource "docker_container" "anythingllm" {
  name  = "anythingllm"
  image = docker_image.anythingllm.latest

  ports {
    internal = 3001
    external = 3001
  }

  volumes = [
    "${var.STORAGE_LOCATION}/anythingllm:/app/server/storage",
    "${var.CONFIG_LOCATION}/anythingllm/.env:/app/server/.env"
  ]

  cap_add = ["SYS_ADMIN"]

  environment = {
    "STORAGE_DIR" = "/app/server/storage"
  }
}

variable "OLLAMA_DOCKER_TAG" {
  default = "latest"
}

variable "WEBUI_DOCKER_TAG" {
  default = "main"
}

variable "OPEN_WEBUI_PORT" {
  default = 3000
}

variable "CONFIG_LOCATION" {
  default = "/path/to/config"
}

variable "STORAGE_LOCATION" {
  default = "/path/to/storage"
}
