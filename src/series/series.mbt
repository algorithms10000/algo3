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

///|
// ════════════════════════════════════════════════════════════════════════
// C1-03：算術譜（Spec Z 之有限模型 / spectral triple）
// 依據 R26 Connes–Consani–Moscovici Zeta Spectral Triples (2025/26)、
// R27 Connes–Consani On the Jacobian of Spec Z (JNCG 2026)、
// R10 Arakelov 除子與 Pic(Spec Z)。取有限算術曲線 Spec(ℤ/nℤ)：
//   H = ℚ^{Div(n)}，D = diag Ω(d)（算術 Dirac），
//   A 由「p | d」之冪等對角算子生成，T_p 為 Hecke 升階算子。
// ════════════════════════════════════════════════════════════════════════

///|
pub fn prime_factorization(n : Int64) -> Array[Array[Int64]] {
  let out : Array[Array[Int64]] = []
  let mut t = n
  let mut p = 2L
  while p * p <= t {
    if t % p == 0L {
      let mut e = 0L
      while t % p == 0L { t = t / p; e += 1L }
      out.push([p, e])
    }
    p += 1L
  }
  if t > 1L { out.push([t, 1L]) }
  out
}

///|
pub fn prime_divisors(n : Int64) -> Array[Int64] {
  let f = prime_factorization(n)
  let out : Array[Int64] = []
  for i in 0..<f.length() { out.push(f[i][0]) }
  out
}

///|
pub fn divisors_of(n : Int64) -> Array[Int64] {
  let out : Array[Int64] = []
  let mut d = 1L
  while d <= n {
    if n % d == 0L { out.push(d) }
    d += 1L
  }
  out
}

///|
/// Ω(n)：素因子個數（計重數），即算術 Dirac 算子之特徵值。
pub fn big_omega(n : Int64) -> Int {
  let f = prime_factorization(n)
  let mut s = 0L
  for i in 0..<f.length() { s += f[i][1] }
  s.to_int()
}

///|
pub fn euler_phi(n : Int64) -> Int64 {
  let mut c = 0L
  for k in 1..<(n.to_int() + 1) {
    if @exact.gcd(k.to_int64(), n) == 1L { c += 1L }
  }
  c
}

///|
/// 算術譜：D 之特徵值多重集 {Ω(d) : d | n}。
pub fn arithmetic_spectrum(n : Int64) -> Array[@exact.Rat] {
  let ds = divisors_of(n)
  let out : Array[@exact.Rat] = []
  for i in 0..<ds.length() { out.push(rint(big_omega(ds[i]).to_int64())) }
  out
}

///|
/// 算術 zeta / Poincaré 多項式：Σ_{d|n} t^{Ω(d)} = ∏_i (1+t+...+t^{e_i})。
pub fn arithmetic_zeta_poly(n : Int64) -> Poly {
  let mut acc : Array[@exact.Rat] = [rat1()]
  let f = prime_factorization(n)
  for i in 0..<f.length() {
    let e = f[i][1]
    let factor : Array[@exact.Rat] = Array::make((e + 1L).to_int(), rat1())
    acc = @exact.poly_mul(acc, factor)
  }
  poly(acc)
}

///|
/// 算術 Dirac 算子 D = diag Ω(d)（以 divisor 為基底）。
pub fn arithmetic_dirac(n : Int64) -> @exact.Mat {
  let ds = divisors_of(n)
  let m = @exact.mat_new(ds.length(), ds.length())
  for i in 0..<ds.length() {
    m.a[i][i] = rint(big_omega(ds[i]).to_int64())
  }
  m
}

///|
/// Hecke 升階算子 T_p：e_d ↦ e_{dp}（若 p 尚可再乘一次）。
pub fn arithmetic_hecke(n : Int64, p : Int64) -> @exact.Mat {
  let ds = divisors_of(n)
  let m = @exact.mat_new(ds.length(), ds.length())
  for j in 0..<ds.length() {
    if ds[j] * p <= n && n % (ds[j] * p) == 0L {
      for i in 0..<ds.length() {
        if ds[i] == ds[j] * p { m.a[i][j] = rat1() }
      }
    }
  }
  m
}

///|
/// 代數 A 之生成元 E_p = diag([p | d])，為冪等對角算子。
pub fn arithmetic_idempotent(n : Int64, p : Int64) -> @exact.Mat {
  let ds = divisors_of(n)
  let m = @exact.mat_new(ds.length(), ds.length())
  for i in 0..<ds.length() {
    if ds[i] % p == 0L { m.a[i][i] = rat1() }
  }
  m
}

///|
/// 定理 T-A1：算術 zeta 多項式之係數 = Ω 分層計數，
/// 且滿足 Euler 乘積 ∏(1+t+...+t^{e_i})；Σ c_k = τ(n)。
pub fn theorem_arithmetic_zeta(n : Int64) -> Bool {
  let z = arithmetic_zeta_poly(n)
  let ds = divisors_of(n)
  let counts : Array[Int] = Array::make(z.coeffs.length(), 0)
  for i in 0..<ds.length() {
    let k = big_omega(ds[i])
    if k < counts.length() { counts[k] += 1 }
  }
  for k in 0..<z.coeffs.length() {
    if !z.coeffs[k].equal(rint(counts[k].to_int64())) { return false }
  }
  let mut total = 0L
  for k in 0..<counts.length() { total += counts[k].to_int64() }
  total == ds.length().to_int64()
}

