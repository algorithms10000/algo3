///|
/// C1 / src/series — 局部公理 L1/L2/L3 的可執行代數
/// 多項式環 ℚ[t]、形式冪級數環 ℚ[[t]]、洛朗級數環 ℚ((t))、
/// 狄利克雷級數環 DS(ℚ)、多項式商環 ℚ[t]/(m)、截斷商 ℚ[[t]]/(t^N)、
/// 全純函數求值與收斂界，全部統一為卷積么半群代數 (monoid convolution algebra)。

///|
pub(all) struct Poly {
  coeffs : Array[@exact.Rat]
}

///|
pub(all) struct Fps {
  coeffs : Array[@exact.Rat]
}

///|
pub(all) struct Laurent {
  offset : Int
  coeffs : Array[@exact.Rat]
}

///|
pub(all) struct Dirichlet {
  coeffs : Array[@exact.Rat]
}

///|
pub(all) struct Quot {
  modulus : Poly
  rep : Poly
}

///|
pub(all) struct DivMod {
  q : Poly
  r : Poly
}

///|
/// 卷積么半群代數：kind 0 = (ℕ,+)，1 = (ℕ≥1,×)，2 = (ℤ,+)。
pub(all) struct ConvAlg {
  kind : Int
  offset : Int
  coeffs : Array[@exact.Rat]
}

///|
pub fn poly(coeffs : Array[@exact.Rat]) -> Poly { Poly::{ coeffs } }

///|
pub fn rat0() -> @exact.Rat { @exact.rat_zero() }

///|
pub fn rat1() -> @exact.Rat { @exact.rat_one() }

///|
pub fn rint(n : Int64) -> @exact.Rat { @exact.rat_int(n) }

///|
pub fn rfrac(n : Int64, d : Int64) -> @exact.Rat { @exact.rat(n, d) }

///|
pub fn poly_degree(p : Poly) -> Int {
  let mut d = p.coeffs.length() - 1
  while d >= 0 && p.coeffs[d].is_zero() { d -= 1 }
  d
}

///|
pub fn poly_trim(p : Poly) -> Poly {
  let d = poly_degree(p)
  if d < 0 { return poly([]) }
  let out : Array[@exact.Rat] = []
  for i = 0; i <= d; i = i + 1 { out.push(p.coeffs[i]) }
  poly(out)
}

///|
pub fn Poly::equal(self : Poly, o : Poly) -> Bool {
  let a = poly_trim(self)
  let b = poly_trim(o)
  if a.coeffs.length() != b.coeffs.length() { return false }
  for i in 0..<a.coeffs.length() {
    if !a.coeffs[i].equal(b.coeffs[i]) { return false }
  }
  true
}

///|
pub fn Poly::add(self : Poly, o : Poly) -> Poly {
  let n = if self.coeffs.length() > o.coeffs.length() {
    self.coeffs.length()
  } else {
    o.coeffs.length()
  }
  let out : Array[@exact.Rat] = Array::make(n, rat0())
  for i in 0..<min_int(self.coeffs.length(), n) { out[i] = out[i].add(self.coeffs[i]) }
  for i in 0..<min_int(o.coeffs.length(), n) { out[i] = out[i].add(o.coeffs[i]) }
  poly(out)
}

///|
fn min_int(a : Int, b : Int) -> Int { if a < b { a } else { b } }

///|
fn max_int(a : Int, b : Int) -> Int { if a > b { a } else { b } }

///|
pub fn Poly::sub(self : Poly, o : Poly) -> Poly {
  let n = max_int(self.coeffs.length(), o.coeffs.length())
  let out : Array[@exact.Rat] = Array::make(n, rat0())
  for i in 0..<min_int(self.coeffs.length(), n) { out[i] = out[i].add(self.coeffs[i]) }
  for i in 0..<min_int(o.coeffs.length(), n) { out[i] = out[i].sub(o.coeffs[i]) }
  poly(out)
}

///|
/// 稀疏跳零的卷積：O(|supp A|·|supp B|) 而非 O(N²)（序列演算法優化）。
pub fn Poly::mul(self : Poly, o : Poly) -> Poly {
  let n = self.coeffs.length() + o.coeffs.length() - 1
  if self.coeffs.length() == 0 || o.coeffs.length() == 0 { return poly([]) }
  let out : Array[@exact.Rat] = Array::make(n, rat0())
  for i in 0..<self.coeffs.length() {
    if self.coeffs[i].is_zero() { continue }
    for j in 0..<o.coeffs.length() {
      if o.coeffs[j].is_zero() { continue }
      out[i + j] = out[i + j].add(self.coeffs[i].mul(o.coeffs[j]))
    }
  }
  poly(out)
}

///|
pub fn Poly::pow(self : Poly, k : Int) -> Poly {
  let mut acc = poly([rat1()])
  for _i in 0..<k { acc = acc.mul(self) }
  acc
}

///|
pub fn Poly::eval(self : Poly, x : @exact.Rat) -> @exact.Rat {
  let mut acc = rat0()
  for i = self.coeffs.length() - 1; i >= 0; i = i - 1 {
    acc = acc.mul(x).add(self.coeffs[i])
  }
  acc
}

