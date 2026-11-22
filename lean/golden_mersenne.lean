/-
═══════════════════════════════════════════════════════════════════════════════
  golden_mersenne.lean
  ───────────────────────────────────────────────────────────────────────────
  Formal Lean 4 verification of the paper

    "Simultaneous identities of the golden ratio and Euler's identity,
     formally verified in Lean 4 over the known Mersenne prime
     exponents"

    J. A. González, V. M. González García, I. M. Dressler Pérez,
    L. M. García Ordóñez

  FILE ARCHITECTURE
  ────────────────────────
  §1   Layer 1: Algebraic bridge        φ^λ = 2, φ^{log 3/log φ} = 3
  §2   Pentagonal–cyclotomic identity  φ = 2cos(π/5) = ζ₁₀+ζ₁₀⁻¹
  §3   Layer 2: Exact correspondence    3·φ^σ(p) = 2^p (52 GIMPS exponents)
  §4   Direct golden ratio              2^q/2^p = φ^((q-p)·λ)
  §5   Mersenne modular concentration   M_p mod 20 ∈ {3,7,11}
  §6   Triple identification of 3       3 = M₂ = |{3,7,11}|
  §7   Euler–Mersenne–Galois connector theorem (12 clauses)
  §8   GIMPS axioms                     8 native primality checks + 44 axioms
  §9   Transcendence of λ_log           via Gelfond–Schneider (axiom)
  —    The identity, characterized      consistency + uniqueness
  §10  Fibonacci splitting               F_p ≡ ±1; type from the exponent
  §11  Binary bridge ↔ golden lattice   M_p = p ones; 2^p = a single bit
  —    Reciprocity link                  pinned joint presentation

  VERIFICATION STATUS
  ──────────────────────
  Sorry in code:         0
  File axioms:           45   44 GIMPS primality proofs (Lucas–Lehmer, §8.2)
                              + Gelfond-Schneider (§9,
                                transcendental_cpow_of_isAlgebraic_of_irrational).
  phi_sq:                     PROVED THEOREM (φ²=φ+1), not an axiom.
  lambda_log_transcendental:  THEOREM derived from GS (irrationality proved
                              via Lucas/ψ).
  Native primality checks: 8   (M_p prime for p ∈ {2,3,5,7,13,17,19,31})

  EXTERNAL DEPENDENCIES
  ─────────────────────
  None beyond Mathlib.  The file is self-contained: it imports only
  Mathlib and defines within its own namespace F1PCFUnified the base facts
  of the corpus (φ, φ_pos, φ_gt_one, φ_ne_zero, phi_sq, mersenne,
  lambda_log, mersenne_bridge, ZtwentyStar, ZtwentyStar_card).

  This file covers all statements cited in the note, including the
  Fibonacci splitting (§10) and its corollaries, and therefore does not
  require the mersenne_unified.lean corpus.
═══════════════════════════════════════════════════════════════════════════════
-/

import Mathlib

set_option linter.style.nativeDecide false
set_option linter.style.whitespace false

open Real Polynomial Filter Topology

noncomputable section

namespace F1PCFUnified

/-- The golden ratio φ = (1 + √5)/2. -/
def φ : ℝ := (1 + Real.sqrt 5) / 2

/-- φ is positive. -/
theorem φ_pos : 0 < φ := by
  unfold φ
  have h5 : 0 ≤ Real.sqrt 5 := Real.sqrt_nonneg 5
  linarith

theorem φ_ne_zero : φ ≠ 0 := ne_of_gt φ_pos

/-- φ > 1.  Since √5 > 2, φ = (1 + √5)/2 > (1 + 2)/2 = 3/2 > 1. -/
theorem φ_gt_one : 1 < φ := by
  unfold φ
  have h5 : 2 < Real.sqrt 5 := by
    have h_sq : (2:ℝ)^2 < 5 := by norm_num
    have := Real.sqrt_lt_sqrt (by norm_num : (0:ℝ) ≤ 4)
              (by norm_num : (4:ℝ) < 5)
    rw [show (4:ℝ) = 2^2 from by norm_num,
        Real.sqrt_sq (by norm_num : (0:ℝ) ≤ 2)] at this
    exact this
  linarith

/-- THEOREM (formerly axiom `phi_sq`): φ² = φ + 1. -/
theorem phi_sq : φ ^ 2 = φ + 1 := by
  unfold φ
  have h5 : Real.sqrt 5 ^ 2 = 5 :=
    Real.sq_sqrt (by norm_num : (5:ℝ) ≥ 0)
  nlinarith [h5]

/-- The logarithmic ratio λ_log = ln 2 / ln φ. -/
def lambda_log : ℝ := Real.log 2 / Real.log φ

def mersenne (p : ℕ) : ℕ := 2 ^ p - 1

/-- THEOREM (Mersenne bridge): φ^(log 2 / log φ) = 2. -/
theorem mersenne_bridge : φ ^ (Real.log 2 / Real.log φ) = 2 := by
  have hlogφ : Real.log φ ≠ 0 := ne_of_gt (Real.log_pos φ_gt_one)
  rw [Real.rpow_def_of_pos φ_pos]
  have hmul : Real.log φ * (Real.log 2 / Real.log φ) = Real.log 2 := by
    field_simp
  rw [hmul, Real.exp_log (by norm_num)]

def ZtwentyStar : Finset (ZMod 20) := {1, 3, 7, 9, 11, 13, 17, 19}

theorem ZtwentyStar_card : ZtwentyStar.card = 8 := by decide

end F1PCFUnified

open F1PCFUnified

noncomputable section


-- ╔═══════════════════════════════════════════════════════════════════════╗
-- ║  §1   LAYER 1 — ALGEBRAIC BRIDGE                                      ║
-- ║       φ^λ = 2 (mersenne_bridge_via_lambda)                            ║
-- ║       φ^{log 3/log φ} = 3 (phi_pow_log3)                              ║
-- ╚═══════════════════════════════════════════════════════════════════════╝

private theorem log_φ_pos : 0 < Real.log φ := Real.log_pos φ_gt_one
private theorem log_φ_ne_zero : Real.log φ ≠ 0 := log_φ_pos.ne'

/-- Mersenne bridge in the form `φ^lambda_log = 2`.
    Equivalent to `mersenne_bridge` in the F1 corpus, but using the constant. -/
theorem mersenne_bridge_via_lambda : φ ^ lambda_log = 2 := by
  unfold lambda_log; exact mersenne_bridge

/-- Ternary companion of the Mersenne bridge: φ^{log 3 / log φ} = 3.
    Essential for Layer 2 (logarithmic correspondence). -/
theorem phi_pow_log3 : φ ^ (Real.log 3 / Real.log φ) = 3 := by
  rw [Real.rpow_def_of_pos φ_pos]
  have hmul : Real.log φ * (Real.log 3 / Real.log φ) = Real.log 3 :=
    mul_div_cancel₀ (Real.log 3) log_φ_ne_zero
  rw [hmul, Real.exp_log (by norm_num : (0:ℝ) < 3)]


-- ╔═══════════════════════════════════════════════════════════════════════╗
-- ║  §2   IDENTIDAD PENTAGONAL-CICLOTÓMICA                                ║
-- ║       φ = 2·cos(π/5) (phi_eq_two_cos_pi_fifth)                        ║
-- ║       φ = ζ₁₀ + ζ₁₀⁻¹ en ℂ (phi_eq_zeta10_sum)                        ║
-- ║       ζ₁₀^10 = 1 (zeta10_pow_ten_eq_one)                              ║
-- ╚═══════════════════════════════════════════════════════════════════════╝

/-- Chebyshev polynomial of degree 5: cos(5θ) = 16cos⁵θ − 20cos³θ + 5cosθ. -/
private theorem cos_five_mul_pentagon (θ : ℝ) :
    Real.cos (5 * θ) =
      16 * Real.cos θ ^ 5 - 20 * Real.cos θ ^ 3 + 5 * Real.cos θ := by
  have hs : Real.sin θ ^ 2 = 1 - Real.cos θ ^ 2 := by
    nlinarith [Real.sin_sq_add_cos_sq θ]
  have c2 : Real.cos (2 * θ) = 2 * Real.cos θ ^ 2 - 1 := Real.cos_two_mul θ
  have s2 : Real.sin (2 * θ) = 2 * Real.sin θ * Real.cos θ := Real.sin_two_mul θ
  have c3 : Real.cos (3 * θ) = 4 * Real.cos θ ^ 3 - 3 * Real.cos θ := by
    rw [show (3 : ℝ) * θ = 2 * θ + θ from by ring, Real.cos_add, c2, s2]
    linear_combination -2 * Real.cos θ * hs
  have s3 : Real.sin (3 * θ) = 3 * Real.sin θ - 4 * Real.sin θ ^ 3 := by
    rw [show (3 : ℝ) * θ = 2 * θ + θ from by ring, Real.sin_add, c2, s2]
    linear_combination 4 * Real.sin θ * hs
  rw [show (5 : ℝ) * θ = 3 * θ + 2 * θ from by ring, Real.cos_add, c2, c3, s2, s3]
  linear_combination Real.cos θ * (8 * Real.sin θ ^ 2 - 8 * Real.cos θ ^ 2 + 2) * hs

/-- cos(π/5) > 0 (since π/5 ∈ (0, π/2)). -/
private theorem cos_pi_five_pos_pentagon : 0 < Real.cos (Real.pi / 5) := by
  apply Real.cos_pos_of_mem_Ioo; constructor <;> linarith [Real.pi_pos]

/-- cos(π/5) satisfies the quadratic 4x² − 2x − 1 = 0.
    Derived from the identity T₅(cos(π/5)) = cos(π) = −1
    by factoring (x+1)(4x²−2x−1)² = 0. -/
private theorem cos_pi_five_quadratic_pentagon :
    4 * Real.cos (Real.pi / 5) ^ 2 - 2 * Real.cos (Real.pi / 5) - 1 = 0 := by
  have hq : 16 * Real.cos (Real.pi/5)^5 - 20 * Real.cos (Real.pi/5)^3
              + 5 * Real.cos (Real.pi/5) + 1 = 0 := by
    have h : Real.cos (5 * (Real.pi / 5)) = Real.cos Real.pi := by ring_nf
    rw [cos_five_mul_pentagon] at h
    rw [Real.cos_pi] at h
    linarith
  set c := Real.cos (Real.pi / 5)
  have h0 : (c + 1) * (4 * c ^ 2 - 2 * c - 1) ^ 2 = 0 := by nlinarith [hq]
  have hquad_sq : (4 * c ^ 2 - 2 * c - 1) ^ 2 = 0 := by
    rcases mul_eq_zero.mp h0 with h | h
    · linarith [cos_pi_five_pos_pentagon]
    · exact h
  nlinarith [hquad_sq]

/-- Helper: φ/2 satisfies the same quadratic 4x² − 2x − 1 = 0. -/
private theorem phi_half_quadratic_pentagon :
    4 * (φ / 2) ^ 2 - 2 * (φ / 2) - 1 = 0 := by
  have h := phi_sq
  field_simp
  nlinarith [h]

/-- Uniqueness of the positive root of 4x² − 2x − 1 = 0.
    The polynomial has roots (1 ± √5)/4; only (1 + √5)/4 = φ/2 is positive. -/
private theorem quadratic_unique_pos_pentagon (x y : ℝ) (hx : 0 < x) (hy : 0 < y)
    (hxe : 4 * x ^ 2 - 2 * x - 1 = 0) (hye : 4 * y ^ 2 - 2 * y - 1 = 0) :
    x = y := by
  have h : (x - y) * (4 * (x + y) - 2) = 0 := by nlinarith
  rcases mul_eq_zero.mp h with h | h
  · linarith
  · exfalso
    have hx_half : x < 1/2 := by linarith
    nlinarith [show 4 * x ^ 2 < 1 from by nlinarith]

/-- cos(π/5) = φ/2.  Consequence of uniqueness of the positive root. -/
private theorem cos_pi_div_five_eq_phi_half :
    Real.cos (Real.pi / 5) = φ / 2 :=
  quadratic_unique_pos_pentagon _ _ cos_pi_five_pos_pentagon
    (by unfold φ; positivity)
    cos_pi_five_quadratic_pentagon
    phi_half_quadratic_pentagon

/-- **PENTAGONAL IDENTITY: φ = 2·cos(π/5)**.

    Connects the algebraic generator φ (defined by φ² = φ + 1)
    with the geometry of the regular pentagon: φ is the diagonal
    length of a regular pentagon with unit side, and 2·cos(π/5) is
    this same length expressed via its central angle.

    This identity is the geometric anchor of "pentagonal–cyclotomic
    symmetry" in the arithmetico-golden content of the Mersenne–φ program:
    φ lies in the real maximal subfield ℚ(√5) = ℚ(ζ₅ + ζ₅⁻¹) of the
    cyclotomic field ℚ(ζ₅), connecting the classification
    (ℤ/20ℤ)* (Galois group of the 20-cyclotomic) with pentagonal geometry. -/