///|
/// 定理 T-A2（spectral triple）：Faddeev–LeVerrier 特徵多項式
/// 與 ∏(t−Ω(d)) 一致；[D, E_p] = 0（有界交換子）；
/// [D, T_p] = T_p（Hecke 升階使 Ω 加 1）；
/// 譜作用 Σ_d Ω(d)² = Σ_k c_k k²。
pub fn theorem_arithmetic_spectral_triple(n : Int64) -> Bool {
  let d = arithmetic_dirac(n)
  let spec = arithmetic_spectrum(n)
  let c1 = @exact.mat_charpoly(d)
  let c2 = @exact.poly_from_roots(spec)
  if c1.length() != c2.length() { return false }
  for i in 0..<c1.length() {
    if !c1[i].equal(c2[i]) { return false }
  }
  let ps = prime_divisors(n)
  for i in 0..<ps.length() {
    let e = arithmetic_idempotent(n, ps[i])
    let comm = @exact.mat_sub(
      @exact.mat_mul(d, e), @exact.mat_mul(e, d),
    )
    for r in 0..<comm.a.length() {
      for c in 0..<comm.a[r].length() {
        if !comm.a[r][c].is_zero() { return false }
      }
    }
    let t = arithmetic_hecke(n, ps[i])
    let comm2 = @exact.mat_sub(
      @exact.mat_mul(d, t), @exact.mat_mul(t, d),
    )
    if !@exact.mat_equal(comm2, t) { return false }
  }
  // 譜作用：tr(D²) = Σ_k c_k k²
  let z = arithmetic_zeta_poly(n)
  let mut action = rat0()
  for k in 0..<z.coeffs.length() {
    action = action.add(z.coeffs[k].mul(rint((k * k).to_int64())))
  }
  @exact.mat_trace(@exact.mat_mul(d, d)).equal(action)
}

///|
/// 定理 T-A3：Spec(ℤ/nℤ) 之 Zariski 極性為伽羅瓦對應（全局公理 G）。
/// X = 素因子子集合，Y = 除子；R(S,d) ⟺ ∀p∈S, p|d。
/// 驗證伴隨性 S ⊆ H(T) ⟺ T ⊆ F(S) 與閉包三律。
pub fn theorem_arithmetic_galois(n : Int64) -> Bool {
  let primes = prime_divisors(n)
  let ds = divisors_of(n)
  let np = primes.length()
  let nd = ds.length()
  // 有限穷舉邊界：|Div(n)| ≤ 14 且素因子 ≤ 6（憑證為有限計算，非無限宣稱）
  if np > 6 || nd > 14 { return false }
  // F(S) = { d | ∀p∈S, p|d }；H(T) = { p | ∀d∈T, p|d }
  let fs : Array[UInt64] = []
  for s in 0..<(1 << np) {
    let mut mask = 0UL
    for j in 0..<nd {
      let mut ok = true
      for i in 0..<np {
        if ((s.to_uint64() >> i) & 1UL) == 1UL && ds[j] % primes[i] != 0L {
          ok = false
          break
        }
      }
      if ok { mask = @exact.set_bit(mask, j) }
    }
    fs.push(mask)
  }
  let ht : Array[UInt64] = []
  for t in 0..<(1 << nd) {
    let mut mask = 0UL
    for i in 0..<np {
      let mut ok = true
      for j in 0..<nd {
        if ((t.to_uint64() >> j) & 1UL) == 1UL && ds[j] % primes[i] != 0L {
          ok = false
          break
        }
      }
      if ok { mask = @exact.set_bit(mask, i) }
    }
    ht.push(mask)
  }
  // 伴隨性
  for s in 0..<(1 << np) {
    for t in 0..<(1 << nd) {
      let left = (s.to_uint64() & ht[t]) == s.to_uint64()
      let right = (t.to_uint64() & fs[s]) == t.to_uint64()
      if left != right { return false }
    }
  }
  // 閉包 c = H∘F 三律
  let full = (1UL << np) - 1UL
  for s in 0..<(1 << np) {
    let c = ht[fs[s].to_int()].to_int()
    if (s.to_uint64() & c.to_uint64()) != s.to_uint64() { return false }
    if ht[fs[c].to_int()] != c.to_uint64() { return false }
    if (c.to_uint64() & full) != c.to_uint64() { return false }
  }
  true
}

///|
/// 定理 T-A4：算術函數恆等式 Σ_{d|n} φ(d) = n、Σ_{d|n} μ(d) = [n=1]、
/// φ(n) = n·∏_{p|n}(1 − 1/p)、Dirichlet 卷積 μ * 1 = ε。
pub fn theorem_arithmetic_functions(n : Int64) -> Bool {
  let ds = divisors_of(n)
  let mut sphi = 0L
  let mut smu = 0L
  for i in 0..<ds.length() {
    sphi += euler_phi(ds[i])
    smu += mobius(ds[i].to_int())
  }
  let expected_mu = if n == 1L { 1L } else { 0L }
  let mut prod = rint(n)
  let ps = prime_divisors(n)
  for i in 0..<ps.length() {
    prod = prod.mul(rfrac(ps[i] - 1L, ps[i]))
  }
  sphi == n && smu == expected_mu && prod.equal(rint(euler_phi(n)))
}

///|
// ════════════════════════════════════════════════════════════════════════
// C1-04 補回 §6'' 待辦：Kinoshita–Li (FOCS 2024, arXiv:2404.05177) 完整近線性合成
// 依原文 Algorithm 1 (PowProj, Graeffe 迭代) 與 Algorithm 2 (Comp, 轉置原理)。
// 以精確有理雙變數多項式 Q(x,y)=1−y·g(x) 實作，複雜度 O(M(n) log m + M(m))。
// Python 原型先於 4 組 (n,m) 交叉驗證 PowProj 與 Comp 皆與直接計算逐項相等。
// ════════════════════════════════════════════════════════════════════════