///|
/// ℚ[t] 上的帶餘除法（ℚ 為體，故對任意非零除式可行）。
pub fn poly_divmod(a : Poly, b : Poly) -> DivMod {
  let la = a.coeffs.length()
  let lb = b.coeffs.length()
  if lb == 0 { return DivMod::{ q: poly([]), r: a } }
  let r : Array[@exact.Rat] = Array::make(la, rat0())
  for i in 0..<la { r[i] = a.coeffs[i] }
  let qn = max_int(1, la - lb + 1)
  let q : Array[@exact.Rat] = Array::make(qn, rat0())
  let lc = b.coeffs[lb - 1]
  for k = la - lb; k >= 0; k = k - 1 {
    let f = r[k + lb - 1].div(lc).unwrap()
    q[k] = f
    for j in 0..<lb { r[k + j] = r[k + j].sub(f.mul(b.coeffs[j])) }
  }
  let rem : Array[@exact.Rat] = []
  for i = 0; i < lb - 1 && i < la; i = i + 1 { rem.push(r[i]) }
  DivMod::{ q: poly_trim(poly(q)), r: poly_trim(poly(rem)) }
}

///|
pub fn poly_mod(a : Poly, m : Poly) -> Poly { poly_divmod(a, m).r }

///|
pub fn poly_gcd(a : Poly, b : Poly) -> Poly {
  let mut x = poly_trim(a)
  let mut y = poly_trim(b)
  let mut steps = 0
  while poly_degree(y) >= 0 && steps < 512 {
    steps += 1
    let r = poly_divmod(x, y).r
    x = y
    y = r
  }
  x
}

///|
/// 多項式商環 ℚ[t]/(m)：(工程內容多次出現的物件之一)
pub fn quot(a : Poly, m : Poly) -> Quot {
  Quot::{ modulus: m, rep: poly_mod(a, m) }
}

///|
pub fn Quot::add(self : Quot, o : Quot) -> Quot {
  quot(self.rep.add(o.rep), self.modulus)
}

///|
pub fn Quot::mul(self : Quot, o : Quot) -> Quot {
  quot(self.rep.mul(o.rep), self.modulus)
}

///|
pub fn Quot::pow(self : Quot, k : Int) -> Quot {
  let mut acc = quot(poly([rat1()]), self.modulus)
  for _i in 0..<k { acc = acc.mul(self) }
  acc
}

///|
pub fn Quot::equal(self : Quot, o : Quot) -> Bool { self.rep.equal(o.rep) }

///|
/// 商環乘法結合律憑證：對給定三元組逐項查核 (ab)c = a(bc)。
pub fn quot_associativity_cert(m : Poly, xs : Array[Poly]) -> Int {
  let mut hits = 0
  for i in 0..<xs.length() {
    for j in 0..<xs.length() {
      for k in 0..<xs.length() {
        let a = quot(xs[i], m)
        let b = quot(xs[j], m)
        let c = quot(xs[k], m)
        if a.mul(b).mul(c).equal(a.mul(b.mul(c))) { hits += 1 }
      }
    }
  }
  hits
}

///|
pub fn fps(coeffs : Array[@exact.Rat]) -> Fps { Fps::{ coeffs } }

///|
pub fn fps_zero(n : Int) -> Fps { Fps::{ coeffs: Array::make(n, rat0()) } }

///|
pub fn fps_one(n : Int) -> Fps {
  let c : Array[@exact.Rat] = Array::make(n, rat0())
  c[0] = rat1()
  Fps::{ coeffs: c }
}

///|
pub fn fps_from_poly(p : Poly, n : Int) -> Fps {
  let c : Array[@exact.Rat] = Array::make(n, rat0())
  for i in 0..<min_int(p.coeffs.length(), n) { c[i] = p.coeffs[i] }
  Fps::{ coeffs: c }
}

///|
/// 形式冪級數環 ℚ[[t]]/(t^cut) 的乘法（L3 截斷商同態）。
pub fn fps_mul(a : Fps, b : Fps, cut : Int) -> Fps {
  let out : Array[@exact.Rat] = Array::make(cut, rat0())
  for i in 0..<min_int(a.coeffs.length(), cut) {
    if a.coeffs[i].is_zero() { continue }
    for j in 0..<min_int(b.coeffs.length(), cut - i) {
      if b.coeffs[j].is_zero() { continue }
      out[i + j] = out[i + j].add(a.coeffs[i].mul(b.coeffs[j]))
    }
  }
  Fps::{ coeffs: out }
}

///|
pub fn fps_add(a : Fps, b : Fps) -> Fps {
  let n = max_int(a.coeffs.length(), b.coeffs.length())
  let out : Array[@exact.Rat] = Array::make(n, rat0())
  for i in 0..<min_int(a.coeffs.length(), n) { out[i] = out[i].add(a.coeffs[i]) }
  for i in 0..<min_int(b.coeffs.length(), n) { out[i] = out[i].add(b.coeffs[i]) }
  Fps::{ coeffs: out }
}

///|
pub fn fps_neg(a : Fps) -> Fps {
  let out : Array[@exact.Rat] = Array::make(a.coeffs.length(), rat0())
  for i in 0..<a.coeffs.length() { out[i] = a.coeffs[i].neg() }
  Fps::{ coeffs: out }
}

