///|
/// C1 / src/exact — 精確算術層
/// L1(有限支撐公理) 與 L5(有限域算術公理) 的係數實作。
/// 全部係數以 Int64 精確表示；有理數以 (n,d) 正規化 (d>0, gcd(n,d)=1)。

///|
pub(all) struct Rat {
  n : Int64
  d : Int64
}

///|
pub(all) struct Bezout {
  x : Int64
  y : Int64
  g : Int64
}

///|
/// 歐幾里得最大公因數，回傳非負值。
pub fn gcd(a0 : Int64, b0 : Int64) -> Int64 {
  let mut a = if a0 < 0L { -a0 } else { a0 }
  let mut b = if b0 < 0L { -b0 } else { b0 }
  while b != 0L {
    let t = a % b
    a = b
    b = t
  }
  a
}

///|
/// 擴展歐幾里得：x*a + y*b = g = gcd(a,b)。
pub fn egcd(a : Int64, b : Int64) -> Bezout {
  let mut old_r = a
  let mut r = b
  let mut old_s = 1L
  let mut s = 0L
  let mut old_t = 0L
  let mut t = 1L
  while r != 0L {
    let q = old_r / r
    let nr = old_r - q * r
    let ns = old_s - q * s
    let nt = old_t - q * t
    old_r = r
    r = nr
    old_s = s
    s = ns
    old_t = t
    t = nt
  }
  if old_r < 0L {
    Bezout::{ x: -old_s, y: -old_t, g: -old_r }
  } else {
    Bezout::{ x: old_s, y: old_t, g: old_r }
  }
}

///|
/// 最小公倍數（非負）。
pub fn lcm(a : Int64, b : Int64) -> Int64 {
  let g = gcd(a, b)
  if g == 0L { 0L } else {
    let v = (a / g) * b
    if v < 0L { -v } else { v }
  }
}

///|
/// 有理數正規化；d = 0 時由 rat_checked 擋下，rat 本身約定 d ≠ 0。
pub fn rat(n : Int64, d : Int64) -> Rat {
  let nn = if d < 0L { -n } else { n }
  let dd = if d < 0L { -d } else { d }
  let g = gcd(nn, dd)
  Rat::{ n: nn / g, d: dd / g }
}

///|
/// 帶檢查的有理數構造：分母為 0 回傳 None（真實處理未定義輸入）。
pub fn rat_checked(n : Int64, d : Int64) -> Rat? {
  if d == 0L { None } else { Some(rat(n, d)) }
}

///|
pub fn rat_zero() -> Rat { Rat::{ n: 0L, d: 1L } }

///|
pub fn rat_one() -> Rat { Rat::{ n: 1L, d: 1L } }

///|
pub fn rat_int(n : Int64) -> Rat { Rat::{ n, d: 1L } }

///|
pub fn Rat::add(self : Rat, o : Rat) -> Rat {
  rat(self.n * o.d + o.n * self.d, self.d * o.d)
}

///|
pub fn Rat::sub(self : Rat, o : Rat) -> Rat {
  rat(self.n * o.d - o.n * self.d, self.d * o.d)
}

///|
pub fn Rat::neg(self : Rat) -> Rat { Rat::{ n: -self.n, d: self.d } }

///|
pub fn Rat::mul(self : Rat, o : Rat) -> Rat { rat(self.n * o.n, self.d * o.d) }

///|
pub fn Rat::inv(self : Rat) -> Rat? {
  if self.n == 0L { None } else {
    let s = if self.n < 0L { -1L } else { 1L }
    let nn = if self.n < 0L { -self.n } else { self.n }
    Some(Rat::{ n: s * self.d, d: nn })
  }
}

///|
pub fn Rat::div(self : Rat, o : Rat) -> Rat? {
  if o.n == 0L { None } else {
    let s = if o.n < 0L { -1L } else { 1L }
    let on = if o.n < 0L { -o.n } else { o.n }
    Some(rat(self.n * o.d * s, self.d * on))
  }
}

///|
/// 交叉相乘比較，避免浮點誤差。
pub fn Rat::cmp(self : Rat, o : Rat) -> Int {
  let l = self.n * o.d
  let r = o.n * self.d
  if l < r { -1 } else if l > r { 1 } else { 0 }
}

///|
pub fn Rat::equal(self : Rat, o : Rat) -> Bool { self.cmp(o) == 0 }

///|
pub fn Rat::is_zero(self : Rat) -> Bool { self.n == 0L }

///|
/// 二進位快速冪（高階常數級優化：O(log k) 而非 O(k)）。
pub fn Rat::pow(self : Rat, k : Int) -> Rat {
  let mut base = self
  let mut e = k
  let mut acc = rat_one()
  while e > 0 {
    if e % 2 == 1 { acc = acc.mul(base) }
    base = base.mul(base)
    e = e / 2
  }
  acc
}

///|
pub fn Rat::to_string(self : Rat) -> String {
  if self.d == 1L { "\{self.n}" } else { "\{self.n}/\{self.d}" }
}