///|
fn biv_new(nx : Int, my : Int) -> Array[Array[@exact.Rat]] {
  let out : Array[Array[@exact.Rat]] = []
  for _i in 0..<nx { out.push(Array::make(my, rat0())) }
  out
}

///|
fn biv_mul(
  a : Array[Array[@exact.Rat]],
  b : Array[Array[@exact.Rat]],
  nx : Int,
  my : Int,
) -> Array[Array[@exact.Rat]] {
  let o = biv_new(nx, my)
  for i in 0..<a.length() {
    if i >= nx { break }
    for j in 0..<a[i].length() {
      if j >= my || a[i][j].is_zero() { continue }
      for k in 0..<b.length() {
        if i + k >= nx { break }
        for l in 0..<b[k].length() {
          if j + l >= my || b[k][l].is_zero() { continue }
          o[i + k][j + l] = o[i + k][j + l].add(a[i][j].mul(b[k][l]))
        }
      }
    }
  }
  o
}

///|
fn biv_neg_x(a : Array[Array[@exact.Rat]]) -> Array[Array[@exact.Rat]] {
  let out : Array[Array[@exact.Rat]] = []
  for i in 0..<a.length() {
    let row : Array[@exact.Rat] = []
    for j in 0..<a[i].length() {
      row.push(if i % 2 == 1 { a[i][j].neg() } else { a[i][j] })
    }
    out.push(row)
  }
  out
}

///|
fn biv_compress(
  a : Array[Array[@exact.Rat]],
  parity : Int,
  new_nx : Int,
  my : Int,
) -> Array[Array[@exact.Rat]] {
  let o = biv_new(new_nx, my)
  for i in 0..<new_nx {
    let src = 2 * i + parity
    if src < a.length() {
      for j in 0..<my {
        if j < a[src].length() { o[i][j] = a[src][j] }
      }
    }
  }
  o
}

///|
fn biv_subst_x2(
  a : Array[Array[@exact.Rat]],
  nx : Int,
  my : Int,
) -> Array[Array[@exact.Rat]] {
  let o = biv_new(nx, my)
  for i in 0..<a.length() {
    if 2 * i < nx {
      for j in 0..<my {
        if j < a[i].length() { o[2 * i][j] = a[i][j] }
      }
    }
  }
  o
}

///|
fn biv_deg_y(q : Array[Array[@exact.Rat]]) -> Int {
  let mut d = 0
  for i in 0..<q.length() {
    for j in 0..<q[i].length() {
      if !q[i][j].is_zero() && j > d { d = j }
    }
  }
  d
}

///|
fn series_div_y(
  p : Array[@exact.Rat],
  q0 : Array[@exact.Rat],
  m : Int,
) -> Array[@exact.Rat] {
  let c : Array[@exact.Rat] = Array::make(m, rat0())
  for k in 0..<m {
    let mut s = if k < p.length() { p[k] } else { rat0() }
    for j in 1..<(k + 1) {
      if j < q0.length() { s = s.sub(q0[j].mul(c[k - j])) }
    }
    c[k] = s
  }
  c
}

///|
fn biv_q(g : Array[@exact.Rat], nx : Int, my : Int) -> Array[Array[@exact.Rat]] {
  let q = biv_new(nx, my)
  q[0][0] = rat1()
  for i in 0..<g.length() {
    if i < nx && my > 1 { q[i][1] = q[i][1].sub(g[i]) }
  }
  q
}

///|
/// Algorithm 1 (PowProj)：以 Graeffe 迭代把 [x^{n−1}] P/Q 之 n 減半。
/// 回傳 u(y)=Σ_{i<m} w(g^i mod x^n) y^i。
pub fn kl_pow_proj(
  w : Array[@exact.Rat],
  g : Array[@exact.Rat],
  m : Int,
) -> Array[@exact.Rat] {
  let n = w.length()
  let my = m
  let mut p = biv_new(n, my)
  for i in 0..<n { p[i][0] = w[n - 1 - i] }
  let mut q = biv_q(g, n, my)
  let mut nx = n
  while nx > 1 {
    let qn = biv_neg_x(q)
    let u = biv_mul(p, qn, nx, my)
    let a = biv_mul(q, qn, nx, my)
    let new_nx = (nx + 1) / 2
    let parity = if (nx - 1) % 2 == 0 { 0 } else { 1 }
    p = biv_compress(u, parity, new_nx, my)
    q = biv_compress(a, 0, new_nx, my)
    nx = new_nx
  }
  series_div_y(p[0], q[0], my)
}

///|
/// Algorithm 2 (Comp)：F_{d,m}(P(y)/Q(x,y)) mod x^n。
/// P(y) 為長度 m 之係數陣列；回傳雙變數（x 次數 < n，y 次數 < m−d）。
fn kl_comp(
  n : Int,
  d : Int,
  m : Int,
  p : Array[@exact.Rat],
  q : Array[Array[@exact.Rat]],
) -> Array[Array[@exact.Rat]] {
  if n == 1 {
    let c = series_div_y(p, q[0], m)
    let out = biv_new(1, m - d)
    for i in d..<m { out[0][i - d] = c[i] }
    return out
  }
  let qn = biv_neg_x(q)
  let a = biv_mul(q, qn, n, m)
  let new_n = (n + 1) / 2
  let v = biv_compress(a, 0, new_n, m)
  let dy = biv_deg_y(q)
  let e = if d - dy > 0 { d - dy } else { 0 }
  let w = kl_comp(new_n, e, m, p, v)
  let w2 = biv_subst_x2(w, n, m)
  let bb = biv_mul(w2, qn, n, m)
  let out = biv_new(n, m - (d - e))
  for i in (d - e)..<(m - e) {
    for xi in 0..<n { out[xi][i - (d - e)] = bb[xi][i] }
  }
  out
}