///|
pub fn Fps::equal(self : Fps, o : Fps) -> Bool {
  let n = min_int(self.coeffs.length(), o.coeffs.length())
  for i in 0..<n {
    if !self.coeffs[i].equal(o.coeffs[i]) { return false }
  }
  true
}

///|
/// Newton 迭代求形式冪級數逆元：g ← g(2 − a·g)，精度每輪加倍 (R7/R8)。
/// 對 a(0) ≠ 0 回傳 g 使 a·g ≡ 1 (mod t^N)。
pub fn fps_inv(a : Fps) -> Fps {
  let n = a.coeffs.length()
  let mut g : Array[@exact.Rat] = [a.coeffs[0].inv().unwrap()]
  let mut m = 1
  while m < n {
    let m2 = min_int(2 * m, n)
    let ac : Array[@exact.Rat] = Array::make(m2, rat0())
    for i in 0..<min_int(n, m2) { ac[i] = a.coeffs[i] }
    let ag = fps_mul(Fps::{ coeffs: ac }, Fps::{ coeffs: g }, m2)
    let t : Array[@exact.Rat] = Array::make(m2, rat0())
    t[0] = rint(2L).sub(ag.coeffs[0])
    for i = 1; i < m2; i = i + 1 { t[i] = ag.coeffs[i].neg() }
    g = fps_mul(Fps::{ coeffs: g }, Fps::{ coeffs: t }, m2).coeffs
    m = m2
  }
  Fps::{ coeffs: g }
}

///|
/// 冪級數複合 f(g(t))，要求 g(0)=0。
/// 以 g 的冪次展開 Σ f_i g^i，並以 g 的 valuation v 剪除 i·v ≥ N 的項。
pub fn fps_compose(f : Fps, g : Fps) -> Fps {
  let n = min_int(f.coeffs.length(), g.coeffs.length())
  let mut v = 0
  while v < g.coeffs.length() && g.coeffs[v].is_zero() { v += 1 }
  if v == 0 { v = 1 }
  let out : Array[@exact.Rat] = Array::make(n, rat0())
  let powers : Array[Fps] = []
  let mut cur = fps_one(n)
  for i in 0..<n {
    powers.push(cur)
    if i * v >= n { cur = fps_zero(n) } else { cur = fps_mul(cur, g, n) }
  }
  for i in 0..<n {
    if f.coeffs[i].is_zero() { continue }
    if i * v >= n { continue }
    for k in 0..<n {
      out[k] = out[k].add(f.coeffs[i].mul(powers[i].coeffs[k]))
    }
  }
  Fps::{ coeffs: out }
}

///|
/// Lagrange 反演 (R8)：f(t)=t·h(t)，h(0)≠0，
/// [t^k] f^{-1} = (1/k)·[t^{k-1}] h^{-k}。
pub fn fps_reversion(f : Fps) -> Fps {
  let n = f.coeffs.length()
  let h : Array[@exact.Rat] = Array::make(n, rat0())
  for i in 0..<(n - 1) { h[i] = f.coeffs[i + 1] }
  let hinv = fps_inv(Fps::{ coeffs: h })
  let out : Array[@exact.Rat] = Array::make(n, rat0())
  let mut p = fps_one(n)
  for k = 1; k < n; k = k + 1 {
    p = fps_mul(p, hinv, n)
    out[k] = p.coeffs[k - 1].div(rint(k.to_int64())).unwrap()
  }
  Fps::{ coeffs: out }
}

///|
pub fn fps_derivative(a : Fps) -> Fps {
  let n = a.coeffs.length()
  let out : Array[@exact.Rat] = Array::make(n, rat0())
  for i in 0..<(n - 1) {
    out[i] = a.coeffs[i + 1].mul(rint((i + 1).to_int64()))
  }
  Fps::{ coeffs: out }
}

///|
pub fn fps_integral(a : Fps) -> Fps {
  let n = a.coeffs.length()
  let out : Array[@exact.Rat] = Array::make(n, rat0())
  for i = 1; i < n; i = i + 1 {
    out[i] = a.coeffs[i - 1].div(rint(i.to_int64())).unwrap()
  }
  Fps::{ coeffs: out }
}

///|
pub fn fps_exp(a : Fps) -> Fps {
  let n = a.coeffs.length()
  let out : Array[@exact.Rat] = Array::make(n, rat0())
  out[0] = rat1()
  for m = 1; m < n; m = m + 1 {
    let mut s = rat0()
    for k = 1; k <= m; k = k + 1 {
      s = s.add(a.coeffs[k].mul(rint(k.to_int64())).mul(out[m - k]))
    }
    out[m] = s.div(rint(m.to_int64())).unwrap()
  }
  Fps::{ coeffs: out }
}

///|
pub fn fps_log(a : Fps) -> Fps {
  let inv = fps_inv(a)
  let d = fps_derivative(a)
  let c = fps_mul(inv, d, a.coeffs.length())
  fps_integral(c)
}

///|
/// 全純函數（收斂冪級數）在 x 的截斷求值；Horner O(N)。
pub fn holomorphic_eval(f : Fps, x : @exact.Rat) -> @exact.Rat {
  let mut acc = rat0()
  for i = f.coeffs.length() - 1; i >= 0; i = i - 1 {
    acc = acc.mul(x).add(f.coeffs[i])
  }
  acc
}

