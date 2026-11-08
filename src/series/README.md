# src/series — 局部公理 L1/L2/L3：多項式、形式冪級數、洛朗、狄利克雷、商環、全純

> C1-01 首次開發切片／C1-02 補回／C1-03 數學結構落地／C1-04 前沿待辦補齊／C1-05 §6''' 剩餘結構補回／C1-06 量子環面與 21×14 交織／C1-07 黃金比例、陳–西蒙斯與全代碼健檢／C1-08 六項無限維結構之有限精確憑證。本檔由 `tools/build_readmes.py` 自實際程式與登錄表產生。

## 已獲得公理

- **A-L2** 卷積么半群公理：四類環為同一代數之實例
- **A-L3** 截斷商公理：π_N 為滿環同態

## 已獲得定理列表

- **P2** 截斷 π_N 保持乘法：π_N(ab)=π_N(a)π_N(b)
- **P3** 狄利克雷卷積對應么半群 (ℕ≥1,×)
- **T-S1** 共性定理：(ℕ,+)/(ℕ≥1,×)/(ℤ,+) 卷積皆結合
- **T-S2** exp∘log = id 且 log∘exp = id (mod t^N)
- **T-S3** Newton 迭代反演正確性
- **T-S4** Lagrange 反演與合成恆等式 f(f^{-1})=t
- **T-S5** 洛朗級數賦值可加 val(ab)=val(a)+val(b)
- **T-S6** Möbius 反演 ζ*μ=δ₁ 且 σ=ζ*id
- **T-S7** Euler 乘積：乘法函數由質數冪決定
- **T-S8** Kan 擴展 Lan_φ 保持環結構
- **T-O1** 操作子代入結合律 (P∘Q)∘R=P∘(Q∘R)
- **T-O2** 多元代入求值同態
- **T-S9** Karatsuba 卷積與 school-book 卷積逐項相等
- **T-S10** Bostan–Mori Graeffe 係數抽取與 Newton 反演一致
- **T-S11** Brent–Kung baby-step/giant-step 合成與直接合成一致
- **T-A1** 算術 ζ/Poincaré 多項式 Σ_{d|n}t^{Ω(d)} = ∏(1+...+t^{e_i})
- **T-A2** 算術 spectral triple：χ_D=∏(t−Ω(d))、[D,E_p]=0、[D,T_p]=T_p
- **T-A3** Spec(ℤ/nℤ) 之 Zariski 極性為伽羅瓦對應（伴隨性＋閉包三律）
- **T-A4** Σ_{d|n}φ(d)=n、Σ_{d|n}μ(d)=[n=1]、φ(n)=n∏(1−1/p)
- **T-S12** Kinoshita–Li PowProj：Bostan–Mori Graeffe 迭代之 [x^N]P/Q 正確性
- **T-S13** Kinoshita–Li Comp：O(M(n) log m+M(m)) 合成與直接合成逐項相等
- **T-A5** Connes rank-one：χ_{D+aP}=χ_D−a∏_{d≠1}(t−Ω(d))
- **T-A6** det_ζ=∏_{k≥1}k^{c_k}=|[t^{c₀}]χ_D| 且 ζ_D(2)=tr(D⁺²)
- **T-A7** Grothendieck–Lefschetz：exp(Σω t^k/k)=(1−t)^{−ω}
- **T-A8** adelic AJ 單射、div(AJ(D))=D、Pic(Spec Z)=0
- **T-W1** log Z 導數恆等式 S·P·Q=P′Q−PQ′（mod T^N）
- **T-W2** genus 1 函數方程 Z(E,1/(qT))=Z(E,T)，扭轉算子為對合
- **T-W3** Hasse–Weil 界 |a|≤2√q（a²≤4q）與 a=q+1−N₁
- **T-W4** 有限域曲線 RH 之代數憑證 |α|=|β|=√q 與 Newton 恆等式
- **T-W5** Weil 顯式公式 exp(Σ_{n≤N}NₙTⁿ/n)·Q≡P (mod T^{N+1})
- **T-W6** 解析極限可計算憑證：4(qt)^{N+1}/((N+1)(1−qt)) 有理餘項界
- **T-W7** 六條 F_q 橢圓曲線全套有限精確憑證
- **T-AJ1** E(F_q) 弦切群律為交換群且 |E(F_q)|=N₁=q+1−a（Weil 交織）
- **T-AJ2** AJ 為 Div⁰→Jac(E) 同態且 Abel 定理：主除子 div(x−a)、div(y−lx−m) 之 AJ=0
- **T-AJ3** AJ 滿射、核含主除子、|Jac(E)|=N₁=P(1)（Weil zeta 分子）
- **T-AJ4** Γ-bundle 配對反向互逆、核心雙線性 q^{k·m}、么正不變性指數 0
- **T-AJ5** AJ_q 為滿同態、核=⟨q⟩、陪集數=(p−1)/ord(q)
- **T-AJ6** E(F₇)[3]≅(ℤ/3)²：標號群律、AJ 相容、Weil 配對雙線性／交錯／非退化
- **T-AJ7** Abel–Jacobi 六項憑證合取
- **T-GOLD3** Fibonacci 矩陣譜：x²−x−1、譜投影冪等／正交／完備、Qⁿ=[[F_{n+1},F_n],[F_n,F_{n−1}]]、Cassini、fast doubling、Lucas、Zeckendorf
- **T-GOLD4** Fibonacci trace map 保持 Fricke–Vogt 不變量且可逆；字長=F_{k+1}；轉移矩陣滿足 x_{k+1}=2x_kx_{k−1}−x_{k−2}
- **T-GOLD5** 黃金比例／Fibonacci 矩陣譜四項憑證合取
- **T-AN1** Connes 截斷譜極限：s=2,3,4 之單調、Cauchy 餘項、上界 2、餘項嚴格遞減；有限 Galerkin PSD；det_ζ(n)≤n
- **T-FIBSPEC** D_k 單首一、deg=F_{k+1}、D_{k+1}=D_kD_{k−1}−D_{k−2}；Gordon 平方前綴；Jacobian 特徵多項式 (−2,−1) 變號 ⇒ 雙曲

## 已實作演算法列表

- **AL019** Poly::mul 稀疏跳零卷積（O(|suppA|·|suppB|)）
- **AL020** poly_divmod / poly_gcd 帶餘除法與 gcd（O(deg²)）
- **AL021** quot / Quot::mul 商環算術（O(deg²)）
- **AL022** fps_mul 截斷形式冪級數乘法（O(N²) 帶零剪枝）
- **AL023** fps_inv Newton 倍精度反演（O(M(N) log N)）
- **AL024** fps_compose 冪次展開 + valuation 剪枝（O(N²/v)）
- **AL025** fps_reversion Lagrange 反演（O(N·M(N))）
- **AL026** fps_exp / fps_log 係數遞推（O(N²)）
- **AL027** holomorphic_eval / tail_bound 全純求值與誤差界（O(N)）
- **AL028** laurent_inv 洛朗級數求逆（O(M(N) log N)）
- **AL029** ds_mul O(N log N) 狄利克雷卷積（O(N log N)）
- **AL030** ds_inv / mobius / ds_phi 算術函數（O(N log N)）
- **AL031** conv_mul 三種卷積么半群統一乘法（O(N²) 或 O(N log N)）
- **AL032** lan_along_phi 左 Kan 擴展（纖維和）（O(log N)）
- **AL033** mpoly_substitute 操作子代入（多項式於指數）
- **AL060** kar_mul Karatsuba 次二次卷積（O(n^1.585)）
- **AL061** fps_compose_bk Brent–Kung baby-step/giant-step 合成（O((N/B+B)·M(N))）
- **AL062** graeffe_coeff Bostan–Mori Graeffe 係數抽取（O(M(N) log N)）
- **AL078** prime_factorization / divisors_of / big_omega（O(n)）
- **AL079** arithmetic_zeta_poly 算術 ζ 多項式（O(τ(n))）
- **AL080** arithmetic_hecke 升階算子 T_p（O(τ(n)²)）
- **AL081** theorem_arithmetic_galois Zariski 極性有限穷舉（O(2^{p+d})）
- **AL089** kl_pow_proj / kl_comp / kl_compose（O(M(n)log m+M(m))）
- **AL109** connes_rank_one / regularized_determinant / spectral_zeta（O(τ(n)³)）
- **AL110** spec_z_zeta_series / adelic_abel_jacobi（O(cut²+2^p)）
- **AL116** weil_pow_mod / weil_legendre / weil_point_count（O(q log p)）
- **AL117** weil_power_sum / weil_counts（Frobenius 冪和遞推）（O(N)）
- **AL118** weil_log_derivative_identity / weil_poly_mul（O(N²)）
- **AL119** weil_twist / weil_functional_equation（O(deg²)）
- **AL120** weil_explicit_formula（fps_exp 之形式冪級數驗證）（O(N²)）
- **AL121** weil_tail_bound / theorem_weil_explicit_tail（O(N)）
- **AL138** ec_add / ec_neg / ec_mul（弦切群律）（O(log p)）
- **AL139** ec_all_points（Legendre 快篩逐點列舉 E(F_q)）（O(q²)）
- **AL140** aj_sum / aj_div_add / aj_degree（O(|D|·n)）
- **AL141** aj_vertical_divisor / aj_line_divisor（主除子構造）（O(q²)）
- **AL142** aj_gamma_vu / aj_gamma_uv / aj_gamma_core（O(1)）
- **AL143** aj_q_order / aj_q_coset（q-商之正規代表）（O(ord(q))）
- **AL144** aj_weil_label（E[N] 標號配對）（O(1)）
- **AL159** qmat_mul/add/sub/smul/pow（M₂(ℚ(√5))）（O(n)）
- **AL160** fib_pair 快速倍增 / fib_number / lucas_number（O(log n)）
- **AL161** zeckendorf 貪心不相鄰分解（O(log N)）
- **AL162** fib_word / word_matrix（Fibonacci 字轉移矩陣）（O(F_k)）
- **AL163** fricke_vogt / fib_trace_map（O(1)）
- **AL173** rat_coeffs_equal（Fps/Dirichlet::equal 共用）（O(n)）
- **AL184** connes_spectral_zeta / connes_tail_bound（BigRat 無溢位）（O(N log‖·‖)）
- **AL185** connes_galerkin / connes_psd（BigInt Bareiss 主子式）（O(2^8·8³)）
- **AL186** fib_discriminant（多項式矩陣轉移）（O(F_k²)）
- **AL187** fib_square_prefix（Gordon 二塊）（O(F_k²)）

## 等式

- **E05** 卷積么半群：`(a*b)(m) = Σ_{u*v=m} a(u)b(v)`
- **E06** 截斷商同態：`π_N(a·b) = π_N(a)·π_N(b)`
- **E07** Newton 迭代：`g ← g(2 − a·g)`
- **E08** Lagrange 反演：`[t^k] f^{-1}(t) = (1/k)[t^{k-1}] h(t)^{-k}`
- **E09** 複合反演：`f(f^{-1}(t)) ≡ t (mod t^N)`
- **E10** Möbius 反演：`ζ * μ = δ₁，即 Σ_{d|n} μ(d) = [n=1]`
- **E11** Euler 乘積：`f(n) = Π_{p^e || n} f(p^e)`
- **E36** Karatsuba 遞迴：`T(n) = 3T(n/2) + O(n) = O(n^{log₂3})`
- **E37** Graeffe 減半：`[t^N] P/Q = [t^{⌊N/2⌋}] U_{parity}/V`
- **E38** BK 合成分解：`f(g) = Σ_i (Σ_{j<B} f_{iB+j} g^j) · g^{iB}`
- **E46** 算術 ζ：`Σ_{d|n} t^{Ω(d)} = ∏_i (1+t+⋯+t^{e_i})`
- **E47** Dirac–Hecke 交換子：`[D,E_p]=0；[D,T_p]=T_p；tr D² = Σ_k c_k k²`
- **E51** Kinoshita–Li PowProj：`[x^N] P/Q = 偶部 U(x²)+x·奇部 U(x²)/A(x²)`
- **E62** Connes rank-one：`det(D+I+aP)=det(D+I)(1+a)`
- **E63** Lefschetz zeta：`Z(X,t)=exp(Σ_k #X(F_{q^k})t^k/k)=1/(1−t)^{ω(n)}`
- **E64** Adelic Abel–Jacobi：`AJ(D)=∏_p p^{e_p}；div(AJ(D))=D`
- **E70** Weil 點數：`N₁ = q+1+Σ_x χ_q(x³+ac·x+bc)，a = q+1−N₁`
- **E71** Frobenius 冪和：`s₀=2, s₁=a, sₙ=a·sₙ₋₁−q·sₙ₋₂；Nₙ=qⁿ+1−sₙ`
- **E72** Hasse–Weil zeta：`Z(E,T)=(1−aT+qT²)/((1−T)(1−qT))，P(T)=1−aT+qT²`
- **E73** 對數導數恆等式：`S·P·Q = P′Q − PQ′，S(T)=Σ_{n≥1}NₙTⁿ⁻¹`
- **E74** Weil 函數方程：`qT²P(1/(qT))=P(T)，qT²Q(1/(qT))=Q(T) ⇒ Z(1/(qT))=Z(T)`
- **E75** Weil 顯式公式：`log Z(E,T)=Σ_{n≥1}NₙTⁿ/n；exp(L_N)·Q≡P (mod T^{N+1})`
- **E76** 顯式公式餘項界：`|Σ_{n>N}Nₙtⁿ/n| ≤ 4(qt)^{N+1}/((N+1)(1−qt))，|qt|<1`
- **E77** RH 代數式（有限域曲線）：`α+β=a, αβ=q, a²−4q≤0 ⇒ |α|²=|β|²=q`
- **E89** Abel–Jacobi 映射：`AJ(Σ n_i[P_i]) = Σ n_i P_i ∈ Jac(E)=ℂ^g/Λ_g（有限域模型：E(F_q)）`
- **E90** Abel 定理：`D ∈ PDiv(E) ⇒ AJ(D)=0；div(x−a)=Σ_{x(P)=a} m_P[P] − 2[O]`
- **E91** Weil 分子與 Jacobian 階：`|Jac(E)(F_q)| = N₁ = q+1−a = P(1) = 1−a+q`
- **E92** Γ-bundle 配對（R56 Prop.3）：`⟨q^s v(q^m v,u)|q^r u(q^k u,v)⟩ = q^{r−s−km}`
- **E93** 配對反向互逆：`⟨q^r u(q^k u,v)|q^s v(q^m v,u)⟩ = q^{km+s−r} = (q^{r−s−km})⁻¹`
- **E94** 核心雙線性：`⟨u(q^r u,v)|v(q^s v,u)⟩ = q^{r·s}（么正不變性）`
- **E95** q-商 AJ：`AJ_q : F_p^* → F_p^*/⟨q⟩，ker=⟨q⟩，|coker|=(p−1)/ord(q)`
- **E96** E[3] 標號 Weil 配對：`E(F₇)[3]≅(ℤ/3)²，e₃((a,b),(c,d))=2^{ad−bc} mod 7`
- **E105** Fibonacci 特徵多項式：`χ_Q(λ)=λ²−λ−1；特徵值 φ, ψ=−φ⁻¹`
- **E106** 譜投影：`P₊=(Q−ψI)/√5, P₋=(φI−Q)/√5；P₊²=P₊, P₊P₋=0, P₊+P₋=I`
- **E107** Qⁿ 與 Cassini：`Qⁿ=[[F_{n+1},F_n],[F_n,F_{n−1}]]；F_{n+1}F_{n−1}−F_n²=(−1)ⁿ`
- **E108** 快速倍增：`F_{2n}=F_n(2F_{n+1}−F_n), F_{2n+1}=F_{n+1}²+F_n²`
- **E109** Fricke–Vogt：`I(x,y,z)=x²+y²+z²−2xyz−1，T(x,y,z)=(2xy−z,x,y)，I∘T=I`
- **E110** Fibonacci 跡遞推：`x_{k+1}=2x_kx_{k−1}−x_{k−2}，|w_k|=F_{k+1}`
- **E123** Connes 截斷餘項：`S_{N+j}(s)−S_N(s) ≤ 1/((s−1)N^{s−1})；S_N(s)+bound ≤ 2`
- **E124** Weil Galerkin：`G=Σ_n w_n v_n v_nᵀ, w_n=1_{n 為素數冪} ⇒ G ⪰ 0（2^8 主子式實算）`
- **E125** 正則化行列式界：`det_ζ(n) ∈ ℤ_{>0}, det_ζ(n) ≤ n ⇒ log det_ζ(n)/n → 0`
- **E126** Fibonacci 判別遞推：`D_{k+1}=D_kD_{k−1}−D_{k−2}, deg D_k=F_{k+1}, D_k 單首一`
- **E127** Gordon 二塊：`Fibonacci 字 w_k (k≥5) 具平方前綴 u·u ⇒ 無點譜`
- **E128** Trace map 雙曲：`p(λ)=λ³−2yλ²−2xλ+1；p(−2)<0<p(−1) ⇒ ∃λ<−1`

## 資料夾視角依賴關係圖

```text
[src/series]
  ├─ 依賴 → src/exact
  └─ 被依賴 ← src/algebra
  └─ 被依賴 ← src/compose
  └─ 被依賴 ← .
```

## 動線

係數陣列 → 卷積么半群 → Poly/Fps/Laurent/Dirichlet/Quot → Newton/Lagrange → 全純求值。

## 接入／輸出接口

接入：Array[Rat] 係數。輸出：fps_inv、fps_reversion、fps_compose、ds_mul、quot、mpoly_substitute、theorem_*。

實際公開符號（擷取自本資料夾 .mbt）：

```text
  monomial  mpoly_const  mpoly_canonical  MPoly::add
  MPoly::sub  MPoly::mul  MPoly::pow  MPoly::scale
  MPoly::equal  mpoly_substitute  mpoly_eval  theorem_operad_associative
  theorem_substitution_hom  Monomial  MPoly  poly
  rat0  rat1  rint  rfrac
  poly_degree  poly_trim  Poly::equal  Poly::add
  Poly::sub  Poly::mul  Poly::pow  Poly::eval
  poly_divmod  poly_mod  poly_gcd  quot
  Quot::add  Quot::mul  Quot::pow  Quot::equal
  quot_associativity_cert  fps  fps_zero  fps_one
  fps_from_poly  fps_mul  fps_add  fps_neg
  Fps::equal  fps_inv  fps_compose  fps_reversion
  fps_derivative  fps_integral  fps_exp  fps_log
  holomorphic_eval  rat_abs  cauchy_hadamard_lower_bound  holomorphic_tail_bound
  fps_eval  theorem_exp_log_inverse  theorem_newton_inverse  theorem_reversion
  laurent  Laurent::add  Laurent::mul  laurent_valuation
  laurent_inv  theorem_laurent_valuation  dirichlet  ds_mul
  ds_one  ds_zeta  ds_identity  ds_inv
  mobius  ds_mobius  ds_phi  Dirichlet::equal
  theorem_dirichlet_mobius  theorem_euler_product  conv_mul  ConvAlg::equal
  theorem_conv_associative  lan_along_phi  theorem_lan_ring_hom  poly_mul_karatsuba
  fps_mul_karatsuba  theorem_karatsuba_equivalence  fps_compose_bk  theorem_bk_composition
  graeffe_coeff  theorem_graeffe_coeff  prime_factorization  prime_divisors
  divisors_of  big_omega  euler_phi  arithmetic_spectrum
  arithmetic_zeta_poly  arithmetic_dirac  arithmetic_hecke  arithmetic_idempotent
  theorem_arithmetic_zeta  theorem_arithmetic_spectral_triple  theorem_arithmetic_galois  theorem_arithmetic_functions
  kl_pow_proj  kl_compose  theorem_kl_pow_proj  theorem_kl_compose
  connes_rank_one  regularized_determinant  spectral_zeta  theorem_connes_rank_one
  theorem_connes_zeta_det  lefschetz_trace  spec_z_zeta_series  theorem_spec_z_lefschetz
  adelic_abel_jacobi  theorem_spec_z_adelic  weil_point_count  weil_curve
  weil_power_sum  weil_counts  weil_poly_p  weil_poly_q
  weil_log_derivative_identity  weil_functional_equation  weil_hasse  weil_rh_modulus
  weil_explicit_formula  weil_tail_bound  theorem_weil_explicit_tail  theorem_weil_curve
  ec_infinity  ec_pt  ec_equal  ec_neg
  ec_add  ec_mul  ec_all_points  aj_divisor
  aj_degree  aj_sum  aj_vertical_divisor  aj_line_divisor
  aj_gamma_vu  aj_gamma_uv  aj_gamma_core  aj_q_order
  aj_q_coset  aj_weil_label  theorem_aj_group_law  theorem_aj_abel
  theorem_aj_pic0  theorem_aj_gamma_pairing  theorem_aj_quantum_quotient  theorem_aj_weil_torsion
  theorem_abel_jacobi  qmat  qmat_identity  qmat_mul
  qmat_add  qmat_sub  qmat_smul  qmat_equal
  qmat_pow  fibonacci_matrix  fib_pair  fib_number
  lucas_number  zeckendorf  theorem_fib_spectrum  fricke_vogt
  fib_trace_map  theorem_fib_trace_map  theorem_golden_fibonacci  connes_spectral_zeta
  connes_tail_bound  connes_galerkin  theorem_connes_finite_limit  fib_discriminant
  fib_square_prefix  theorem_fib_spectral_finite  Poly  Fps
  Laurent  Dirichlet  Quot  DivMod
  ConvAlg  WeilCurve  ECPoint  AJTerm
  AJDivisor  QMat
```

## 驗證

```bash
export PATH=/tmp/moonhome/bin:$PATH
cd /home/user/c1
moon check src/series --deny-warn
```