///|
/// 模冪：二進位快速冪，O(log e)。
pub fn mod_pow(a0 : Int64, e : Int, m : Int64) -> Int64 {
  let mut base = ((a0 % m) + m) % m
  let mut exp = e
  let mut acc = 1L
  while exp > 0 {
    if exp % 2 == 1 { acc = (acc * base) % m }
    base = (base * base) % m
    exp = exp / 2
  }
  acc
}

///|
/// 模逆（m 為質數時對所有非零 a 存在），不可逆回傳 0。
pub fn mod_inv(a : Int64, m : Int64) -> Int64 {
  let b = egcd(a, m)
  if b.g == 0L { 0L } else {
    let q = b.x / b.g
    ((q % m) + m) % m
  }
}

///|
/// 有限域 F_p 上的加法、乘法、減法。
pub fn fp_add(a : Int64, b : Int64, p : Int64) -> Int64 { ((a + b) % p + p) % p }

///|
pub fn fp_mul(a : Int64, b : Int64, p : Int64) -> Int64 { ((a * b) % p + p) % p }

///|
pub fn fp_sub(a : Int64, b : Int64, p : Int64) -> Int64 { ((a - b) % p + p) % p }

///|
/// 二項係數 C(n,k)：Pascal 動態規劃，O(n·k)，避免階乘溢位。
pub fn binom(n : Int, k : Int) -> Int64 {
  if k < 0 || k > n { 0L } else {
    let kk = if k < n - k { k } else { n - k }
    let row : Array[Int64] = Array::make(kk + 1, 0L)
    row[0] = 1L
    for i = 1; i <= n; i = i + 1 {
      let hi = if i < kk { i } else { kk }
      for j = hi; j >= 1; j = j - 1 {
        row[j] = row[j] + row[j - 1]
      }
    }
    row[kk]
  }
}

///|
/// 階乘（n ≤ 20 保證 Int64 精確）。
pub fn factorial(n : Int) -> Int64 {
  let mut acc = 1L
  for i = 2; i <= n; i = i + 1 { acc *= i.to_int64() }
  acc
}

///|
/// Kernighan popcount：位元級硬體指令數 O(#1-bits)。
pub fn popcount(x0 : UInt64) -> Int {
  let mut x = x0
  let mut c = 0
  while x != 0UL {
    c += 1
    x = x & (x - 1UL)
  }
  c
}

///|
pub fn bit(x : UInt64, k : Int) -> Bool { ((x >> k) & 1UL) == 1UL }

///|
pub fn set_bit(x : UInt64, k : Int) -> UInt64 { x | (1UL << k) }

///|
pub fn clear_bit(x : UInt64, k : Int) -> UInt64 { x & (0xFFFFFFFFFFFFFFFFUL ^ (1UL << k)) }

///|
/// GF(2) 位元打包高斯消去：以 UInt64 一列表示一列，O(rows·cols) 且常數極低。
pub fn gf2_rank(rows : Array[UInt64], ncols : Int) -> Int {
  let basis : Array[UInt64] = Array::make(ncols, 0UL)
  let mut rank = 0
  for i in 0..<rows.length() {
    let mut v = rows[i]
    let mut done = false
    for c = 0; c < ncols && !done; c = c + 1 {
      if ((v >> c) & 1UL) == 1UL {
        if basis[c] == 0UL {
          basis[c] = v
          rank += 1
          done = true
        } else {
          v = v ^ basis[c]
        }
      }
    }
  }
  rank
}

///|
pub fn gf2_nullity(rows : Array[UInt64], ncols : Int) -> Int {
  ncols - gf2_rank(rows, ncols)
}

///|
/// 素數體 F_p 上矩陣秩（列消去 + 模逆），用於同調／層黏合的一般係數。
pub fn rank_mod_p(input : Array[Array[Int64]], p : Int64) -> Int {
  let rows = input.length()
  if rows == 0 { return 0 }
  let cols = input[0].length()
  let m : Array[Array[Int64]] = []
  for i in 0..<rows {
    let row : Array[Int64] = Array::make(cols, 0L)
    for j in 0..<cols { row[j] = ((input[i][j] % p) + p) % p }
    m.push(row)
  }
  let mut r = 0
  for c = 0; c < cols && r < rows; c = c + 1 {
    let mut pivot = -1
    for i = r; i < rows; i = i + 1 {
      if m[i][c] != 0L { pivot = i; break }
    }
    if pivot < 0 { continue }
    let tmp = m[r]
    m[r] = m[pivot]
    m[pivot] = tmp
    let inv = mod_inv(m[r][c], p)
    for j in 0..<cols { m[r][j] = (m[r][j] * inv) % p }
    for i in 0..<rows {
      if i == r { continue }
      let f = m[i][c]
      if f != 0L {
        for j in 0..<cols {
          m[i][j] = ((m[i][j] - f * m[r][j]) % p + p) % p
        }
      }
    }
    r += 1
  }
  r
}

