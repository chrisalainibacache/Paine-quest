# HD Stage 1 — progress

- Stable main remains untouched.
- Stage 1 albedo candidates are generated in CI and retained as artifacts.
- Height/normal candidates are diagnostic only; they are not assigned to game materials.
- The first albedo comparison shows insufficient perceptual improvement on concrete and asphalt; do not integrate as-is.
- Brick detail is more visible but currently relies on sharpening/upscaling and is not yet a true source-detail reconstruction.
- Next gate: inspect height/normal outputs and validate tiling before any shader or material integration.

- Added normal/height-map candidates for inspection; no runtime assets changed.

- The workflow was hardened to keep generated normal maps in the same review artifact and remove a malformed duplicate step.

- Normal maps now derive gradients at final 512px resolution with controlled stronger strength; this remains an isolated diagnostic candidate.