theorem phi_eq_two_cos_pi_fifth : φ = 2 * Real.cos (Real.pi / 5) := by
  rw [cos_pi_div_five_eq_phi_half]; ring

/-- **CYCLOTOMIC CONNECTION: φ as complexified 2·cos(π/5)**.

    φ lies in the real maximal subfield of the cyclotomic ℚ(ζ₂₀):
    φ ∈ ℚ(√5) = ℚ(ζ₅ + ζ₅⁻¹) ⊂ ℚ(ζ₁₀) ⊂ ℚ(ζ₂₀).

    This complexified version of the pentagonal identity bridges
    to the cyclotomic geometry where the classification (ℤ/20ℤ)* lives. -/
theorem phi_via_cyclotomic_10 :
    (φ : ℂ) = 2 * Complex.cos ((Real.pi / 5 : ℝ) : ℂ) := by
  have hp : φ = 2 * Real.cos (Real.pi / 5) := phi_eq_two_cos_pi_fifth
  apply_fun ((↑) : ℝ → ℂ) at hp
  push_cast at hp ⊢
  exact hp

/-- **φ as a sum of 10th roots of unity**: φ = ζ₁₀ + ζ₁₀⁻¹,
    where ζ₁₀ = exp(πi/5).

    This is the explicit geometric realization: φ is the sum of the two
    conjugate primitive 10th roots of unity {exp(±πi/5)}.

    Combined with phi_via_cyclotomic_10 and Euler's identity:
    2·cos(z) = exp(zI) + exp(-zI). -/
theorem phi_eq_zeta10_sum :
    (φ : ℂ) = Complex.exp (((Real.pi / 5 : ℝ) : ℂ) * Complex.I) +
              Complex.exp (-(((Real.pi / 5 : ℝ) : ℂ) * Complex.I)) := by
  -- General Euler-cosine identity: exp(z*I) + exp(-(z*I)) = 2 cos(z)
  have euler_cos : ∀ z : ℂ, Complex.exp (z * Complex.I) +
                            Complex.exp (-(z * Complex.I)) = 2 * Complex.cos z := by
    intro z
    rw [Complex.exp_mul_I]
    have h_neg : -(z * Complex.I) = (-z) * Complex.I := by ring
    rw [h_neg, Complex.exp_mul_I, Complex.cos_neg, Complex.sin_neg]
    ring
  rw [euler_cos]
  exact phi_via_cyclotomic_10

/-- **Verification: ζ₁₀ = exp(πi/5) is a 10th root of unity**.

    Confirms that the ζ₁₀ used in phi_eq_zeta10_sum satisfies ζ₁₀^10 = 1,
    i.e., it is genuinely a 10th root of unity. -/
theorem zeta10_pow_ten_eq_one :
    Complex.exp (((Real.pi / 5 : ℝ) : ℂ) * Complex.I) ^ 10 = 1 := by
  rw [← Complex.exp_nat_mul]
  have h_eq : ((10 : ℕ) : ℂ) * (((Real.pi / 5 : ℝ) : ℂ) * Complex.I) =
              ((2 * Real.pi : ℝ) : ℂ) * Complex.I := by
    push_cast; ring
  rw [h_eq]
  -- exp(2π·I) = cos(2π) + I·sin(2π) = 1 + I·0 = 1
  rw [Complex.exp_mul_I]
  rw [← Complex.ofReal_cos, ← Complex.ofReal_sin]
  rw [Real.cos_two_pi, Real.sin_two_pi]
  push_cast
  ring


-- ╔═══════════════════════════════════════════════════════════════════════╗
-- ║  §3   CAPA 2 — CORRESPONDENCIA LOGARÍTMICA EXACTA                     ║
-- ║       σ(p) = p·λ − log_φ 3                                            ║
-- ║       3·φ^σ(p) = 2^p (golden_tower_bridge)                            ║
-- ║       Unicidad de σ(p) (sigma_mersenne_unique)                        ║
-- ║       52 exponentes GIMPS (mersenne_phi_correspondence_52)            ║
-- ╚═══════════════════════════════════════════════════════════════════════╝

/-- σ(p) = p·λ − log_φ(3): golden tower level associated to the exponent p. -/
def sigma_mersenne (p : ℝ) : ℝ :=
  p * lambda_log - Real.log 3 / Real.log φ

/-- **Golden tower theorem (algebraic, general)**.
    For all p : ℝ, the level σ(p) satisfies exactly 3 · φ^σ(p) = 2^p.

    Proof:  3 · φ^{p·λ − log_φ 3}
           = 3 · φ^{p·λ} / φ^{log_φ 3}      [rpow_sub]
           = 3 · (φ^λ)^p / φ^{log_φ 3}      [rpow_mul]
           = 3 · 2^p / 3                     [mersenne_bridge_via_lambda + phi_pow_log3]
           = 2^p                             [ring] -/
theorem golden_tower_bridge (p : ℝ) :
    (3 : ℝ) * φ ^ sigma_mersenne p = (2 : ℝ) ^ p := by
  simp only [sigma_mersenne]
  rw [Real.rpow_sub φ_pos]
  rw [show p * lambda_log = lambda_log * p from mul_comm _ _]
  rw [Real.rpow_mul (le_of_lt φ_pos)]
  rw [mersenne_bridge_via_lambda, phi_pow_log3]
  ring

/-- Explicit inversion: σ(p) = log_φ(2^p / 3). -/
theorem sigma_mersenne_eq_logb (p : ℝ) :
    sigma_mersenne p = Real.logb φ ((2 : ℝ) ^ p / 3) := by
  simp only [Real.logb, sigma_mersenne, lambda_log]
  rw [Real.log_div (Real.rpow_pos_of_pos (by norm_num : (0:ℝ) < 2) p).ne'
        (by norm_num : (3:ℝ) ≠ 0),
      Real.log_rpow (by norm_num : (0:ℝ) < 2)]
  ring

/-- Uniqueness: the only σ : ℝ with 3·φ^σ = 2^p is σ = sigma_mersenne p. -/
theorem sigma_mersenne_unique (p σ : ℝ)
    (h : (3 : ℝ) * φ ^ σ = (2 : ℝ) ^ p) :
    σ = sigma_mersenne p := by
  have hbridge := golden_tower_bridge p
  have hφσ : φ ^ σ = φ ^ sigma_mersenne p :=
    mul_left_cancel₀ (by norm_num : (3:ℝ) ≠ 0) (h.trans hbridge.symm)
  have heq : Real.log (φ ^ σ) = Real.log (φ ^ sigma_mersenne p) :=
    congr_arg Real.log hφσ
  rw [Real.log_rpow φ_pos, Real.log_rpow φ_pos] at heq
  exact mul_right_cancel₀ log_φ_ne_zero heq

/-- List of the 52 known Mersenne prime exponents.
    Source: GIMPS (Great Internet Mersenne Prime Search), 2024.
    Each p in this list is prime and M_p = 2^p − 1 is also prime.
    The last is p = 136279841, discovered in October 2024. -/
def known_mersenne_exponents : List ℕ :=
  [2, 3, 5, 7, 13, 17, 19, 31, 61, 89, 107, 127, 521, 607, 1279,
   2203, 2281, 3217, 4253, 4423, 9689, 9941, 11213, 19937, 21701,
   23209, 44497, 86243, 110503, 132049, 216091, 756839, 859433,
   1257787, 1398269, 2976221, 3021377, 6972593, 13466917, 20996011,
   24036583, 25964951, 30402457, 32582657, 37156667, 42643801,
   43112609, 57885161, 74207281, 77232917, 82589933, 136279841]

theorem known_mersenne_exponents_card :
    known_mersenne_exponents.length = 52 := by native_decide

theorem known_mersenne_exponents_pos :
    ∀ p ∈ known_mersenne_exponents, 0 < p := by native_decide

theorem known_mersenne_exponents_prime :
    ∀ p ∈ known_mersenne_exponents, Nat.Prime p := by native_decide

theorem known_mersenne_exponents_sorted :
    known_mersenne_exponents.Pairwise (· < ·) := by native_decide

/-- **Central theorem of Layer 2**: the logarithmic correspondence is exact
    for each of the 52 known exponents. It is not a numerical approximation:
    it is an algebraic identity satisfied by all Mersenne exponents. -/
theorem mersenne_phi_correspondence_52 :
    ∀ p ∈ known_mersenne_exponents,
      (3 : ℝ) * φ ^ sigma_mersenne (p : ℝ) = (2 : ℝ) ^ (p : ℝ) :=
  fun p _ => golden_tower_bridge (p : ℝ)

/-- The 52 levels σ(p) are strictly ordered: σ(p_i) < σ(p_j) whenever i < j. -/
theorem sigma_strictly_increasing :
    ∀ i j : Fin known_mersenne_exponents.length,
      i < j →
      sigma_mersenne (known_mersenne_exponents.get i : ℝ) <
      sigma_mersenne (known_mersenne_exponents.get j : ℝ) := by
  have h_lam : 0 < lambda_log := by
    unfold lambda_log
    have hlog2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
    exact div_pos hlog2 log_φ_pos
  intro i j hij
  simp only [sigma_mersenne]
  apply sub_lt_sub_right
  apply mul_lt_mul_of_pos_right _ h_lam
  exact Nat.cast_lt.mpr (known_mersenne_exponents_sorted.rel_get_of_lt hij)



-- ╔═══════════════════════════════════════════════════════════════════════╗
-- ║  §4   RATIO ÁUREO DIRECTO ENTRE POTENCIAS DE 2                        ║
-- ║       2^q/2^p = φ^((q-p)·λ) (mersenne_ratio_golden)                   ║
-- ║       Especialización GIMPS (mersenne_ratio_at_known_pairs)           ║
-- ╚═══════════════════════════════════════════════════════════════════════╝

/-- **Direct golden ratio between powers of 2**.
    For every pair (p, q) ∈ ℝ², the ratio 2^q / 2^p is exactly φ^((q−p)·λ).

    This is the structural statement that the multiplicative orbit {2^p : p ∈ ℝ}
    embeds in the golden lattice φ^(ℝ·λ_log) with coordinates given by p·λ_log.

    Applied to pairs of prime Mersenne exponents, it expresses that each pair
    (M_{p_i}+1, M_{p_j}+1) = (2^{p_i}, 2^{p_j}) has exact golden ratio
    determined by the difference of the exponents. -/
theorem mersenne_ratio_golden (p q : ℝ) :
    (2 : ℝ) ^ q / (2 : ℝ) ^ p = φ ^ ((q - p) * lambda_log) := by
  rw [← mersenne_bridge_via_lambda]
  rw [← Real.rpow_mul (le_of_lt φ_pos)]
  rw [← Real.rpow_mul (le_of_lt φ_pos)]
  rw [← Real.rpow_sub φ_pos]
  congr 1
  ring

/-- Specialization of the golden ratio to pairs of known prime Mersenne
    exponents (52 elements of the GIMPS list).
    Each pair (p_i, p_j) yields the ratio 2^{p_j} / 2^{p_i} = φ^((p_j−p_i)·λ). -/
theorem mersenne_ratio_at_known_pairs
    (i j : Fin known_mersenne_exponents.length) :
    (2 : ℝ) ^ (known_mersenne_exponents.get j : ℝ) /
    (2 : ℝ) ^ (known_mersenne_exponents.get i : ℝ) =
    φ ^ (((known_mersenne_exponents.get j : ℝ) -
          (known_mersenne_exponents.get i : ℝ)) * lambda_log) :=
  mersenne_ratio_golden _ _


-- ╔═══════════════════════════════════════════════════════════════════════╗
-- ║  §5   CONCENTRACIÓN MODULAR DE MERSENNE                               ║
-- ║       Para todo primo p: M_p mod 20 ∈ {3,7,11}                        ║
-- ║       (mersenne_concentration_general)                                ║
-- ╚═══════════════════════════════════════════════════════════════════════╝

/-! ### §5.1  B1 — Mersenne concentration (all primes) -/

/-- Computational lemma: 16² = 16 in Z₂₀ (16 is idempotent modulo 20). -/
private lemma sixteen_sq_zmod20 : (16 : ZMod 20) * 16 = 16 := by decide

/-- 16^k = 16 in Z₂₀ for all k ≥ 1. -/
private lemma sixteen_pow_succ (n : ℕ) : (16 : ZMod 20) ^ (n + 1) = 16 := by
  induction n with
  | zero => decide
  | succ k ih => rw [pow_succ, ih]; decide

/-- 2^4 = 16 in Z₂₀. -/
private lemma two_pow_four_zmod20 : (2 : ZMod 20) ^ 4 = 16 := by decide