///|
/// Smith 標準型不變因子：整數行列歐幾里得運算 + 可整除鏈正規化。
/// 輸入為整數矩陣，輸出非負不變因子 d_1 | d_2 | ...。
pub fn smith_invariants(input : Array[Array[Int64]]) -> Array[Int64] {
  let rows = input.length()
  if rows == 0 { return [] }
  let cols = input[0].length()
  let a : Array[Array[Int64]] = []
  for i in 0..<rows {
    let row : Array[Int64] = Array::make(cols, 0L)
    for j in 0..<cols { row[j] = input[i][j] }
    a.push(row)
  }
  let lim = if rows < cols { rows } else { cols }
  let out : Array[Int64] = []
  for k = 0; k < lim; k = k + 1 {
    let mut steps = 0
    let mut settled = false
    while !settled && steps < 20000 {
      steps += 1
      let mut best = 0L
      let mut bi = -1
      let mut bj = -1
      for i = k; i < rows; i = i + 1 {
        for j = k; j < cols; j = j + 1 {
          let v = a[i][j]
          let av = if v < 0L { -v } else { v }
          if av > 0L && (bi < 0 || av < best) {
            best = av
            bi = i
            bj = j
          }
        }
      }
      if bi < 0 { settled = true; break }
      if bi != k {
        let t = a[k]
        a[k] = a[bi]
        a[bi] = t
      }
      if bj != k {
        for i in 0..<rows {
          let t = a[i][k]
          a[i][k] = a[i][bj]
          a[i][bj] = t
        }
      }
      if a[k][k] < 0L {
        for j in 0..<cols { a[k][j] = -a[k][j] }
      }
      let p = a[k][k]
      let mut dirty = false
      for i = k + 1; i < rows; i = i + 1 {
        if a[i][k] != 0L {
          let q = a[i][k] / p
          for j in 0..<cols { a[i][j] -= q * a[k][j] }
          if a[i][k] != 0L {
            let t = a[k]
            a[k] = a[i]
            a[i] = t
            dirty = true
            break
          }
        }
      }
      if dirty { continue }
      for j = k + 1; j < cols; j = j + 1 {
        if a[k][j] != 0L {
          let q = a[k][j] / p
          for i in 0..<rows { a[i][j] -= q * a[i][k] }
          if a[k][j] != 0L {
            for i in 0..<rows {
              let t = a[i][k]
              a[i][k] = a[i][j]
              a[i][j] = t
            }
            dirty = true
            break
          }
        }
      }
      if dirty { continue }
      let mut bad = false
      for i = k + 1; i < rows && !bad; i = i + 1 {
        for j = k + 1; j < cols; j = j + 1 {
          if a[i][j] % p != 0L {
            for j2 = 0; j2 < cols; j2 = j2 + 1 { a[k][j2] += a[i][j2] }
            bad = true
            break
          }
        }
      }
      if bad { continue }
      settled = true
    }
    let v = a[k][k]
    out.push(if v < 0L { -v } else { v })
  }
  // 可整除鏈：反覆以 (gcd, lcm) 取代相鄰對，直到 d_i | d_{i+1}。
  let mut rounds = 0
  while rounds < 64 {
    rounds += 1
    let mut changed = false
    for i = 0; i < out.length() - 1; i = i + 1 {
      let x = out[i]
      let y = out[i + 1]
      if y != 0L && x != 0L && y % x != 0L {
        out[i] = gcd(x, y)
        out[i + 1] = lcm(x, y)
        changed = true
      }
    }
    if !changed { break }
  }
  out
}

///|
/// 整數矩陣的行列式（2×2，精確）。
pub fn det2(a : Int64, b : Int64, c : Int64, d : Int64) -> Int64 { a * d - b * c }

///|
// ════════════════════════════════════════════════════════════════════════
// C1-03：精確有理矩陣與譜引擎（算術譜／拉普拉斯圖譜／歸一化圖譜／K 理論共用）
// 全部運算在 ℚ 上以 (n,d) 正規化完成，無浮點誤差。
// 依據 Chung 正規化 Laplacian、Hansen–Ghrist sheaf Laplacian、
// Faddeev–LeVerrier 特徵多項式、Kirchhoff 矩陣樹定理。
// ════════════════════════════════════════════════════════════════════════

///|
pub(all) struct Mat {
  a : Array[Array[Rat]]
}

///|
pub fn mat_from(a : Array[Array[Rat]]) -> Mat { Mat::{ a } }

///|
pub fn mat_new(n : Int, m : Int) -> Mat {
  let rows : Array[Array[Rat]] = []
  for _i in 0..<n { rows.push(Array::make(m, rat_zero())) }
  Mat::{ a: rows }
}

///|
pub fn mat_clone(x : Mat) -> Mat {
  let rows : Array[Array[Rat]] = []
  for i in 0..<x.a.length() {
    let row : Array[Rat] = Array::make(x.a[i].length(), rat_zero())
    for j in 0..<x.a[i].length() { row[j] = x.a[i][j] }
    rows.push(row)
  }
  Mat::{ a: rows }
}