///|
pub fn rat_abs(r : @exact.Rat) -> @exact.Rat {
  if r.cmp(rat0()) < 0 { r.neg() } else { r }
}

///|
/// Cauchy–Hadamard 半徑下界：min_{n≥1} |a_{n-1}/a_n|。
pub fn cauchy_hadamard_lower_bound(f : Fps) -> @exact.Rat {
  let mut best : @exact.Rat? = None
  for n = 1; n < f.coeffs.length(); n = n + 1 {
    if f.coeffs[n].is_zero() { continue }
    let q = rat_abs(f.coeffs[n - 1]).div(rat_abs(f.coeffs[n])).unwrap()
    match best {
      None => best = Some(q)
      Some(b) => if q.cmp(b) < 0 { best = Some(q) }
    }
  }
  match best {
    None => rat1()
    Some(b) => b
  }
}

///|
/// 全純函數截斷尾項的幾何級數上界 (ρ|x|<1 時有效)：
/// |Σ_{n≥N} a_n x^n| ≤ |a_N x^N| / (1 − ρ|x|)。
pub fn holomorphic_tail_bound(f : Fps, x : @exact.Rat, order : Int) -> @exact.Rat? {
  let ax = rat_abs(x)
  let mut rho = rat0()
  for n = 1; n < f.coeffs.length(); n = n + 1 {
    if f.coeffs[n].is_zero() { continue }
    let q = rat_abs(f.coeffs[n]).div(rat_abs(f.coeffs[n - 1])).unwrap()
    if q.cmp(rho) > 0 { rho = q }
  }
  let denom = rat1().sub(rho.mul(ax))
  if denom.cmp(rat0()) <= 0 { return None }
  if order >= f.coeffs.length() { return None }
  Some(rat_abs(f.coeffs[order].mul(x.pow(order))).div(denom).unwrap())
}

///|
pub fn fps_eval(f : Fps, x : @exact.Rat) -> @exact.Rat { holomorphic_eval(f, x) }

///|
/// 定理 T-S2：exp(log a) ≡ a、log(exp b) ≡ b (mod t^N)。
pub fn theorem_exp_log_inverse(a : Fps, b : Fps) -> Bool {
  let e = fps_exp(fps_log(a))
  let l = fps_log(fps_exp(b))
  e.equal(a) && l.equal(b)
}

///|
/// 定理 T-S3：Newton 反演正確性 a·fps_inv(a) ≡ 1 (mod t^N)。
pub fn theorem_newton_inverse(a : Fps) -> Bool {
  let g = fps_inv(a)
  let prod = fps_mul(a, g, a.coeffs.length())
  prod.equal(fps_one(a.coeffs.length()))
}

///|
/// 定理 T-S4：Lagrange 反演的合成恆等式 f(f^{-1}(t)) ≡ t (mod t^N)。
pub fn theorem_reversion(f : Fps) -> Bool {
  let g = fps_reversion(f)
  let comp = fps_compose(f, g)
  let target : Array[@exact.Rat] = Array::make(f.coeffs.length(), rat0())
  if target.length() > 1 { target[1] = rat1() }
  comp.equal(Fps::{ coeffs: target })
}

///|
/// 洛朗級數環 ℚ((t))：係數由 offset 起算。
pub fn laurent(offset : Int, coeffs : Array[@exact.Rat]) -> Laurent {
  Laurent::{ offset, coeffs }
}

///|
pub fn Laurent::add(self : Laurent, o : Laurent) -> Laurent {
  let off = min_int(self.offset, o.offset)
  let end = max_int(self.offset + self.coeffs.length(), o.offset + o.coeffs.length())
  let out : Array[@exact.Rat] = Array::make(end - off, rat0())
  for i in 0..<self.coeffs.length() {
    out[self.offset + i - off] = out[self.offset + i - off].add(self.coeffs[i])
  }
  for i in 0..<o.coeffs.length() {
    out[o.offset + i - off] = out[o.offset + i - off].add(o.coeffs[i])
  }
  Laurent::{ offset: off, coeffs: out }
}

///|
pub fn Laurent::mul(self : Laurent, o : Laurent) -> Laurent {
  let off = self.offset + o.offset
  let n = self.coeffs.length() + o.coeffs.length() - 1
  let out : Array[@exact.Rat] = Array::make(n, rat0())
  for i in 0..<self.coeffs.length() {
    if self.coeffs[i].is_zero() { continue }
    for j in 0..<o.coeffs.length() {
      if o.coeffs[j].is_zero() { continue }
      out[i + j] = out[i + j].add(self.coeffs[i].mul(o.coeffs[j]))
    }
  }
  Laurent::{ offset: off, coeffs: out }
}

///|
pub fn laurent_valuation(a : Laurent) -> Int {
  let mut k = 0
  while k < a.coeffs.length() && a.coeffs[k].is_zero() { k += 1 }
  if k == a.coeffs.length() { -1 } else { a.offset + k }
}

