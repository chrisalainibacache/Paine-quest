# HD texture remaster — technical evaluation

## Scope
Experimental branch: `feature/remaster-hd-textures-pilot`
Base release: `3ea7d0621583feb33514f38f1a01c180beb5ea5`

This work does not modify `main`, gameplay scenes, display resolution, renderer settings, or shipping texture assets.

## Source audit
The pilot textures are 256x256 albedo images:
- `assets/environment/textures/concrete.png`
- `assets/environment/textures/bricks_old.png`
- `assets/environment/textures/asphalt_cracked.png`

The existing `shaders/ps1_surface.gdshader` already uses world-space triplanar sampling, nearest-mipmap filtering, anti-repetition sampling, macro variation, and base-of-wall grime. This shader is part of the established PS1 art direction and must not be replaced by a generic PBR material.

## Experiments and findings
1. 2x Lanczos enlargement plus sharpening: preserves the source but does not create genuine detail.
2. Procedural periodic grain: rejected. It introduces artificial directional patterns and changes the surface character.
3. Source high-frequency restoration: technically preserves source detail better, but side-by-side review shows insufficient perceptual improvement to justify replacing the original 256x256 textures.

No candidate has been promoted into the game's asset paths.

## Decision
Do not ship automated upscales as an HD remaster.

The next production-quality route is art-directed texture reconstruction at 512x512, using the original albedo as a strict reference:
- preserve macro silhouettes, crack paths, brick/stone boundaries, palette, and value range;
- author only material-appropriate microstructure;
- make every texture tile seamlessly;
- compare at identical world-space texel density, not merely enlarged preview size;
- import and test on Android Compatibility before promotion.

Keep original albedos as rollback sources. Any normal/height map experiment must be separate from albedo and must not be applied until the shader path is validated.

## Current state
- Branch is isolated from `main`.
- Pilot scripts and workflow generate downloadable review artifacts only.
- No shipping texture, scene, shader, resolution, or renderer setting has been changed.
- No PR merge or release has been performed.