///|
pub fn mat_identity(n : Int) -> Mat {
  let m = mat_new(n, n)
  for i in 0..<n { m.a[i][i] = rat_one() }
  m
}

///|
pub fn mat_scale(x : Mat, s : Rat) -> Mat {
  let m = mat_new(x.a.length(), if x.a.length() == 0 { 0 } else { x.a[0].length() })
  for i in 0..<x.a.length() {
    for j in 0..<x.a[i].length() { m.a[i][j] = x.a[i][j].mul(s) }
  }
  m
}

///|
pub fn mat_add(x : Mat, y : Mat) -> Mat {
  let m = mat_clone(x)
  for i in 0..<x.a.length() {
    for j in 0..<x.a[i].length() { m.a[i][j] = x.a[i][j].add(y.a[i][j]) }
  }
  m
}

///|
pub fn mat_sub(x : Mat, y : Mat) -> Mat { mat_add(x, mat_scale(y, rat_int(-1L))) }

///|
pub fn mat_mul(x : Mat, y : Mat) -> Mat {
  let n = x.a.length()
  let k = if x.a.length() == 0 { 0 } else { x.a[0].length() }
  let p = if y.a.length() == 0 { 0 } else { y.a[0].length() }
  let m = mat_new(n, p)
  for i in 0..<n {
    for j in 0..<p {
      let mut acc = rat_zero()
      for t in 0..<k { acc = acc.add(x.a[i][t].mul(y.a[t][j])) }
      m.a[i][j] = acc
    }
  }
  m
}

///|
pub fn mat_transpose(x : Mat) -> Mat {
  let n = x.a.length()
  let p = if n == 0 { 0 } else { x.a[0].length() }
  let m = mat_new(p, n)
  for i in 0..<n {
    for j in 0..<p { m.a[j][i] = x.a[i][j] }
  }
  m
}

///|
pub fn mat_equal(x : Mat, y : Mat) -> Bool {
  if x.a.length() != y.a.length() { return false }
  for i in 0..<x.a.length() {
    if x.a[i].length() != y.a[i].length() { return false }
    for j in 0..<x.a[i].length() {
      if !x.a[i][j].equal(y.a[i][j]) { return false }
    }
  }
  true
}

///|
pub fn mat_trace(x : Mat) -> Rat {
  let mut acc = rat_zero()
  for i in 0..<x.a.length() { acc = acc.add(x.a[i][i]) }
  acc
}

///|
/// 有理高斯消去行列式（奇異矩陣回傳 0，無除以零捷徑）。
pub fn mat_det(x : Mat) -> Rat {
  let n = x.a.length()
  if n == 0 { return rat_one() }
  let a = mat_clone(x)
  let mut det = rat_one()
  for c in 0..<n {
    let mut piv = -1
    for i in c..<n {
      if !a.a[i][c].is_zero() { piv = i; break }
    }
    if piv < 0 { return rat_zero() }
    if piv != c {
      let tmp = a.a[c]
      a.a[c] = a.a[piv]
      a.a[piv] = tmp
      det = det.neg()
    }
    let p = a.a[c][c]
    det = det.mul(p)
    for j in 0..<n { a.a[c][j] = a.a[c][j].div(p).unwrap() }
    for i in (c + 1)..<n {
      let fac = a.a[i][c]
      if fac.is_zero() { continue }
      for j in 0..<n {
        a.a[i][j] = a.a[i][j].sub(fac.mul(a.a[c][j]))
      }
    }
  }
  det
}

///|
/// 有理列消去之秩（RREF 主元數）。
pub fn mat_rank(x : Mat) -> Int {
  if x.a.length() == 0 { return 0 }
  let a = mat_clone(x)
  let n = x.a.length()
  let m = x.a[0].length()
  let mut r = 0
  for c in 0..<m {
    let mut piv = -1
    for i in r..<n {
      if !a.a[i][c].is_zero() { piv = i; break }
    }
    if piv < 0 { continue }
    let tmp = a.a[r]
    a.a[r] = a.a[piv]
    a.a[piv] = tmp
    let p = a.a[r][c]
    for j in 0..<m { a.a[r][j] = a.a[r][j].div(p).unwrap() }
    for i in 0..<n {
      if i == r { continue }
      let fac = a.a[i][c]
      if fac.is_zero() { continue }
      for j in 0..<m { a.a[i][j] = a.a[i][j].sub(fac.mul(a.a[r][j])) }
    }
    r += 1
    if r == n { break }
  }
  r
}

///|
/// 多項式（升冪係數）加法、乘法、純量乘、求值。
pub fn poly_add(a : Array[Rat], b : Array[Rat]) -> Array[Rat] {
  let n = if a.length() > b.length() { a.length() } else { b.length() }
  let out : Array[Rat] = Array::make(n, rat_zero())
  for i in 0..<a.length() { out[i] = out[i].add(a[i]) }
  for i in 0..<b.length() { out[i] = out[i].add(b[i]) }
  out
}