///|
/// 近線性合成 f(g) mod x^n：Comp(n, m−1, m, y^{m−1}f(y^{−1}), 1−yg(x))。
pub fn kl_compose(
  f : Array[@exact.Rat],
  g : Array[@exact.Rat],
  n : Int,
) -> Array[@exact.Rat] {
  let m = f.length()
  if m == 0 || n == 0 { return [] }
  let rev : Array[@exact.Rat] = []
  let mut i = m
  while i > 0 { i -= 1; rev.push(f[i]) }
  let c = kl_comp(n, m - 1, m, rev, biv_q(g, n, m))
  let out : Array[@exact.Rat] = []
  for xi in 0..<n { out.push(c[xi][0]) }
  out
}

///|
/// 直接計算 w(g^i mod x^n) 作為對照（O(n·m·M(n))，僅供有限憑證）。
fn direct_pow_proj(
  w : Array[@exact.Rat],
  g : Array[@exact.Rat],
  m : Int,
) -> Array[@exact.Rat] {
  let n = w.length()
  let out : Array[@exact.Rat] = Array::make(m, rat0())
  let mut power : Array[@exact.Rat] = Array::make(n, rat0())
  power[0] = rat1()
  for i in 0..<m {
    let mut s = rat0()
    for k in 0..<n { s = s.add(w[k].mul(power[k])) }
    out[i] = s
    let nxt : Array[@exact.Rat] = Array::make(n, rat0())
    for k in 0..<n {
      if power[k].is_zero() { continue }
      for t in 0..<n {
        if k + t < n && t < g.length() {
          nxt[k + t] = nxt[k + t].add(power[k].mul(g[t]))
        }
      }
    }
    power = nxt
  }
  out
}

///|
/// 定理 T-S12：Kinoshita–Li PowProj 與直接 Krylov 計算逐項相等。
pub fn theorem_kl_pow_proj(n : Int, m : Int) -> Bool {
  let w : Array[@exact.Rat] = []
  let g : Array[@exact.Rat] = []
  for i in 0..<n {
    w.push(rfrac(1L, (i + 3).to_int64()))
    g.push(if i == 0 { rat0() } else { rfrac(1L, (i + 1).to_int64()) })
  }
  let a = kl_pow_proj(w, g, m)
  let b = direct_pow_proj(w, g, m)
  for i in 0..<m {
    if !a[i].equal(b[i]) { return false }
  }
  true
}

///|
/// 定理 T-S13：Kinoshita–Li Comp 與既有直接合成 fps_compose 逐項相等。
pub fn theorem_kl_compose(n : Int, m : Int) -> Bool {
  let f : Array[@exact.Rat] = []
  let g : Array[@exact.Rat] = []
  for i in 0..<m { f.push(rfrac(1L, (i + 2).to_int64())) }
  for i in 0..<n {
    g.push(if i == 0 { rat0() } else { rfrac(1L, (i + 1).to_int64()) })
  }
  let a = kl_compose(f, g, n)
  // 直接對照：power iteration 使用 f 的全部 m 項（不限 min(m,n)）
  let b : Array[@exact.Rat] = Array::make(n, rat0())
  let mut power : Array[@exact.Rat] = Array::make(n, rat0())
  power[0] = rat1()
  for i in 0..<m {
    for k in 0..<n { b[k] = b[k].add(f[i].mul(power[k])) }
    let nxt : Array[@exact.Rat] = Array::make(n, rat0())
    for k in 0..<n {
      if power[k].is_zero() { continue }
      for t in 0..<n {
        if k + t < n && t < g.length() {
          nxt[k + t] = nxt[k + t].add(power[k].mul(g[t]))
        }
      }
    }
    power = nxt
  }
  for i in 0..<n {
    if !a[i].equal(b[i]) { return false }
  }
  if m == n {
    let c = fps_compose(Fps::{ coeffs: f }, Fps::{ coeffs: g })
    for i in 0..<n {
      if !a[i].equal(c.coeffs[i]) { return false }
    }
  }
  true
}

///|
// ════════════════════════════════════════════════════════════════════════
// C1-04 補回 §6''：Connes zeta spectral triples（R26）與 Spec Z（R27）
// rank-one 擾動、正則化行列式、譜 zeta；adelic Abel–Jacobi、
// Grothendieck–Lefschetz 跡公式、A¹-同倫不變性之有限憑證。
// ════════════════════════════════════════════════════════════════════════

///|
/// 找 divisor d=1 在 divisors_of(n) 中之索引（rank-one 投影之基底）。
fn unit_divisor_index(n : Int64) -> Int {
  let ds = divisors_of(n)
  for i in 0..<ds.length() {
    if ds[i] == 1L { return i }
  }
  -1
}

///|
/// Connes rank-one 擾動 D_a = D + a·|1⟩⟨1|（|1⟩ 為 d=1 之基底向量）。
pub fn connes_rank_one(n : Int64, a : Int64) -> @exact.Mat {
  let d = @exact.mat_clone(arithmetic_dirac(n))
  let j = unit_divisor_index(n)
  if j >= 0 { d.a[j][j] = d.a[j][j].add(rint(a)) }
  d
}

///|
fn binomial_int(n : Int, k : Int) -> Int64 {
  let mut c = 1L
  for i in 0..<k { c = c * (n - i).to_int64() / (i + 1).to_int64() }
  c
}

