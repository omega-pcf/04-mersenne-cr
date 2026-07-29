# Simultaneous Identities of the Golden Ratio and Euler's Identity, Formally Verified in Lean 4 over the Known Mersenne Prime Exponents

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.TODO.svg)](https://doi.org/10.5281/zenodo.TODO)
[![Project Page](https://img.shields.io/badge/Project%20Page-omega--pcf.com-blue)](https://omega-pcf.com/mersenne-cr)

## Authors

**Jorge Armando González García**¹, **Víctor Manuel González García**¹, **Itzel Marion Dressler Pérez**², **Luz María García Ordóñez**¹

¹ *TTAMAYO PUNTO COM, S.A.P.I. de C.V., Research & Development Division, Mexico*
² *Independent Researcher*

---

## Abstract

We present a sustained study of a single object followed across representations, where the content lives in the equivalences between them, not in any representation in isolation. We prove and formally verify in Lean 4 that the golden ratio φ=(1+√5)/2 satisfies simultaneously twelve identities, inclusions, and identifications across five canonical structures: the complex rotor of Euler's identity, the real trigonometric and real-multiplicative lines, the arithmetic of Mersenne numbers modulo 20, and the Galois group (ℤ/20ℤ)× of ℚ(ζ₂₀)/ℚ. The central clause is the identity 3φ^{σ(p)}=2^p, with σ(p)=pλ−log_φ 3 and λ=log_φ 2 transcendental by Gelfond–Schneider. Specialised to the 52 known Mersenne prime exponents (GIMPS, 1952–2024), it holds exactly for each, and every pair of Mersenne numbers, in their binary form 2^p=M_p+1, stands in an exact golden ratio. The factor 3 coincides with M₂, with the number of admissible residue classes of M_p mod 20, and with the numerator of M₂/|(ℤ/20ℤ)×|=3/8. The verification is conducted against Mathlib4 with 0 sorry, taking as external axioms only the Gelfond–Schneider theorem and the 44 large GIMPS primalities.

**Keywords:** Golden ratio, Mersenne primes, cyclotomic fields, modular concentration, Gelfond–Schneider theorem, formal verification, Lean 4.

## Citation

González García, J. A., González García, V. M., Dressler Pérez, I. M., & García Ordóñez, L. M. (2026). *Simultaneous identities of the golden ratio and Euler's identity, formally verified in Lean 4 over the known Mersenne prime exponents*. Preprint. DOI: [10.5281/zenodo.TODO](https://doi.org/10.5281/zenodo.TODO).

```bibtex
@article{Gonzalez2026MersenneCR,
  author  = {González García, J. A. and González García, V. M. and Dressler Pérez, I. M. and García Ordóñez, L. M.},
  title   = {Simultaneous identities of the golden ratio and Euler's identity, formally verified in Lean 4 over the known Mersenne prime exponents},
  journal = {Preprint},
  year    = {2026},
  doi     = {TODO},
  url     = {https://doi.org/10.5281/zenodo.TODO}
}
```

## Repository Structure

### Manuscript (`src/`)

- **`main.tex`**: Master document file.

- **`src/chapters/`**:
  - `01-introduction.tex`: Historical context and classification under equivalence.
  - `02-universal-identity.tex`: Statement and proof of the universal identity.
  - `03-factor-three.tex`: The factor 3 as M₂ and modular concentration.
  - `04-fibonacci-splitting.tex`: Fibonacci splitting and its consequences.
  - `05-reciprocal-turn.tex`: Reciprocal turn structure.
  - `06-discussion.tex`: Implications and broader theory.
  - `07-formal-verification.tex`: Lean 4 formalization and verification tables.
  - `08-closing-remark.tex`: Final synthesis and future directions.
  - `09-ai-statement.tex`: AI assistance disclosure.
  - `acknowledgments.tex`: Acknowledgments.
  - `disclosure.tex`: Conflict of interest disclosure.
- **`src/bibliography.bib`**: References (auto-generated from `citation.csl.json`).

### Formal Verification (`lean/`)

- **`lean/golden_mersenne.lean`**: Single self-contained Lean 4 proof file (1599 lines, 0 sorry). Built against Mathlib4 (Lean toolchain `v4.28.0`). Imports only Mathlib. Proves the twelve identities, the central clause 3φ^{σ(p)}=2^p, and the Fibonacci splitting.
- **`lean/lakefile.toml`**: Lake build configuration with Mathlib dependency.
- **`lean/lean-toolchain`**: Lean toolchain version.

### Figures (`scripts/figures/`)

- **`scripts/figures/cd_correspondance.tex`**: CD correspondence diagram (standalone TikZ).
- **`scripts/figures/build.sh`**: Builds all figures via Docker (`kjarosh/latex:2024.4-full`).

## Verification Execution

```bash
pnpm run verify
```

This runs the Lean 4 proof verification via `lake build` in the `lean/` directory. The proof imports only Mathlib and takes as external axioms the Gelfond–Schneider theorem and the 44 large GIMPS primalities.

```bash
pnpm run verify:lean
```

Same as `verify` — runs `cd lean && lake build`.

## Build and Compilation

```bash
pnpm run build
```

Or for full build with figures:

```bash
pnpm run build:full
```

> [!IMPORTANT]
> - **Metadata Flow**: `citation.csl.json` provides the source references, which are synchronized into `src/bibliography.bib`, `CITATION.cff`, and `.zenodo.json` during the build.
> - **Figures**: Assets are generated automatically; manual execution of `pnpm run generate:figures` is only required for auditing specific components.
> - **Verification**: While `build` produces the documentation artifacts, formal proof verification must be executed via `pnpm run verify`.

## Release

To automate a new versioned release (updates Zenodo deposition, Changelog, Tags, and GitHub Release):

```bash
pnpm run release
```

This triggers a full build, asset regeneration, and metadata synchronization before publishing, ensuring a deterministic and fully auditable release state.

### Traditional Manual Build

For local environments with a full TeX Live distribution, you may use the standard compilation sequence:

```bash
pdflatex main
biber main
pdflatex main
pdflatex main
```

## License

See [LICENSE](LICENSE) for details.