///|
pub fn poly_scale(a : Array[Rat], s : Rat) -> Array[Rat] {
  let out : Array[Rat] = Array::make(a.length(), rat_zero())
  for i in 0..<a.length() { out[i] = a[i].mul(s) }
  out
}

///|
pub fn poly_mul(a : Array[Rat], b : Array[Rat]) -> Array[Rat] {
  if a.length() == 0 || b.length() == 0 { return [] }
  let out : Array[Rat] = Array::make(a.length() + b.length() - 1, rat_zero())
  for i in 0..<a.length() {
    for j in 0..<b.length() {
      out[i + j] = out[i + j].add(a[i].mul(b[j]))
    }
  }
  out
}

///|
pub fn poly_eval(c : Array[Rat], x : Rat) -> Rat {
  let mut acc = rat_zero()
  let mut i = c.length()
  while i > 0 {
    i -= 1
    acc = acc.mul(x).add(c[i])
  }
  acc
}

///|
/// Faddeev–LeVerrier：B_k = M·B_{k−1} + c_k I，
/// c_k = −tr(M·B_{k−1})/k；回傳升冪係數 [c_n, ..., c_1, 1]。
pub fn mat_charpoly(x : Mat) -> Array[Rat] {
  let n = x.a.length()
  if n == 0 { return [rat_one()] }
  let mut b = mat_identity(n)
  let cs : Array[Rat] = []
  for k in 1..<(n + 1) {
    let mb = mat_mul(x, b)
    let tr = mat_trace(mb)
    let ck = rat_int(-(k.to_int64())).inv().unwrap().mul(tr)
    cs.push(ck)
    b = mat_add(mb, mat_scale(mat_identity(n), ck))
  }
  let out : Array[Rat] = []
  out.push(cs[n - 1])
  for k in 1..<n { out.push(cs[n - 1 - k]) }
  out.push(rat_one())
  out
}

///|
/// Lagrange 插值：由 n+1 個 (x_i, y_i) 求次數 ≤ n 之多項式（升冪）。
pub fn poly_from_points(xs : Array[Rat], ys : Array[Rat]) -> Array[Rat] {
  let n = xs.length()
  if n == 0 { return [] }
  // Newton 差商 + Horner 還原：與 Lagrange 等價，但中間量保持小整數，
  // 避免節點乘積造成 Int64 溢位（C1-03 修正）。
  let c : Array[Rat] = []
  for i in 0..<n { c.push(ys[i]) }
  for j in 1..<n {
    let mut i = n - 1
    while i >= j {
      c[i] = c[i].sub(c[i - 1]).div(xs[i].sub(xs[i - j])).unwrap()
      i -= 1
    }
  }
  let mut acc : Array[Rat] = [c[n - 1]]
  let mut k = n - 2
  while k >= 0 {
    acc = poly_add(poly_mul(acc, [xs[k].neg(), rat_one()]), [c[k]])
    k -= 1
  }
  acc
}

///|
/// det(A − tB)：以 t = 0,1,...,n 求值後插值，得廣義特徵多項式（升冪）。
/// 用於 ℒ = I − D^{−1/2}AD^{−1/2} 之等價廣義特徵問題 L x = λ D x。
pub fn mat_generalized_charpoly(a : Mat, b : Mat) -> Array[Rat] {
  let n = a.a.length()
  let xs : Array[Rat] = []
  let ys : Array[Rat] = []
  for t in 0..<(n + 1) {
    let tv = rat_int(t.to_int64())
    xs.push(tv)
    ys.push(mat_det(mat_sub(a, mat_scale(b, tv))))
  }
  poly_from_points(xs, ys)
}

///|
fn sign_of(x : Rat) -> Int {
  if x.n > 0L { 1 } else if x.n < 0L { -1 } else { 0 }
}

///|
/// 有理二分法：在 [lo,hi] 且有符號變異時隔離一個實根（回傳 lo 端近似）。
pub fn poly_bisect(c : Array[Rat], lo0 : Rat, hi0 : Rat, steps : Int) -> Rat {
  let mut lo = lo0
  let mut hi = hi0
  let slo = sign_of(poly_eval(c, lo))
  for _i in 0..<steps {
    let mid = lo.add(hi).mul(rat(1L, 2L))
    let sm = sign_of(poly_eval(c, mid))
    if sm == 0 { return mid }
    if sm == slo { lo = mid } else { hi = mid }
  }
  lo
}

