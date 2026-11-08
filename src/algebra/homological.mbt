///|
/// C1 / src/algebra/homological — 局部化、短正合序列導函子 Ext¹、Morita 等價
/// (組合範例 11/12/13)。所有物件皆為可計算的整數／矩陣模型。

///|
pub(all) struct Localized {
  num : Int64
  den : Int64
}

///|
pub fn localized(num0 : Int64, den0 : Int64) -> Localized {
  let s = if den0 < 0L { -1L } else { 1L }
  let n = num0 * s
  let d = den0 * s
  let g = @exact.gcd(n, d)
  if g == 0L { Localized::{ num: 0L, den: 1L } } else {
    Localized::{ num: n / g, den: d / g }
  }
}

///|
pub fn prime_factors(n0 : Int64) -> Array[Int64] {
  let mut n = if n0 < 0L { -n0 } else { n0 }
  let out : Array[Int64] = []
  let mut p = 2L
  while p * p <= n {
    if n % p == 0L {
      out.push(p)
      while n % p == 0L { n = n / p }
    }
    p += 1L
  }
  if n > 1L { out.push(n) }
  out
}

///|
pub fn denominator_allowed(d : Int64, primes : Array[Int64]) -> Bool {
  let fs = prime_factors(d)
  for i in 0..<fs.length() {
    let mut hit = false
    for j in 0..<primes.length() {
      if primes[j] == fs[i] { hit = true; break }
    }
    if !hit { return false }
  }
  true
}

///|
/// S^{-1}ℤ 的元素：分母的質因子須全在 S 內。
pub fn localize(primes : Array[Int64], num : Int64, den : Int64) -> Localized? {
  if den == 0L { return None }
  let l = localized(num, den)
  if denominator_allowed(l.den, primes) { Some(l) } else { None }
}

///|
pub fn canonical_map(n : Int64) -> Localized { Localized::{ num: n, den: 1L } }

///|
pub fn Localized::add(self : Localized, o : Localized) -> Localized {
  localized(self.num * o.den + o.num * self.den, self.den * o.den)
}

///|
pub fn Localized::mul(self : Localized, o : Localized) -> Localized {
  localized(self.num * o.num, self.den * o.den)
}

///|
pub fn Localized::neg(self : Localized) -> Localized {
  Localized::{ num: -self.num, den: self.den }
}

///|
pub fn Localized::inv(self : Localized) -> Localized? {
  if self.num == 0L { None } else { Some(localized(self.den, self.num)) }
}

///|
pub fn Localized::equal(self : Localized, o : Localized) -> Bool {
  self.num * o.den == o.num * self.den
}

///|
/// 局部化的泛性質： canon 保持環運算；每個 s∈S 可逆；
/// 任意把 S 送到可逆元的 f: ℤ→ℚ 唯一延拓為 f~(a/s) = f(a)/f(s)。
pub fn extend_hom(x : Localized, f : (Int64) -> @exact.Rat) -> @exact.Rat {
  f(x.num).div(f(x.den)).unwrap()
}

///|
pub fn theorem_localization_universal(primes : Array[Int64], samples : Array[Int64]) -> Bool {
  let f = fn(n : Int64) -> @exact.Rat { @series.rint(n) }
  for i in 0..<primes.length() {
    let s = primes[i]
    let ls = canonical_map(s)
    let inv = ls.inv()
    match inv {
      None => return false
      Some(v) => if !ls.mul(v).equal(canonical_map(1L)) { return false }
    }
  }
  for i in 0..<samples.length() {
    for j in 0..<samples.length() {
      let a = canonical_map(samples[i])
      let b = canonical_map(samples[j])
      if !extend_hom(a.add(b), f).equal(f(samples[i] + samples[j])) { return false }
      if !extend_hom(a.mul(b), f).equal(f(samples[i] * samples[j])) { return false }
    }
  }
  for i in 0..<samples.length() {
    let loc = localize(primes, samples[i], primes[0])
    match loc {
      None => return false
      Some(x) => if !extend_hom(x, f).equal(@series.rfrac(samples[i], primes[0])) {
        return false
      }
    }
  }
  true
}

