#!/usr/bin/env bash
# Verify bundled MobileNet ONNX exists and (optional) OCI image builds with sample Containerfile.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ONNX="${ROOT}/extras/models/mobilenetv2-7.onnx"
MIN_BYTES=$((10 * 1024 * 1024))

echo "== kserve-workshop sample verification =="
echo "ROOT: ${ROOT}"

if [[ ! -f "$ONNX" ]]; then
  echo "FAIL: Missing ${ONNX}"
  exit 1
fi

size=$(wc -c < "$ONNX")
if [[ "$size" -lt "$MIN_BYTES" ]]; then
  echo "FAIL: ${ONNX} seems too small (${size} bytes); expected bundled MobileNet ONNX."
  exit 1
fi
echo "OK: Found MobileNet ONNX (${size} bytes)"

stage="${ROOT}/scratch/model-build-verify"
rm -rf "${stage}"
mkdir -p "${stage}/models/1"
cp "$ONNX" "${stage}/models/1/"

if command -v podman >/dev/null 2>&1; then
  echo "Running: podman build (Containerfile.model-example) ..."
  podman build -f "${ROOT}/configs/samples/Containerfile.model-example" \
    -t kserve-workshop-mobilenet-verify:local \
    "${stage}"
  echo "OK: podman build succeeded"
  podman rmi kserve-workshop-mobilenet-verify:local 2>/dev/null || true
else
  echo "SKIP: podman not found; ONNX check only."
fi

rm -rf "${stage}"
echo "== All checks passed =="