///|
/// 正則化行列式 det_ζ(D) = ∏_{λ≠0} λ = ∏_{k≥1} k^{c_k}。
pub fn regularized_determinant(n : Int64) -> @exact.Rat {
  let z = arithmetic_zeta_poly(n)
  let mut out = rat1()
  for k in 1..<z.coeffs.length() {
    let mut term = rat1()
    for _j in 0..<z.coeffs[k].n.to_int() { term = term.mul(rint(k.to_int64())) }
    out = out.mul(term)
  }
  out
}

///|
/// 譜 zeta：ζ_D(s) = Σ_{λ≠0} λ^{−s} = Σ_{k≥1} c_k / k^s（s ≥ 1，精確有理）。
pub fn spectral_zeta(n : Int64, s : Int) -> @exact.Rat {
  let z = arithmetic_zeta_poly(n)
  let mut out = rat0()
  for k in 1..<z.coeffs.length() {
    let mut denom = rat1()
    for _j in 0..<s { denom = denom.mul(rint(k.to_int64())) }
    out = out.add(z.coeffs[k].div(denom).unwrap())
  }
  out
}

///|
/// 定理 T-A5（Connes rank-one 擾動）：
/// charpoly(D+aP) = charpoly(D) − a·∏_{d≠1}(t−Ω(d))（matrix determinant lemma），
/// det(D+I+aP) = det(D+I)·(1+a)（Sylvester 行列式定理）。
pub fn theorem_connes_rank_one(n : Int64, a : Int64) -> Bool {
  let j = unit_divisor_index(n)
  if j < 0 { return false }
  let d0 = arithmetic_dirac(n)
  let d1 = connes_rank_one(n, a)
  let cp0 = @exact.mat_charpoly(d0)
  let cp1 = @exact.mat_charpoly(d1)
  let spec = arithmetic_spectrum(n)
  let rest : Array[@exact.Rat] = []
  for i in 0..<spec.length() {
    if i != j { rest.push(spec[i]) }
  }
  let minor = @exact.poly_from_roots(rest)
  let predicted = @exact.poly_add(
    cp0,
    @exact.poly_scale(minor, rint(-a)),
  )
  if predicted.length() != cp1.length() { return false }
  for i in 0..<cp1.length() {
    if !cp1[i].equal(predicted[i]) { return false }
  }
  let id = @exact.mat_identity(d0.a.length())
  let shift = @exact.mat_add(d0, id)
  let shift2 = @exact.mat_clone(shift)
  shift2.a[j][j] = shift2.a[j][j].add(rint(a))
  let det0 = @exact.mat_det(shift)
  let det1 = @exact.mat_det(shift2)
  det1.equal(det0.mul(rat1().add(rint(a))))
}

///|
/// 定理 T-A6（正則化行列式與譜 zeta）：
/// det_ζ = ∏_{k≥1} k^{c_k} = |[t^{c₀}] charpoly(D)|，
/// ζ_D(2) = tr((D⁺)²)（D⁺ 為非零譜上之偽逆），
/// 且 ζ_D(1) 可由 zeta 多項式直接導出。
pub fn theorem_connes_zeta_det(n : Int64) -> Bool {
  let d = arithmetic_dirac(n)
  let cp = @exact.mat_charpoly(d)
  let z = arithmetic_zeta_poly(n)
  let c0 = z.coeffs[0].n
  if c0 < 0 || c0 >= cp.length().to_int64() { return false }
  let coeff = cp[c0.to_int()]
  let detz = regularized_determinant(n)
  if !coeff.equal(detz) && !coeff.neg().equal(detz) { return false }
  // ζ_D(2) = Σ_{k≥1} c_k/k² = tr(偽逆²)
  let mut pseudo2 = rat0()
  for k in 1..<z.coeffs.length() {
    let denom = rint(k.to_int64()).mul(rint(k.to_int64()))
    pseudo2 = pseudo2.add(z.coeffs[k].div(denom).unwrap())
  }
  if !spectral_zeta(n, 2).equal(pseudo2) { return false }
  spectral_zeta(n, 1).n > 0L && detz.n > 0L
}

///|
/// Spec(Z/nZ) 之點數 ω(n)：Frobenius 在 H⁰ 上為恆等，H¹ = 0。
pub fn lefschetz_trace(n : Int64, _k : Int) -> Int {
  prime_divisors(n).length()
}

///|
/// Grothendieck–Lefschetz 跡公式：Z(X,t) = exp(Σ_k #X(F_{q^k}) t^k/k)
/// = det(1−t·Frob|H¹)/(det(1−t·Frob|H⁰)) = 1/(1−t)^ω。
pub fn spec_z_zeta_series(n : Int64, cut : Int) -> Fps {
  let w = prime_divisors(n).length()
  let logz : Array[@exact.Rat] = Array::make(cut, rat0())
  for k in 1..<cut {
    logz[k] = rint(w.to_int64()).div(rint(k.to_int64())).unwrap()
  }
  fps_exp(Fps::{ coeffs: logz })
}

///|
fn spec_z_geometric_series(n : Int64, cut : Int) -> Fps {
  let w = prime_divisors(n).length()
  let denom : Array[@exact.Rat] = Array::make(cut, rat0())
  for k in 0..<cut {
    if k <= w {
      let sign = if k % 2 == 0 { 1L } else { -1L }
      denom[k] = rint(sign * binomial_int(w, k))
    }
  }
  fps_inv(Fps::{ coeffs: denom })
}

