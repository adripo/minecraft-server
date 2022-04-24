target "docker-metadata-action" {}

target "build" {
  inherits = [
    "docker-metadata-action",
    "build-amd64",
    "build-arm64"]
}

target "build-amd64" {
  context = "./"
  dockerfile = "Dockerfile"
  args = {
    S6_OVERLAY_ARCH = "x86_64"
  }
  platforms = [
    "linux/amd64"
  ]
}

target "build-arm64" {
  context = "./"
  dockerfile = "Dockerfile"
  args = {
    S6_OVERLAY_ARCH = "aarch64"
  }
  platforms = [
    "linux/arm64"
  ]
}