///|
/// ℚ((t)) 為體：最低次係數非零者可逆。
pub fn laurent_inv(a : Laurent) -> Laurent {
  let mut k = 0
  while k < a.coeffs.length() && a.coeffs[k].is_zero() { k += 1 }
  let c : Array[@exact.Rat] = Array::make(a.coeffs.length(), rat0())
  for i in 0..<(a.coeffs.length() - k) { c[i] = a.coeffs[k + i] }
  let inv = fps_inv(Fps::{ coeffs: c })
  Laurent::{ offset: -(a.offset + k), coeffs: inv.coeffs }
}

///|
/// 定理 T-S5：洛朗級數賦值可加 val(ab) = val(a) + val(b)。
pub fn theorem_laurent_valuation(a : Laurent, b : Laurent) -> Bool {
  let va = laurent_valuation(a)
  let vb = laurent_valuation(b)
  laurent_valuation(a.mul(b)) == va + vb
}

///|
pub fn dirichlet(coeffs : Array[@exact.Rat]) -> Dirichlet { Dirichlet::{ coeffs } }

///|
/// 狄利克雷卷積：(a*b)(n) = Σ_{d|n} a(d)b(n/d)，O(N log N) 除法枚舉。
pub fn ds_mul(a : Dirichlet, b : Dirichlet) -> Dirichlet {
  let n = min_int(a.coeffs.length(), b.coeffs.length())
  let out : Array[@exact.Rat] = Array::make(n, rat0())
  for i = 1; i <= n; i = i + 1 {
    if a.coeffs[i - 1].is_zero() { continue }
    for j = 1; j <= n / i; j = j + 1 {
      out[i * j - 1] = out[i * j - 1].add(a.coeffs[i - 1].mul(b.coeffs[j - 1]))
    }
  }
  Dirichlet::{ coeffs: out }
}

///|
pub fn ds_one(n : Int) -> Dirichlet {
  let c : Array[@exact.Rat] = Array::make(n, rat0())
  c[0] = rat1()
  Dirichlet::{ coeffs: c }
}

///|
pub fn ds_zeta(n : Int) -> Dirichlet {
  let c : Array[@exact.Rat] = Array::make(n, rat1())
  Dirichlet::{ coeffs: c }
}

///|
pub fn ds_identity(n : Int) -> Dirichlet {
  let c : Array[@exact.Rat] = Array::make(n, rat0())
  for i = 1; i <= n; i = i + 1 { c[i - 1] = rint(i.to_int64()) }
  Dirichlet::{ coeffs: c }
}

///|
pub fn ds_inv(a : Dirichlet) -> Dirichlet {
  let n = a.coeffs.length()
  let out : Array[@exact.Rat] = Array::make(n, rat0())
  out[0] = a.coeffs[0].inv().unwrap()
  for m = 2; m <= n; m = m + 1 {
    let mut s = rat0()
    for d = 2; d <= m; d = d + 1 {
      if m % d == 0 { s = s.add(a.coeffs[d - 1].mul(out[m / d - 1])) }
    }
    out[m - 1] = s.neg().div(a.coeffs[0]).unwrap()
  }
  Dirichlet::{ coeffs: out }
}

///|
/// Möbius μ(n)：平方因子則 0，否則 (-1)^{#prime factors}。
pub fn mobius(n : Int) -> Int64 {
  let mut m = n
  let mut cnt = 0
  let mut p = 2
  while p * p <= m {
    if m % p == 0 {
      m = m / p
      if m % p == 0 { return 0L }
      cnt += 1
    } else {
      p += 1
    }
  }
  if m > 1 { cnt += 1 }
  if cnt % 2 == 0 { 1L } else { -1L }
}

///|
pub fn ds_mobius(n : Int) -> Dirichlet {
  let c : Array[@exact.Rat] = Array::make(n, rat0())
  for i = 1; i <= n; i = i + 1 { c[i - 1] = rint(mobius(i)) }
  Dirichlet::{ coeffs: c }
}

///|
pub fn ds_phi(n : Int) -> Dirichlet {
  let c : Array[@exact.Rat] = Array::make(n, rat0())
  for m = 1; m <= n; m = m + 1 {
    let mut res = m.to_int64()
    let mut t = m
    let mut p = 2
    while p * p <= t {
      if t % p == 0 {
        while t % p == 0 { t = t / p }
        res = res - res / p.to_int64()
      }
      p += 1
    }
    if t > 1 { res = res - res / t.to_int64() }
    c[m - 1] = rint(res)
  }
  Dirichlet::{ coeffs: c }
}

///|
pub fn Dirichlet::equal(self : Dirichlet, o : Dirichlet) -> Bool {
  let n = min_int(self.coeffs.length(), o.coeffs.length())
  for i in 0..<n {
    if !self.coeffs[i].equal(o.coeffs[i]) { return false }
  }
  true
}

///|
/// 定理 T-S6：ζ * μ = δ_1（Möbius 反演公式），及 σ = ζ * id。
pub fn theorem_dirichlet_mobius(n : Int) -> Bool {
  let z = ds_zeta(n)
  let mu = ds_mobius(n)
  let prod = ds_mul(z, mu)
  let sigma = ds_mul(z, ds_identity(n))
  let mut ok = prod.equal(ds_one(n))
  for m = 1; m <= n; m = m + 1 {
    let mut s = 0L
    for d = 1; d <= m; d = d + 1 {
      if m % d == 0 { s += d.to_int64() }
    }
    if !sigma.coeffs[m - 1].equal(rint(s)) { ok = false }
  }
  ok
}