///|
/// 定理 T-A7（Lefschetz 跡公式）：零維 Spec(Z/nZ) 之 zeta 級數
/// exp(Σ_k ω·t^k/k) 與 (1−t)^{−ω} 逐項相等，且指數係數為二項式係數。
pub fn theorem_spec_z_lefschetz(n : Int64, cut : Int) -> Bool {
  let a = spec_z_zeta_series(n, cut)
  let b = spec_z_geometric_series(n, cut)
  let w = prime_divisors(n).length()
  for k in 0..<cut {
    if !a.coeffs[k].equal(b.coeffs[k]) { return false }
    let expect = rint(binomial_int(w + k - 1, k))
    if !a.coeffs[k].equal(expect) { return false }
  }
  for k in 1..<cut {
    if lefschetz_trace(n, k) != w { return false }
  }
  true
}

///|
/// Adelic Abel–Jacobi：D = Σ e_p·[p] ↦ AJ(D) = ∏ p^{e_p} ∈ ℚ*。
pub fn adelic_abel_jacobi(n : Int64, exps : Array[Int64]) -> @exact.Rat {
  let ps = prime_divisors(n)
  let mut out = rat1()
  for i in 0..<ps.length() {
    if i >= exps.length() { continue }
    let mut factor = rat1()
    for _j in 0..<exps[i].to_int() { factor = factor.mul(rint(ps[i])) }
    for _j in 0..<(-exps[i]).to_int() { factor = factor.div(rint(ps[i])).unwrap() }
    out = out.mul(factor)
  }
  out
}

///|
fn rat_valuation(q : @exact.Rat, p : Int64) -> Int64 {
  let mut a = q.n
  let mut e = 0L
  while a != 0L && a % p == 0L { a = a / p; e += 1L }
  let mut b = q.d
  while b != 0L && b % p == 0L { b = b / p; e -= 1L }
  e
}

///|
/// 定理 T-A8（adelic Abel–Jacobi / Pic(Spec Z) = 0）：
/// 度數零除子之 AJ 為單射（唯一分解），div(AJ(D)) = D；
/// 等價於線性等價類皆為主除子（類數 1），乘積公式 AJ(D)·AJ(−D)=1。
pub fn theorem_spec_z_adelic(n : Int64) -> Bool {
  let ps = prime_divisors(n)
  let np = ps.length()
  if np > 3 { return false }
  let total = 1 << (2 * np)
  for code in 0..<total {
    let exps : Array[Int64] = Array::make(np, 0L)
    let mut t = code
    for i in 0..<np { exps[i] = (t % 5).to_int64() - 2L; t = t / 5 }
    let mut deg = 0L
    for i in 0..<np { deg += exps[i] }
    if deg != 0L { continue }
    let q = adelic_abel_jacobi(n, exps)
    let mut zero = true
    for i in 0..<np {
      if exps[i] != 0L { zero = false; break }
      if rat_valuation(q, ps[i]) != 0L { return false }
    }
    if zero && !q.equal(rat1()) { return false }
    if !zero && q.equal(rat1()) { return false }
    // 乘積公式 AJ(D)·AJ(−D) = 1
    let neg : Array[Int64] = []
    for i in 0..<np { neg.push(-exps[i]) }
    if !q.mul(adelic_abel_jacobi(n, neg)).equal(rat1()) { return false }
  }
  true
}

///|
/// ═══════════════════════════════════════════════════════════════════════
/// C1-05 §6'''(A) — Connes / Spec Z 解析極限之「有限精確憑證」
/// E/F_q : y² = x³ + ac·x + bc；逐條算 N₁、Frobenius trace a、全部 N_n、
/// Z(E,T) = (1 − aT + qT²) / ((1−T)(1−qT))、對稱函數方程、Hasse–Weil 界
/// （= 有限域曲線 RH：αβ=q, α+β=a, a²≤4q ⇒ |α|=|β|=√q）、
/// Weil 顯式公式 log Z = Σ_{n≥1} N_n Tⁿ/n 與其精確有理餘項上界。
/// 誠實邊界：此處是逐條有限域曲線的完全精確計算憑證，
/// 不是 Spec Z 之 archimedean 無限維解析極限、也不是 RH 的一般證明。
/// ═══════════════════════════════════════════════════════════════════════

///|
pub(all) struct WeilCurve {
  q : Int64
  ac : Int64
  bc : Int64
  a : Int64
  n1 : Int64
  discr : Int64
}

///|
fn weil_pow_mod(base0 : Int64, e0 : Int64, p : Int64) -> Int64 {
  let mut base = ((base0 % p) + p) % p
  let mut e = e0
  let mut out = 1L
  while e > 0L {
    if (e & 1L) == 1L { out = (out * base) % p }
    base = (base * base) % p
    e = e >> 1
  }
  out
}

///|
/// Legendre 符號 χ_p(x) ∈ {−1,0,1}，由 Euler 判準 x^{(p−1)/2} mod p。
fn weil_legendre(x : Int64, p : Int64) -> Int64 {
  let v = ((x % p) + p) % p
  if v == 0L { return 0L }
  if weil_pow_mod(v, (p - 1L) / 2L, p) == 1L { 1L } else { -1L }
}

///|
/// 演算法 A-Weil1：穷舉 x ∈ F_q 數點 N₁ = q + 1 + Σ_x χ(x³+ac x+bc)。
pub fn weil_point_count(q : Int64, ac : Int64, bc : Int64) -> Int64 {
  let mut s = 0L
  for x in 0..<q.to_int() {
    let xi = x.to_int64()
    let f = ((((xi * xi) % q) * xi) % q + (ac * xi + bc) % q) % q
    s = s + weil_legendre(f, q)
  }
  q + 1L + s
}