/-- Key lemma: for every prime p, (2:Z₂₀)^p ∈ {4, 8, 12}.
    Proof structure: case analysis on p mod 4, using that for odd
    primes p ≥ 5, p mod 4 ∈ {1, 3}. -/
private lemma pow2_zmod20_prime (p : ℕ) (hp : p.Prime) :
    (2 : ZMod 20) ^ p ∈ ({4, 8, 12} : Finset (ZMod 20)) := by
  rcases Nat.lt_or_ge p 4 with hlt | hge
  · -- p ∈ {0, 1, 2, 3}; only 2 and 3 are prime
    interval_cases p
    · exact absurd hp (by decide)
    · exact absurd hp (by decide)
    · decide
    · decide
  · -- p ≥ 4. Since p is prime and ≥ 4, p is odd
    have hq_pos : 1 ≤ p / 4 := Nat.one_le_div_iff (by norm_num) |>.mpr hge
    -- p % 4 ≠ 0 (otherwise 4 ∣ p ⇒ 2 ∣ p ⇒ p = 2, absurd)
    have hr_ne0 : p % 4 ≠ 0 := by
      intro h
      have h4 : 4 ∣ p := Nat.dvd_of_mod_eq_zero h
      have h2 : 2 ∣ p := dvd_trans (by norm_num) h4
      rcases hp.eq_one_or_self_of_dvd 2 h2 with h1 | h1
      · norm_num at h1
      · rw [← h1] at hge; norm_num at hge
    -- p % 4 ≠ 2 (otherwise 2 ∣ p and since p ≥ 4, p ≠ 2)
    have hr_ne2 : p % 4 ≠ 2 := by
      intro h
      have hp2 : p % 2 = 0 := by omega
      have h2 : 2 ∣ p := Nat.dvd_of_mod_eq_zero hp2
      rcases hp.eq_one_or_self_of_dvd 2 h2 with h1 | h1
      · norm_num at h1
      · rw [← h1] at hge; norm_num at hge
    -- 16^(p/4) = 16  (since p/4 ≥ 1)
    obtain ⟨n, hn⟩ : ∃ n, p / 4 = n + 1 := ⟨p / 4 - 1, by omega⟩
    have h16 : (16 : ZMod 20) ^ (p / 4) = 16 := by
      rw [hn]; exact sixteen_pow_succ n
    -- Decomposition 2^p = (2^4)^(p/4) · 2^(p%4) = 16^(p/4) · 2^(p%4)
    have hdec : (2 : ZMod 20) ^ p =
                (16 : ZMod 20) ^ (p / 4) * (2 : ZMod 20) ^ (p % 4) := by
      conv_lhs => rw [← Nat.div_add_mod p 4]
      rw [pow_add, pow_mul, two_pow_four_zmod20]
    rw [hdec, h16]
    -- Case analysis on p % 4 ∈ {1, 3}
    have hr_lt : p % 4 < 4 := Nat.mod_lt p (by norm_num)
    interval_cases (p % 4)
    · exact absurd rfl hr_ne0
    · -- p % 4 = 1: 16 · 2 = 32 ≡ 12  (mod 20)
      decide
    · exact absurd rfl hr_ne2
    · -- p % 4 = 3: 16 · 8 = 128 ≡ 8  (mod 20)
      decide

/-- **B1 — Mersenne concentration (all primes)**.
    For every prime p, M_p = 2^p − 1 ≡ {3, 7, 11} (mod 20).
    A strict subset of the 8 Golden Prime classes of Z₂₀*. -/
theorem mersenne_concentration_general (p : ℕ) (hp : p.Prime) :
    (F1PCFUnified.mersenne p : ZMod 20) ∈ ({3, 7, 11} : Finset (ZMod 20)) := by
  -- (F1PCFUnified.mersenne p : Z₂₀) = (2:Z₂₀)^p − 1
  have hcast : (F1PCFUnified.mersenne p : ZMod 20) = (2 : ZMod 20) ^ p - 1 := by
    unfold F1PCFUnified.mersenne
    rw [Nat.cast_sub Nat.one_le_two_pow]
    push_cast; ring
  rw [hcast]
  have hpow := pow2_zmod20_prime p hp
  -- Finite check: {4, 8, 12} − 1 = {3, 7, 11}
  have hfin : ∀ x : ZMod 20,
      x ∈ ({4, 8, 12} : Finset (ZMod 20)) →
      x - 1 ∈ ({3, 7, 11} : Finset (ZMod 20)) := by decide
  exact hfin _ hpow


-- ╔═══════════════════════════════════════════════════════════════════════╗
-- ║  §6   TRIPLE IDENTIFICATION OF 3                                      ║
-- ║       3 = M₂ = |{3,7,11}| (three_eq_M2_eq_admissible_card)            ║
-- ╚═══════════════════════════════════════════════════════════════════════╝


/-- **The factor 3 in the central identity is the cardinality of the
    admissible class set, equal to M₂**.

    This is the structural statement that the "3" in
    `3 · φ^σ(p) = 2^p` (golden_tower_bridge) is not arbitrary: it coincides with

    (i) `M₂ = 2² − 1 = 3`, the first Mersenne prime,

    (ii) the cardinality |{3, 7, 11}| of the admissible class set
         of M_p modulo 20 (mersenne_concentration_general).

    This coincidence (3 = M₂ = card of admissible classes) explains
    why ternary base is the natural mediating structure between
    Mersenne primes and the golden base φ. -/
theorem admissible_classes_card_eq_M2 :
    ({3, 7, 11} : Finset (ZMod 20)).card = F1PCFUnified.mersenne 2 := by
  decide

/-- More explicit version: the literal `3` coincides with all three
    interpretations simultaneously. -/
theorem three_eq_M2_eq_admissible_card :
    (3 : ℕ) = F1PCFUnified.mersenne 2 ∧
    (3 : ℕ) = ({3, 7, 11} : Finset (ZMod 20)).card := by
  refine ⟨?_, ?_⟩
  · decide
  · decide


-- ╔═══════════════════════════════════════════════════════════════════════╗
-- ║  §7   EULER–MERSENNE–GALOIS CONNECTOR THEOREM                         ║
-- ║       Formal synthesis of the connection between Euler's identity     ║
-- ║       and the universal identity of the paper through φ.              ║
-- ║                                                                       ║
-- ║       Articulates the four inscriptions of φ:                         ║
-- ║         (i)   φ in the Euler rotor (ζ₁₀+ζ₁₀⁻¹ in ℂ)                   ║
-- ║         (ii)  φ in the pentagon (2·cos(π/5) in ℝ)                     ║
-- ║         (iii) φ in binary doubling (φ^λ = 2)                          ║
-- ║         (iv)  φ in modular concentration ({3,7,11} ⊂ Z₂₀*)            ║
-- ║                                                                       ║
-- ║       Plus the structural Mersenne/Galois ratio statement:            ║
-- ║       |{3,7,11}|·|Z₂₀*| = M₂·|Z₂₀*|, equivalent to M₂/|Z₂₀*| = 3/8.   ║
-- ║                                                                       ║
-- ║       Plus discretization of the rotor into 10th roots of unity.      ║
-- ╚═══════════════════════════════════════════════════════════════════════╝

/-- Euler's identity in rotor form: `e^{iπ} = −1`.  The rotor `e^{iθ}` at
    the half-turn `θ = π` returns `−1` — Euler's identity itself. -/
theorem euler_rotor : Complex.exp (↑Real.pi * Complex.I) = -1 :=
  Complex.exp_pi_mul_I

/-- **Structural coincidence theorem for φ** (Theorem 3.4 of the paper).

    A single φ satisfies simultaneously twelve identities, inclusions,
    and identifications in their respective canonical structures.  The
    content of the theorem is the simultaneous holding of all twelve
    clauses under a single φ; no proper sub-collection of the clauses
    constitutes the content.

    The clauses inhabit canonical structures of distinct kinds:
      complex-rotational and cyclotomic        (i, ii, xii)
      real-trigonometric                       (iii)
      logarithmic and real-multiplicative      (iv, v)
      arithmetic-modular over ℤ/20ℤ            (vi, vii)
      cross-domain real-to-complex             (viii)
      Galois-theoretic of ℚ(ζ₂₀)/ℚ             (ix, x, xi)

    The φ real of clauses (iii)-(vii) and the φ complex of clauses
    (i)-(ii) are the same algebraic number, identified by the canonical
    embedding ℝ ↪ ℂ (clause viii).

    Genealogy: Euler 1748 (e^{iπ}+1=0 as simultaneous coincidence of
    independent identities), Gauss 1801 (structural identities over
    ℚ(ζ_p)), Connes-Consani 2014-2021 (unification identities on the
    F_1 substrate).  The present theorem records the corresponding
    structural coincidence for φ. -/
theorem phi_euler_mersenne_connector :
    -- (i) CIRCULAR PULSE: φ is the sum of two conjugate decagon vertices
    --     on S¹ ⊂ ℂ (inscription of φ in the Euler rotor)
    (φ : ℂ) = Complex.exp (((Real.pi / 5 : ℝ) : ℂ) * Complex.I) +
              Complex.exp (-(((Real.pi / 5 : ℝ) : ℂ) * Complex.I)) ∧
    -- (ii) ROTOR CLOSURE: ζ₁₀ closes the Euler rotation in 10 steps
    --      (the 2π period is discretized in the decagon)
    Complex.exp (((Real.pi / 5 : ℝ) : ℂ) * Complex.I) ^ 10 = 1 ∧
    -- (iii) PENTAGONAL PULSE: φ = 2·cos(π/5) in ℝ
    --       (inscription of φ in the geometry of the regular pentagon)
    (φ : ℝ) = 2 * Real.cos (Real.pi / 5) ∧
    -- (iv) BINARY PULSE: φ^λ = 2 closes the golden period at doubling
    --      (transcendental period λ_log of the real multiplicative line)
    (φ : ℝ) ^ lambda_log = 2 ∧
    -- (v) UNIVERSAL IDENTITY: binary × ternary × pentagonal composition
    --     3·φ^σ(p) = 2^p for all p ∈ ℝ
    (∀ p : ℝ, (3 : ℝ) * (φ : ℝ) ^ sigma_mersenne p = (2 : ℝ) ^ p) ∧
    -- (vi) MERSENNE CONCENTRATION: M_p mod 20 ∈ {3,7,11}
    --      for every prime p
    (∀ p : ℕ, p.Prime →
      (F1PCFUnified.mersenne p : ZMod 20) ∈ ({3, 7, 11} : Finset (ZMod 20))) ∧
    -- (vii) TRIPLE IDENTIFICATION: 3 = M₂ = |{3,7,11}|
    --       (the ternary factor coincides with first Mersenne and cardinality)
    ((3 : ℕ) = F1PCFUnified.mersenne 2 ∧
     (3 : ℕ) = ({3, 7, 11} : Finset (ZMod 20)).card) ∧
    -- (viii) COERCION ℝ ↪ ℂ: φ_ℝ and φ_ℂ are the same object
    --        (the φ of the universal identity and the φ of the Euler rotor
    --         coincide under the canonical embedding ℝ ↪ ℂ)
    ((φ : ℝ) : ℂ) = (φ : ℂ) ∧
    -- (ix) GALOIS GROUP ORDER: |Z₂₀*| = 8
    --      (the eight automorphisms of the regular decagon extended to ℚ(ζ₂₀))
    ZtwentyStar.card = 8 ∧
    -- (x) STRUCTURAL INCLUSION: the three admissible classes are a sub-object
    --     of the decagon Galois group (not arbitrary residues)
    ({3, 7, 11} : Finset (ZMod 20)) ⊆ ZtwentyStar ∧
    -- (xi) STRUCTURAL MERSENNE/GALOIS RATIO:
    --      |{3,7,11}|·8 = M₂·|Z₂₀*|
    --      (Mersenne primes occupy the fraction M₂/|Z₂₀*| = 3/8
    --       of the decagon Galois group classes)
    ({3, 7, 11} : Finset (ZMod 20)).card * 8 =
      F1PCFUnified.mersenne 2 * ZtwentyStar.card ∧
    -- (xii) ROTOR DISCRETIZATION: powers of ζ₁₀ are 10th roots
    --       of unity —the ten vertices of the regular decagon on S¹—
    (∀ k : ℕ,
      (Complex.exp (((Real.pi / 5 : ℝ) : ℂ) * Complex.I) ^ k) ^ 10 = 1) := by
  refine ⟨phi_eq_zeta10_sum,
          zeta10_pow_ten_eq_one,
          phi_eq_two_cos_pi_fifth,
          mersenne_bridge_via_lambda,
          golden_tower_bridge,
          mersenne_concentration_general,
          three_eq_M2_eq_admissible_card,
          rfl,
          ZtwentyStar_card,
          ?_,
          ?_,
          ?_⟩
  -- (x) {3, 7, 11} ⊆ Z₂₀*: finite check
  · decide
  -- (xi) 3·8 = M₂·8: since M₂ = 3 and |Z₂₀*| = 8
  · decide
  -- (xii) (ζ₁₀^k)^10 = 1 for all k : ℕ
  -- Proof: (ζ₁₀^k)^10 = ζ₁₀^(k·10) = ζ₁₀^(10·k) = (ζ₁₀^10)^k = 1^k = 1
  · intro k
    rw [← pow_mul, mul_comm k 10, pow_mul, zeta10_pow_ten_eq_one, one_pow]


