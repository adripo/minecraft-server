target "docker-metadata-action" {}

group "build" {
  inherits = [
    "docker-metadata-action"
  ]
  targets = [
    "build-amd64",
    "build-arm64"]
}

target "build-default" {
  context = "./"
  dockerfile = "Dockerfile"
}

target "build-amd64" {
  inherits = [
    "build-default"
  ]
  args = {
    S6_OVERLAY_ARCH = "x86_64"
  }
  platforms = [
    "linux/amd64"
  ]
}

target "build-arm64" {
  inherits = [
    "build-default"
  ]
  args = {
    S6_OVERLAY_ARCH = "aarch64"
  }
  platforms = [
    "linux/arm64"
  ]
}