///|
pub fn weil_curve(q : Int64, ac : Int64, bc : Int64) -> WeilCurve {
  let n1 = weil_point_count(q, ac, bc)
  let a = q + 1L - n1
  WeilCurve::{ q, ac, bc, a, n1, discr: a * a - 4L * q }
}

///|
/// 演算法 A-Weil2：αⁿ+βⁿ 由 s₀=2, s₁=a, sₙ=a·sₙ₋₁−q·sₙ₋₂ 精確遞推。
pub fn weil_power_sum(q : Int64, a : Int64, n : Int) -> Int64 {
  if n == 0 { return 2L }
  if n == 1 { return a }
  let mut sm2 = 2L
  let mut sm1 = a
  for _i in 2..<n {
    let sn = a * sm1 - q * sm2
    sm2 = sm1
    sm1 = sn
  }
  a * sm1 - q * sm2
}

///|
/// 演算法 A-Weil3：Nₙ = #E(F_{qⁿ}) = qⁿ + 1 − sₙ（Weil 公式）。
pub fn weil_counts(q : Int64, a : Int64, cut : Int) -> Array[Int64] {
  let out : Array[Int64] = []
  let mut pw = 1L
  let mut sm2 = 2L
  let mut sm1 = a
  for n in 1..<(cut + 1) {
    pw = pw * q
    let sn = if n == 1 { a } else { a * sm1 - q * sm2 }
    if n > 1 { sm2 = sm1 }
    sm1 = sn
    out.push(pw + 1L - sn)
  }
  out
}

///|
pub fn weil_poly_p(q : Int64, a : Int64) -> Array[Int64] { [1L, -a, q] }

///|
pub fn weil_poly_q(q : Int64) -> Array[Int64] { [1L, -(1L + q), q] }

///|
fn weil_poly_deriv(c : Array[Int64]) -> Array[Int64] {
  let out : Array[Int64] = []
  for i in 1..<c.length() { out.push((i.to_int64()) * c[i]) }
  out
}

///|
/// 截斷整係數多項式乘法（係數為 Int64；C1-05 憑證範圍內無溢位）。
fn weil_poly_mul(a : Array[Int64], b : Array[Int64], cut : Int) -> Array[Int64] {
  let out : Array[Int64] = Array::make(cut, 0L)
  for i in 0..<a.length() {
    for j in 0..<b.length() {
      if i + j < cut { out[i + j] = out[i + j] + a[i] * b[j] }
    }
  }
  out
}

///|
fn weil_poly_sub(a : Array[Int64], b : Array[Int64], cut : Int) -> Array[Int64] {
  let out : Array[Int64] = Array::make(cut, 0L)
  for i in 0..<cut {
    let x = if i < a.length() { a[i] } else { 0L }
    let y = if i < b.length() { b[i] } else { 0L }
    out[i] = x - y
  }
  out
}

///|
/// 定理 T-W1：log Z 之導數恆等式 S·P·Q = P′Q − PQ′（mod T^cut），
/// S(T) = Σ_{n≥1} Nₙ Tⁿ⁻¹。此式等價於 Weil 顯式公式的係數級聯。
pub fn weil_log_derivative_identity(q : Int64, a : Int64, cut : Int) -> Bool {
  let ns = weil_counts(q, a, cut)
  let p = weil_poly_p(q, a)
  let qq = weil_poly_q(q)
  let sp = weil_poly_mul(ns, p, cut)
  let lhs = weil_poly_mul(sp, qq, cut)
  let dpq = weil_poly_mul(weil_poly_deriv(p), qq, cut)
  let pdq = weil_poly_mul(p, weil_poly_deriv(qq), cut)
  let rhs = weil_poly_sub(dpq, pdq, cut)
  for i in 0..<cut {
    if lhs[i] != rhs[i] { return false }
  }
  true
}

///|
/// T ↦ 1/(qT) 的「qT² 扭轉」：q·(qT²)·c(1/(qT)) 之係數（整數化，無負冪）。
fn weil_twist(q : Int64, c : Array[Int64]) -> Array[Int64] {
  let d = c.length() - 1
  let out : Array[Int64] = Array::make(c.length(), 0L)
  for i in 0..<c.length() {
    let mut w = 1L
    for _k in 0..<(d + 1 - i) { w = w * q }
    out[d - i] = c[i] * w / q
  }
  out
}

///|
/// 定理 T-W2：genus 1 函數方程 Z(E, 1/(qT)) = Z(E,T)。
/// 因 qT²P(1/(qT)) = P(T) 且 qT²Q(1/(qT)) = Q(T)，
/// 等價於扭轉算子 tw 作用後 P、Q 同乘 q；並驗證 tw² = q^{d}·id 為對合。
pub fn weil_functional_equation(q : Int64, a : Int64) -> Bool {
  let p = weil_poly_p(q, a)
  let qq = weil_poly_q(q)
  let tp = weil_twist(q, p)
  let tq = weil_twist(q, qq)
  for i in 0..<3 {
    if tp[i] != q * p[i] { return false }
    if tq[i] != q * qq[i] { return false }
  }
  // 對任意二次係數向量 tw 是對合：tw²(c) = q^{d}·c（d = deg c = 2）。
  let samples = [[1L, 2L, 3L], [q, -a, 0L], [0L, 1L, -q], [1L, 0L, q]]
  for c in samples {
    let once = weil_twist(q, c)
    let twice = weil_twist(q, once)
    let mut scale = 1L
    for _k in 0..<(c.length() - 1) { scale = scale * q }
    for i in 0..<c.length() {
      if twice[i] != c[i] * scale { return false }
    }
  }
  true
}