///|
/// 定理 T-S7：Euler 乘積 — 對乘法函數 σ 與 φ，
/// f(n) = Π_{p^e || n} f(p^e) 對所有 n ≤ N 成立。
pub fn theorem_euler_product(n : Int) -> Bool {
  let sigma = ds_mul(ds_zeta(n), ds_identity(n))
  let phi = ds_phi(n)
  for m = 2; m <= n; m = m + 1 {
    let mut t = m
    let mut p = 2
    let mut prod_s = rat1()
    let mut prod_p = rat1()
    let mut check = 1
    while p * p <= t {
      if t % p == 0 {
        let mut e = 0
        let mut pe = 1
        while t % p == 0 {
          t = t / p
          e += 1
          pe *= p
        }
        let mut ss = 0L
        let mut pw = 1L
        for i = 0; i <= e; i = i + 1 {
          ss += pw
          pw *= p.to_int64()
        }
        let ph = (pe - pe / p).to_int64()
        prod_s = prod_s.mul(rint(ss))
        prod_p = prod_p.mul(rint(ph))
        check *= pe
      }
      p += 1
    }
    if t > 1 {
      let pe = t
      prod_s = prod_s.mul(rint((1 + pe).to_int64()))
      prod_p = prod_p.mul(rint((pe - 1).to_int64()))
      check *= pe
    }
    if check != m { return false }
    if !prod_s.equal(sigma.coeffs[m - 1]) { return false }
    if !prod_p.equal(phi.coeffs[m - 1]) { return false }
  }
  true
}

///|
/// 共性定理 (L2)：三種么半群卷積在同一資料結構上給出結合代數。
pub fn conv_mul(a : ConvAlg, b : ConvAlg, cut : Int) -> ConvAlg {
  if a.kind == 0 {
    let out : Array[@exact.Rat] = Array::make(cut, rat0())
    for i in 0..<min_int(a.coeffs.length(), cut) {
      for j in 0..<min_int(b.coeffs.length(), cut - i) {
        out[i + j] = out[i + j].add(a.coeffs[i].mul(b.coeffs[j]))
      }
    }
    ConvAlg::{ kind: 0, offset: 0, coeffs: out }
  } else if a.kind == 1 {
    let out : Array[@exact.Rat] = Array::make(cut, rat0())
    for i = 1; i <= cut; i = i + 1 {
      for j = 1; j <= cut / i; j = j + 1 {
        out[i * j - 1] = out[i * j - 1].add(a.coeffs[i - 1].mul(b.coeffs[j - 1]))
      }
    }
    ConvAlg::{ kind: 1, offset: 1, coeffs: out }
  } else {
    let off = a.offset + b.offset
    let n = min_int(a.coeffs.length() + b.coeffs.length() - 1, cut)
    let out : Array[@exact.Rat] = Array::make(n, rat0())
    for i in 0..<min_int(a.coeffs.length(), n) {
      for j in 0..<min_int(b.coeffs.length(), n - i) {
        out[i + j] = out[i + j].add(a.coeffs[i].mul(b.coeffs[j]))
      }
    }
    ConvAlg::{ kind: 2, offset: off, coeffs: out }
  }
}

///|
pub fn ConvAlg::equal(self : ConvAlg, o : ConvAlg) -> Bool {
  if self.kind != o.kind || self.offset != o.offset { return false }
  if self.coeffs.length() != o.coeffs.length() { return false }
  for i in 0..<self.coeffs.length() {
    if !self.coeffs[i].equal(o.coeffs[i]) { return false }
  }
  true
}

///|
/// 定理 T-S1（共性／多合一）：(a*b)*c = a*(b*c) 對 ℕ,+／ℕ≥1,×／ℤ,+ 三種么半群皆成立。
pub fn theorem_conv_associative(kind : Int, cut : Int) -> Bool {
  let mk = fn(k : Int) -> ConvAlg {
    let c : Array[@exact.Rat] = Array::make(cut, rat0())
    for i in 0..<cut {
      c[i] = rfrac(((i + k + 1) % 5 + 1).to_int64(), ((i + k) % 3 + 2).to_int64())
    }
    let off = if kind == 2 { -1 } else if kind == 1 { 1 } else { 0 }
    ConvAlg::{ kind, offset: off, coeffs: c }
  }
  let a = mk(0)
  let b = mk(2)
  let c = mk(4)
  conv_mul(conv_mul(a, b, cut), c, cut).equal(conv_mul(a, conv_mul(b, c, cut), cut))
}

///|
/// 左 Kan 擴展 (組合範例 1)：么半群同態 φ(n) = 2^n 由 (ℕ,+) 送到 (ℕ≥1,×)，
/// Lan_φ(f)(m) = Σ_{n : 2^n = m} f(n)，為纖維上的和。
pub fn lan_along_phi(f : Fps, cut : Int) -> Dirichlet {
  let out : Array[@exact.Rat] = Array::make(cut, rat0())
  let mut n = 0
  let mut m = 1L
  while m.to_int() <= cut && n < f.coeffs.length() {
    out[m.to_int() - 1] = f.coeffs[n]
    n += 1
    m *= 2L
  }
  Dirichlet::{ coeffs: out }
}