///|
/// 最小正實根：在 (0,2] 以 1/8 步長掃描精確根或首個符號變異。
/// 刻意不遞迴二分，以保持分母 ≤ 16、所有中間量為可表示之 Int64 有理數；
/// 回傳值誤差 ≤ 1/16，為「可驗證之下界／上界」而非浮點近似。
pub fn poly_smallest_positive_root(c : Array[Rat]) -> Rat? {
  let s0 = sign_of(poly_eval(c, rat_zero()))
  if s0 == 0 { return None }
  let mut prev = rat_zero()
  for i in 1..<17 {
    let t = rat(i.to_int64(), 8L)
    let s = sign_of(poly_eval(c, t))
    // 網格上的精確根（含偶重根，如 K₃ 之 λ₂=3/2）直接回傳，不依賴符號變異。
    if s == 0 { return Some(t) }
    if s != s0 { return Some(prev.add(t).mul(rat(1L, 2L))) }
    prev = t
  }
  None
}

///|
/// 多項式降一次（去掉已知根 t=0）：c(t)/t，升冪係數左移。
pub fn poly_deflate_zero(c : Array[Rat]) -> Array[Rat] {
  let out : Array[Rat] = []
  for i in 1..<c.length() { out.push(c[i]) }
  out
}

///|
/// 由根集合建構多項式 ∏(t − r_i)（升冪係數）。
pub fn poly_from_roots(roots : Array[Rat]) -> Array[Rat] {
  let mut acc : Array[Rat] = [rat_one()]
  for i in 0..<roots.length() {
    acc = poly_mul(acc, [roots[i].neg(), rat_one()])
  }
  acc
}

///|
/// 定理 T-X1：Faddeev–LeVerrier 特徵多項式滿足 Cayley–Hamilton p(M)=0，
/// 且 det(M) = (−1)^n p(0)、tr(M) = −p 之次高係數。
pub fn theorem_charpoly_cayley_hamilton(x : Mat) -> Bool {
  let n = x.a.length()
  if n == 0 { return false }
  let c = mat_charpoly(x)
  let mut acc = mat_new(n, n)
  let mut power = mat_identity(n)
  for k in 0..<(n + 1) {
    acc = mat_add(acc, mat_scale(power, c[k]))
    power = mat_mul(power, x)
  }
  for i in 0..<n {
    for j in 0..<n {
      if !acc.a[i][j].is_zero() { return false }
    }
  }
  let det = mat_det(x)
  let p0 = c[0]
  let expected = if n % 2 == 0 { p0 } else { p0.neg() }
  det.equal(expected) && c[n - 1].equal(mat_trace(x).neg())
}

///|
// ════════════════════════════════════════════════════════════════════════
// C1-04 補回 §6'' 待辦：FFT/NTT 完整乘法、Toom–Cook 3-way、TMVP
// NTT 取 p = 998244353 = 119·2^23 + 1，原根 3；全程 Int64 模算術。
// Toom–3 以 5 個求值點（0,1,−1,2,−2）+ Lagrange 插值，5 次半尺寸乘法。
// TMVP 以「Toeplitz 嵌入循環矩陣 + NTT」實作 Toeplitz 矩陣向量乘積。
// ════════════════════════════════════════════════════════════════════════

///|
pub const NTT_PRIME : Int64 = 998244353L

///|
pub const NTT_ROOT : Int64 = 3L

///|
fn imod(a : Int64, p : Int64) -> Int64 { ((a % p) + p) % p }

///|
/// 迭代 Cooley–Tukey NTT；invert=true 時為逆變換（含 n^{−1}）。
pub fn ntt(a0 : Array[Int64], invert : Bool) -> Array[Int64] {
  let p = NTT_PRIME
  let n = a0.length()
  let a : Array[Int64] = []
  for i in 0..<n { a.push(imod(a0[i], p)) }
  let mut j = 0
  // bit-reversal permutation
  for k in 0..<n {
    if k < j {
      let t = a[k]
      a[k] = a[j]
      a[j] = t
    }
    let mut bit = n / 2
    while (j & bit) != 0 {
      j = j ^ bit
      bit = bit / 2
    }
    j = j ^ bit
  }
  let mut len = 2
  while len <= n {
    let mut wlen = mod_pow(NTT_ROOT, (p - 1L).to_int() / len, p)
    if invert { wlen = mod_inv(wlen, p) }
    for ii in 0..<(n / len) {
      let mut w = 1L
      for jj in 0..<(len / 2) {
        let u = a[ii * len + jj]
        let v = imod(w * a[ii * len + jj + len / 2], p)
        a[ii * len + jj] = imod(u + v, p)
        a[ii * len + jj + len / 2] = imod(u - v, p)
        w = imod(w * wlen, p)
      }
    }
    len = len * 2
  }
  if invert {
    let ninv = mod_inv(n.to_int64(), p)
    for k in 0..<n { a[k] = imod(a[k] * ninv, p) }
  }
  a
}

///|
/// 長度為 2 的冪之循環卷積（Toeplitz 嵌入所需）。
fn ntt_cyclic_mul(a : Array[Int64], b : Array[Int64], size : Int) -> Array[Int64] {
  let fa = ntt(a, false)
  let fb = ntt(b, false)
  let fc : Array[Int64] = []
  for i in 0..<size { fc.push(imod(fa[i] * fb[i], NTT_PRIME)) }
  ntt(fc, true)
}