///|
/// Ext¹(ℤ/m, ℤ/n) ≅ ℤ/gcd(m,n)：擴張等價類的 Baer 群。
pub fn ext1_cyclic(m : Int64, n : Int64) -> Int64 { @exact.gcd(m, n) }

///|
pub fn extension_classes(m : Int64, n : Int64) -> Array[Int64] {
  let g = ext1_cyclic(m, n)
  let out : Array[Int64] = []
  let mut k = 0L
  while k < g { out.push(k); k += 1L }
  out
}

///|
pub fn baer_sum(m : Int64, n : Int64, a : Int64, b : Int64) -> Int64 {
  let g = ext1_cyclic(m, n)
  ((a + b) % g + g) % g
}

///|
/// 導函子分類：擴張 0→ℤ/n→E_k→ℤ/m→0 的展示矩陣 [[n,0],[k,m]]，
/// 其 Smith 不變因子決定中間群 E_k（同調代數的分類）。
pub fn extension_presentation(m : Int64, n : Int64, k : Int64) -> Array[Array[Int64]] {
  [[n, 0L], [k, m]]
}

///|
pub fn extension_invariants(m : Int64, n : Int64, k : Int64) -> Array[Int64] {
  @exact.smith_invariants(extension_presentation(m, n, k))
}

///|
pub fn divisor_count(n0 : Int64) -> Int64 {
  let mut c = 0L
  let mut d = 1L
  while d * d <= n0 {
    if n0 % d == 0L {
      c += 1L
      if d * d != n0 { c += 1L }
    }
    d += 1L
  }
  c
}

///|
/// 定理 T-E1：Ext¹ 的 Smith 不變因子僅依賴 k mod gcd(m,n)，擴張類有 g=gcd(m,n)
/// 個；中間群的同構型個數則為 τ(g)（不同擴張類可對應同構的中間群）。
pub fn theorem_ext1_classification(limit : Int64) -> Bool {
  let mut m = 1L
  while m <= limit {
    let mut n = 1L
    while n <= limit {
      let g = ext1_cyclic(m, n)
      let classes = extension_classes(m, n)
      if classes.length().to_int64() != g { return false }
      let distinct : Array[Array[Int64]] = []
      let mut k = 0L
      while k < m * n {
        let inv = extension_invariants(m, n, k)
        let mut seen = false
        for i in 0..<distinct.length() {
          let d = distinct[i]
          if d.length() == inv.length() && d[0] == inv[0] && d[1] == inv[1] {
            seen = true
            break
          }
        }
        if !seen { distinct.push(inv) }
        let inv2 = extension_invariants(m, n, k + g)
        if inv.length() != inv2.length() || inv[0] != inv2[0] || inv[1] != inv2[1] {
          return false
        }
        k += 1L
      }
      if distinct.length().to_int64() != divisor_count(g) { return false }
      n += 1L
    }
    m += 1L
  }
  true
}

///|
/// 定理 T-E2：Baer 和為 ℤ/g 上的加法，滿足結合律與單位元。
pub fn theorem_baer_group(limit : Int64) -> Bool {
  let mut m = 1L
  while m <= limit {
    let mut n = 1L
    while n <= limit {
      let g = ext1_cyclic(m, n)
      for a = 0L; a < g; a = a + 1L {
        if baer_sum(m, n, a, 0L) != a { return false }
        for b = 0L; b < g; b = b + 1L {
          for c = 0L; c < g; c = c + 1L {
            if baer_sum(m, n, baer_sum(m, n, a, b), c) !=
              baer_sum(m, n, a, baer_sum(m, n, b, c)) {
              return false
            }
          }
        }
      }
      n += 1L
    }
    m += 1L
  }
  true
}

///|
pub fn mat_identity(n : Int) -> Array[Array[Int64]] {
  let out : Array[Array[Int64]] = []
  for i in 0..<n {
    let row : Array[Int64] = Array::make(n, 0L)
    row[i] = 1L
    out.push(row)
  }
  out
}

