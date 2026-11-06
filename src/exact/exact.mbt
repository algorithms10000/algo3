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
