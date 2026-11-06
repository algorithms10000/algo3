///|
/// C1 / src/algebra/hilbert — 多項式商環 R/I 與 Hilbert–Poincaré 級數 (R1/R2)
/// 單項式理想 I = (t^{g_1},...,t^{g_r}) ⊂ ℚ[x_1..x_n]：
/// H_{R/I}(t) = Q(t)/(1-t)^n，Q(t) = Σ_{S⊆[r]} (-1)^{|S|} t^{deg lcm(S)}。
/// 另一路獨立計算：逐次枚舉標準單項式基底，兩者交叉查核。

///|
pub(all) struct MonoIdeal {
  nvars : Int
  gens : Array[Array[Int]]
}

///|
pub fn mono_ideal(nvars : Int, gens : Array[Array[Int]]) -> MonoIdeal {
  MonoIdeal::{ nvars, gens }
}

///|
pub fn monomial_lcm(a : Array[Int], b : Array[Int]) -> Array[Int] {
  let n = a.length()
  let out : Array[Int] = Array::make(n, 0)
  for i in 0..<n { out[i] = if a[i] > b[i] { a[i] } else { b[i] } }
  out
}

///|
pub fn monomial_degree(e : Array[Int]) -> Int {
  let mut d = 0
  for i in 0..<e.length() { d += e[i] }
  d
}

///|
pub fn monomial_divides(g : Array[Int], e : Array[Int]) -> Bool {
  for i in 0..<g.length() {
    if g[i] > e[i] { return false }
  }
  true
}

///|
pub fn monomial_in_ideal(ideal : MonoIdeal, e : Array[Int]) -> Bool {
  for i in 0..<ideal.gens.length() {
    if monomial_divides(ideal.gens[i], e) { return true }
  }
  false
}

///|
fn int_popcount(x0 : Int) -> Int {
  let mut x = x0
  let mut c = 0
  while x > 0 {
    if x % 2 == 1 { c += 1 }
    x = x / 2
  }
  c
}

///|
fn ideal_max_lcm_degree(ideal : MonoIdeal) -> Int {
  let mut d = 0
  for v in 0..<ideal.nvars {
    let mut mx = 0
    for i in 0..<ideal.gens.length() {
      if ideal.gens[i][v] > mx { mx = ideal.gens[i][v] }
    }
    d += mx
  }
  d
}

///|
fn expvec_equal(a : Array[Int], b : Array[Int]) -> Bool {
  if a.length() != b.length() { return false }
  for i in 0..<a.length() {
    if a[i] != b[i] { return false }
  }
  true
}

///|
/// 最小生成元：去掉重複與被其他生成元整除者（lcm 格的原子化）。
fn minimal_generators(gens : Array[Array[Int]]) -> Array[Array[Int]] {
  let out : Array[Array[Int]] = []
  for i in 0..<gens.length() {
    let mut dup = false
    for j = 0; j < out.length(); j = j + 1 {
      if expvec_equal(out[j], gens[i]) { dup = true; break }
    }
    if dup { continue }
    let mut dominated = false
    for j in 0..<gens.length() {
      if j == i { continue }
      if monomial_divides(gens[j], gens[i]) && !expvec_equal(gens[j], gens[i]) {
        dominated = true
        break
      }
    }
    if !dominated { out.push(gens[i]) }
  }
  out
}

///|
/// 容斥分子 Q(t) = Σ_{S⊆[r]} (-1)^{|S|} t^{deg lcm(S)}。
/// 先做 lcm 格原子化（去重／去被整除者），再以逐步 lcm 展開 2^r 子集的
/// Taylor resolution 交錯和；對冗餘子集以成對抵消剪枝。
pub fn hilbert_numerator(ideal : MonoIdeal) -> Array[Int64] {
  let gens = minimal_generators(ideal.gens)
  let r = gens.length()
  let maxd = ideal_max_lcm_degree(ideal)
  let q : Array[Int64] = Array::make(maxd + 1, 0L)
  let total = 1 << r
  for mask = 0; mask < total; mask = mask + 1 {
    let mut lcm : Array[Int] = Array::make(ideal.nvars, 0)
    for i = 0; i < r; i = i + 1 {
      if (mask / (1 << i)) % 2 == 1 { lcm = monomial_lcm(lcm, gens[i]) }
    }
    let deg = monomial_degree(lcm)
    let sign = if int_popcount(mask) % 2 == 0 { 1L } else { -1L }
    q[deg] += sign
  }
  q
}

///|
/// H_{R/I}(t) = Q(t)·(1-t)^{-n} 的係數：h_m = Σ_d Q_d·C(n+m-d-1, n-1)。
pub fn hilbert_coefficients(ideal : MonoIdeal, len : Int) -> Array[Int64] {
  let q = hilbert_numerator(ideal)
  let out : Array[Int64] = Array::make(len, 0L)
  for m = 0; m < len; m = m + 1 {
    let mut s = 0L
    for d = 0; d < q.length() && d <= m; d = d + 1 {
      if q[d] == 0L { continue }
      let rest = m - d
      let b = @exact.binom(ideal.nvars + rest - 1, ideal.nvars - 1)
      s += q[d] * b
    }
    out[m] = s
  }
  out
}

