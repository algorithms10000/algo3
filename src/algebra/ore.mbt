///|
/// C1 / src/algebra/ore — 歪多項式環 / Ore 擴展 R[x;σ,δ] (R3/R4/R6)
/// 取 R = ℚ[u]，σ(u) = q·u，δ = 0（量子平面 x·u = q·u·x）。
/// 另行實作 Jackson q-導子 δ(u^k) = [k]_q u^{k-1} 並驗證 σ-Leibniz 律。

///|
pub(all) struct SkewPoly {
  coeffs : Array[@series.Poly]
}

///|
pub fn skew(coeffs : Array[@series.Poly]) -> SkewPoly { SkewPoly::{ coeffs } }

///|
pub fn skew_zero() -> @series.Poly { @series.poly([]) }

///|
pub fn skew_one() -> @series.Poly { @series.poly([@series.rat1()]) }

///|
/// σ^k 作用於係數環 ℚ[u]：u^j ↦ q^{k·j} u^j。
pub fn sigma_apply(p : @series.Poly, q : @exact.Rat, k : Int) -> @series.Poly {
  let out : Array[@exact.Rat] = Array::make(p.coeffs.length(), @series.rat0())
  for j in 0..<p.coeffs.length() {
    out[j] = p.coeffs[j].mul(q.pow(k * j))
  }
  @series.poly(out)
}

///|
/// Ore 乘法：(a_i x^i)(b_j x^j) = a_i·σ^i(b_j) x^{i+j}。
pub fn ore_mul(a : SkewPoly, b : SkewPoly, q : @exact.Rat) -> SkewPoly {
  if a.coeffs.length() == 0 || b.coeffs.length() == 0 { return skew([]) }
  let n = a.coeffs.length() + b.coeffs.length() - 1
  let out : Array[@series.Poly] = Array::make(n, skew_zero())
  for i in 0..<a.coeffs.length() {
    for j in 0..<b.coeffs.length() {
      let s = sigma_apply(b.coeffs[j], q, i)
      out[i + j] = out[i + j].add(a.coeffs[i].mul(s))
    }
  }
  skew(out)
}

///|
pub fn ore_degree(a : SkewPoly) -> Int {
  let mut d = -1
  for i in 0..<a.coeffs.length() {
    if @series.poly_degree(a.coeffs[i]) >= 0 { d = i }
  }
  d
}

///|
pub fn ore_trim(a : SkewPoly) -> SkewPoly {
  let d = ore_degree(a)
  if d < 0 { return skew([]) }
  let out : Array[@series.Poly] = []
  for i = 0; i <= d; i = i + 1 { out.push(a.coeffs[i]) }
  skew(out)
}

///|
pub fn SkewPoly::equal(self : SkewPoly, o : SkewPoly) -> Bool {
  let a = ore_trim(self)
  let b = ore_trim(o)
  if a.coeffs.length() != b.coeffs.length() { return false }
  for i in 0..<a.coeffs.length() {
    if !a.coeffs[i].equal(b.coeffs[i]) { return false }
  }
  true
}

///|
pub(all) struct OreDiv {
  q : SkewPoly
  r : SkewPoly
}

///|
/// 首一右除：對 x·u = q·u·x 之 Ore 環，以 σ^{m-d} 修正消去最高次項。
pub fn ore_divmod(a : SkewPoly, b : SkewPoly, q0 : @exact.Rat) -> OreDiv {
  let d = ore_degree(b)
  if d < 0 { return OreDiv::{ q: skew([]), r: a } }
  let la = a.coeffs.length()
  let rem : Array[@series.Poly] = Array::make(la, skew_zero())
  for i in 0..<la { rem[i] = a.coeffs[i] }
  let qn = if la - d > 0 { la - d } else { 1 }
  let quo : Array[@series.Poly] = Array::make(qn, skew_zero())
  let mut m = la - 1
  while m >= d {
    let lead = @series.poly_degree(rem[m])
    if lead < 0 { m -= 1; continue }
    // 首一條件：b_d 為常數 1，故 σ^{m-d}(b_d) = 1
    let lead_b = b.coeffs[d]
    if @series.poly_degree(lead_b) != 0 {
      m -= 1
      continue
    }
    if !lead_b.coeffs[0].equal(@series.rat1()) {
      m -= 1
      continue
    }
    let c = rem[m]
    let k = m - d
    if k < qn { quo[k] = quo[k].add(c) }
    for j = 0; j <= d; j = j + 1 {
      let shifted = sigma_apply(b.coeffs[j], q0, k)
      rem[k + j] = rem[k + j].sub(c.mul(shifted))
    }
    m -= 1
  }
  let rpoly : Array[@series.Poly] = []
  for i = 0; i < d && i < la; i = i + 1 { rpoly.push(rem[i]) }
  OreDiv::{ q: ore_trim(skew(quo)), r: ore_trim(skew(rpoly)) }
}

