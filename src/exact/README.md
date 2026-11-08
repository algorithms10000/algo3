# src/exact — 精確算術層：Rat、gcd/egcd、模算術、GF(2) 秩、Smith 標準型

> C1-01 首次開發切片／C1-02 補回／C1-03 數學結構落地／C1-04 前沿待辦補齊／C1-05 §6''' 剩餘結構補回／C1-06 量子環面與 21×14 交織／C1-07 黃金比例、陳–西蒙斯與全代碼健檢。本檔由 `tools/build_readmes.py` 自實際程式與登錄表產生。

## 已獲得公理

- **A-L1** 有限支撐公理：精確有理係數 + 明確截斷次數
- **A-L5** 有限域算術公理：Int64 模運算 + GF(2) 位元打包

## 已獲得定理列表

- **L14** GF(2) 秩-零化度：dim ker = ncols − rank
- **T-X1** Faddeev–LeVerrier 特徵多項式滿足 Cayley–Hamilton 與 det/tr 恆等式
- **T-X2** NTT 正逆變換互逆、卷積 = school-book mod 998244353
- **T-X3** Toeplitz 循環嵌入 NTT 之矩陣向量乘積 = 直接乘積（TMVP）
- **T-X4** Toom–Cook 3-way（5 求值點 + Lagrange 插值）= 整數卷積
- **T-X5** n=3⁹ 時 NTT < Toom-3 < Karatsuba < school-book 之運算量序
- **T-X6** BigInt Bareiss 行列式無溢位：6×6 中介量 1.5·10¹⁹ 仍給 det=16231235440
- **T-GOLD1** ℚ(√5)：φ²=φ+1、φ⁻¹=φ−1、φ+ψ=1、φψ=−1、φⁿ=F_nφ+F_{n−1}、L_n=φⁿ+ψⁿ∈ℤ
- **T-GOLD2** ℚ(ζ₅)：ζ⁵=1、Φ₅(ζ)=0；t=ζ+ζ⁴ 滿足 t²+t−1=0 ⇒ 1+t=φ

## 已實作演算法列表

- **AL001** gcd / egcd 歐幾里得與擴展歐幾里得（O(log min(a,b))）
- **AL002** rat 有理數正規化與四則運算（O(log d)）
- **AL003** Rat::pow 二進位快速冪（O(log k)）
- **AL004** mod_pow / mod_inv 模冪與模逆（O(log e)）
- **AL005** binom Pascal 動態規劃（O(n·k)）
- **AL006** popcount Kernighan 位元計數（O(#1-bits)）
- **AL007** gf2_rank / gf2_nullity 位元打包消去（O(rows·cols/64)）
- **AL008** rank_mod_p 素數體矩陣秩（O(r²c)）
- **AL009** smith_invariants Smith 標準型與可整除鏈（多項式時間）
- **AL063** mat_det / mat_rank 有理高斯消去（O(n³)）
- **AL064** mat_charpoly Faddeev–LeVerrier（O(n⁴)）
- **AL065** poly_from_points Newton 差商插值（無溢位）（O(n²)）
- **AL066** mat_generalized_charpoly det(A−tB) 求值插值（O(n⁴)）
- **AL067** poly_smallest_positive_root 1/8 網格根隔離（O(deg·16)）
- **AL090** ntt / ntt_mul / ntt_cyclic_mul（O(n log n)）
- **AL091** toeplitz_mvp_ntt 循環嵌入（O(n log n)）
- **AL092** toom3_mul 五點求值 Lagrange 插值（O(n^log₃5)）
- **AL093** multiplication_costs 複雜度模型（O(log n)）
- **AL115** big_gcd / br_norm / mat_det_bigrat / bigrat_sign（O(n³·log‖det‖)）
- **AL156** q5_add/sub/mul/neg/inv/pow/is_int（ℚ(√5) 精確算術）（O(n)）
- **AL157** c5_reduce/c5_mul/c5_pow（Φ₅ 分圓環降次）（O(n²)）
- **AL158** mat_rank_big（BigInt Bareiss 有理消去求秩，無溢位）（O(n³ log‖·‖)）
- **AL172** vec_equal_i64 / vec_equal_int（三處重複本體合併）（O(n)）

## 等式

- **E39** 特徵多項式：`p_M(t) = det(tI − M) = t^n + c_{n−1}t^{n−1} + ⋯ + c₀`
- **E40** Cayley–Hamilton：`p_M(M) = 0；det(M) = (−1)^n p_M(0)`
- **E52** NTT 卷積：`c = NTT⁻¹(NTT(a)·NTT(b)) mod p, p=998244353`
- **E53** Toom–3：`C(z)=Σ_j ℓ_j(z)·A(z_j)B(z_j)，5 次半尺寸乘法`
- **E69** Bareiss 消去：`a_{ij}^{(k)} = (p·a_{ij} − a_{ik}a_{kj}) / prev，中介量恆為子式`
- **E101** 黃金比例：`φ=(1+√5)/2, φ²=φ+1, φ⁻¹=φ−1, ψ=(1−√5)/2, φψ=−1`
- **E102** φⁿ 與 Lucas：`φⁿ=F_nφ+F_{n−1}；L_n=φⁿ+ψⁿ∈ℤ`
- **E103** Φ₅ 分圓環：`Φ₅(z)=1+z+z²+z³+z⁴=0；z⁵=1`
- **E104** 分圓黃金橋：`t=ζ+ζ⁴ ⇒ t²+t−1=0；1+t=φ`

## 資料夾視角依賴關係圖

```text
[src/exact]
  └─ 被依賴 ← src/galois
  └─ 被依賴 ← src/series
  └─ 被依賴 ← src/algebra
  └─ 被依賴 ← src/graphs
  └─ 被依賴 ← src/compose
  └─ 被依賴 ← .
```

## 動線

Int64/UInt64 位元 → gcd/Rat/矩陣秩 → 供所有上層套件做精確係數與 GF(2) 消去。

## 接入／輸出接口

接入：Int64/UInt64 位元資料。輸出：Rat、gcd、gf2_rank、rank_mod_p、smith_invariants、binom、popcount。

實際公開符號（擷取自本資料夾 .mbt）：

```text
  vec_equal_i64  vec_equal_int  gcd  egcd
  lcm  rat  rat_checked  rat_zero
  rat_one  rat_int  Rat::add  Rat::sub
  Rat::neg  Rat::mul  Rat::inv  Rat::div
  Rat::cmp  Rat::equal  Rat::is_zero  Rat::pow
  Rat::to_string  mod_pow  mod_inv  fp_add
  fp_mul  fp_sub  binom  factorial
  popcount  bit  set_bit  clear_bit
  gf2_rank  gf2_nullity  rank_mod_p  smith_invariants
  det2  mat_from  mat_new  mat_clone
  mat_identity  mat_scale  mat_add  mat_sub
  mat_mul  mat_transpose  mat_equal  mat_trace
  bigrat_sign  mat_det_bigrat  mat_det  mat_rank_big
  mat_rank  poly_add  poly_scale  poly_mul
  poly_eval  mat_charpoly  poly_from_points  mat_generalized_charpoly
  poly_bisect  poly_smallest_positive_root  poly_deflate_zero  poly_from_roots
  theorem_charpoly_cayley_hamilton  ntt  ntt_mul  theorem_ntt_equivalence
  toeplitz_mvp_ntt  theorem_toeplitz_mvp  toom3_mul  theorem_toom3_equivalence
  multiplication_costs  theorem_complexity_ordering  theorem_bareiss_determinant  q5
  q5_int  q5_phi  q5_psi  q5_sqrt5
  q5_add  q5_sub  q5_mul  q5_neg
  q5_inv  q5_equal  q5_is_zero  q5_is_int
  q5_pow  c5  c5_int  c5_zeta
  c5_add  c5_sub  c5_neg  c5_mul
  c5_pow  c5_equal  c5_is_zero  theorem_q5_golden
  theorem_c5_golden_bridge  Rat  Bezout  Mat
  Q5  C5
```

## 驗證

```bash
export PATH=/tmp/moonhome/bin:$PATH
cd /home/user/c1
moon check src/exact --deny-warn
```