///|
/// 定理 T-S8（Kan 擴展保持環結構）：φ 為么半群同態 ⇒
/// Lan_φ(f·g) = Lan_φ(f) * Lan_φ(g)（此處 f,g 的支撐落於 2 的冪次）。
pub fn theorem_lan_ring_hom(cut : Int) -> Bool {
  let fa : Array[@exact.Rat] = Array::make(cut, rat0())
  let fb : Array[@exact.Rat] = Array::make(cut, rat0())
  fa[0] = rat1()
  fa[1] = rint(1L)
  fb[0] = rint(2L)
  fb[2] = rint(3L)
  let f = Fps::{ coeffs: fa }
  let g = Fps::{ coeffs: fb }
  let lhs = lan_along_phi(fps_mul(f, g, cut), cut)
  let rhs = ds_mul(lan_along_phi(f, cut), lan_along_phi(g, cut))
  lhs.equal(rhs)
}

///|
// ════════════════════════════════════════════════════════════════════════
// C1-02 補回 §6 待辦：高階常數級優化
// (a) Karatsuba 次二次卷積 O(n^{log2 3})（Lyu 之 KaratsubaSkew /
//     Puchinger–Wachter-Zeh 快速 skew 乘法之交換係數特例）
// (b) Brent–Kung baby-step/giant-step 合成，搭配 Karatsuba 乘法
// (c) Bostan–Mori Graeffe 迭代 / Kinoshita–Li (FOCS 2024) 之
//     [t^N] P(t)/Q(t) 係數抽取，O(M(N) log N)，每次遞迴把 N 減半
// ════════════════════════════════════════════════════════════════════════

///|
fn arr_slice(a : Array[@exact.Rat], from : Int, to : Int) -> Array[@exact.Rat] {
  let out : Array[@exact.Rat] = []
  let mut i = from
  while i < to && i < a.length() {
    out.push(a[i])
    i += 1
  }
  out
}

///|
fn arr_add(a : Array[@exact.Rat], b : Array[@exact.Rat]) -> Array[@exact.Rat] {
  let n = max_int(a.length(), b.length())
  let out : Array[@exact.Rat] = Array::make(n, rat0())
  for i in 0..<a.length() { out[i] = out[i].add(a[i]) }
  for i in 0..<b.length() { out[i] = out[i].add(b[i]) }
  out
}

///|
fn arr_sub(a : Array[@exact.Rat], b : Array[@exact.Rat]) -> Array[@exact.Rat] {
  let n = max_int(a.length(), b.length())
  let out : Array[@exact.Rat] = Array::make(n, rat0())
  for i in 0..<a.length() { out[i] = out[i].add(a[i]) }
  for i in 0..<b.length() { out[i] = out[i].sub(b[i]) }
  out
}

///|
/// Karatsuba：3 次半尺寸乘法取代 4 次，遞迴 T(n)=3T(n/2)+O(n)。
fn kar_mul(a : Array[@exact.Rat], b : Array[@exact.Rat]) -> Array[@exact.Rat] {
  if a.length() == 0 || b.length() == 0 { return [] }
  let n = max_int(a.length(), b.length())
  if n <= 16 {
    let out : Array[@exact.Rat] = Array::make(a.length() + b.length() - 1, rat0())
    for i in 0..<a.length() {
      for j in 0..<b.length() {
        out[i + j] = out[i + j].add(a[i].mul(b[j]))
      }
    }
    return out
  }
  let m = n / 2
  let a0 = arr_slice(a, 0, m)
  let a1 = arr_slice(a, m, n)
  let b0 = arr_slice(b, 0, m)
  let b1 = arr_slice(b, m, n)
  let z0 = kar_mul(a0, b0)
  let z2 = kar_mul(a1, b1)
  let z1 = kar_mul(arr_add(a0, a1), arr_add(b0, b1))
  let cross = arr_sub(arr_sub(z1, z0), z2)
  let out : Array[@exact.Rat] = Array::make(a.length() + b.length() - 1, rat0())
  for i in 0..<z0.length() {
    if i < out.length() { out[i] = out[i].add(z0[i]) }
  }
  for i in 0..<cross.length() {
    if i + m < out.length() { out[i + m] = out[i + m].add(cross[i]) }
  }
  for i in 0..<z2.length() {
    if i + 2 * m < out.length() { out[i + 2 * m] = out[i + 2 * m].add(z2[i]) }
  }
  out
}

///|
pub fn poly_mul_karatsuba(a : Poly, b : Poly) -> Poly {
  poly(kar_mul(a.coeffs, b.coeffs))
}

///|
pub fn fps_mul_karatsuba(a : Fps, b : Fps, cut : Int) -> Fps {
  let aa = arr_slice(a.coeffs, 0, cut)
  let bb = arr_slice(b.coeffs, 0, cut)
  let prod = kar_mul(aa, bb)
  let out : Array[@exact.Rat] = Array::make(cut, rat0())
  for i in 0..<min_int(prod.length(), cut) { out[i] = prod[i] }
  Fps::{ coeffs: out }
}