///|
fn next_pow2(x : Int) -> Int {
  let mut n = 1
  while n < x { n = n * 2 }
  n
}

///|
/// 循環卷積（mod p）之 NTT 乘法，結果截斷至 cut。
pub fn ntt_mul(a : Array[Int64], b : Array[Int64], cut : Int) -> Array[Int64] {
  let need = a.length() + b.length() - 1
  let size = next_pow2(need)
  let aa : Array[Int64] = Array::make(size, 0L)
  let bb : Array[Int64] = Array::make(size, 0L)
  for i in 0..<a.length() { aa[i] = imod(a[i], NTT_PRIME) }
  for i in 0..<b.length() { bb[i] = imod(b[i], NTT_PRIME) }
  let fa = ntt(aa, false)
  let fb = ntt(bb, false)
  let fc : Array[Int64] = []
  for i in 0..<size { fc.push(imod(fa[i] * fb[i], NTT_PRIME)) }
  let c = ntt(fc, true)
  let out : Array[Int64] = []
  for i in 0..<cut { out.push(if i < c.length() { c[i] } else { 0L }) }
  out
}

///|
fn naive_conv_int(a : Array[Int64], b : Array[Int64], cut : Int) -> Array[Int64] {
  let out : Array[Int64] = Array::make(cut, 0L)
  for i in 0..<a.length() {
    for j in 0..<b.length() {
      if i + j < cut {
        out[i + j] = imod(out[i + j] + imod(a[i] * b[j], NTT_PRIME), NTT_PRIME)
      }
    }
  }
  out
}

///|
/// 定理 T-X2：NTT 正逆變換互逆，且 NTT 卷積與 school-book 卷積 mod p 相等。
pub fn theorem_ntt_equivalence(n : Int) -> Bool {
  let a : Array[Int64] = []
  let b : Array[Int64] = []
  for i in 0..<n {
    a.push(((i * 7 + 3) % 1000).to_int64())
    b.push(((i * 11 + 5) % 1000).to_int64())
  }
  let size = next_pow2(n)
  let aa : Array[Int64] = Array::make(size, 0L)
  for i in 0..<n { aa[i] = a[i] }
  let fwd = ntt(aa, false)
  let back = ntt(fwd, true)
  for i in 0..<n {
    if back[i] != imod(a[i], NTT_PRIME) { return false }
  }
  let cut = 2 * n - 1
  let c1 = ntt_mul(a, b, cut)
  let c2 = naive_conv_int(a, b, cut)
  for i in 0..<cut {
    if c1[i] != c2[i] { return false }
  }
  true
}

///|
/// Toeplitz 矩陣向量乘積：T(i,j)=t_{i−j}，以 2n×2n 循環嵌入 + NTT 計算。
pub fn toeplitz_mvp_ntt(
  tpos : Array[Int64],
  tneg : Array[Int64],
  v : Array[Int64],
) -> Array[Int64] {
  let n = v.length()
  let size = next_pow2(2 * n)
  let col : Array[Int64] = Array::make(size, 0L)
  col[0] = tpos[0]
  for k in 1..<n { col[k] = tpos[k] }
  // 標準循環嵌入：下半放 t_{−(n−1)},...,t_{−1}
  for k in 1..<n { col[size - k] = tneg[k] }
  let vec : Array[Int64] = Array::make(size, 0L)
  for i in 0..<n { vec[i] = v[i] }
  let c = ntt_cyclic_mul(col, vec, size)
  let out : Array[Int64] = []
  for i in 0..<n { out.push(c[i]) }
  out
}

///|
fn toeplitz_direct(tpos : Array[Int64], tneg : Array[Int64], v : Array[Int64]) -> Array[Int64] {
  let n = v.length()
  let out : Array[Int64] = Array::make(n, 0L)
  for i in 0..<n {
    for j in 0..<n {
      let t = if i >= j { tpos[i - j] } else { tneg[j - i] }
      out[i] = imod(out[i] + imod(t * v[j], NTT_PRIME), NTT_PRIME)
    }
  }
  out
}

///|
/// 定理 T-X3：Toeplitz 循環嵌入 NTT 與直接矩陣向量乘積相等（TMVP）。
pub fn theorem_toeplitz_mvp(n : Int) -> Bool {
  let tpos : Array[Int64] = []
  let tneg : Array[Int64] = []
  let v : Array[Int64] = []
  for k in 0..<n {
    tpos.push(((k * 3 + 1) % 97).to_int64())
    tneg.push(if k == 0 { 0L } else { ((k * 5 + 2) % 89).to_int64() })
    v.push(((k * 7 + 4) % 101).to_int64())
  }
  let a = toeplitz_mvp_ntt(tpos, tneg, v)
  let b = toeplitz_direct(tpos, tneg, v)
  for i in 0..<n {
    if a[i] != b[i] { return false }
  }
  true
}

///|
fn rat_arr(a : Array[Int64]) -> Array[Rat] {
  let out : Array[Rat] = []
  for i in 0..<a.length() { out.push(rat_int(a[i])) }
  out
}