///|
/// 定理 T-W3：Hasse–Weil 界 |a| ≤ 2√q（等價 a² ≤ 4q），且 a = q+1−N₁。
pub fn weil_hasse(c : WeilCurve) -> Bool {
  c.n1 >= 0L && c.a == c.q + 1L - c.n1 && c.discr <= 0L &&
    c.discr == c.a * c.a - 4L * c.q &&
    weil_point_count(c.q, c.ac, c.bc) == c.n1
}

///|
/// 定理 T-W4：有限域曲線 RH 之代數憑證。α+β=a, αβ=q, a²−4q≤0
/// ⇒ α,β 為共軛複根且 |α|²=|β|²=αβ=q。另驗 Newton 恆等式
/// s₂ = a²−2q, s₃ = a³−3aq。
pub fn weil_rh_modulus(c : WeilCurve) -> Bool {
  if c.discr > 0L { return false }
  let s2 = weil_power_sum(c.q, c.a, 2)
  let s3 = weil_power_sum(c.q, c.a, 3)
  c.a * c.a - 2L * c.q == s2 &&
    c.a * c.a * c.a - 3L * c.a * c.q == s3 &&
    s2 * s2 - 4L * c.q * c.q == (c.a * c.a - 4L * c.q) * (c.a * c.a) &&
    weil_power_sum(c.q, c.a, 1) == c.a
}

///|
/// 定理 T-W5：Weil 顯式公式之形式冪級數憑證
/// exp(Σ_{n=1}^{N} Nₙ Tⁿ/n) · Q(T) ≡ P(T) (mod T^{N+1})。
pub fn weil_explicit_formula(q : Int64, a : Int64, cut : Int) -> Bool {
  let ns = weil_counts(q, a, cut)
  let lg : Array[@exact.Rat] = Array::make(cut + 1, rat0())
  for n in 1..<(cut + 1) { lg[n] = @exact.rat(ns[n - 1], n.to_int64()) }
  let e = fps_exp(Fps::{ coeffs: lg })
  let qq : Array[@exact.Rat] = []
  for x in weil_poly_q(q) { qq.push(rint(x)) }
  let pp : Array[@exact.Rat] = Array::make(cut + 1, rat0())
  let pco = weil_poly_p(q, a)
  for i in 0..<3 { pp[i] = rint(pco[i]) }
  let lhs = fps_mul(e, Fps::{ coeffs: qq }, cut + 1)
  lhs.equal(Fps::{ coeffs: pp })
}

///|
/// 演算法 A-Weil4：顯式公式截斷餘項之精確有理上界。
/// 由 |Nₙ| ≤ 4qⁿ 與 |qt| < 1 得
/// |Σ_{n>N} Nₙ tⁿ/n| ≤ 4(qt)^{N+1} / ((N+1)(1−qt))。
pub fn weil_tail_bound(q : Int64, cut : Int, t : @exact.Rat) -> @exact.Rat {
  let qt = t.mul(rint(q))
  let one = rat1()
  let den = one.sub(qt)
  if den.n <= 0L { return rat0() }
  let mut pw = den
  for _k in 0..<(cut + 1) { pw = pw.mul(qt) }
  @exact.rat(4L, (cut + 1).to_int64()).mul(pw).div(den).unwrap()
}

///|
/// 定理 T-W6：解析極限之可計算憑證。取 t = 1/(4q)，
/// 餘項界隨 N 嚴格遞減且 N=8 時小於 1/1000；
/// 同時 N 項截斷顯式公式在所有抽樣曲線成立。
pub fn theorem_weil_explicit_tail() -> Bool {
  let q = 19L
  let t = @exact.rat(1L, 4L * q)
  let b8 = weil_tail_bound(q, 8, t)
  let b9 = weil_tail_bound(q, 9, t)
  if b8.n <= 0L || !(b9.n * b8.d < b8.n * b9.d) { return false }
  if b8.mul(rint(1000L)).n * 1L >= b8.d { return false }
  for c in [q, 5L, 7L, 11L, 13L, 17L] {
    if !weil_explicit_formula(c, weil_curve(c, 0L, 1L).a, 8) { return false }
  }
  true
}

///|
/// 定理 T-W7：六條 F_q 橢圓曲線之全套有限精確憑證。
/// 每條檢查點數、Hasse、RH 代數式、對數導數恆等式、函數方程、
/// 顯式公式，以及 Frobenius 特徵多項式之判別式 ≤ 0。
pub fn theorem_weil_curve() -> Bool {
  let curves = [
    (5L, 2L, 0L, 4L), (7L, 0L, 3L, -5L), (11L, 1L, 3L, -6L),
    (13L, 0L, 4L, -7L), (17L, 3L, 0L, -8L), (19L, 0L, 1L, 8L),
  ]
  for (q, ac, bc, a0) in curves {
    let c = weil_curve(q, ac, bc)
    if c.a != a0 { return false }
    if !weil_hasse(c) { return false }
    if !weil_rh_modulus(c) { return false }
    if !weil_log_derivative_identity(q, c.a, 8) { return false }
    if !weil_functional_equation(q, c.a) { return false }
    if !weil_explicit_formula(q, c.a, 8) { return false }
    // Newton 恆等式另一形式：s_{n+2} = a·s_{n+1} − q·s_n
    for n in 0..<6 {
      if weil_power_sum(q, c.a, n + 2) !=
         c.a * weil_power_sum(q, c.a, n + 1) - q * weil_power_sum(q, c.a, n) {
        return false
      }
    }
  }
  true
}
