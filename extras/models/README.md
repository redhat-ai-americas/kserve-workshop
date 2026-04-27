# Bundled sample model (MobileNet v2 ONNX)

This directory ships a single file so workshops work offline and without Hugging Face.

| File | Description |
|------|-------------|
| `mobilenetv2-7.onnx` | MobileNet v2 classifier in ONNX opset 7 from the [ONNX Model Zoo](https://github.com/onnx/models/tree/main/validated/vision/classification/mobilenet). |

## License

The ONNX Model Zoo classifies this model under Apache License v2.0 (see the upstream repository). Redistribute and use in accordance with that license.

## Workshop usage

- Copy or reference this file when building the OCI image layout under `models/1/` (see [Topic 2](/docs/02-preparing-and-storing-models.md)).
- Or upload the same file to a workbench PVC for PVC-based deployment.

## Updating the file

To refresh from upstream (requires network):

```sh
curl -fsSL -o mobilenetv2-7.onnx \
  "https://github.com/onnx/models/raw/main/validated/vision/classification/mobilenet/model/mobilenetv2-7.onnx"
```