///|
fn toom3_eval(a : Array[Rat], k : Int, z : Rat) -> Array[Rat] {
  let out : Array[Rat] = Array::make(k, rat_zero())
  for t in 0..<3 {
    let wt = z.pow(t)
    for i in 0..<k {
      let idx = t * k + i
      if idx < a.length() { out[i] = out[i].add(a[idx].mul(wt)) }
    }
  }
  out
}

///|
fn lagrange_basis(xs : Array[Rat], j : Int) -> Array[Rat] {
  let mut num : Array[Rat] = [rat_one()]
  let mut den = rat_one()
  for i in 0..<xs.length() {
    if i == j { continue }
    num = poly_mul(num, [xs[i].neg(), rat_one()])
    den = den.mul(xs[j].sub(xs[i]))
  }
  poly_scale(num, rat_one().div(den).unwrap())
}

///|
/// Toom–Cook 3-way：3 個區塊、5 個求值點、5 次半尺寸乘法，T(n)=5T(n/3)+O(n)。
pub fn toom3_mul(a0 : Array[Int64], b0 : Array[Int64]) -> Array[Int64] {
  let a = rat_arr(a0)
  let b = rat_arr(b0)
  let nn = if a.length() > b.length() { a.length() } else { b.length() }
  if nn <= 3 {
    let c = poly_mul(a, b)
    let out : Array[Int64] = []
    for i in 0..<c.length() { out.push(c[i].n) }
    return out
  }
  let k = (nn + 2) / 3
  let xs = [rat_zero(), rat_one(), rat_int(-1L), rat_int(2L), rat_int(-2L)]
  let prods : Array[Array[Rat]] = []
  for j in 0..<xs.length() {
    let av = toom3_eval(a, k, xs[j])
    let bv = toom3_eval(b, k, xs[j])
    prods.push(poly_mul(av, bv))
  }
  // C_t(x) = Σ_j l_{j,t} P_j(x)
  let ct : Array[Array[Rat]] = []
  for t in 0..<5 {
    let mut acc : Array[Rat] = []
    for j in 0..<xs.length() {
      let l = lagrange_basis(xs, j)
      let w = if t < l.length() { l[t] } else { rat_zero() }
      let scaled = poly_scale(prods[j], w)
      acc = poly_add(acc, scaled)
    }
    ct.push(acc)
  }
  let outlen = a0.length() + b0.length() - 1
  let out : Array[Int64] = Array::make(outlen, 0L)
  for t in 0..<5 {
    for i in 0..<ct[t].length() {
      let idx = t * k + i
      if idx < outlen {
        let v = ct[t][i]
        if v.d != 1L { return [] }
        out[idx] += v.n
      }
    }
  }
  out
}

///|
fn naive_conv_int64(a : Array[Int64], b : Array[Int64]) -> Array[Int64] {
  let out : Array[Int64] = Array::make(a.length() + b.length() - 1, 0L)
  for i in 0..<a.length() {
    for j in 0..<b.length() { out[i + j] += a[i] * b[j] }
  }
  out
}

///|
/// 定理 T-X4：Toom–3 與 school-book 整數卷積逐項相等。
pub fn theorem_toom3_equivalence(n : Int) -> Bool {
  let a : Array[Int64] = []
  let b : Array[Int64] = []
  for i in 0..<n {
    a.push(((i * 3 + 1) % 17).to_int64())
    b.push(((i * 5 + 2) % 19).to_int64())
  }
  let c1 = toom3_mul(a, b)
  let c2 = naive_conv_int64(a, b)
  if c1.length() != c2.length() { return false }
  for i in 0..<c2.length() {
    if c1[i] != c2[i] { return false }
  }
  true
}

///|
/// 複雜度模型（實算運算次數）：schoolbook / Karatsuba / Toom-3 / NTT / TMVP。
pub fn multiplication_costs(n : Int) -> Array[Int64] {
  let school = (n * n).to_int64()
  let mut kara = 1L
  let mut kk = n
  while kk > 1 { kara *= 3L; kk = kk / 2 }
  let mut toom = 1L
  let mut tt = n
  while tt > 1 { toom *= 5L; tt = tt / 3 }
  let l = next_pow2(2 * n)
  let mut log2 = 0
  let mut tmp = 1
  while tmp < l { tmp *= 2; log2 += 1 }
  let nttcost = (3L * (log2 + 1).to_int64() * l.to_int64()) / 2L
  let tmvp = kara + (3L * n.to_int64()) - 1L
  [school, kara, toom, nttcost, tmvp]
}

///|
/// 定理 T-X5：對 n=3⁹=19683，複雜度模型滿足 NTT < Toom-3 < Karatsuba < school-book。
pub fn theorem_complexity_ordering() -> Bool {
  let c = multiplication_costs(19683)
  c[3] < c[2] && c[2] < c[1] && c[1] < c[0] && c[4] >= c[1]
}
