#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${SCRIPT_DIR}/.."
PROJECT_NAME="ObjectivePGP"
PROJECT_FILE_PATH="${PROJECT_DIR}/${PROJECT_NAME}.xcodeproj"
TARGET_NAME="${PROJECT_NAME}"
CONFIGURATION="Release"

BUILD_ROOT="$(mktemp -d)"
trap 'rm -rf "${BUILD_ROOT}"' EXIT

platform_from_sdk() {
  local sdk="${1}"

  if [[ "${sdk}" == iphoneos* ]]; then
    echo "iphoneos"
    return
  fi

  if [[ "${sdk}" == iphonesimulator* ]]; then
    echo "iphonesimulator"
    return
  fi

  if [[ "${sdk}" == macosx* ]]; then
    echo "macosx"
    return
  fi

  echo "${sdk}"
}

build_framework() {
  local sdk="${1}"
  local platform
  platform="$(platform_from_sdk "${sdk}")"

  local -a xcodebuild_args=(
    -jobs 1
    -project "${PROJECT_FILE_PATH}"
    -target "${TARGET_NAME}"
    -configuration "${CONFIGURATION}"
    -sdk "${sdk}"
    ONLY_ACTIVE_ARCH=NO
    BUILD_DIR="${BUILD_ROOT}"
    SYMROOT="${BUILD_ROOT}/symroot-${sdk}"
    OBJROOT="${BUILD_ROOT}/objroot-${sdk}"
  )

  if [[ "${sdk}" != macosx* ]]; then
    xcodebuild_args+=(PLATFORM_NAME="${platform}")
  fi

  xcrun xcodebuild "${xcodebuild_args[@]}" build
}

SDKs=($(xcrun xcodebuild -showsdks | grep -Eo 'iphoneos|iphonesimulator|macosx[0-9.]+' | sort -u))
for sdk in "${SDKs[@]}"; do
  build_framework "${sdk}"
done

mkdir -p "${PROJECT_DIR}/Frameworks"
rm -rf "${PROJECT_DIR}/Frameworks/${TARGET_NAME}.xcframework"

iphoneos_framework="$(find "${BUILD_ROOT}" -path "*/Release-iphoneos/${TARGET_NAME}.framework" -type d | head -n 1)"
iphonesim_framework="$(find "${BUILD_ROOT}" -path "*/Release-iphonesimulator/${TARGET_NAME}.framework" -type d | head -n 1)"
macos_framework="$(find "${BUILD_ROOT}" -path "*/Release/${TARGET_NAME}.framework" -type d | head -n 1)"

if [[ -z "${iphoneos_framework}" || -z "${iphonesim_framework}" || -z "${macos_framework}" ]]; then
  echo "Missing built framework(s):"
  echo "iphoneos: ${iphoneos_framework:-<missing>}"
  echo "iphonesimulator: ${iphonesim_framework:-<missing>}"
  echo "macos: ${macos_framework:-<missing>}"
  exit 1
fi

xcrun xcodebuild -quiet -create-xcframework \
  -framework "${iphoneos_framework}" \
  -framework "${iphonesim_framework}" \
  -framework "${macos_framework}" \
  -output "${PROJECT_DIR}/Frameworks/${TARGET_NAME}.xcframework"

echo "Framework build succeeded"
