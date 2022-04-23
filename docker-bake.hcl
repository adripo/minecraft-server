target "docker-metadata-action" {}

target "build-amd64" {
  inherits = ["docker-metadata-action"]
  context = "./"
  dockerfile = "Dockerfile"
  args = {
    "S6_OVERLAY_ARCH" = "x86_64"
  }
  platforms = [
    "linux/amd64"
  ]
}

target "build-arm64" {
  inherits = ["docker-metadata-action"]
  context = "./"
  dockerfile = "Dockerfile"
  args = {
    "S6_OVERLAY_ARCH" = "aarch64"
  }
  platforms = [
    "linux/arm64"
  ]
}

target "build-armv7" {
  inherits = ["docker-metadata-action"]
  context = "./"
  dockerfile = "Dockerfile"
  args = {
    "S6_OVERLAY_ARCH" = "arm"
  }
  platforms = [
    "linux/arm/v7"
  ]
}