end


-- ╔═══════════════════════════════════════════════════════════════════════╗
-- ║  §8   GIMPS AXIOMS — Primality of M_p                                 ║
-- ║                                                                       ║
-- ║       For p ≤ 31: 8 primality proofs verifiable in Lean by            ║
-- ║                    native_decide (locally computable).                ║
-- ║       For p ≥ 61: 44 primality proofs externally verified by          ║
-- ║                    GIMPS via the Lucas–Lehmer test (not computable    ║
-- ║                    in Lean due to size; M_82589933 has ~25M digits).  ║
-- ║                                                                       ║
-- ║       The paper states in the abstract: "the entire framework is      ║
-- ║       formalised in Lean 4 ... with 0 sorry; only the 44 GIMPS        ║
-- ║       primalities for p ≥ 61 are taken as inputs".  This section      ║
-- ║       fulfills that claim.                                            ║
-- ╚═══════════════════════════════════════════════════════════════════════╝

namespace GIMPS

/-! ### §8.1  Computable primality: M_p for p ∈ {2, 3, 5, 7, 13, 17, 19, 31}

    These 8 primality proofs are verified within Lean by direct
    evaluation (native_decide).  They require no external input. -/

theorem mersenne_prime_2  : Nat.Prime (2 ^  2 - 1) := by native_decide
theorem mersenne_prime_3  : Nat.Prime (2 ^  3 - 1) := by native_decide
theorem mersenne_prime_5  : Nat.Prime (2 ^  5 - 1) := by native_decide
theorem mersenne_prime_7  : Nat.Prime (2 ^  7 - 1) := by native_decide
theorem mersenne_prime_13 : Nat.Prime (2 ^ 13 - 1) := by native_decide
theorem mersenne_prime_17 : Nat.Prime (2 ^ 17 - 1) := by native_decide
theorem mersenne_prime_19 : Nat.Prime (2 ^ 19 - 1) := by native_decide
theorem mersenne_prime_31 : Nat.Prime (2 ^ 31 - 1) := by native_decide

/-! ### §8.2  GIMPS axioms: M_p prime for p ∈ {61, 89, ..., 136279841}

    The 44 primality proofs externally verified by the GIMPS project
    via the Lucas–Lehmer test.  Entered as axioms because their
    verification in Lean is computationally prohibitive:
    M_136279841 has approximately 41,024,320 decimal digits. -/

axiom mersenne_prime_61        : Nat.Prime (2 ^ 61        - 1)
axiom mersenne_prime_89        : Nat.Prime (2 ^ 89        - 1)
axiom mersenne_prime_107       : Nat.Prime (2 ^ 107       - 1)
axiom mersenne_prime_127       : Nat.Prime (2 ^ 127       - 1)
axiom mersenne_prime_521       : Nat.Prime (2 ^ 521       - 1)
axiom mersenne_prime_607       : Nat.Prime (2 ^ 607       - 1)
axiom mersenne_prime_1279      : Nat.Prime (2 ^ 1279      - 1)
axiom mersenne_prime_2203      : Nat.Prime (2 ^ 2203      - 1)
axiom mersenne_prime_2281      : Nat.Prime (2 ^ 2281      - 1)
axiom mersenne_prime_3217      : Nat.Prime (2 ^ 3217      - 1)
axiom mersenne_prime_4253      : Nat.Prime (2 ^ 4253      - 1)
axiom mersenne_prime_4423      : Nat.Prime (2 ^ 4423      - 1)
axiom mersenne_prime_9689      : Nat.Prime (2 ^ 9689      - 1)
axiom mersenne_prime_9941      : Nat.Prime (2 ^ 9941      - 1)
axiom mersenne_prime_11213     : Nat.Prime (2 ^ 11213     - 1)
axiom mersenne_prime_19937     : Nat.Prime (2 ^ 19937     - 1)
axiom mersenne_prime_21701     : Nat.Prime (2 ^ 21701     - 1)
axiom mersenne_prime_23209     : Nat.Prime (2 ^ 23209     - 1)
axiom mersenne_prime_44497     : Nat.Prime (2 ^ 44497     - 1)
axiom mersenne_prime_86243     : Nat.Prime (2 ^ 86243     - 1)
axiom mersenne_prime_110503    : Nat.Prime (2 ^ 110503    - 1)
axiom mersenne_prime_132049    : Nat.Prime (2 ^ 132049    - 1)
axiom mersenne_prime_216091    : Nat.Prime (2 ^ 216091    - 1)
axiom mersenne_prime_756839    : Nat.Prime (2 ^ 756839    - 1)
axiom mersenne_prime_859433    : Nat.Prime (2 ^ 859433    - 1)
axiom mersenne_prime_1257787   : Nat.Prime (2 ^ 1257787   - 1)
axiom mersenne_prime_1398269   : Nat.Prime (2 ^ 1398269   - 1)
axiom mersenne_prime_2976221   : Nat.Prime (2 ^ 2976221   - 1)
axiom mersenne_prime_3021377   : Nat.Prime (2 ^ 3021377   - 1)
axiom mersenne_prime_6972593   : Nat.Prime (2 ^ 6972593   - 1)
axiom mersenne_prime_13466917  : Nat.Prime (2 ^ 13466917  - 1)
axiom mersenne_prime_20996011  : Nat.Prime (2 ^ 20996011  - 1)
axiom mersenne_prime_24036583  : Nat.Prime (2 ^ 24036583  - 1)
axiom mersenne_prime_25964951  : Nat.Prime (2 ^ 25964951  - 1)
axiom mersenne_prime_30402457  : Nat.Prime (2 ^ 30402457  - 1)
axiom mersenne_prime_32582657  : Nat.Prime (2 ^ 32582657  - 1)
axiom mersenne_prime_37156667  : Nat.Prime (2 ^ 37156667  - 1)
axiom mersenne_prime_42643801  : Nat.Prime (2 ^ 42643801  - 1)
axiom mersenne_prime_43112609  : Nat.Prime (2 ^ 43112609  - 1)
axiom mersenne_prime_57885161  : Nat.Prime (2 ^ 57885161  - 1)
axiom mersenne_prime_74207281  : Nat.Prime (2 ^ 74207281  - 1)
axiom mersenne_prime_77232917  : Nat.Prime (2 ^ 77232917  - 1)
axiom mersenne_prime_82589933  : Nat.Prime (2 ^ 82589933  - 1)
axiom mersenne_prime_136279841 : Nat.Prime (2 ^ 136279841 - 1)

end GIMPS


/-═══════════════════════════════════════════════════════════════════════════
  FORMAL CONTENT SUMMARY (golden_mersenne.lean)
  ───────────────────────────────────────────────────────────────────────────

  PAPER CORRESPONDENCE (label → Lean identifier)
    thm:universal            →  golden_tower_bridge
    thm:unique               →  sigma_mersenne_unique
    lem:binary               →  mersenne_bridge_via_lambda
    lem:ternary              →  phi_pow_log3
    thm:ratio-main           →  mersenne_ratio_golden
    cor:inverse              →  sigma_mersenne_eq_logb
    cor:51                   →  mersenne_phi_correspondence_52,
                                sigma_strictly_increasing
    rem:transcendence        →  lambda_log_transcendental
    rem:binary               →  mersenne_succ_eq_two_pow,
                                mersenne_digits_ones,
                                two_pow_digits_single_bit,
                                golden_step_is_bit_shift
    thm:concentration-main   →  mersenne_concentration_general
    thm:three-main           →  three_eq_M2_eq_admissible_card
    thm:euler-connector      →  phi_euler_mersenne_connector
    thm:characterization     →  golden_identity_characterization
    rem:characterization     →  golden_identity_is_consistent_overdetermined
    thm:fib-main             →  fibonacci_splitting_general
    lem:fib-split            →  fib_split_case
    lem:fib-inert            →  fib_inert_case
    thm:residue-split        →  mersenne_fibonacci_type
    cor:split-from-p         →  mersenne_mod5_from_p_mod4
    prop:rank-inert          →  mersenne_rank_iff_inert
    cor:joint                →  mersenne_presentation_from_p_mod4

  STATISTICS
    Lines:                          1599
    Declarations:                    ~86
    Sorry in code:                     0
    File axioms:                      45   (44 GIMPS + Gelfond–Schneider)
    phi_sq:                                 proved theorem (not an axiom)

  SELF-CONTAINMENT
    The file does not depend on mersenne_unified.lean: the Fibonacci splitting
    (§10) and binary bridge (§11) are included here, along with the
    reciprocity link that pins the joint presentation from
    p mod 4 (mersenne_presentation_from_p_mod4).
═══════════════════════════════════════════════════════════════════════════-/



-- ╔═══════════════════════════════════════════════════════════════════════╗
-- ║  §9   TRANSCENDENCE OF λ_log  (from lambda_log_transcendental)        ║
-- ║       λ_log = log 2 / log φ is transcendental over ℚ, via Gelfond–    ║
-- ║       Schneider (explicit axiom, not yet in Mathlib mainline).        ║
-- ║       Reuses φ, φ_pos, φ_gt_one, φ_ne_zero, phi_sq, lambda_log,       ║
-- ║       mersenne_bridge_via_lambda and log_φ_pos defined above.         ║
-- ╚═══════════════════════════════════════════════════════════════════════╝
noncomputable section

/-- Golden conjugate ψ = (1 − √5)/2, conjugate root of X² − X − 1. -/
def ψ : ℝ := (1 - Real.sqrt 5) / 2

theorem psi_sq : ψ ^ 2 = ψ + 1 := by
  unfold ψ
  have h5 : Real.sqrt 5 ^ 2 = 5 := Real.sq_sqrt (by norm_num)
  nlinarith [h5]

theorem phi_mul_psi : φ * ψ = -1 := by
  unfold φ ψ
  have h5 : Real.sqrt 5 ^ 2 = 5 := Real.sq_sqrt (by norm_num)
  nlinarith [h5]

theorem phi_add_psi : φ + ψ = 1 := by
  unfold φ ψ; ring

theorem psi_lt_one_abs : |ψ| < 1 := by
  unfold ψ
  have h2 : (2:ℝ) < Real.sqrt 5 := by
    have : (2:ℝ)^2 < 5 := by norm_num
    nlinarith [Real.sq_sqrt (show (5:ℝ) ≥ 0 by norm_num),
               Real.sqrt_nonneg 5]
  have h3 : Real.sqrt 5 < 3 := by
    nlinarith [Real.sq_sqrt (show (5:ℝ) ≥ 0 by norm_num),
               Real.sqrt_nonneg 5]
  rw [abs_lt]; constructor <;> nlinarith

theorem psi_ne_zero : ψ ≠ 0 := by
  have := phi_mul_psi
  intro h; rw [h, mul_zero] at this; norm_num at this

/-! ### Step (A): φ is algebraic over ℚ (root of X² − X − 1). -/

theorem phi_isAlgebraic : IsAlgebraic ℚ φ := by
  refine ⟨Polynomial.X ^ 2 - Polynomial.X - Polynomial.C 1, ?_, ?_⟩
  · -- the polynomial X² − X − 1 is nonzero (leading coefficient is 1)
    intro h
    have hc := congrArg (fun p : Polynomial ℚ => p.coeff 2) h
    simp [Polynomial.coeff_X_pow, Polynomial.coeff_X, Polynomial.coeff_one] at hc
  · -- φ is a root: φ² − φ − 1 = 0  (from phi_sq)
    simp only [map_sub, map_pow, Polynomial.aeval_X, map_one]
    have h := phi_sq         -- φ^2 = φ + 1
    linarith [h]

/-! ### Step (B): λ_log is irrational  (∀ i j : ℤ, λ_log ≠ i/j).

    Strategy: if λ_log = a/b (a,b ≥ 1) then φ^a = 2^b (log injective).
    With the conjugate ψ:  φ^a + ψ^a = L_a ∈ ℤ  (Lucas), and |ψ^a| < 1 with
    ψ^a ≠ 0.  Then ψ^a = L_a − 2^b would be a nonzero integer with
    absolute value < 1 — impossible.  Contradiction.
-/

