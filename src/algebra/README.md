# src/algebra — Ore 歪多項式環、Hilbert–Poincaré、局部化、Ext¹、Morita

> C1-01 首次開發切片／C1-02 補回／C1-03 數學結構落地／C1-04 前沿待辦補齊／C1-05 §6''' 剩餘結構補回／C1-06 量子環面與 21×14 交織／C1-07 黃金比例、陳–西蒙斯與全代碼健檢／C1-08 六項無限維結構之有限精確憑證。本檔由 `tools/build_readmes.py` 自實際程式與登錄表產生。

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
- **T-QT1** 定義關係 VU=qUV、U/V 可逆、乘法結合（2-上循環 ω=b·c）
- **T-QT2** 正則跡 τ 為循環跡 τ(xy)=τ(yx)
- **T-QT3** δ₁,δ₂ 滿足 Leibniz／交換／τ∘δᵢ=0；Connes 循環 2-上循環循環不變且非恆零
- **T-QT4** qⁿ=1 時中心由 Uⁿ,Vⁿ 生成：U^aV^b 與 U,V 同時交換 ⟺ n|a 且 n|b
- **T-QT5** Heisenberg clock/shift 表示 VU=qUV、U³=V³=I、L_U L_V=q⁻¹L_V L_U
- **T-QT6** Weil 配對雙線性／交錯／非退化；[g_x,g_y]=q^{bc−ad}=e_n(x,y)⁻¹
- **T-QT7** SL₂(ℤ) Morita 作用：么模基底變換、ℤ+θℤ 保持、(gh)·θ=g·(h·θ)
- **T-QT8** 量子二維環面七項憑證合取
- **T-CS1** Verlinde 公式於全部 4³ 組重現 SU(2)₃ 融合律且係數為整數、真空為 δ
- **T-CS2** 偶數扇域 {0,2} 為 Fibonacci 融合範疇；N_τ 特徵多項式 x²−x−1；D²=2(φ+2)
- **T-CS3** SU(2)₃ 模數據：Ŝ 對稱、Ŝ²=(1/c₀)I、Ŝ⁴=(1/c₀²)I、dim H_{g=2}=20
- **T-CS4** Wilson loop d=sin(2π/5)/sin(π/5)=φ；WRT(S³)²=c₀=(5−√5)/20
- **T-CS11** 陳–西蒙斯四項憑證合取
- **T-CSTAR** C* 有限 GNS：τ(aa*)=Σc²、Cauchy–Schwarz、Harper 動差 4/28/232/2156、‖h^{2n}‖≤4^{2n}、clock/shift 表示
- **T-K** 高階 K 有限層：K₁ 單位群階、Matsumoto 關係矩陣滿秩 ⇒ K₂(F₇)=0、Quillen q^i−1、Bass A¹/Laurent
- **T-PV6** 3 階 δ-模特徵向量解空間、Wronskian/Abel 恆等式；Kovacic I/II 之 F₅/F₂₅ Riccati 根與 gauge 不變直線一致
- **T-CS-T** SU(2)₃ T 相位 θ_a=ζ₂₀^{a(a+2)}、Gauss sum G·Ḡ=D²、(AT)³ 純量且 κκ̄=D_fib⁶、手術和 τ₀=D²／週期 20／自共軛

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
- **AL131** qt_mul / qt_add / qt_norm（2-上循環 ω=b·c）（O(|x|·|y|)）
- **AL132** qt_trace / qt_deriv / qt_star / qt_commutator_mon（O(|x|²)）
- **AL133** qt_root_vec / qt_root_mul_vec（n² 維 F_p 代數）（O(n⁴)）
- **AL134** qt_root_left_matrix / qt_root_deriv_matrix / qt_root_label_star（O(n⁴)）
- **AL135** qt_mat_add / qt_mat_sub / qt_mat_mul / qt_mat_smul（O(n⁶)）
- **AL136** qt_root_weil_exp / qt_root_comm_exp（O(1)）
- **AL137** theorem_qt_morita_sl2（SL₂(ℤ) 有理分式作用與群律）（O(|G|²)）
- **AL155** qt_root_qshift_matrix / qt_root_trace_projection（O(n⁴)）
- **AL164** cs_chebyshev_u / cs_shat（Kac–Peterson S 之 ℚ(√5) 精確化）（O(n)）
- **AL165** cs_verlinde / cs_comb / cs_c0（O(k³)）
- **AL188** cstar_tau_norm2 / cstar_harper_moment（O(n·|a|²)）
- **AL189** k1_unit_order / k1_units_brute（O(p^k)）
- **AL190** Matsumoto Steinberg 關係矩陣與秩（O(p³)）
- **AL191** pv3_nullity（3 階 δ-模 GF(p) 秩）（O(m·3³)）
- **AL192** pv_riccati_fp_roots / pv_riccati_fq2_roots（O(p²)）
- **AL193** cs_theta / cs_d2_qc / cs_gauss_sum / cs_surgery_sum（O(k·8²)）
- **AL194** QC2 2×2 分圓矩陣乘法與 (AT)³ 純量判定（O(8²)）

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
- **E81** 量子環面定義關係：`VU = q UV；ω((a,b),(c,d)) = b·c`
- **E82** 單項乘法：`(q^{e₁}U^{a₁}V^{b₁})(q^{e₂}U^{a₂}V^{b₂}) = q^{e₁+e₂+b₁a₂}U^{a₁+a₂}V^{b₁+b₂}`
- **E83** 正則跡：`τ(Σ c_{a,b}U^aV^b) = c_{0,0}；τ(xy)=τ(yx)`
- **E84** Connes 循環 2-上循環：`φ(x⁰,x¹,x²)=τ(x⁰δ₁x¹δ₂x²−x⁰δ₂x¹δ₁x²)，φ 循環不變`
- **E85** root of unity 中心：`qⁿ=1 ⇒ Z(A_q)=F[Uⁿ,Vⁿ]；[U^aV^b,U]=0∧[U^aV^b,V]=0 ⟺ n|a,n|b`
- **E86** Weil pairing：`e_n((a,b),(c,d))=q^{ad−bc}；[g_x,g_y]=q^{bc−ad}=e_n(x,y)⁻¹`
- **E87** Heisenberg 表示：`U=diag(q^{−i}), V e_i=e_{i+1} ⇒ VU=qUV, Uⁿ=Vⁿ=I`
- **E88** SL₂(ℤ) Morita：`θ↦(aθ+b)/(cθ+d)；ℤ+θℤ ≅ (cθ+d)⁻¹(ℤ+θℤ)；K₀(A_θ)≅ℤ+θℤ`
- **E111** Kac–Peterson S：`S_{ab}=√(2/5)sin((a+1)(b+1)π/5)；Ŝ_{ab}=U_{(a+1)(b+1)−1}(φ/2)`
- **E112** Verlinde：`N_{ab}^c=(2/5)sin²(π/5)·Σ_x Ŝ_{ax}Ŝ_{bx}Ŝ_{cx}/Ŝ_{0x}`
- **E113** SU(2)₃ 融合：`N_{ab}^c=1 ⟺ |a−b|≤c≤min(a+b,6−a−b) 且 a+b+c 偶`
- **E114** 量子維度：`d_a=S_{0a}/S_{00}=U_a(φ/2)=(1,φ,φ,1)；D²=Σd²=2(φ+2)`
- **E115** Fibonacci 融合：`τ⊗τ=1⊕τ；N_τ=[[0,1],[1,1]]，χ=x²−x−1`
- **E116** 模關係：`Ŝ²=(1/c₀)I, Ŝ⁴=(1/c₀²)I, (ST)³=S², S⁴=I`
- **E117** WRT 與 Wilson：`WRT(S³)²=S₀₀²=c₀=(5−√5)/20；sin(2π/5)/sin(π/5)=φ`
- **E129** C* GNS 正性：`τ(a*a)=Σ|c|²≥0；|τ(b*a)|² ≤ τ(a*a)τ(b*b)`
- **E130** Harper 動差：`τ(h²)=4, τ(h⁴)=28, τ(h⁶)=232, τ(h⁸)=2156`
- **E131** K₁ 與 Quillen：`K₁(F_p[t]/(t^k))=(p−1)p^{k−1}；|K_{2i−1}(F_q)|=q^i−1, K_{2i}=0`
- **E132** Matsumoto K₂：`{ab,c}={a,c}+{b,c}, {x,1−x}=0, {a,−a}=0 ⇒ K₂(F₇)=0`
- **E133** 3 階 PV：`δ(v t^j)=jvt^j ⇒ ∇(vt^j)=0 ⟺ (A−jI)v=0；δW=tr(A)W`
- **E134** Kovacic II：`Riccati u²+a₁u+a₀=0 於 F₅ 無根、於 F₂₅ 有 Frobenius 共軛二根`
- **E135** T 矩陣相位：`θ_a=ζ₂₀^{a(a+2)}=(1,ζ³,ζ⁸,ζ¹⁵)；θ_a²⁰=1, θ_aθ̄_a=1`
- **E136** Gauss sum：`G=Σ_a θ_a d_a², G·Ḡ=D²=5+√5`
- **E137** 模關係有限層：`(AT)³=κI, κκ̄=D_fib⁶=(φ+2)³`
- **E138** 手術和：`τ_p=Σ_a θ_a^p d_a², τ₀=D², τ_{p+20}=τ_p, τ_pτ̄_p 自共軛`

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
  theorem_pv_gauge_group  theorem_pv_kovacic  theorem_pv_additive_subgroup  qt_mono
  qt_zero  qt_one  qt_u  qt_v
  qt_q  qt_u_inv  qt_v_inv  qt_add
  qt_neg  qt_sub  qt_mul  qt_equal
  qt_trace  qt_deriv  qt_star  qt_commutator_mon
  qt_root_reduce  qt_root_vec  qt_root_mono_vec  qt_root_mul_vec
  qt_root_trace  qt_root_left_matrix  qt_root_identity_matrix  qt_root_deriv_matrix
  qt_root_label_star  qt_mat_add  qt_mat_sub  qt_mat_mul
  qt_mat_smul  qt_mat_equal  qt_root_apply  qt_root_weil_exp
  qt_root_comm_exp  qt_root_qshift_matrix  qt_root_trace_projection  theorem_qt_relation
  theorem_qt_trace_cyclic  theorem_qt_derivations  theorem_qt_center  theorem_qt_heisenberg
  theorem_qt_weil_pairing  theorem_qt_morita_sl2  theorem_quantum_torus  cs_chebyshev_u
  cs_shat  cs_c0  cs_comb  cs_verlinde
  theorem_cs_verlinde  theorem_cs_fibonacci_sector  theorem_cs_modular  theorem_cs_wilson_golden
  theorem_chern_simons  cstar_tau_norm2  cstar_harper  cstar_harper_moment
  theorem_cstar_finite_gns  k1_unit_order  k1_units_brute  theorem_higher_k_finite
  pv3_nullity  theorem_pv_order3  pv_riccati_fp_roots  pv_riccati_fq2_roots
  theorem_pv_kovacic_finite  cs_theta  cs_d2_qc  cs_gauss_sum
  cs_surgery_sum  theorem_cs_t_surgery  SkewPoly  OreDiv
  Fq2  SkewFq  SFqDiv  OreGCL
  F5pDiv  SkewGB  FuDiv  FuBezout
  DiffModule  QTMon  QTElem  QTRoot
  QC2
```

## 驗證

```bash
export PATH=/tmp/moonhome/bin:$PATH
cd /home/user/c1
moon check src/algebra --deny-warn
```
