#!/bin/bash
set -euo pipefail

mkdir -p debs

if command -v dpkg-scanpackages >/dev/null 2>&1; then
  dpkg-scanpackages --multiversion debs /dev/null > Packages
else
  echo "dpkg-scanpackages is required" >&2
  exit 1
fi

gzip -9c Packages > Packages.gz

cat > Release <<EOF
Origin: xADAS
Label: xADAS Dev
Suite: stable
Version: 1.0
Codename: ios
Architectures: iphoneos-arm64
Components: main
Description: xADAS development packages for rootless iOS jailbreak devices.
Date: $(LC_ALL=C date -u '+%a, %d %b %Y %H:%M:%S UTC')
EOF

printf 'MD5Sum:\n' >> Release
for f in Packages Packages.gz; do
  printf ' %s %16d %s\n' "$(md5sum "$f" | awk '{print $1}')" "$(stat -c%s "$f")" "$f" >> Release
done

printf 'SHA256:\n' >> Release
for f in Packages Packages.gz; do
  printf ' %s %16d %s\n' "$(sha256sum "$f" | awk '{print $1}')" "$(stat -c%s "$f")" "$f" >> Release
done