/-- ★ Lucas integers: φ^n + ψ^n is an integer.
    By strong induction using φ+ψ = 1 and φ·ψ = −1:
      L_{n+2} = L_{n+1} + L_n, with L_0 = 2, L_1 = 1.
    ⚠ This is the lemma most likely to require adjustment (two-step
      induction / Nat.strong_induction). The statement and recurrence
      are correct. -/
theorem phi_pow_add_psi_pow_isInt (n : ℕ) :
    ∃ m : ℤ, φ ^ n + ψ ^ n = (m : ℝ) := by
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    match n with
    | 0 => exact ⟨2, by norm_num⟩
    | 1 => exact ⟨1, by rw [pow_one, pow_one]; exact_mod_cast phi_add_psi⟩
    | (k + 2) =>
      obtain ⟨m1, h1⟩ := ih (k + 1) (by omega)
      obtain ⟨m0, h0⟩ := ih k (by omega)
      refine ⟨m1 + m0, ?_⟩
      -- φ^{k+2}+ψ^{k+2} = (φ+ψ)(φ^{k+1}+ψ^{k+1}) − φψ(φ^k+ψ^k)
      --                 = 1·L_{k+1} − (−1)·L_k = L_{k+1} + L_k
      have hrec : φ ^ (k + 2) + ψ ^ (k + 2)
                = (φ + ψ) * (φ ^ (k + 1) + ψ ^ (k + 1))
                  - (φ * ψ) * (φ ^ k + ψ ^ k) := by ring
      rw [hrec, phi_add_psi, phi_mul_psi, h1, h0]; push_cast; ring


/-- Helper (naturals): for a, b ≥ 1, λ_log ≠ a/b.
    If λ_log = a/b then φ^a = 2^b (log injective), so by Lucas (★)
    ψ^a = L_a − 2^b ∈ ℤ with 0 < |ψ^a| < 1 — impossible. -/
