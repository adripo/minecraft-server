target "docker-metadata-action" {}

group "build" {
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
    "docker-metadata-action",
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
    "docker-metadata-action",
    "build-default"
  ]
  args = {
    S6_OVERLAY_ARCH = "aarch64"
  }
  platforms = [
    "linux/arm64"
  ]
}
