# Changelog

## [0.3.16](https://github.com/omega-pcf/04-mersenne-cr/compare/v0.3.15...v0.3.16) (2026-07-31)

### Bug Fixes

* **bib:** clean GIMPS CSL entry and enable xurl for breakable URLs ([33edfa9](https://github.com/omega-pcf/04-mersenne-cr/commit/33edfa9ae36d9f169933e07a51231cb8aae4e72b))
* **build:** use biblatex format, clean stale artifacts, surface latex errors ([fe87825](https://github.com/omega-pcf/04-mersenne-cr/commit/fe878255723c59d4a9de4f66c11ffe103d000fc4))

### Documentation

* investigate citation-js howpublished synthesis and URL overflow in [14] GIMPS ([90af646](https://github.com/omega-pcf/04-mersenne-cr/commit/90af646dc9ecc9bd72b04c0db5d1423ace1cd5b9))

### Chores

* regenerate metadata and PDF after biblatex format fix ([12eb30d](https://github.com/omega-pcf/04-mersenne-cr/commit/12eb30dd85d8241ee07948f94dd062dd8e3412f6))
* update .gitignore, remove .cursorignore, add CC-BY 4.0 LICENSE ([cdb3f46](https://github.com/omega-pcf/04-mersenne-cr/commit/cdb3f46a83e0624a1b80a5a4f5de95e6a316bdb8))

## [0.3.15](https://github.com/omega-pcf/04-mersenne-cr/compare/v0.3.14...v0.3.15) (2026-07-30)

### Bug Fixes

* **tex:** prevent stretched spacing around introduction figure ([367de3f](https://github.com/omega-pcf/04-mersenne-cr/commit/367de3fff5f6039f8f8062d054145c677f415008))

### Documentation

* acknowledge MiniMax, Z.ai, and Xiaomi Research in formal verification ([ce1c3fc](https://github.com/omega-pcf/04-mersenne-cr/commit/ce1c3fcb546c934a3e18bd82605135fed91a8341))

## [0.3.14](https://github.com/omega-pcf/04-mersenne-cr/compare/v0.3.13...v0.3.14) (2026-07-30)

### Documentation

* add standardized build pipeline docs ([fee815e](https://github.com/omega-pcf/04-mersenne-cr/commit/fee815e12e61e1ce1b8983de68d7ef34c68273ee))
* remove obsolete Docker investigation notes ([d6509c7](https://github.com/omega-pcf/04-mersenne-cr/commit/d6509c7626057b8883c42e7b27458c49dd643f34))

## [0.3.13](https://github.com/omega-pcf/04-mersenne-cr/compare/v0.3.12...v0.3.13) (2026-07-30)

### Bug Fixes

* **build:** remove --user flag, add TEXMF isolation, biber version check ([d4e202e](https://github.com/omega-pcf/04-mersenne-cr/commit/d4e202e2265a588eb34b6625d25979f393649c31))
* **build:** resolve Docker bind-mount write vanishing with spawnSync + shell script ([5fdbe1c](https://github.com/omega-pcf/04-mersenne-cr/commit/5fdbe1c722879f4660f193efc23537bc8022f5bb))
* **build:** single-container LaTeX pipeline to mitigate bind-mount race ([0c29975](https://github.com/omega-pcf/04-mersenne-cr/commit/0c299750908ee4165f8a4fc0eb793b9cdc99c643))
* **build:** use latexmk instead of manual pdflatex/biber — industry standard ([1b12a9c](https://github.com/omega-pcf/04-mersenne-cr/commit/1b12a9ce62cca99bd288284d7c93b4975c01227a))
* **tex:** reflow title line breaks and fix \allowbreak inside \lean{} commands ([b0b2f54](https://github.com/omega-pcf/04-mersenne-cr/commit/b0b2f54c77101a34f9e4c47f8ea079188f19405a))
* **tex:** reflow title line breaks and fix \allowbreak inside \lean{} commands ([3636cd8](https://github.com/omega-pcf/04-mersenne-cr/commit/3636cd86dbe076ab0308e3411e70402526e6761b))
* **tex:** reflow title line breaks for consistent formatting ([5f67726](https://github.com/omega-pcf/04-mersenne-cr/commit/5f67726b8f343387b7b0b3834c41748389624fd2))

## [0.3.12](https://github.com/omega-pcf/04-mersenne-cr/compare/v0.3.11...v0.3.12) (2026-07-29)

### Bug Fixes

* **tex:** restore short title 'and Euler's identity' in header ([f7c542e](https://github.com/omega-pcf/04-mersenne-cr/commit/f7c542effdda12bd789813d4fb8a7d7378d8fcff))

## [0.3.11](https://github.com/omega-pcf/04-mersenne-cr/compare/v0.3.10...v0.3.11) (2026-07-29)

### Bug Fixes

* **citation:** complete Acevedo Agudelo 2021 entry with journal metadata ([24cf02f](https://github.com/omega-pcf/04-mersenne-cr/commit/24cf02f76a9a1f42deb90039f66ae6b24ddcfa04))
* **citation:** update Grisales Herrera entry with verified Zenodo metadata ([4f5cb60](https://github.com/omega-pcf/04-mersenne-cr/commit/4f5cb6071a6f714aac0d0deab8cbd1c53c63e7f2))

### Documentation

* add Zenodo All Versions DOI to first page ([0e93f50](https://github.com/omega-pcf/04-mersenne-cr/commit/0e93f5010e963c3e7122cfe5e6e27bead0554c1a))

### Chores

* rebuild metadata after citation updates ([9fa642e](https://github.com/omega-pcf/04-mersenne-cr/commit/9fa642e7e17f8353fddb5a3656d003dfb6744aff))

## [0.3.10](https://github.com/omega-pcf/04-mersenne-cr/compare/v0.3.9...v0.3.10) (2026-07-29)

### Bug Fixes

* **citation:** add doi to package.json, propagate via pipeline ([294a540](https://github.com/omega-pcf/04-mersenne-cr/commit/294a540073d26952f3f8d489b32f08366535f4c1))
* **citation:** remove self-citation Corr entry from citation.csl.json ([4c29cca](https://github.com/omega-pcf/04-mersenne-cr/commit/4c29cca121699259f044420df6de5629b3751e2c))
* **citation:** set Zenodo upload_type to publication/preprint, add DOI 10.5281/zenodo.21681395 ([031bc4d](https://github.com/omega-pcf/04-mersenne-cr/commit/031bc4d2fda172987d90f7def18c4cb3ff0fce46))

## [0.3.9](https://github.com/omega-pcf/04-mersenne-cr/compare/v0.3.8...v0.3.9) (2026-07-29)

### Bug Fixes

* **ci:** add edit before newversion, show delete HTTP status ([885a6ba](https://github.com/omega-pcf/04-mersenne-cr/commit/885a6ba095e1280ed64357540233d8dac1374df5))

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