///|
/// 定理 T-S9：Karatsuba 卷積與 school-book 卷積逐項相等。
pub fn theorem_karatsuba_equivalence(n : Int) -> Bool {
  let ca : Array[@exact.Rat] = []
  let cb : Array[@exact.Rat] = []
  for i in 0..<n {
    ca.push(rfrac((i + 1).to_int64(), (i % 3 + 2).to_int64()))
    cb.push(rfrac((i + 2).to_int64(), (i % 4 + 3).to_int64()))
  }
  let pa = poly(ca)
  let pb = poly(cb)
  if !pa.mul(pb).equal(poly_mul_karatsuba(pa, pb)) { return false }
  let fa = Fps::{ coeffs: ca }
  let fb = Fps::{ coeffs: cb }
  if !fps_mul(fa, fb, n).equal(fps_mul_karatsuba(fa, fb, n)) { return false }
  true
}

///|
/// Brent–Kung baby-step / giant-step 合成：
/// f(g) = Σ_i (Σ_{j<B} f_{iB+j} g^j) · g^{iB}，以 Karatsuba 做每次截斷乘法。
pub fn fps_compose_bk(f : Fps, g : Fps, block : Int) -> Fps {
  let n = min_int(f.coeffs.length(), g.coeffs.length())
  let b = if block < 1 { 1 } else { block }
  let powers : Array[Fps] = []
  let mut cur = fps_one(n)
  for _j in 0..<b {
    powers.push(cur)
    cur = fps_mul_karatsuba(cur, g, n)
  }
  let gstep = cur
  let mut outer = fps_one(n)
  let out : Array[@exact.Rat] = Array::make(n, rat0())
  let mut i = 0
  while i * b < n {
    let inner : Array[@exact.Rat] = Array::make(n, rat0())
    for j in 0..<b {
      let idx = i * b + j
      if idx < n && !f.coeffs[idx].is_zero() {
        for k in 0..<n {
          inner[k] = inner[k].add(f.coeffs[idx].mul(powers[j].coeffs[k]))
        }
      }
    }
    let chunk = fps_mul_karatsuba(Fps::{ coeffs: inner }, outer, n)
    for k in 0..<n { out[k] = out[k].add(chunk.coeffs[k]) }
    outer = fps_mul_karatsuba(outer, gstep, n)
    i += 1
  }
  Fps::{ coeffs: out }
}

///|
pub fn theorem_bk_composition(f : Fps, g : Fps, block : Int) -> Bool {
  fps_compose(f, g).equal(fps_compose_bk(f, g, block))
}

///|
fn alternate_negate(q : Array[@exact.Rat]) -> Array[@exact.Rat] {
  let out : Array[@exact.Rat] = []
  for i in 0..<q.length() {
    out.push(if i % 2 == 1 { q[i].neg() } else { q[i] })
  }
  out
}

///|
/// Bostan–Mori Graeffe 迭代：[t^N] P/Q，遞迴把 N 減半，O(M(N) log N)。
/// 要求 Q(0) = 1。Q(t)Q(−t) = V(t²) 為偶級數，U = P·Q(−t) 分偶/奇部。
pub fn graeffe_coeff(p : Array[@exact.Rat], q : Array[@exact.Rat], n : Int) -> @exact.Rat {
  if n == 0 {
    if p.length() == 0 { return rat0() }
    return p[0]
  }
  let qn = alternate_negate(q)
  let u = fps_mul(Fps::{ coeffs: p }, Fps::{ coeffs: qn }, n + 1)
  let v = fps_mul(Fps::{ coeffs: q }, Fps::{ coeffs: qn }, n + 1)
  let half = if n % 2 == 0 { n / 2 } else { (n - 1) / 2 }
  let w : Array[@exact.Rat] = []
  for k in 0..<(half + 1) {
    let idx = 2 * k
    if idx < v.coeffs.length() { w.push(v.coeffs[idx]) } else { w.push(rat0()) }
  }
  let un : Array[@exact.Rat] = []
  for k in 0..<(half + 1) {
    let idx = if n % 2 == 0 { 2 * k } else { 2 * k + 1 }
    if idx < u.coeffs.length() { un.push(u.coeffs[idx]) } else { un.push(rat0()) }
  }
  graeffe_coeff(un, w, half)
}

///|
/// 定理 T-S10：Graeffe 係數抽取與 Newton 反演之直接計算逐項相等。
pub fn theorem_graeffe_coeff(n : Int) -> Bool {
  let pp : Array[@exact.Rat] = Array::make(n + 1, rat0())
  let qq : Array[@exact.Rat] = Array::make(n + 1, rat0())
  pp[0] = rat1()
  if n + 1 > 1 { pp[1] = rint(2L) }
  if n + 1 > 2 { pp[2] = rfrac(1L, 3L) }
  qq[0] = rat1()
  if n + 1 > 1 { qq[1] = rint(-1L) }
  if n + 1 > 2 { qq[2] = rfrac(1L, 2L) }
  let inv = fps_inv(Fps::{ coeffs: qq })
  let direct = fps_mul(Fps::{ coeffs: pp }, inv, n + 1)
  for k in 0..<(n + 1) {
    let g = graeffe_coeff(pp, qq, k)
    if !direct.coeffs[k].equal(g) { return false }
  }
  true
}