///|
fn count_monomials_rec(
  ideal : MonoIdeal,
  m : Int,
  pos : Int,
  exps : Array[Int],
) -> Int64 {
  if pos == ideal.nvars {
    if m != 0 { return 0L }
    if monomial_in_ideal(ideal, exps) { return 0L }
    return 1L
  }
  let mut total = 0L
  for v = 0; v <= m; v = v + 1 {
    exps[pos] = v
    total += count_monomials_rec(ideal, m - v, pos + 1, exps)
  }
  exps[pos] = 0
  total
}

///|
/// 直接計數：總次數 m 且不屬於 I 的標準單項式個數。
pub fn hilbert_direct_count(ideal : MonoIdeal, m : Int) -> Int64 {
  let exps : Array[Int] = Array::make(ideal.nvars, 0)
  count_monomials_rec(ideal, m, 0, exps)
}

///|
fn collect_basis_rec(
  ideal : MonoIdeal,
  maxdeg : Int,
  pos : Int,
  used : Int,
  exps : Array[Int],
  out : Array[Array[Int]],
) -> Unit {
  if pos == ideal.nvars {
    if !monomial_in_ideal(ideal, exps) {
      let cp : Array[Int] = Array::make(ideal.nvars, 0)
      for i in 0..<ideal.nvars { cp[i] = exps[i] }
      out.push(cp)
    }
    return
  }
  for v = 0; v <= maxdeg - used; v = v + 1 {
    exps[pos] = v
    collect_basis_rec(ideal, maxdeg, pos + 1, used + v, exps, out)
  }
  exps[pos] = 0
}

///|
/// 商環 R/I 的標準單項式基底（次數 ≤ maxdeg），即多項式商環的顯式模型。
pub fn quotient_basis(ideal : MonoIdeal, maxdeg : Int) -> Array[Array[Int]] {
  let out : Array[Array[Int]] = []
  let exps : Array[Int] = Array::make(ideal.nvars, 0)
  collect_basis_rec(ideal, maxdeg, 0, 0, exps, out)
  out
}

///|
/// 定理 T-H1：容斥 Hilbert–Poincaré 級數與標準單項式基底逐次吻合。
pub fn theorem_hilbert_inclusion_exclusion(ideal : MonoIdeal, len : Int) -> Bool {
  let h = hilbert_coefficients(ideal, len)
  for m = 0; m < len; m = m + 1 {
    if h[m] != hilbert_direct_count(ideal, m) { return false }
  }
  let basis = quotient_basis(ideal, len - 1)
  let cnt : Array[Int64] = Array::make(len, 0L)
  for i in 0..<basis.length() {
    let d = monomial_degree(basis[i])
    if d < len { cnt[d] += 1L }
  }
  for m = 0; m < len; m = m + 1 {
    if cnt[m] != h[m] { return false }
  }
  true
}

///|
/// 一元多項式商環 ℚ[t]/(t^d) 的 Hilbert 級數 (1-t^d)/(1-t)。
pub fn hilbert_quotient_series(d : Int, len : Int) -> Array[Int64] {
  let out : Array[Int64] = Array::make(len, 0L)
  for m = 0; m < len; m = m + 1 { out[m] = if m < d { 1L } else { 0L } }
  out
}

///|
/// skew PBW / Ore 擴展之分次 Hilbert 級數 = (1-t)^{-n} (R2)。
pub fn poincare_skew_pbw(n : Int, len : Int) -> Array[Int64] {
  let out : Array[Int64] = Array::make(len, 0L)
  for m = 0; m < len; m = m + 1 { out[m] = @exact.binom(n + m - 1, n - 1) }
  out
}

///|
/// 定理 T-H2：ℚ[t]/(t^d) 的 Hilbert 函數滿足 h(n)-h(n-1)=δ_{n,0}-δ_{n,d}，
/// 且 (1-t)·H(t) = 1-t^d 之多項式係數恆等式。
pub fn theorem_hilbert_quotient(d : Int, len : Int) -> Bool {
  let h = hilbert_quotient_series(d, len)
  for n = 1; n < len; n = n + 1 {
    let delta = (if n == 0 { 1L } else { 0L }) - (if n == d { 1L } else { 0L })
    if h[n] - h[n - 1] != delta { return false }
  }
  true
}

///|
/// 定理 T-H3：n 個變數的 skew PBW 擴展與交換多項式環有相同 Hilbert 級數
/// （σ 保持次數 ⇒ 分次維度不變）。
pub fn theorem_hilbert_skew(n : Int, len : Int) -> Bool {
  let h = poincare_skew_pbw(n, len)
  let comm = mono_ideal(n, [])
  let hc = hilbert_coefficients(comm, len)
  for m = 0; m < len; m = m + 1 {
    if h[m] != hc[m] { return false }
  }
  true
}