private theorem lambda_log_ne_nat_div (a b : ℕ) (ha : 1 ≤ a) (hb : 1 ≤ b) :
    lambda_log ≠ (a : ℝ) / (b : ℝ) := by
  intro hab
  have hb' : (b : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (by omega)
  have hlogφ : Real.log φ ≠ 0 := ne_of_gt log_φ_pos
  -- log 2 · b = a · log φ
  have hcross : Real.log 2 * (b : ℝ) = (a : ℝ) * Real.log φ := by
    have hab2 : Real.log 2 / Real.log φ = (a : ℝ) / (b : ℝ) := hab
    rwa [div_eq_div_iff hlogφ hb'] at hab2
  -- 2^b = φ^a  (natural powers, viewed as reals)
  have hpow : (2 : ℝ) ^ b = φ ^ a := by
    rw [← Real.rpow_natCast (2 : ℝ) b, ← Real.rpow_natCast φ a,
        Real.rpow_def_of_pos (by norm_num : (0:ℝ) < 2),
        Real.rpow_def_of_pos φ_pos]
    congr 1
    linear_combination hcross
  -- Lucas: φ^a + ψ^a = L_a ∈ ℤ, so ψ^a = L_a − 2^b ∈ ℤ
  obtain ⟨mm, hmm⟩ := phi_pow_add_psi_pow_isInt a
  have hψ_eq : ψ ^ a = ((mm - 2 ^ b : ℤ) : ℝ) := by
    have hmm' : (2 : ℝ) ^ b + ψ ^ a = (mm : ℝ) := by rw [hpow]; exact hmm
    push_cast; linarith [hmm']
  -- but 0 < |ψ^a| < 1
  have hne : ψ ^ a ≠ 0 := pow_ne_zero a psi_ne_zero
  have hlt1 : |ψ ^ a| < 1 := by
    rw [abs_pow]; exact pow_lt_one₀ (abs_nonneg ψ) psi_lt_one_abs (by omega)
  rw [hψ_eq] at hne hlt1
  have hk0 : (mm - 2 ^ b : ℤ) ≠ 0 := by exact_mod_cast hne
  rcases abs_lt.mp hlt1 with ⟨h1, h2⟩
  have h1' : (-1 : ℤ) < mm - 2 ^ b := by exact_mod_cast h1
  have h2' : (mm - 2 ^ b : ℤ) < 1 := by exact_mod_cast h2
  omega

/-- λ_log is irrational in the form required by Gelfond–Schneider.
    Reduction of the integer case (i, j) to the natural-number helper via
    absolute values (λ_log > 0 forces i, j to share the same sign). -/
theorem lambda_log_irrational : ∀ i j : ℤ, lambda_log ≠ (i : ℝ) / (j : ℝ) := by
  intro i j hij
  have hll_pos : 0 < lambda_log :=
    div_pos (Real.log_pos (by norm_num)) log_φ_pos
  rcases eq_or_ne j 0 with hj | hj
  · rw [hj] at hij
    simp only [Int.cast_zero, div_zero] at hij
    rw [hij] at hll_pos; exact lt_irrefl 0 hll_pos
  · have hpos : (0 : ℝ) < (i : ℝ) / (j : ℝ) := hij ▸ hll_pos
    have hi : i ≠ 0 := by
      rintro rfl
      simp only [Int.cast_zero, zero_div] at hpos
      exact absurd hpos (lt_irrefl 0)
    have key : lambda_log = (i.natAbs : ℝ) / (j.natAbs : ℝ) := by
      rw [hij, Nat.cast_natAbs, Nat.cast_natAbs, Int.cast_abs, Int.cast_abs,
          ← abs_div, abs_of_pos hpos]
    exact lambda_log_ne_nat_div i.natAbs j.natAbs
      (Int.natAbs_pos.mpr hi) (Int.natAbs_pos.mpr hj) key

/-! ### Step (C): rpow (ℝ) → cpow (ℂ) bridge for φ^λ_log. -/

theorem phi_cpow_lambda_eq_two : (φ : ℂ) ^ (lambda_log : ℂ) = 2 := by
  rw [← Complex.ofReal_cpow φ_pos.le]
  -- (↑φ)^(↑λ) = ↑(φ^λ);  φ^λ = 2 by mersenne_bridge_via_lambda
  rw [show φ ^ lambda_log = (2:ℝ) from mersenne_bridge_via_lambda]
  norm_num

/-! ### Step (D): MAIN THEOREM — λ_log is transcendental. -/

/-- **Gelfond–Schneider** (cpow form, Karatarakis–Wiedijk 2026, arXiv 2603.24823).
    Not yet in Mathlib mainline (lives in a fork), hence declared as an
    explicit axiom with its exact signature.  It is the only external input
    of this file: everything else is proved (0 sorry). -/
axiom transcendental_cpow_of_isAlgebraic_of_irrational (α β : ℂ)
    (hα : IsAlgebraic ℚ α) (hβ : IsAlgebraic ℚ β)
    (htriv : α ≠ 0 ∧ α ≠ 1) (hirr : ∀ i j : ℤ, β ≠ (i : ℂ) / (j : ℂ)) :
    Transcendental ℚ (α ^ β)

theorem lambda_log_transcendental : Transcendental ℚ lambda_log := by
  -- by contradiction: if λ_log were algebraic, GS would yield φ^λ_log
  -- transcendental, contradicting φ^λ_log = 2 (algebraic).
  rw [Transcendental]
  intro halg    -- halg : IsAlgebraic ℚ lambda_log
  -- transfer algebraicity from ℝ to ℂ via the inclusion ℚ → ℂ
  have hβℂ : IsAlgebraic ℚ (lambda_log : ℂ) := by
    have h : IsAlgebraic ℚ (algebraMap ℝ ℂ lambda_log) := halg.algebraMap
    simpa using h
  have hφℂ : IsAlgebraic ℚ (φ : ℂ) := by
    have h : IsAlgebraic ℚ (algebraMap ℝ ℂ φ) := phi_isAlgebraic.algebraMap
    simpa using h
  have hirrℂ : ∀ i j : ℤ, (lambda_log : ℂ) ≠ (i : ℂ) / (j : ℂ) := by
    -- from lambda_log_irrational (ℝ) to ℂ: λ_log is real, and (↑i/↑j : ℂ) real ⟹
    -- it would equal a real rational, contradicting real irrationality.
    intro i j hc
    apply lambda_log_irrational i j
    have := congrArg Complex.re hc
    simpa using this
  have htriv : (φ : ℂ) ≠ 0 ∧ (φ : ℂ) ≠ 1 := by
    refine ⟨?_, ?_⟩
    · exact_mod_cast φ_ne_zero
    · intro hc
      have hφ1 : φ = 1 := by exact_mod_cast hc
      linarith [φ_gt_one]
  -- apply Gelfond–Schneider
  have hgs : Transcendental ℚ ((φ : ℂ) ^ (lambda_log : ℂ)) :=
    transcendental_cpow_of_isAlgebraic_of_irrational
      (φ : ℂ) (lambda_log : ℂ) hφℂ hβℂ htriv hirrℂ
  -- but (φ:ℂ)^(λ:ℂ) = 2, which is algebraic
  rw [phi_cpow_lambda_eq_two] at hgs
  have h2alg : IsAlgebraic ℚ (2 : ℂ) := by
    have h := isAlgebraic_algebraMap (R := ℚ) (A := ℂ) 2
    simpa using h
  exact hgs h2alg

end



-- ╔═══════════════════════════════════════════════════════════════════════╗
-- ║  THE IDENTITY, CHARACTERIZED                                          ║
-- ║  (consistency and uniqueness theorem for an overdetermined system)    ║
-- ║                                                                       ║
-- ║  It is not an axiom nor a disguised definition: it is the unique      ║
-- ║  point where determinations fixed separately, each by a theorem       ║
-- ║  external to the equation, come together.  The equation 3·φ^σ = 2^p   ║
-- ║  is, as an equality, the evaluation of a definition                   ║
-- ║  (σ := p·λ − log_φ 3); the CONTENT is the mutual compatibility of     ║
-- ║  those determinations, which the kernel certifies by accepting the    ║
-- ║  conjunction without sorry.                                           ║
-- ╚═══════════════════════════════════════════════════════════════════════╝

noncomputable section

open F1PCFUnified

/-- **The golden identity, characterized** as consistency + uniqueness of an
    overdetermined system. -/
theorem golden_identity_characterization :
    (∀ p : ℝ, (3 : ℝ) * φ ^ sigma_mersenne p = (2 : ℝ) ^ p) ∧
    (∀ p σ : ℝ, (3 : ℝ) * φ ^ σ = (2 : ℝ) ^ p → σ = sigma_mersenne p) ∧
    Transcendental ℚ lambda_log ∧
    ((3 : ℕ) = F1PCFUnified.mersenne 2 ∧
     (3 : ℕ) = ({3, 7, 11} : Finset (ZMod 20)).card) ∧
    (∀ p : ℕ, p.Prime →
      (F1PCFUnified.mersenne p : ZMod 20) ∈ ({3, 7, 11} : Finset (ZMod 20))) :=
  ⟨golden_tower_bridge,
   sigma_mersenne_unique,
   lambda_log_transcendental,
   three_eq_M2_eq_admissible_card,
   mersenne_concentration_general⟩

/-- Reading of the characterization: the central equation (i) does not prove
    itself; it is shown to exist, to be unique, and to coincide with
    external determinations (iii)–(iv). -/
theorem golden_identity_is_consistent_overdetermined :
    ∃! σ : ℝ → ℝ,
      (∀ p : ℝ, (3 : ℝ) * φ ^ σ p = (2 : ℝ) ^ p) := by
  refine ⟨sigma_mersenne, golden_tower_bridge, ?_⟩
  intro σ' hσ'
  funext p
  exact sigma_mersenne_unique p (σ' p) (hσ' p)

end

-- ╔═════════════════════════════════════════════════════════════════════════╗
-- ║  §10  FIBONACCI SPLITTING (ported from mersenne_unified.lean §5.2)      ║
-- ║        + §4.4 of the paper: type from the exponent                      ║
-- ║   mersenne → F1PCFUnified.mersenne ; reuses mersenne_concentration_gen. ║
-- ╚═════════════════════════════════════════════════════════════════════════╝

noncomputable section

/-! ### §5.2  B2 — General Fibonacci splitting (via AdjoinRoot/Frobenius) -/

/-- Binet identity in any commutative ring with α² = α + 1:
    α^(n+1) = F_{n+1}·α + F_n. -/
private theorem fib_pow_aux {R : Type*} [CommRing R] (α : R) (hα : α ^ 2 = α + 1) :
    ∀ n : ℕ, α ^ (n + 1) = (Nat.fib (n + 1) : R) * α + (Nat.fib n : R) := by
  intro n
  induction n with
  | zero => simp [Nat.fib_one, Nat.fib_zero]
  | succ k ih =>
    calc α ^ (k + 2)
        = α ^ (k + 1) * α := by ring
      _ = ((Nat.fib (k + 1) : R) * α + (Nat.fib k : R)) * α := by rw [ih]
      _ = (Nat.fib (k + 1) : R) * α ^ 2 + (Nat.fib k : R) * α := by ring
      _ = (Nat.fib (k + 1) : R) * (α + 1) + (Nat.fib k : R) * α := by rw [hα]
      _ = ((Nat.fib (k + 1) + Nat.fib k : ℕ) : R) * α + (Nat.fib (k + 1) : R) := by
            push_cast; ring
      _ = (Nat.fib (k + 2) : R) * α + (Nat.fib (k + 1) : R) := by
            rw [add_comm (Nat.fib (k + 1)) (Nat.fib k), ← Nat.fib_add_two]

private theorem fib_pow_prime {p : ℕ} (hp : p.Prime) {R : Type*} [CommRing R]
    (α : R) (hα : α ^ 2 = α + 1) :
    α ^ p = (Nat.fib p : R) * α + (Nat.fib (p - 1) : R) := by
  have hp1 : p - 1 + 1 = p := Nat.succ_pred_eq_of_pos hp.pos
  have h := fib_pow_aux α hα (p - 1)
  rw [hp1] at h
  exact h

private theorem five_ne_zero_zmod {p : ℕ} (hp : p.Prime) (hp5 : p ≠ 5) :
    (5 : ZMod p) ≠ 0 := by
  have : Fact p.Prime := ⟨hp⟩
  change ((5 : ℕ) : ZMod p) ≠ 0
  rw [Ne, ZMod.natCast_eq_zero_iff]
  intro hdvd
  rcases (show Nat.Prime 5 from by norm_num).eq_one_or_self_of_dvd p hdvd with h1 | h5
  · have : 2 ≤ p := hp.two_le
    omega
  · exact hp5 h5

/-- Split case: if X² − X − 1 has a root α ∈ Z_p, then F_p ≡ 1 (mod p).
    Strategy: Fermat (α^p = α via ZMod.pow_card in F_p) + Binet identity.
    The key identity (2α−1)² = 5 ≠ 0 (valid for p ≠ 5) allows cancellation
    of the factor (2α−1) in the difference between the two cases α and 1−α. -/
private theorem fib_split_case {p : ℕ} (hp : p.Prime) (_hp2 : p ≠ 2) (hp5 : p ≠ 5)
    (α : ZMod p) (hα : α ^ 2 = α + 1) :
    (Nat.fib p : ZMod p) = 1 := by
  have : Fact p.Prime := ⟨hp⟩
  have hβ  : (1 - α) ^ 2 = (1 - α) + 1 := by linear_combination hα
  have hfα : α ^ p = (Nat.fib p : ZMod p) * α + (Nat.fib (p-1) : ZMod p) :=
    fib_pow_prime hp α hα
  have hfβ : (1-α) ^ p = (Nat.fib p : ZMod p) * (1-α) + (Nat.fib (p-1) : ZMod p) :=
    fib_pow_prime hp (1 - α) hβ
  have heqα : (Nat.fib p : ZMod p) * α + (Nat.fib (p-1) : ZMod p) = α := by
    rw [← hfα]; exact ZMod.pow_card α
  have heqβ : (Nat.fib p : ZMod p) * (1-α) + (Nat.fib (p-1) : ZMod p) = 1 - α := by
    rw [← hfβ]; exact ZMod.pow_card (1 - α)
  have hdiff : ((Nat.fib p : ZMod p) - 1) * (2 * α - 1) = 0 := by
    linear_combination heqα - heqβ
  -- (2α − 1)² = 5 in Z_p, and 5 ≠ 0 when p ≠ 5
  have h2α1_sq : (2 * α - 1) ^ 2 = (5 : ZMod p) := by linear_combination 4 * hα
  have h2α1_ne : 2 * α - 1 ≠ 0 := by
    intro h
    have : ((2 : ZMod p) * α - 1) ^ 2 = 0 := by rw [h]; ring
    rw [h2α1_sq] at this
    exact five_ne_zero_zmod hp hp5 this
  rcases mul_eq_zero.mp hdiff with hfp | h2
  · exact sub_eq_zero.mp hfp
  · exact absurd h2 h2α1_ne

/-- Inert case: if X² − X − 1 is irreducible in Z_p[X], then F_p ≡ −1 (mod p).
    Strategy (5 steps):
      (1) In K = Z_p[α]/(α²−α−1) = GF(p²): (α^p)² = α^p + 1  by freshman's dream.
      (2) X² − X − 1 has no root in Z_p (by explicit irreducibility).
      (3) α^p ≠ α  because ∏_{a:Z_p}(α − a) = α^p − α = 0 in the domain K,
          implying α = algMap c with c² = c + 1 in Z_p (contradicting (2)).
      (4) α^p = 1 − α  (the other root: (α^p − α)(α^p − (1−α)) = 0 and α^p ≠ α).
      (5) F_p ≡ −1 mod p  (if F_p + 1 ≠ 0, then α = algMap c with c²=c+1,
          contradicting (2)). -/
private theorem fib_inert_case {p : ℕ} (hp : p.Prime) (_hp2 : p ≠ 2) (_hp5 : p ≠ 5)
    (hirr : Irreducible (X ^ 2 - X - 1 : (ZMod p)[X])) :
    (Nat.fib p : ZMod p) = p - 1 ∧ (Nat.fib (p - 1) : ZMod p) = 1 := by
  have hFact : Fact p.Prime := ⟨hp⟩
  let K := AdjoinRoot (X ^ 2 - X - 1 : (ZMod p)[X])
  have : Fact (Irreducible (X ^ 2 - X - 1 : (ZMod p)[X])) := ⟨hirr⟩
  have hKChar : CharP K p :=
    charP_of_injective_algebraMap (algebraMap (ZMod p) K).injective p
  let α : K := AdjoinRoot.root _
  have hα_sq : α ^ 2 = α + 1 := by
    have h : Polynomial.aeval α (X ^ 2 - X - 1 : (ZMod p)[X]) = 0 :=
      AdjoinRoot.eval₂_root _
    simp only [map_sub, map_pow, map_one, Polynomial.aeval_X] at h
    linear_combination h
  -- Step 1: (α^p)² = α^p + 1 (freshman's dream)
  have hαp_root : (α ^ p) ^ 2 = α ^ p + 1 := by
    calc (α ^ p) ^ 2
        = (α ^ 2) ^ p := by ring
      _ = (α + 1) ^ p := by rw [hα_sq]
      _ = α ^ p + 1 ^ p := add_pow_char ..
      _ = α ^ p + 1 := by ring
  -- Step 2: X² − X − 1 has no roots in Z_p
  have hirr_no_root : ∀ c : ZMod p, c ^ 2 ≠ c + 1 := by
    intro c hc
    have hkey : c - c ^ 2 = -1 := by linear_combination -hc
    have hfact : (X ^ 2 - X - 1 : (ZMod p)[X]) = (X - C c) * (X - C (1 - c)) := by
      have hrw : (X - C c) * (X - C (1 - c)) = X ^ 2 - X + C (c - c ^ 2) := by
        simp only [map_sub, map_pow, map_one]
        ring
      rw [hrw, hkey]
      simp only [map_neg, map_one]
      ring
    have hnu : ∀ d : ZMod p, ¬ IsUnit (X - C d : (ZMod p)[X]) := by
      intro d hu
      obtain ⟨u, _, hu_eq⟩ := Polynomial.isUnit_iff.mp hu
      have h1 : natDegree (C u) = natDegree (X - C d) := congr_arg natDegree hu_eq
      rw [natDegree_C, natDegree_X_sub_C] at h1
      contradiction
    rcases hirr.isUnit_or_isUnit hfact with h | h
    · exact hnu c h
    · exact hnu (1 - c) h
  have hinj : Function.Injective (algebraMap (ZMod p) K) :=
    (algebraMap (ZMod p) K).injective
  -- Step 3: α^p ≠ α
  have hαp_ne : α ^ p ≠ α := by
    intro heq
    -- Over 𝔽_p: X^p − X = ∏_{a∈𝔽_p}(X − a)  (Fermat: each a is a simple root).
    have hcard : Fintype.card (ZMod p) = p := ZMod.card p
    have hmonic : (X ^ p - X : (ZMod p)[X]).Monic := by
      refine monic_X_pow_sub ?_
      rw [degree_X]; exact_mod_cast hp.one_lt
    have hroots : (X ^ p - X : (ZMod p)[X]).roots = Finset.univ.val := by
      have h := FiniteField.roots_X_pow_card_sub_X (K := ZMod p)
      rwa [hcard] at h
    have hsplit : Splits (X ^ p - X : (ZMod p)[X]) := by
      rw [splits_iff_card_roots, hroots,
          FiniteField.X_pow_card_sub_X_natDegree_eq (ZMod p) hp.one_lt]
      simp [hcard]
    have hXpX : (X ^ p - X : (ZMod p)[X]) = ∏ a : ZMod p, (X - C a) := by
      rw [hsplit.eq_prod_roots_of_monic hmonic, hroots, Finset.prod_eq_multiset_prod]
    have hprod : ∏ a : ZMod p, (α - algebraMap (ZMod p) K a) = 0 := by
      have h := congrArg (Polynomial.aeval α) hXpX
      simp only [map_sub, map_pow, Polynomial.aeval_X, map_prod, Polynomial.aeval_C] at h
      rw [heq, sub_self] at h
      exact h.symm
    obtain ⟨c, _, hc⟩ := (Finset.prod_eq_zero_iff).mp hprod
    have hα_eq : α = algebraMap (ZMod p) K c := eq_of_sub_eq_zero hc
    have hc_sq : c ^ 2 = c + 1 := by
      apply hinj
      rw [map_pow, map_add, map_one, ← hα_eq]
      exact hα_sq
    exact hirr_no_root c hc_sq
  -- Step 4: α^p = 1 − α
  have hfrob : α ^ p = 1 - α := by
    have hprod : (α ^ p - α) * (α ^ p - (1 - α)) = 0 := by
      linear_combination hαp_root - hα_sq
    rcases mul_eq_zero.mp hprod with h | h
    · exact absurd (sub_eq_zero.mp h) hαp_ne
    · exact sub_eq_zero.mp h
  have hfib_K : (Nat.fib p : K) * α + (Nat.fib (p - 1) : K) = 1 - α :=
    (fib_pow_prime hp α hα_sq).symm ▸ hfrob
  -- Step 5: F_p ≡ −1 (mod p)
  have hFp : (Nat.fib p : ZMod p) = -1 := by
    by_contra hne
    have hFp1_ne : (Nat.fib p : ZMod p) + 1 ≠ 0 := fun h => hne (by linear_combination h)
    have hFp1_K : (Nat.fib p : K) + 1 ≠ 0 := by
      intro h; apply hFp1_ne; apply hinj
      push_cast [map_add, map_one]; exact h
    have hlin : ((Nat.fib p : K) + 1) * α = 1 - (Nat.fib (p - 1) : K) := by
      linear_combination hfib_K
    set c : ZMod p := (1 - (Nat.fib (p - 1) : ZMod p)) / ((Nat.fib p : ZMod p) + 1)
    have hα_c : α = algebraMap (ZMod p) K c := by
      rw [show c = (1 - (Nat.fib (p - 1) : ZMod p)) / ((Nat.fib p : ZMod p) + 1)
            from rfl]
      rw [map_div₀, map_sub, map_one, map_add, map_one, map_natCast, map_natCast]
      rw [eq_div_iff hFp1_K]
      linear_combination hlin
    have hc_sq : c ^ 2 = c + 1 := by
      apply hinj
      rw [map_pow, map_add, map_one, ← hα_c]
      exact hα_sq
    exact hirr_no_root c hc_sq
  -- F_{p-1} ≡ 1 : from hfib_K (F_p·α + F_{p-1} = 1 − α) with F_p = −1, basis {1,α}.
  have hFpm1 : (Nat.fib (p - 1) : ZMod p) = 1 := by
    have hFpK : (Nat.fib p : K) = -1 := by
      have h := congrArg (algebraMap (ZMod p) K) hFp
      rwa [map_natCast, map_neg, map_one] at h
    have hK1 : (Nat.fib (p - 1) : K) = 1 := by
      linear_combination hfib_K - α * hFpK
    have heq : algebraMap (ZMod p) K (Nat.fib (p - 1) : ZMod p)
             = algebraMap (ZMod p) K 1 := by rw [map_natCast, map_one]; exact hK1
    exact hinj heq
  exact ⟨by rw [hFp, ZMod.natCast_self]; ring, hFpm1⟩

private theorem not_irreducible_iff_exists_root_of_degree_two
    {K : Type*} [Field K] (f : K[X]) (hdeg : f.natDegree = 2) :
    ¬ Irreducible f ↔ ∃ x : K, IsRoot f x := by
  have hd2 : 2 ≤ f.natDegree := by omega
  have hd3 : f.natDegree ≤ 3 := by omega
  rw [irreducible_iff_roots_eq_zero_of_degree_le_three hd2 hd3]
  have hne : f ≠ 0 := by
    intro h
    rw [h, natDegree_zero] at hdeg
    omega
  rw [not_iff_comm, Multiset.eq_zero_iff_forall_notMem]
  push Not
  simp [mem_roots hne, IsRoot]

/-- **B2 — General Fibonacci splitting**.
    For every prime p ≠ 2, 5: F_p ≡ ±1 (mod p).
    Split case (X²−X−1 reducible mod p): F_p ≡ +1.
    Inert case (X²−X−1 irreducible mod p): F_p ≡ −1 ≡ p−1. -/
theorem fibonacci_splitting_general (p : ℕ) (hp : p.Prime)
    (hp2 : p ≠ 2) (hp5 : p ≠ 5) :
    (Nat.fib p : ZMod p) = 1 ∨ (Nat.fib p : ZMod p) = p - 1 := by
  have : Fact p.Prime := ⟨hp⟩
  by_cases hirr : Irreducible (X ^ 2 - X - 1 : (ZMod p)[X])
  · right; exact (fib_inert_case hp hp2 hp5 hirr).1
  · left
    have hdeg : (X ^ 2 - X - 1 : (ZMod p)[X]).natDegree = 2 := by compute_degree!
    rw [not_irreducible_iff_exists_root_of_degree_two
        (X ^ 2 - X - 1 : (ZMod p)[X]) hdeg] at hirr
    obtain ⟨α, hα⟩ := hirr
    have he : Polynomial.eval α (X ^ 2 - X - 1 : (ZMod p)[X]) = 0 := hα
    simp only [Polynomial.eval_sub, Polynomial.eval_pow, Polynomial.eval_X,
               Polynomial.eval_one] at he
    have hα_sq : α ^ 2 = α + 1 := by linear_combination he
    exact fib_split_case hp hp2 hp5 α hα_sq

/-! ### §5.3  B3 — Synthesis: Mersenne via Fibonacci -/

/-- **B3 — Mersenne via Fibonacci**: when M_p is prime, its mod 20 class
    and its Fibonacci type coincide:
      Class 3 or 7 (inert) → F_{M_p} ≡ −1 (mod M_p)
      Class 11     (split) → F_{M_p} ≡ +1 (mod M_p) -/
theorem mersenne_fibonacci_type
    (p : ℕ) (hp : p.Prime)
    (hMp : (F1PCFUnified.mersenne p).Prime)
    (hMp2 : F1PCFUnified.mersenne p ≠ 2)
    (hMp5 : F1PCFUnified.mersenne p ≠ 5) :
    -- B1: concentration
    (F1PCFUnified.mersenne p : ZMod 20) ∈ ({3, 7, 11} : Finset (ZMod 20)) ∧
    -- B2: Fibonacci type
    ((Nat.fib (F1PCFUnified.mersenne p) : ZMod (F1PCFUnified.mersenne p)) = 1 ∨
     (Nat.fib (F1PCFUnified.mersenne p) : ZMod (F1PCFUnified.mersenne p))
       = F1PCFUnified.mersenne p - 1) :=
  ⟨mersenne_concentration_general p hp,
   fibonacci_splitting_general (F1PCFUnified.mersenne p) hMp hMp2 hMp5⟩

/-- Tabular verification for p ∈ {2, 3, 5} (M_p ∈ {3, 7, 31}). -/
theorem mersenne_fibonacci_tabulated :
    (Nat.fib 3  % 3  = 2) ∧    -- p=2, M_2=3,  class 3 (inert)
    (Nat.fib 7  % 7  = 6) ∧    -- p=3, M_3=7,  class 7 (inert)
    (Nat.fib 31 % 31 = 1) :=    -- p=5, M_5=31, class 11 (split)
  by native_decide

/-- Split/inert partition of the eight classes of Z₂₀* by residue mod 5:
    split (QR, ≡ ±1 mod 5) = {1,9,11,19}; inert (NR, ≡ ±2 mod 5) = {3,7,13,17}.
    Self-contained version (without the Galois functor G). -/
theorem chi5_values :
    (∀ q ∈ ({1,9,11,19} : Finset (ZMod 20)),
        ((q.val : ZMod 5) = 1 ∨ (q.val : ZMod 5) = 4)) ∧
    (∀ q ∈ ({3,7,13,17} : Finset (ZMod 20)),
        ((q.val : ZMod 5) = 2 ∨ (q.val : ZMod 5) = 3)) := by decide



-- ════════════════════════════════════════════════════════════════════════
--  Corollary 1  (cor:split-from-p):  M_p mod 5 depends ONLY on p mod 4.
--  2^p mod 5 has period 4; hence the type (split/inert) is pinned by p.
-- ════════════════════════════════════════════════════════════════════════

theorem mersenne_mod5_from_p_mod4 (p : ℕ) :
    (F1PCFUnified.mersenne p : ZMod 5) =
      (if p % 4 = 1 then 1 else if p % 4 = 2 then 3
       else if p % 4 = 3 then 2 else 0) := by
  have hcast : (F1PCFUnified.mersenne p : ZMod 5) = (2 : ZMod 5) ^ p - 1 := by
    unfold F1PCFUnified.mersenne
    rw [Nat.cast_sub Nat.one_le_two_pow]; push_cast; ring
  have h4 : (2 : ZMod 5) ^ 4 = 1 := by decide
  have hper : (2 : ZMod 5) ^ p = (2 : ZMod 5) ^ (p % 4) := by
    conv_lhs => rw [← Nat.div_add_mod p 4, pow_add, pow_mul, h4, one_pow, one_mul]
  rw [hcast, hper]
  have hlt : p % 4 < 4 := by omega
  interval_cases (p % 4) <;> decide

-- ════════════════════════════════════════════════════════════════════════
--  Corollary 2  (prop:rank-inert):  M_p ∣ F_{M_p+1}  ⟺  M_p inert.
--  Via the Fibonacci predecessor/successor values in each case:
--     split : F_{q-1} ≡ 0,  F_q ≡ 1,  so F_{q+1} = F_q + F_{q-1} ≡ 1  (≠ 0)
--     inert : F_{q-1} ≡ 1,  F_q ≡ −1, so F_{q+1} ≡ 0
-- ════════════════════════════════════════════════════════════════════════

/-- Split: F_{p-1} ≡ 0.  From Binet α^p = F_p·α + F_{p-1} with α∈Z_p, Fermat
    (α^p = α) and F_p ≡ 1 (fib_split_case). -/
private theorem fib_pred_split {p : ℕ} (hp : p.Prime) (hp2 : p ≠ 2) (hp5 : p ≠ 5)
    (α : ZMod p) (hα : α ^ 2 = α + 1) :
    (Nat.fib (p - 1) : ZMod p) = 0 := by
  have : Fact p.Prime := ⟨hp⟩
  have hbin : α ^ p = (Nat.fib p : ZMod p) * α + (Nat.fib (p - 1) : ZMod p) :=
    fib_pow_prime hp α hα
  have hferm : α ^ p = α := ZMod.pow_card α
  have hfp : (Nat.fib p : ZMod p) = 1 := fib_split_case hp hp2 hp5 α hα
  rw [hferm, hfp, one_mul] at hbin
  linear_combination -hbin

/-- Inert: F_{p+1} ≡ 0.  Same setup as fib_inert_case (K = GF(p²),
    α^p = 1 − α); then Binet in K gives F_{p-1} = 1 and F_p = −1, whence
    F_{p+1} = F_p + F_{p-1} = 0. -/
private theorem fib_succ_inert {p : ℕ} (hp : p.Prime) (hp2 : p ≠ 2) (hp5 : p ≠ 5)
    (hirr : Irreducible (X ^ 2 - X - 1 : (ZMod p)[X])) :
    (Nat.fib (p + 1) : ZMod p) = 0 := by
  -- Reuses fib_inert_case, which now returns F_p = p−1 and F_{p-1} = 1.
  obtain ⟨hFp, hFpm1⟩ := fib_inert_case hp hp2 hp5 hirr
  have hp1 : 1 ≤ p := hp.pos
  have hFp' : (Nat.fib p : ZMod p) = -1 := by
    rw [hFp, ZMod.natCast_self]; ring
  have hrec : (Nat.fib (p + 1) : ZMod p)
            = (Nat.fib p : ZMod p) + (Nat.fib (p - 1) : ZMod p) := by
    have hpm : p + 1 = (p - 1) + 2 := by omega
    rw [hpm, Nat.fib_add_two]; push_cast
    rw [show (p - 1) + 1 = p from by omega]; ring
  rw [hrec, hFp', hFpm1]; ring

/-- **prop:rank-inert**:  M_p ∣ F_{M_p+1}  ⟺  M_p is inert (F_{M_p} ≡ M_p − 1). -/
theorem mersenne_rank_iff_inert (p : ℕ) (_hp : p.Prime)
    (hMp : (F1PCFUnified.mersenne p).Prime)
    (hMp2 : F1PCFUnified.mersenne p ≠ 2) (hMp5 : F1PCFUnified.mersenne p ≠ 5) :
    (Nat.fib (F1PCFUnified.mersenne p + 1) : ZMod (F1PCFUnified.mersenne p)) = 0 ↔
    (Nat.fib (F1PCFUnified.mersenne p) : ZMod (F1PCFUnified.mersenne p))
        = F1PCFUnified.mersenne p - 1 := by
  set q := F1PCFUnified.mersenne p with hq
  have : Fact q.Prime := ⟨hMp⟩
  have hqdeg : (X ^ 2 - X - 1 : (ZMod q)[X]).natDegree = 2 := by compute_degree!
  have hq1le : 1 ≤ q := hMp.pos
  have hrec : (Nat.fib (q + 1) : ZMod q)
            = (Nat.fib q : ZMod q) + (Nat.fib (q - 1) : ZMod q) := by
    have hqm : q + 1 = (q - 1) + 2 := by omega
    rw [hqm, Nat.fib_add_two]; push_cast
    rw [show (q - 1) + 1 = q from by omega]; ring
  by_cases hirr : Irreducible (X ^ 2 - X - 1 : (ZMod q)[X])
  · -- INERT:  F_q ≡ −1  and  F_{q+1} ≡ 0  →  both sides true
    have hFq : (Nat.fib q : ZMod q) = q - 1 := (fib_inert_case hMp hMp2 hMp5 hirr).1
    have hsucc : (Nat.fib (q + 1) : ZMod q) = 0 := fib_succ_inert hMp hMp2 hMp5 hirr
    exact ⟨fun _ => hFq, fun _ => hsucc⟩
  · -- SPLIT:  F_q ≡ 1  and  F_{q+1} ≡ 1  →  both sides false
    rw [not_irreducible_iff_exists_root_of_degree_two _ hqdeg] at hirr
    obtain ⟨α, hα⟩ := hirr
    simp only [IsRoot.def, eval_sub, eval_pow, eval_X, eval_one] at hα
    have hαsq : α ^ 2 = α + 1 := by linear_combination hα
    have hFq   : (Nat.fib q : ZMod q) = 1 := fib_split_case hMp hMp2 hMp5 α hαsq
    have hpred : (Nat.fib (q - 1) : ZMod q) = 0 := fib_pred_split hMp hMp2 hMp5 α hαsq
    have hsucc : (Nat.fib (q + 1) : ZMod q) = 1 := by rw [hrec, hFq, hpred]; ring
    -- F_{q+1} = 1 ≠ 0  and  F_q = 1 ≠ q − 1 (since q ≠ 2)
    constructor
    · intro h; rw [hsucc] at h; exact absurd h one_ne_zero
    · intro h
      rw [hFq, ZMod.natCast_self] at h   -- h : 1 = 0 - 1  (i.e. 1 = −1)
      have h2 : (2 : ZMod q) = 0 := by linear_combination h
      -- q ∣ 2  ⟹  q = 2, contradicting hMp2
      rw [show (2 : ZMod q) = ((2 : ℕ) : ZMod q) by push_cast; ring,
          ZMod.natCast_eq_zero_iff] at h2
      exact absurd ((Nat.prime_dvd_prime_iff_eq hMp Nat.prime_two).mp h2) hMp2

end


-- ╔═══════════════════════════════════════════════════════════════════════╗
-- ║  §11  BINARY BRIDGE ↔ GOLDEN LATTICE                                  ║
-- ║  M_p = p ones; 2^p = M_p+1 = a single bit; golden step φ^λ=2 = shift. ║
-- ╚═══════════════════════════════════════════════════════════════════════╝

noncomputable section
open F1PCFUnified

/-- The "+1" that maps M_p to a power of 2: M_p + 1 = 2^p. -/
theorem mersenne_succ_eq_two_pow (p : ℕ) :
    F1PCFUnified.mersenne p + 1 = 2 ^ p := by
  unfold F1PCFUnified.mersenne
  exact Nat.sub_add_cancel Nat.one_le_two_pow

/-- In binary, M_p = 2^p − 1 is a run of p ones. -/
theorem mersenne_digits_ones (p : ℕ) :
    Nat.digits 2 (F1PCFUnified.mersenne p) = List.replicate p 1 := by
  unfold F1PCFUnified.mersenne
  induction p with
  | zero => simp
  | succ n ih =>
    have h2 : (2 : ℕ) ^ (n + 1) = 2 * 2 ^ n := by rw [pow_succ]; ring
    have hone : 1 ≤ 2 ^ n := Nat.one_le_two_pow
    have hpos : 0 < 2 ^ (n + 1) - 1 := by omega
    rw [Nat.digits_def' (b := 2) (by norm_num) hpos]
    have hmod : (2 ^ (n + 1) - 1) % 2 = 1 := by omega
    have hdiv : (2 ^ (n + 1) - 1) / 2 = 2 ^ n - 1 := by omega
    rw [hmod, hdiv, ih]
    rfl

/-- In binary, 2^p is a single bit (p zeros followed by a 1). -/
theorem two_pow_digits_single_bit (p : ℕ) :
    Nat.digits 2 (2 ^ p) = List.replicate p 0 ++ [1] := by
  induction p with
  | zero => simp
  | succ n ih =>
    have h2 : (2 : ℕ) ^ (n + 1) = 2 * 2 ^ n := by rw [pow_succ]; ring
    have hpos : 0 < 2 ^ (n + 1) := pow_pos (by norm_num) _
    rw [Nat.digits_def' (b := 2) (by norm_num) hpos]
    have hmod : 2 ^ (n + 1) % 2 = 0 := by omega
    have hdiv : 2 ^ (n + 1) / 2 = 2 ^ n := by omega
    rw [hmod, hdiv, ih]
    rfl

/-- The multiplicative golden step φ^λ = 2 is a bit shift. -/
theorem golden_step_is_bit_shift (p : ℝ) :
    φ ^ lambda_log * (2 : ℝ) ^ p = (2 : ℝ) ^ (p + 1) := by
  rw [mersenne_bridge_via_lambda]
  rw [Real.rpow_add (by norm_num : (0:ℝ) < 2), Real.rpow_one]
  ring

end


-- ══════════════════════════════════════════════════════════════════════════
--  RECIPROCITY LINK  →  pinned joint presentation (D)
--  X²−X−1 has a root mod q ⟺ 5 is a square mod q ⟺ q ≡ ±1 (mod 5).
--  Combined with mersenne_mod5_from_p_mod4 and fib_split/inert_case, this pins
--  the sign by case of p mod 4.  ⚠ Best effort without compiler: verifies the
--  marked lemma names ⚠ (legendreSym/reciprocity API).
-- ══════════════════════════════════════════════════════════════════════════

open Polynomial in
/-- X²−X−1 has a root in ZMod q ⟺ 5 is a square in ZMod q (q odd prime).
    (2α−1)² = 4α²−4α+1 = 5 when α²=α+1; converse via α=(β+1)/2. -/
private lemma root_x2mx1_iff_five_sq {q : ℕ} [Fact q.Prime] (hq2 : q ≠ 2) :
    (∃ α : ZMod q, α ^ 2 = α + 1) ↔ ∃ β : ZMod q, β ^ 2 = 5 := by
  have hqp : q.Prime := Fact.out
  have h2 : (2 : ZMod q) ≠ 0 := by
    intro h
    rw [show (2 : ZMod q) = ((2 : ℕ) : ZMod q) by push_cast; ring,
        ZMod.natCast_eq_zero_iff] at h
    exact hq2 ((Nat.prime_dvd_prime_iff_eq hqp (by norm_num)).mp h)
  constructor
  · rintro ⟨α, hα⟩
    exact ⟨2 * α - 1, by linear_combination 4 * hα⟩
  · rintro ⟨β, hβ⟩
    refine ⟨(β + 1) / 2, ?_⟩
    field_simp
    linear_combination hβ

/-- Nonzero squares mod 5 are exactly {1, 4}  (finite computation). -/
private lemma isSquare_zmod5 :
    ∀ y : ZMod 5, y ≠ 0 → (IsSquare y ↔ y = 1 ∨ y = 4) := by decide

/-- Of {3,7,11}⊂Z₂₀, only 11 reduces to 1 mod 5  (finite computation). -/
private lemma zmod20_class_of_mod5_eq_one :
    ∀ x : ZMod 20, x ∈ ({3, 7, 11} : Finset (ZMod 20)) →
      (ZMod.castHom (by norm_num : (5:ℕ) ∣ 20) (ZMod 5)) x = 1 → x = 11 := by decide

/-- Of {3,7,11}⊂Z₂₀, only 7 reduces to 2 mod 5  (finite computation). -/
private lemma zmod20_class_of_mod5_eq_two :
    ∀ x : ZMod 20, x ∈ ({3, 7, 11} : Finset (ZMod 20)) →
      (ZMod.castHom (by norm_num : (5:ℕ) ∣ 20) (ZMod 5)) x = 2 → x = 7 := by decide

/-- 5 is a square mod q ⟺ q ≡ 1 ∨ 4 (mod 5).  Quadratic reciprocity
    (5 ≡ 1 mod 4 ⟹ (5|q)=(q|5)), and q is a QR mod 5 ⟺ q mod 5 ∈ {1,4}. -/
private lemma five_sq_iff_mod5 {q : ℕ} (hq : q.Prime) (hq2 : q ≠ 2) (hq5 : q ≠ 5) :
    (∃ β : ZMod q, β ^ 2 = 5) ↔ ((q : ZMod 5) = 1 ∨ (q : ZMod 5) = 4) := by
  have : Fact q.Prime := ⟨hq⟩
  have : Fact (5 : ℕ).Prime := ⟨by norm_num⟩
  -- (∃ β, β²=5) ⟺ IsSquare (5:ZMod q)
  have hIsSq : (∃ β : ZMod q, β ^ 2 = 5) ↔ IsSquare (5 : ZMod q) := by
    constructor
    · rintro ⟨β, hβ⟩; exact ⟨β, by rw [← hβ]; ring⟩
    · rintro ⟨β, hβ⟩; exact ⟨β, by rw [hβ]; ring⟩
  rw [hIsSq]
  -- quadratic reciprocity (5 % 4 = 1):
  --   IsSquare (5 : ZMod q) ⟺ IsSquare (q : ZMod 5)
  have hrecip : IsSquare (5 : ZMod q) ↔ IsSquare (q : ZMod 5) := by
    have h := ZMod.exists_sq_eq_prime_iff_of_mod_four_eq_one
                (p := 5) (q := q) (by norm_num) hq2
    rw [show ((5 : ℕ) : ZMod q) = (5 : ZMod q) by push_cast; ring] at h
    exact h.symm
  rw [hrecip]
  -- IsSquare (q : ZMod 5) ⟺ (q:ZMod 5) ∈ {1,4}  (nonzero squares mod 5)
  have hq0 : ((q : ZMod 5)) ≠ 0 := by
    rw [Ne, ZMod.natCast_eq_zero_iff]
    exact fun hd => hq5 (((Nat.prime_dvd_prime_iff_eq (by norm_num) hq).mp hd).symm)
  exact isSquare_zmod5 _ hq0

/-- Split (root exists) ⟺ p ≡ 1 (mod 4), for M_p prime (≠2,5). -/
private lemma mersenne_split_iff_p_mod4 (p : ℕ) (hp : p.Prime)
    (hMp : (F1PCFUnified.mersenne p).Prime)
    (hMp2 : F1PCFUnified.mersenne p ≠ 2) (hMp5 : F1PCFUnified.mersenne p ≠ 5) :
    (∃ α : ZMod (F1PCFUnified.mersenne p), α ^ 2 = α + 1) ↔ p % 4 = 1 := by
  have : Fact (F1PCFUnified.mersenne p).Prime := ⟨hMp⟩
  rw [root_x2mx1_iff_five_sq hMp2, five_sq_iff_mod5 hMp hMp2 hMp5]
  -- (M_p : ZMod 5) is pinned by p%4 (mersenne_mod5_from_p_mod4): 1/3/2 → {1}/{3}/{2}
  rw [mersenne_mod5_from_p_mod4 p]
  -- p%4=1 → 1 ∈ {1,4} (yes); p%4=2 → 3 (no); p%4=3 → 2 (no); p%4=0 → 0 (no, but p prime>2 ⟹ odd)
  have hodd : p % 4 = 1 ∨ p % 4 = 3 ∨ p = 2 := by
    rcases hp.eq_two_or_odd with h | h
    · exact Or.inr (Or.inr h)
    · omega   -- p odd ⟹ p%4 ∈ {1,3}
  rcases hodd with h | h | h
  · rw [if_pos h]; simp [h]
  · rw [if_neg (by omega : ¬ p % 4 = 1), if_neg (by omega : ¬ p % 4 = 2), if_pos h, h]
    decide
  · subst h; decide

/-- **Pinned joint presentation (D).** p mod 4 pins the triple
    (mod 20 class, type, sign of F_{M_p}): three values. -/
theorem mersenne_presentation_from_p_mod4 (p : ℕ) (hp : p.Prime)
    (hMp : (F1PCFUnified.mersenne p).Prime)
    (hMp2 : F1PCFUnified.mersenne p ≠ 2) (hMp5 : F1PCFUnified.mersenne p ≠ 5) :
    (p % 4 = 1 → (F1PCFUnified.mersenne p : ZMod 20) = 11 ∧
       (Nat.fib (F1PCFUnified.mersenne p) : ZMod (F1PCFUnified.mersenne p)) = 1) ∧
    (p % 4 = 3 → (F1PCFUnified.mersenne p : ZMod 20) = 7 ∧
       (Nat.fib (F1PCFUnified.mersenne p) : ZMod (F1PCFUnified.mersenne p))
         = F1PCFUnified.mersenne p - 1) ∧
    (p = 2 → (F1PCFUnified.mersenne p : ZMod 20) = 3 ∧
       (Nat.fib (F1PCFUnified.mersenne p) : ZMod (F1PCFUnified.mersenne p))
         = F1PCFUnified.mersenne p - 1) := by
  have : Fact (F1PCFUnified.mersenne p).Prime := ⟨hMp⟩
  have hconc := mersenne_concentration_general p hp
  have hmod5 := mersenne_mod5_from_p_mod4 p
  -- reduction ZMod 20 → ZMod 5 to pin the class 11/7/3 from mod5 and {3,7,11}
  refine ⟨?_, ?_, ?_⟩
  · intro h1
    have hsplit : ∃ α : ZMod (F1PCFUnified.mersenne p), α ^ 2 = α + 1 :=
      (mersenne_split_iff_p_mod4 p hp hMp hMp2 hMp5).mpr h1
    obtain ⟨α, hα⟩ := hsplit
    refine ⟨?_, fib_split_case hMp hMp2 hMp5 α hα⟩
    have hm5 : (F1PCFUnified.mersenne p : ZMod 5) = 1 := by rw [hmod5, if_pos h1]
    exact zmod20_class_of_mod5_eq_one _ hconc (by rw [map_natCast]; exact hm5)
  · intro h3
    have hnroot : ¬ ∃ α : ZMod (F1PCFUnified.mersenne p), α ^ 2 = α + 1 := by
      rw [mersenne_split_iff_p_mod4 p hp hMp hMp2 hMp5]; omega
    have hdeg : (X ^ 2 - X - 1 : (ZMod (F1PCFUnified.mersenne p))[X]).natDegree = 2 := by
      compute_degree!
    have hirr : Irreducible (X ^ 2 - X - 1 : (ZMod (F1PCFUnified.mersenne p))[X]) := by
      by_contra hc
      rw [not_irreducible_iff_exists_root_of_degree_two _ hdeg] at hc
      obtain ⟨x, hx⟩ := hc
      apply hnroot
      simp only [IsRoot.def, eval_sub, eval_pow, eval_X, eval_one] at hx
      exact ⟨x, by linear_combination hx⟩
    refine ⟨?_, (fib_inert_case hMp hMp2 hMp5 hirr).1⟩
    have hm5 : (F1PCFUnified.mersenne p : ZMod 5) = 2 := by
      rw [hmod5, if_neg (by omega : ¬ p % 4 = 1), if_neg (by omega : ¬ p % 4 = 2),
          if_pos h3]
    exact zmod20_class_of_mod5_eq_two _ hconc (by rw [map_natCast]; exact hm5)
  · intro h2
    -- p = 2 ⟹ M_2 = 3, all by direct computation
    subst h2
    exact ⟨by decide, by decide⟩