///|
pub fn mat_mul(a : Array[Array[Int64]], b : Array[Array[Int64]], n : Int) -> Array[Array[Int64]] {
  let out : Array[Array[Int64]] = []
  for i in 0..<n {
    let row : Array[Int64] = Array::make(n, 0L)
    for j in 0..<n {
      let mut s = 0L
      for k in 0..<n { s += a[i][k] * b[k][j] }
      row[j] = s
    }
    out.push(row)
  }
  out
}

///|
pub fn mat_equal(a : Array[Array[Int64]], b : Array[Array[Int64]], n : Int) -> Bool {
  for i in 0..<n {
    for j in 0..<n {
      if a[i][j] != b[i][j] { return false }
    }
  }
  true
}

///|
pub fn mat_vec_mul(m : Array[Array[Int64]], w : Array[Int64], n : Int) -> Array[Int64] {
  let out : Array[Int64] = Array::make(n, 0L)
  for i in 0..<n {
    let mut s = 0L
    for j in 0..<n { s += m[i][j] * w[j] }
    out[i] = s
  }
  out
}

///|
pub fn dot(v : Array[Int64], w : Array[Int64]) -> Int64 {
  let mut s = 0L
  for i in 0..<v.length() { s += v[i] * w[i] }
  s
}

///|
pub fn outer_product(w : Array[Int64], v : Array[Int64]) -> Array[Array[Int64]] {
  let n = w.length()
  let out : Array[Array[Int64]] = []
  for i in 0..<n {
    let row : Array[Int64] = Array::make(n, 0L)
    for j in 0..<n { row[j] = w[i] * v[j] }
    out.push(row)
  }
  out
}

///|
pub fn vec_scale(w : Array[Int64], s : Int64) -> Array[Int64] {
  let out : Array[Int64] = Array::make(w.length(), 0L)
  for i in 0..<w.length() { out[i] = w[i] * s }
  out
}

///|
fn vec_equal(a : Array[Int64], b : Array[Int64]) -> Bool {
  @exact.vec_equal_i64(a, b)
}

///|
/// 定理 T-M1（Morita context）：P = ℤ^n (row), Q = ℤ^n (column)，
/// Q⊗_ℤ P → M_n(ℤ) 為外積、P⊗_{M_n} Q → ℤ 為內積，滿足
/// (q·p)q' = q(p·q') 且 (q·p)² = (p·q)(q·p)。
pub fn theorem_morita_context(n : Int) -> Bool {
  let v : Array[Int64] = Array::make(n, 0L)
  let w : Array[Int64] = Array::make(n, 0L)
  for i in 0..<n {
    v[i] = (i + 1).to_int64()
    w[i] = (2 * i + 3).to_int64()
  }
  let m = outer_product(w, v)
  let s = dot(v, w)
  let lhs = mat_vec_mul(m, w, n)
  let rhs = vec_scale(w, s)
  if !vec_equal(lhs, rhs) { return false }
  let scaled : Array[Array[Int64]] = []
  for i in 0..<n {
    let row : Array[Int64] = Array::make(n, 0L)
    for j in 0..<n { row[j] = m[i][j] * s }
    scaled.push(row)
  }
  mat_equal(mat_mul(m, m, n), scaled, n)
}

///|
/// 定理 T-M2：M_n(ℤ) 乘法結合律（環側）與單位元（Morita 等價的代數側）。
pub fn theorem_matrix_ring(n : Int) -> Bool {
  let v : Array[Int64] = Array::make(n, 0L)
  for i in 0..<n { v[i] = (i % 3 + 1).to_int64() }
  let a = outer_product(v, v)
  let b = mat_identity(n)
  let c = outer_product(v, vec_scale(v, 2L))
  let l = mat_mul(mat_mul(a, b, n), c, n)
  let r = mat_mul(a, mat_mul(b, c, n), n)
  mat_equal(l, r, n) && mat_equal(mat_mul(a, b, n), a, n)
}
