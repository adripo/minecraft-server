#!/usr/bin/env sh

# Download server installer
curl "${DW_LINK}" --output "${MC_SERVER}_installer.jar"

# Install server
java -jar "${MC_SERVER}_installer.jar" --installServer
# Cleanup
rm -rf "${MC_SERVER}_installer.jar"
rm -rf "${MC_SERVER}_installer.jar.log"
rm -rf "run.bat"

## Setup JVM args
#printf -- "\n-Xms2G -Xmx10G" >> user_jvm_args.txt