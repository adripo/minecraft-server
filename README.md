# minecraft-server
Minecraft server Docker version

## Build
```
source build.env
DATE_NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

docker build \
    --no-cache \
    --pull \
    -t adripo/${MC_NAME}:${MC_VERSION} \
    --build-arg BUILD_DATE=${DATE_NOW} \
    $(cat build.env | sed -e 's/#.*//' -e 's/[ ^I]*$//' -e '/^$/ d' -e 's/^/--build-arg /g' | tr '\n' ' ') \
    .
```
