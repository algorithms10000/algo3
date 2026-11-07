# src/series — 局部公理 L1/L2/L3：多項式、形式冪級數、洛朗、狄利克雷、商環、全純

> C1-01 首次開發切片／C1-02 補回／C1-03 數學結構落地。本檔由 `tools/build_readmes.py` 自實際程式與登錄表產生。

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
  Poly  Fps  Laurent  Dirichlet
  Quot  DivMod  ConvAlg
```

## 驗證

```bash
export PATH=/tmp/moonhome/bin:$PATH
cd /home/user/c1
moon check src/series --deny-warn
```