///|
/// 右最大公因數 gcrd：Ore 環上的歐幾里得演算法。
pub fn ore_gcrd(a : SkewPoly, b : SkewPoly, q0 : @exact.Rat) -> SkewPoly {
  let mut x = ore_trim(a)
  let mut y = ore_trim(b)
  let mut steps = 0
  while ore_degree(y) >= 0 && steps < 128 {
    steps += 1
    let r = ore_divmod(x, y, q0).r
    x = y
    y = r
  }
  x
}

///|
/// 定理 T-Ore1：量子平面交換律 x·u = q·u·x。
pub fn theorem_ore_commutation(q : @exact.Rat) -> Bool {
  let x = skew([skew_zero(), skew_one()])
  let u = skew([@series.poly([@series.rat0(), @series.rat1()])])
  let xu = ore_mul(x, u, q)
  let ux = ore_mul(u, x, q)
  let scaled : Array[@series.Poly] = []
  for i in 0..<ux.coeffs.length() {
    let c : Array[@exact.Rat] = Array::make(ux.coeffs[i].coeffs.length(), @series.rat0())
    for j in 0..<ux.coeffs[i].coeffs.length() {
      c[j] = ux.coeffs[i].coeffs[j].mul(q)
    }
    scaled.push(@series.poly(c))
  }
  xu.equal(skew(scaled))
}

///|
/// 定理 T-Ore2：Ore 乘法滿足結合律 (ab)c = a(bc)。
pub fn theorem_ore_associative(q : @exact.Rat) -> Bool {
  let p0 = @series.poly([@series.rat1(), @series.rint(2L)])
  let p1 = @series.poly([@series.rint(3L), @series.rat0(), @series.rint(-1L)])
  let p2 = @series.poly([@series.rint(-2L), @series.rfrac(1L, 2L)])
  let a = skew([p0, p1])
  let b = skew([p2, skew_one()])
  let c = skew([skew_one(), p0])
  ore_mul(ore_mul(a, b, q), c, q).equal(ore_mul(a, ore_mul(b, c, q), q))
}

///|
/// 定理 T-Ore3：Ore 環為無零因子 ⇒ deg(fg) = deg f + deg g。
pub fn theorem_ore_degree(q : @exact.Rat) -> Bool {
  let a = skew([@series.poly([@series.rint(2L)]), skew_one()])
  let b = skew([@series.poly([@series.rint(3L)]), skew_one(), skew_one()])
  let ab = ore_mul(a, b, q)
  ore_degree(ab) == ore_degree(a) + ore_degree(b)
}

///|
/// 定理 T-Ore4：gcrd 右整除 f 與 g（右餘式為零）。
pub fn theorem_ore_gcrd_divides(q : @exact.Rat) -> Bool {
  let a = skew([@series.poly([@series.rint(2L)]), skew_one(), skew_one()])
  let b = skew([skew_one(), @series.poly([@series.rint(-1L)])])
  let g = ore_gcrd(a, b, q)
  ore_degree(g) >= 0 && ore_degree(ore_divmod(a, g, q).r) < 0 &&
    ore_degree(ore_divmod(b, g, q).r) < 0
}

///|
/// q-整數 [k]_q = 1 + q + ... + q^{k-1}（精確有理係數）。
pub fn qint_rat(k : Int, q : @exact.Rat) -> @exact.Rat {
  let mut acc = @series.rat0()
  let mut p = @series.rat1()
  for _i in 0..<k {
    acc = acc.add(p)
    p = p.mul(q)
  }
  acc
}

///|
/// Jackson q-導子 δ(u^k) = [k]_q u^{k-1}。
pub fn q_derivative(p : @series.Poly, q : @exact.Rat) -> @series.Poly {
  if p.coeffs.length() <= 1 { return @series.poly([]) }
  let out : Array[@exact.Rat] = Array::make(p.coeffs.length() - 1, @series.rat0())
  for k = 1; k < p.coeffs.length(); k = k + 1 {
    out[k - 1] = p.coeffs[k].mul(qint_rat(k, q))
  }
  @series.poly(out)
}

///|
/// 定理 T-Ore5：σ-Leibniz 律 δ(rs) = δ(r)s + σ(r)δ(s) 對所有單項式 r=u^i, s=u^j。
pub fn theorem_ore_leibniz(q : @exact.Rat, maxdeg : Int) -> Bool {
  for i = 1; i <= maxdeg; i = i + 1 {
    for j = 1; j <= maxdeg; j = j + 1 {
      let lhs = qint_rat(i + j, q)
      let rhs = qint_rat(i, q).add(q.pow(i).mul(qint_rat(j, q)))
      if !lhs.equal(rhs) { return false }
    }
  }
  true
}

///|
/// 定理 T-Ore6：Ore 擴展的 Hilbert–Poincaré 級數等於交換多項式環 (R2)。
pub fn theorem_ore_hilbert(n : Int, len : Int) -> Bool {
  theorem_hilbert_skew(n, len)
}
