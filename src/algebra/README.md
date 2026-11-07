# src/algebra — Ore 歪多項式環、Hilbert–Poincaré、局部化、Ext¹、Morita

> C1-01 首次開發切片／C1-02 補回／C1-03 數學結構落地／C1-04 前沿待辦補齊／C1-05 §6''' 剩餘結構補回。本檔由 `tools/build_readmes.py` 自實際程式與登錄表產生。

## 已獲得定理列表

- **P4** Ore 關係 x·r = σ(r)x + δ(r)
- **P5** Hilbert 分子為 lcm 格的交錯和
- **P7** Morita 雙模映射為外積與內積
- **T-H1** Hilbert–Poincaré 容斥級數 = 標準單項式基底計數
- **T-H2** ℚ[t]/(t^d) 的 Hilbert 函數差分遞推
- **T-H3** skew PBW 擴展與交換環有相同 Hilbert 級數
- **T-Ore1** 量子平面交換律 x·u = q·u·x
- **T-Ore2** Ore 乘法結合律
- **T-Ore3** Ore 環無零因子：deg(fg)=deg f+deg g
- **T-Ore4** gcrd 右整除 f 與 g
- **T-Ore5** σ-Leibniz 律對所有單項式成立
- **T-Ore6** Ore 擴展 Hilbert 級數 = (1−t)^{-n}
- **T-L1** 局部化 S^{-1}ℤ 的泛性質與唯一延拓
- **T-E1** Ext¹ 分類：擴張類 g 個、中間群同構型 τ(g) 個
- **T-E2** Baer 和構成 ℤ/g 上的交換群
- **T-M1** Morita context 雙模相容性 (q·p)q'=q(p·q')
- **T-M2** M_n(ℤ) 為結合環且具單位元
- **T-Ore7** deg lclm = deg f + deg g − deg gcrd = rank(Sylvester)，lclm 為公共右倍式
- **T-Ore8** F_25 上多組非交換實例的 lclm/Sylvester 恆等式穷舉
- **T-Ore9** σ ≠ id：x·θ = −θ·x，Ore 環真正非交換
- **T-K0-1** G₀(R/(f)) ≅ ℤ^s，s=相異不可約右因子數；合成因子次數和=deg f
- **T-K0-2** Quillen–Grayson 基本定理：H_R(t)=1/(1−t)，秩 1→2→1→0，Euler=0
- **T-K0-3** Morita 不變性：2×2 冪等矩陣 tr(e)=rank(e)·1
- **T-K0-4** K₀ 函子性：局部化泛性質與基本定理複合為零
- **T-K0-5** δ=0 時 x^k r = σ^k(r) x^k（Shin 2024 q-binomial 之 σ²=id 特例）
- **T-Ore10** reduced norm 落於中心 F_5[t]、具乘法性且 N(f)=f·f̄
- **T-Ore11** Ore bound 為最小首一中心左倍式且 deg ≤ 2deg f
- **T-Ore12** 中心分解 h_i 兩兩右互質、Σdeg h_i=deg f、lclm(h_i)=f
- **T-Ore13** 參數 GCRD 特化 σ-等變且每層 Sylvester 秩缺陷 = deg gcrd
- **T-Ore14** 模組 Gröbner 基底秩 = deg lclm，最低次列 = gcrd
- **T-Ore15** 兩層模組分解因子不可約、次數和=deg f、與直接分解同譜
- **T-Ore16** δ-Galois：G_a(F_5) 與 δ 交換，固定環 = δ-常數 F_5
- **T-Ore17** A¹-不變性：F_5[u] 么模列皆可補全，K₀(F_5[u])≅ℤ
- **T-Ore18** Laurent 局部化 gcd 乘法性 u^k·gcd(a,b)
- **T-PV1** 一般 δ-模基本解矩陣與 Abel 恆等式 δ(det Y)=tr(A)det Y
- **T-PV2** δ-Galois gauge 群精確階數：480 / 20 / 16 / 480 與乘法封閉
- **T-PV3** Kovacic 第一型有限 Galois 對應：Riccati 根數 = 不變直線數 = dim V
- **T-PV4** C1-04 G_a(F₅) 模型嵌入一般 gauge 群之階 p 加法子群

## 已實作演算法列表

- **AL034** hilbert_numerator lcm 格容斥 + 原子化（O(2^r·n)）
- **AL035** hilbert_coefficients / direct_count（O(N·n)）
- **AL036** quotient_basis 標準單項式基底枚舉（O(C(n+d,d))）
- **AL037** ore_mul / ore_divmod / ore_gcrd（O(deg²·deg_u)）
- **AL038** q_derivative Jackson q-導子（O(deg_u)）
- **AL039** localize / extend_hom 局部化（O(log d)）
- **AL040** extension_invariants Ext¹ 的 SNF 分類（多項式時間）
- **AL041** outer_product / mat_vec_mul Morita 雙模（O(n²)）
- **AL053** sfq_gcrd_lclm 擴展右歐幾里得（同時得 gcrd 與 lclm）（O(deg²) 於 F_25）
- **AL054** sfq_sylvester_rank Ore Sylvester 矩陣秩（ISSAC'24）（O((df+dg)³)）
- **AL055** fq2_rank F_25 高斯消去與 fq2_inv 範數求逆（O(r·c·min(r,c))）
- **AL056** sfq_divmod F_25 上 σ^k 修正之右除（O(deg²)）
- **AL082** sfq_factor 歪多項式右因子分解（O(25^{d}·deg²)）
- **AL083** sfq_distinct_factors G₀ 生成元（O(k²)）
- **AL094** f5p_irreducibles / f5p_embed / f5p_divmod（O(5^d·d³)）
- **AL095** ore_even_odd / ore_reduced_norm / ore_bound（O(d²)）
- **AL096** ore_central_decomposition / ore_two_level_factor（O(5^d·d³)）
- **AL097** sfq_module_groebner（leading-degree RREF）（O((df+dg)³)）
- **AL098** sfq_specialize / parametric_gcrd_strata（O(5·(df+dg)³)）
- **AL099** fp5_translate / fp5_delta δ-Galois 群（O(5³)）
- **AL100** fu_gcd_ext / a1_homotopy / theorem_a1_*（O(125²·d²)）
- **AL126** dr_mul / dr_der（Euler δ=t d/dt 之截斷環）（O(m²)）
- **AL127** diff_fundamental（基本解矩陣 Picard 遞推）（O(m²)）
- **AL128** diff_solution_nullity（2m×2m F_p 線性映射秩）（O(m³)）
- **AL129** dm_gl2 / diff_gauge_group / diff_invariant_lines（O(p⁴·m+p²·|G|)）
- **AL130** diff_riccati_roots / theorem_pv_kovacic（O(p·m²)）

## 等式

- **E12** Hilbert–Poincaré：`H_{R/I}(t) = (Σ_S (−1)^{|S|} t^{deg lcm(S)})/(1−t)^n`
- **E13** 商環 Hilbert 遞推：`h(n) − h(n−1) = δ_{n,0} − δ_{n,d}`
- **E14** Ore 交換律：`x·u = q·u·x`
- **E15** σ-Leibniz：`δ(rs) = δ(r)s + σ(r)δ(s)`
- **E16** q-整數恆等式：`[i+j]_q = [i]_q + q^i [j]_q`
- **E17** Ext¹：`Ext¹(ℤ/m, ℤ/n) ≅ ℤ/gcd(m,n)`
- **E18** Morita context：`(q·p)q' = q(p·q') 且 (q·p)² = (p·q)(q·p)`
- **E31** Ore 度數公式：`deg lclm(f,g) = deg f + deg g − deg gcrd(f,g)`
- **E32** Sylvester 秩：`deg lclm(f,g) = rank Syl(f,g)`
- **E33** F_25 係數體：`θ² = 2, σ(θ) = θ⁵ = −θ, σ² = id`
- **E48** K₀ 基本定理：`K₀(R[t,t⁻¹]) ≅ K₀(R) ⊕ K₋₁(R)；Euler: 1−2+1−0=0`
- **E49** G₀ 商環：`G₀(R/(f)) ≅ ℤ^{#distinct irreducible right factors}`
- **E54** Reduced norm：`N(f)=Aσ(A)−t Bσ(B) ∈ F_5[t]，t=x²`
- **E55** Ore bound：`deg φ ≤ 2 deg f；φ = N(f)/lc(N(f))`
- **E65** A¹-同倫不變性：`K₀(F_5[u])≅K₀(F_5)≅ℤ；det[[a,b],[−q,p]]=1`
- **E80** δ-Galois / Abel / Kovacic：`δ(det Y)=tr(A)det Y；G=⋂Z_{GL₂}(A_k)；δu+u²+a₁u+a₀=0`

## 資料夾視角依賴關係圖

```text
[src/algebra]
  ├─ 依賴 → src/exact
  ├─ 依賴 → src/series
  └─ 被依賴 ← src/compose
  └─ 被依賴 ← .
```

## 動線

單項式指數向量 → lcm 格容斥 → Hilbert 級數；Ore σ 作用 → 歪多項式；SNF → Ext¹/Morita。

## 接入／輸出接口

接入：@series.Poly、指數向量、整數矩陣。輸出：hilbert_coefficients、ore_mul/ore_gcrd、extension_invariants、theorem_*。

實際公開符號（擷取自本資料夾 .mbt）：

```text
  mono_ideal  monomial_lcm  monomial_degree  monomial_divides
  monomial_in_ideal  hilbert_numerator  hilbert_coefficients  hilbert_direct_count
  quotient_basis  theorem_hilbert_inclusion_exclusion  hilbert_quotient_series  poincare_skew_pbw
  theorem_hilbert_quotient  theorem_hilbert_skew  MonoIdeal  localized
  prime_factors  denominator_allowed  localize  canonical_map
  Localized::add  Localized::mul  Localized::neg  Localized::inv
  Localized::equal  extend_hom  theorem_localization_universal  ext1_cyclic
  extension_classes  baer_sum  extension_presentation  extension_invariants
  divisor_count  theorem_ext1_classification  theorem_baer_group  mat_identity
  mat_mul  mat_equal  mat_vec_mul  dot
  outer_product  vec_scale  theorem_morita_context  theorem_matrix_ring
  Localized  skew  skew_zero  skew_one
  sigma_apply  ore_mul  ore_degree  ore_trim
  SkewPoly::equal  ore_divmod  ore_gcrd  theorem_ore_commutation
  theorem_ore_associative  theorem_ore_degree  theorem_ore_gcrd_divides  qint_rat
  q_derivative  theorem_ore_leibniz  theorem_ore_hilbert  fq2
  fq2_zero  fq2_one  fq2_add  fq2_sub
  fq2_mul  fq2_sigma  fq2_is_zero  fq2_equal
  fq2_inv  skew_fq  sfq_degree  sfq_trim
  sfq_mul  sfq_add  sfq_neg  sfq_sub
  sfq_monic  sfq_divmod  sfq_gcrd_lclm  fq2_rank
  sfq_sylvester  sfq_sylvester_rank  sfq_right_divides  theorem_ore_lclm
  sfq_sample  theorem_ore_lclm_batch  theorem_fq2_field  theorem_ore_noncommutative
  sfq_equal  sfq_monic_enum  sfq_min_right_factor  sfq_irreducible
  sfq_factor  sfq_distinct_factors  theorem_k0_skew_quotient  theorem_k0_fundamental
  theorem_k0_morita_idempotents  theorem_k0_functorial  theorem_ore_sigma_binomial  f5p_irreducibles
  f5p_embed  ore_even_odd  ore_reduced_norm  ore_bound
  ore_central_decomposition  theorem_ore_reduced_norm  theorem_ore_bound  theorem_ore_central_decomposition
  sfq_specialize  parametric_gcrd_strata  theorem_parametric_gcrd  sfq_module_groebner
  theorem_ore_module_groebner  theorem_ore_parametric_groebner  ore_two_level_factor  theorem_ore_two_level
  theorem_delta_galois  fu_gcd_ext  a1_homotopy  theorem_a1_invariance
  theorem_a1_laurent  diff_module  diff_fundamental  theorem_pv_wronskian
  diff_solution_nullity  diff_gauge_group  diff_invariant_lines  diff_riccati_roots
  theorem_pv_gauge_group  theorem_pv_kovacic  theorem_pv_additive_subgroup  SkewPoly
  OreDiv  Fq2  SkewFq  SFqDiv
  OreGCL  F5pDiv  SkewGB  FuDiv
  FuBezout  DiffModule
```

## 驗證

```bash
export PATH=/tmp/moonhome/bin:$PATH
cd /home/user/c1
moon check src/algebra --deny-warn
```
