# Changelog

## [0.3.8](https://github.com/omega-pcf/04-mersenne-cr/compare/v0.3.7...v0.3.8) (2026-07-29)

### Bug Fixes

* **ci:** create deposition automatically — no manual setup needed ([d2d2c4d](https://github.com/omega-pcf/04-mersenne-cr/commit/d2d2c4d923e497398d03c61ac96bc7d0cb3dd4f0))

## [0.3.7](https://github.com/omega-pcf/04-mersenne-cr/compare/v0.3.6...v0.3.7) (2026-07-29)

## [0.3.6](https://github.com/omega-pcf/04-mersenne-cr/compare/v0.3.5...v0.3.6) (2026-07-29)

### Bug Fixes

* update running title to include Euler's identity ([266bc2f](https://github.com/omega-pcf/04-mersenne-cr/commit/266bc2f5b65ceb761838304b192c3fe3cd7a042c))

### Documentation

* add README matching sibling repo style ([a0758d4](https://github.com/omega-pcf/04-mersenne-cr/commit/a0758d40f90a83cfab951949ab39e0fb230a40b2))
* document Zenodo file upload issue and related GitHub issue ([5c8fe7e](https://github.com/omega-pcf/04-mersenne-cr/commit/5c8fe7e0cb7a8e6dc56f070bc53349a0cdb1b652))

## [0.3.5](https://github.com/omega-pcf/04-mersenne-cr/compare/v0.3.4...v0.3.5) (2026-07-29)

### Bug Fixes

* **ci:** use gh release download --archive zip for source zipball ([d5f93ca](https://github.com/omega-pcf/04-mersenne-cr/commit/d5f93cae1dd274187f2ceab86a4a1161297051dc))

## [0.3.4](https://github.com/omega-pcf/04-mersenne-cr/compare/v0.3.3...v0.3.4) (2026-07-29)

### Bug Fixes

* **ci:** fix zenodo upload — use POST multipart + download zipball from API ([f3fa9e5](https://github.com/omega-pcf/04-mersenne-cr/commit/f3fa9e50372761fe360c6b45c1b16c9595546484))

## [0.3.3](https://github.com/omega-pcf/04-mersenne-cr/compare/v0.3.2...v0.3.3) (2026-07-29)

## [0.3.2](https://github.com/omega-pcf/04-mersenne-cr/compare/v0.3.1...v0.3.2) (2026-07-29)

## [0.3.1](https://github.com/omega-pcf/04-mersenne-cr/compare/v0.3.0...v0.3.1) (2026-07-29)

## [0.3.0](https://github.com/omega-pcf/04-mersenne-cr/compare/v0.2.2...v0.3.0) (2026-07-29)

### Features

* **ci:** add Zenodo upload workflow via REST API ([f92cad8](https://github.com/omega-pcf/04-mersenne-cr/commit/f92cad888d6915e8d7efb6df408bc72dc1212bcb))

### Bug Fixes

* **citation:** replace invalid resource_type 'publication-technicalreport' with 'publication' ([583ab2b](https://github.com/omega-pcf/04-mersenne-cr/commit/583ab2be73e83728cf3fae27afc3a93d3f332e54))

## [0.2.2](https://github.com/omega-pcf/04-mersenne-cr/compare/v0.2.1...v0.2.2) (2026-07-29)

### Bug Fixes

* **citation:** remove invalid publication_type from .zenodo.json ([94c0258](https://github.com/omega-pcf/04-mersenne-cr/commit/94c0258ab784dab4b0254094360dea4dcf02107e))
* **citation:** replace invalid 'manuscript' type with 'article' in CSL ([1a732c5](https://github.com/omega-pcf/04-mersenne-cr/commit/1a732c5860ac41e4ead894baafc110699edcb1d0))
* **citation:** revert ORCID to URL format (schema requires it) ([a48edeb](https://github.com/omega-pcf/04-mersenne-cr/commit/a48edebc74dda21c6174dbd7bd74b3ae5e1bb182))

## [0.2.1](https://github.com/omega-pcf/04-mersenne-cr/compare/v0.2.0...v0.2.1) (2026-07-29)

### Bug Fixes

* **citation:** set upload_type to software for Zenodo ([6aa9ac9](https://github.com/omega-pcf/04-mersenne-cr/commit/6aa9ac9dfd783bfb4a12a110d6ba34df48182f94))

## 0.2.0 (2026-07-29)

### Features

* **figures:** add commutative diagram and build pipeline ([e57d05d](https://github.com/omega-pcf/04-mersenne-cr/commit/e57d05d60fca7ac643d4605fd826cc096e6150aa))
* initial commit — Mersenne CR note and golden Lean proof ([6ac9a95](https://github.com/omega-pcf/04-mersenne-cr/commit/6ac9a954887326a25da78e1ef20d999978a65446))
* **lean:** initialize Lean 4 project with Mathlib v4.29.0 ([6cfaa44](https://github.com/omega-pcf/04-mersenne-cr/commit/6cfaa4438d85611c011a64dbe4e9608f4b037893))
* scaffold build infrastructure and segment manuscript ([b1296e9](https://github.com/omega-pcf/04-mersenne-cr/commit/b1296e9917b360e09fe5112d953295d73ed8ba7d))

### Bug Fixes

* **citation:** repair CSL→Zenodo pipeline bugs ([337f4e8](https://github.com/omega-pcf/04-mersenne-cr/commit/337f4e84a27a7779ba152335ae9ca10e7884a0bf))
* **citations:** add confirmed DOIs via Hound MCP ([2f71909](https://github.com/omega-pcf/04-mersenne-cr/commit/2f719096c23bd21fcfbbcaf32418d1573723c59c))
* **citations:** add Corr entry and correct metadata ([4c51bc0](https://github.com/omega-pcf/04-mersenne-cr/commit/4c51bc0cb864cd193c311f3080f14be5c1f15ed9))
* **citations:** remove stale verification artifact ([4027208](https://github.com/omega-pcf/04-mersenne-cr/commit/4027208cd14ce48cddcab702f6a45e23c45f9eeb))
* **figures:** update commutative diagram layout and spacing ([2d80209](https://github.com/omega-pcf/04-mersenne-cr/commit/2d802097039981478b391ba9d44ae2e463825636))
* **lean:** resolve all linter warnings ([d8fe80d](https://github.com/omega-pcf/04-mersenne-cr/commit/d8fe80ddaadc2930322a11c06a72125eb8c8324b))

### Styles

* standardize LaTeX preamble to match 01/02 target state ([4a8c732](https://github.com/omega-pcf/04-mersenne-cr/commit/4a8c732d61f255fb6a04fb112abd9207486939cb))
* use muted red for linkcolor across all repos ([49dd4ca](https://github.com/omega-pcf/04-mersenne-cr/commit/49dd4ca03834db8e53c3ae3f39a0e246c2afb0d3))

### Chores

* exclude lean/.lake from git, update build artifacts ([7cc07e7](https://github.com/omega-pcf/04-mersenne-cr/commit/7cc07e7a09ce5f622501fac6f238b1097c83f3b2))
* **lean:** remove journal name from file header ([3657f03](https://github.com/omega-pcf/04-mersenne-cr/commit/3657f03a3768ae8ca1ddc277c40205f376c9a5f3))
* remove deprecated files ([ce08989](https://github.com/omega-pcf/04-mersenne-cr/commit/ce089893e64feee4f4052c494c1c7009f6ca5250))
