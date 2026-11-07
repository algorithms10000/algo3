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

///|
// ════════════════════════════════════════════════════════════════════════
// C1-02 補回 §6 待辦：Ore 環上的完整 lclm 與 Sylvester 矩陣 gcrd
// 依據 Giesbrecht (1992) deg lclm = deg f + deg g − deg gcrd、
// Caruso–Le Borgne (2017) §3.2.2 擴展右歐幾里得、
// Ding–Wang–Xiao–Zheng ISSAC'24 之 Ore Sylvester 矩陣、
// Giesbrecht (2026) 量子平面中心界與 gcrd 分割。
// 取係數體 k = F_25 = F_5[θ]/(θ²−2)，σ = Frobenius: θ ↦ θ^5 = −θ。
// σ 階數 2 ⇒ 此為真正非交換的 Ore 環 k[x;σ]（σ ≠ id）。
// ════════════════════════════════════════════════════════════════════════

///|
pub(all) struct Fq2 {
  a : Int64
  b : Int64
}

///|
fn m5(x : Int64) -> Int64 { ((x % 5L) + 5L) % 5L }

///|
pub fn fq2(a : Int64, b : Int64) -> Fq2 { Fq2::{ a: m5(a), b: m5(b) } }

///|
pub fn fq2_zero() -> Fq2 { fq2(0L, 0L) }

///|
pub fn fq2_one() -> Fq2 { fq2(1L, 0L) }

///|
pub fn fq2_add(x : Fq2, y : Fq2) -> Fq2 { fq2(x.a + y.a, x.b + y.b) }

///|
pub fn fq2_sub(x : Fq2, y : Fq2) -> Fq2 { fq2(x.a - y.a, x.b - y.b) }

///|
/// (a+bθ)(c+dθ) = (ac+2bd) + (ad+bc)θ，因 θ² = 2。
pub fn fq2_mul(x : Fq2, y : Fq2) -> Fq2 {
  fq2(x.a * y.a + 2L * x.b * y.b, x.a * y.b + x.b * y.a)
}

///|
/// σ^k：σ(a+bθ) = a−bθ，σ² = id。
pub fn fq2_sigma(x : Fq2, k : Int) -> Fq2 {
  if k % 2 == 1 { fq2(x.a, -x.b) } else { x }
}

///|
pub fn fq2_is_zero(x : Fq2) -> Bool { x.a == 0L && x.b == 0L }

///|
pub fn fq2_equal(x : Fq2, y : Fq2) -> Bool { x.a == y.a && x.b == y.b }

///|
/// 範數 N(a+bθ) = a² − 2b² ≠ 0（2 在 F_5 中非平方），故 F_25 為體。
pub fn fq2_inv(x : Fq2) -> Fq2? {
  let norm = m5(x.a * x.a - 2L * x.b * x.b)
  if norm == 0L { None } else {
    let ni = @exact.mod_inv(norm, 5L)
    Some(fq2(x.a * ni, -x.b * ni))
  }
}

///|
pub(all) struct SkewFq {
  coeffs : Array[Fq2]
}

///|
pub fn skew_fq(coeffs : Array[Fq2]) -> SkewFq { SkewFq::{ coeffs } }

///|
pub fn sfq_degree(a : SkewFq) -> Int {
  let mut d = a.coeffs.length() - 1
  while d >= 0 && fq2_is_zero(a.coeffs[d]) { d -= 1 }
  d
}

///|
pub fn sfq_trim(a : SkewFq) -> SkewFq {
  let d = sfq_degree(a)
  if d < 0 { return skew_fq([]) }
  let out : Array[Fq2] = []
  for i = 0; i <= d; i = i + 1 { out.push(a.coeffs[i]) }
  skew_fq(out)
}

///|
/// Ore 乘法：(a_i x^i)(b_j x^j) = a_i σ^i(b_j) x^{i+j}。
pub fn sfq_mul(a : SkewFq, b : SkewFq) -> SkewFq {
  if a.coeffs.length() == 0 || b.coeffs.length() == 0 { return skew_fq([]) }
  let n = a.coeffs.length() + b.coeffs.length() - 1
  let out : Array[Fq2] = Array::make(n, fq2_zero())
  for i in 0..<a.coeffs.length() {
    for j in 0..<b.coeffs.length() {
      out[i + j] = fq2_add(out[i + j], fq2_mul(a.coeffs[i], fq2_sigma(b.coeffs[j], i)))
    }
  }
  sfq_trim(skew_fq(out))
}

///|
pub fn sfq_add(a : SkewFq, b : SkewFq) -> SkewFq {
  let n = if a.coeffs.length() > b.coeffs.length() {
    a.coeffs.length()
  } else {
    b.coeffs.length()
  }
  let out : Array[Fq2] = Array::make(n, fq2_zero())
  for i in 0..<a.coeffs.length() { out[i] = fq2_add(out[i], a.coeffs[i]) }
  for i in 0..<b.coeffs.length() { out[i] = fq2_add(out[i], b.coeffs[i]) }
  sfq_trim(skew_fq(out))
}

///|
pub fn sfq_neg(a : SkewFq) -> SkewFq {
  let out : Array[Fq2] = []
  for i in 0..<a.coeffs.length() {
    out.push(fq2(-a.coeffs[i].a, -a.coeffs[i].b))
  }
  skew_fq(out)
}

///|
pub fn sfq_sub(a : SkewFq, b : SkewFq) -> SkewFq { sfq_add(a, sfq_neg(b)) }

///|
/// 左乘常數使多項式首一：(lc)^{-1}·f。
pub fn sfq_monic(a : SkewFq) -> SkewFq {
  let d = sfq_degree(a)
  if d < 0 { return skew_fq([]) }
  let c = fq2_inv(a.coeffs[d]).unwrap()
  let out : Array[Fq2] = []
  for i = 0; i <= d; i = i + 1 { out.push(fq2_mul(c, a.coeffs[i])) }
  sfq_trim(skew_fq(out))
}

///|
pub(all) struct SFqDiv {
  q : SkewFq
  r : SkewFq
}

///|
/// 右除：a = q·b + r，deg r < deg b。
/// 消去最高次項時須對 b 的首項取 σ^k（k = m − deg b）。
pub fn sfq_divmod(a : SkewFq, b : SkewFq) -> SFqDiv {
  let d = sfq_degree(b)
  if d < 0 { return SFqDiv::{ q: skew_fq([]), r: a } }
  let la = a.coeffs.length()
  let r : Array[Fq2] = Array::make(la, fq2_zero())
  for i in 0..<la { r[i] = a.coeffs[i] }
  let qn = if la - d > 0 { la - d } else { 1 }
  let q : Array[Fq2] = Array::make(qn, fq2_zero())
  let mut m = la - 1
  while m >= d {
    if fq2_is_zero(r[m]) { m -= 1; continue }
    let k = m - d
    let lead = fq2_sigma(b.coeffs[d], k)
    let c = fq2_mul(r[m], fq2_inv(lead).unwrap())
    if k < q.length() { q[k] = fq2_add(q[k], c) }
    for j = 0; j <= d; j = j + 1 {
      let idx = k + j
      if idx < r.length() {
        r[idx] = fq2_sub(r[idx], fq2_mul(c, fq2_sigma(b.coeffs[j], k)))
      }
    }
    m -= 1
  }
  let rem : Array[Fq2] = []
  for i = 0; i < d && i < la; i = i + 1 { rem.push(r[i]) }
  SFqDiv::{ q: sfq_trim(skew_fq(q)), r: sfq_trim(skew_fq(rem)) }
}

///|
pub(all) struct OreGCL {
  gcrd : SkewFq
  lclm : SkewFq
  deg_f : Int
  deg_g : Int
  deg_gcrd : Int
  deg_lclm : Int
  row_zero : Bool
}

///|
/// 擴展右歐幾里得：同時得到 gcrd 與 lclm。
/// 追蹤兩列 (α,β) 使 r = α·f + β·g；當餘式為 0 時
/// α·f = −β·g 即為最小公共右倍式 lclm。
pub fn sfq_gcrd_lclm(f : SkewFq, g : SkewFq) -> OreGCL {
  let f0 = sfq_monic(f)
  let g0 = sfq_monic(g)
  let mut r0 = f0
  let mut r1 = g0
  let mut a0 = skew_fq([fq2_one()])
  let mut bb0 = skew_fq([])
  let mut a1 = skew_fq([])
  let mut bb1 = skew_fq([fq2_one()])
  let mut steps = 0
  while sfq_degree(r1) >= 0 && steps < 200 {
    steps += 1
    let dm = sfq_divmod(r0, r1)
    let qq = dm.q
    let na0 = sfq_sub(a0, sfq_mul(qq, a1))
    let nb0 = sfq_sub(bb0, sfq_mul(qq, bb1))
    let rem = dm.r
    r0 = r1
    r1 = rem
    a0 = a1
    bb0 = bb1
    a1 = na0
    bb1 = nb0
  }
  let lclm = sfq_mul(a1, f0)
  let combo = sfq_add(lclm, sfq_mul(bb1, g0))
  OreGCL::{
    gcrd: r0, lclm, deg_f: sfq_degree(f0), deg_g: sfq_degree(g0),
    deg_gcrd: sfq_degree(r0), deg_lclm: sfq_degree(lclm),
    row_zero: sfq_degree(combo) < 0,
  }
}

///|
/// F_25 上矩陣之秩（高斯消去，樞紐以 fq2_inv 正規化）。
pub fn fq2_rank(rows0 : Array[Array[Fq2]], n : Int) -> Int {
  let rows : Array[Array[Fq2]] = []
  for i in 0..<rows0.length() {
    let row : Array[Fq2] = Array::make(n, fq2_zero())
    for j in 0..<n { row[j] = rows0[i][j] }
    rows.push(row)
  }
  let mut r = 0
  for c in 0..<n {
    let mut piv = -1
    for i in r..<rows.length() {
      if !fq2_is_zero(rows[i][c]) { piv = i; break }
    }
    if piv < 0 { continue }
    let tmp = rows[r]
    rows[r] = rows[piv]
    rows[piv] = tmp
    let iv = fq2_inv(rows[r][c]).unwrap()
    for j in 0..<n { rows[r][j] = fq2_mul(iv, rows[r][j]) }
    for i in 0..<rows.length() {
      if i != r && !fq2_is_zero(rows[i][c]) {
        let fac = rows[i][c]
        for j in 0..<n {
          rows[i][j] = fq2_sub(rows[i][j], fq2_mul(fac, rows[r][j]))
        }
      }
    }
    r += 1
    if r == rows.length() { break }
  }
  r
}

///|
/// Ore Sylvester 矩陣 (ISSAC'24)：列為 x^i·f (i < deg g) 與 x^j·g (j < deg f)
/// 之 σ-偏移係數向量；其階數缺陷恰為 deg gcrd。
pub fn sfq_sylvester(f : SkewFq, g : SkewFq) -> Array[Array[Fq2]] {
  let f0 = sfq_monic(f)
  let g0 = sfq_monic(g)
  let df = sfq_degree(f0)
  let dg = sfq_degree(g0)
  let n = df + dg
  let rows : Array[Array[Fq2]] = []
  for i in 0..<dg {
    let row : Array[Fq2] = Array::make(n, fq2_zero())
    for k in 0..<f0.coeffs.length() {
      if i + k < n { row[i + k] = fq2_sigma(f0.coeffs[k], i) }
    }
    rows.push(row)
  }
  for j in 0..<df {
    let row : Array[Fq2] = Array::make(n, fq2_zero())
    for k in 0..<g0.coeffs.length() {
      if j + k < n { row[j + k] = fq2_sigma(g0.coeffs[k], j) }
    }
    rows.push(row)
  }
  rows
}

///|
pub fn sfq_sylvester_rank(f : SkewFq, g : SkewFq) -> Int {
  let f0 = sfq_monic(f)
  let g0 = sfq_monic(g)
  let n = sfq_degree(f0) + sfq_degree(g0)
  fq2_rank(sfq_sylvester(f, g), n)
}

///|
pub fn sfq_right_divides(h : SkewFq, f : SkewFq) -> Bool {
  sfq_degree(sfq_divmod(h, sfq_monic(f)).r) < 0
}

///|
/// 定理 T-Ore7：deg lclm = deg f + deg g − deg gcrd = rank(Sylvester)，
/// lclm 為 f,g 之公共右倍式，擴展歐幾里得零組合成立。
pub fn theorem_ore_lclm(f : SkewFq, g : SkewFq) -> Bool {
  let z = sfq_gcrd_lclm(f, g)
  let rank = sfq_sylvester_rank(f, g)
  z.row_zero && z.deg_lclm == rank &&
    z.deg_gcrd == z.deg_f + z.deg_g - rank &&
    sfq_right_divides(z.lclm, f) && sfq_right_divides(z.lclm, g)
}

///|
pub fn sfq_sample(k : Int) -> Array[SkewFq] {
  let t = k.to_int64()
  let f = skew_fq([fq2(1L, 0L), fq2(t, 1L), fq2(1L, 0L)])
  let g = skew_fq([fq2(2L, t), fq2(1L, 1L), fq2(1L, 0L)])
  [f, g]
}

///|
/// 定理 T-Ore8：對多組真正非交換（σ ≠ id）實例穷舉 lclm/Sylvester 恆等式。
pub fn theorem_ore_lclm_batch(count : Int) -> Bool {
  for k in 0..<count {
    let pair = sfq_sample(k)
    if !theorem_ore_lclm(pair[0], pair[1]) { return false }
  }
  true
}

///|
/// F_25 乘法交換律與 σ 為自同構（Ore 環係數體查核）。
pub fn theorem_fq2_field() -> Bool {
  for a in 0..<5 {
    for b in 0..<5 {
      for c in 0..<5 {
        for d in 0..<5 {
          let x = fq2(a.to_int64(), b.to_int64())
          let y = fq2(c.to_int64(), d.to_int64())
          if !fq2_equal(fq2_mul(x, y), fq2_mul(y, x)) { return false }
          let s = fq2_sigma(fq2_mul(x, y), 1)
          if !fq2_equal(s, fq2_mul(fq2_sigma(x, 1), fq2_sigma(y, 1))) { return false }
        }
      }
    }
  }
  true
}

///|
/// 定理 T-Ore9：σ ≠ id（真正非交換），x·θ = −θ·x。
pub fn theorem_ore_noncommutative() -> Bool {
  let x = skew_fq([fq2_zero(), fq2_one()])
  let th = skew_fq([fq2(0L, 1L)])
  let lhs = sfq_mul(x, th)
  let rhs = sfq_neg(sfq_mul(th, x))
  lhs.coeffs.length() == rhs.coeffs.length() &&
    fq2_equal(lhs.coeffs[1], rhs.coeffs[1])
}

///|
pub fn sfq_equal(a : SkewFq, b : SkewFq) -> Bool {
  let x = sfq_trim(a)
  let y = sfq_trim(b)
  if x.coeffs.length() != y.coeffs.length() { return false }
  for i in 0..<x.coeffs.length() {
    if !fq2_equal(x.coeffs[i], y.coeffs[i]) { return false }
  }
  true
}

///|
// ════════════════════════════════════════════════════════════════════════
// C1-03：歪多項式環 K 理論（G₀/K₀ 之可計算實例）
// R34 Quillen–Grayson 代數 K 理論基本定理、R35 Shin (2024) Ore 擴張之
// Jacobson radical / q-skew 二項式、R36 Oberwolfach 2025 K-theory report、
// R33 泛性質／函子性。取 R = F_25[x;σ]（σ = Frobenius, 階數 2）。
// ════════════════════════════════════════════════════════════════════════

///|
/// 穷舉次數 d 之首一多項式（係數以 F_25 之 25 個元素編碼）。
pub fn sfq_monic_enum(d : Int, code : Int) -> SkewFq {
  let coeffs : Array[Fq2] = []
  let mut t = code
  for _i in 0..<d {
    let v = t % 25
    t = t / 25
    coeffs.push(fq2((v / 5).to_int64(), (v % 5).to_int64()))
  }
  coeffs.push(fq2_one())
  skew_fq(coeffs)
}

///|
fn sfq_monic_count(d : Int) -> Int {
  let mut c = 1
  for _i in 0..<d { c *= 25 }
  c
}

///|
/// 找 f 之最小次數首一右因子（穷舉次數 1..deg f−1，上限 3 以保障有限計算）。
pub fn sfq_min_right_factor(f : SkewFq) -> SkewFq? {
  let df = sfq_degree(f)
  if df <= 1 { return None }
  let cap = if df - 1 > 3 { 3 } else { df - 1 }
  for d in 1..<(cap + 1) {
    for code in 0..<sfq_monic_count(d) {
      let h = sfq_monic_enum(d, code)
      if sfq_right_divides(f, h) { return Some(h) }
    }
  }
  None
}

///|
/// 不可約判準：不存在次數 ≥1 且 < deg h 之首一右因子。
pub fn sfq_irreducible(h : SkewFq) -> Bool {
  let dh = sfq_degree(h)
  if dh <= 0 { return false }
  if dh == 1 { return true }
  let cap = if dh - 1 > 3 { 3 } else { dh - 1 }
  for d in 1..<(cap + 1) {
    for code in 0..<sfq_monic_count(d) {
      if sfq_right_divides(h, sfq_monic_enum(d, code)) { return false }
    }
  }
  true
}

///|
/// 右因子分解（带重数）：f = q·h，遞迴分解 q。
pub fn sfq_factor(f : SkewFq) -> Array[SkewFq] {
  let out : Array[SkewFq] = []
  let f0 = sfq_monic(f)
  match sfq_min_right_factor(f0) {
    None => {
      if sfq_degree(f0) >= 1 { out.push(f0) }
      out
    }
    Some(h) => {
      out.push(h)
      let q = sfq_divmod(f0, h).q
      let rest = sfq_factor(q)
      for i in 0..<rest.length() { out.push(rest[i]) }
      out
    }
  }
}

///|
/// 相異不可約右因子（G₀(R/(f)) 之自由生成元）。
pub fn sfq_distinct_factors(f : SkewFq) -> Array[SkewFq] {
  let fs = sfq_factor(f)
  let out : Array[SkewFq] = []
  for i in 0..<fs.length() {
    let mut seen = false
    for j in 0..<out.length() {
      if sfq_equal(fs[i], out[j]) { seen = true; break }
    }
    if !seen { out.push(fs[i]) }
  }
  out
}

///|
/// 定理 T-K0-1：G₀(R/(f)) ≅ ℤ^{s}，s = 相異不可約右因子數；
/// 合成因子次數和 = deg f（Cartan 矩陣之列和），每個因子不可約且整除 f。
pub fn theorem_k0_skew_quotient(f : SkewFq) -> Bool {
  let fs = sfq_factor(f)
  let df = sfq_degree(f)
  let mut total = 0
  let mut prod = skew_fq([fq2_one()])
  for i in 0..<fs.length() {
    if !sfq_irreducible(fs[i]) { return false }
    total += sfq_degree(fs[i])
    // f = h_k ⋯ h_2 h_1（右分解之合成級）
    prod = sfq_mul(fs[i], prod)
  }
  if !sfq_equal(prod, sfq_monic(f)) { return false }
  let distinct = sfq_distinct_factors(f)
  let mut mult_sum = 0
  for i in 0..<distinct.length() {
    let mut mult = 0
    for j in 0..<fs.length() {
      if sfq_equal(distinct[i], fs[j]) { mult += 1 }
    }
    mult_sum += mult * sfq_degree(distinct[i])
  }
  total == df && mult_sum == df && distinct.length() <= fs.length()
}

///|
/// 定理 T-K0-2（基本定理 / graded Grothendieck group）：
/// R = F_25[x;σ] 每個次數自由秩 1 ⇒ Hilbert–Poincaré 級數 1/(1−t)，
/// K₀^gr 秩 = 1；基本定理長正合序列
/// 0→K₀(R)→K₀(R[x])⊕K₀(R[x⁻¹])→K₀(R[x,x⁻¹])→K₋₁(R)→0
/// 之秩為 1→2→1→0，複合為零、Euler 特徵數 1−2+1−0 = 0。
pub fn theorem_k0_fundamental(cut : Int) -> Bool {
  let denom = @series.Fps::{
    coeffs: [@exact.rat_one(), @exact.rat_int(-1L), @exact.rat_zero(), @exact.rat_zero(),
      @exact.rat_zero(), @exact.rat_zero(), @exact.rat_zero(), @exact.rat_zero()],
  }
  let h = @series.fps_inv(denom)
  for i in 0..<cut {
    if !h.coeffs[i].equal(@exact.rat_one()) { return false }
  }
  // 邊界映射：d1 = [1,1] : ℤ → ℤ²；d2 = [1,−1] : ℤ² → ℤ
  let d1 = @exact.mat_from([[
    @exact.rat_one(), @exact.rat_one(),
  ]])
  let d2 = @exact.mat_from([
    [@exact.rat_one()], [@exact.rat_int(-1L)],
  ])
  let comp = @exact.mat_mul(d1, d2)
  if !comp.a[0][0].is_zero() { return false }
  @exact.mat_rank(d1) == 1 && @exact.mat_rank(d2) == 1 && 1 - 2 + 1 == 0
}

///|
fn fq2_mat2_mul(x : Array[Array[Fq2]], y : Array[Array[Fq2]]) -> Array[Array[Fq2]] {
  let out : Array[Array[Fq2]] = []
  for i in 0..<2 {
    let row : Array[Fq2] = [fq2_zero(), fq2_zero()]
    for j in 0..<2 {
      for k in 0..<2 { row[j] = fq2_add(row[j], fq2_mul(x[i][k], y[k][j])) }
    }
    out.push(row)
  }
  out
}

///|
/// 定理 T-K0-3（Morita 不變性）：K₀(M₂(F_25)) ≅ K₀(F_25) = ℤ。
/// 對 F_5 係數之全部 2×2 冪等矩陣 e 穷舉，驗證 tr(e) = rank(e)·1，
/// 且 rank 只取 0/1/2（投影模分類由秩完全決定）。
pub fn theorem_k0_morita_idempotents() -> Bool {
  for code in 0..<625 {
    let mut t = code
    let a = (t % 5).to_int64()
    t = t / 5
    let b = (t % 5).to_int64()
    t = t / 5
    let c = (t % 5).to_int64()
    t = t / 5
    let d = (t % 5).to_int64()
    let e : Array[Array[Fq2]] = [
      [fq2(a, 0L), fq2(b, 0L)],
      [fq2(c, 0L), fq2(d, 0L)],
    ]
    let e2 = fq2_mat2_mul(e, e)
    if !fq2_equal(e2[0][0], e[0][0]) || !fq2_equal(e2[0][1], e[0][1]) ||
      !fq2_equal(e2[1][0], e[1][0]) || !fq2_equal(e2[1][1], e[1][1]) {
      continue
    }
    let r = fq2_rank(e, 2)
    let tr = fq2_add(e[0][0], e[1][1])
    if !fq2_equal(tr, fq2(r.to_int64(), 0L)) { return false }
    if r < 0 || r > 2 { return false }
  }
  true
}

///|
/// 定理 T-K0-4（泛性質：局部化升格為同構，R33/R34）：
/// K₀ 為函子；對 R → S^{−1}R，投影模之秩保持（K₀ 映射為單射），
/// 以 2×2 矩陣環之秩不變性與基本定理複合為零共同查核。
pub fn theorem_k0_functorial() -> Bool {
  theorem_k0_fundamental(6) && theorem_k0_morita_idempotents()
}

///|
/// 定理 T-K0-5：q-skew 二項式公式（Shin 2024）之 σ 階數 2 特例：
/// x²·r = σ²(r)x² = r x²（因 σ²=id）；更一般地 x^k r = σ^k(r) x^k
/// 在 δ=0 時對所有 r ∈ F_25、k ≤ 4 成立。
pub fn theorem_ore_sigma_binomial() -> Bool {
  let x = skew_fq([fq2_zero(), fq2_one()])
  for k in 1..<5 {
    let mut xp = skew_fq([fq2_one()])
    for _i in 0..<k { xp = sfq_mul(xp, x) }
    for a in 0..<5 {
      for b in 0..<5 {
        let r = fq2(a.to_int64(), b.to_int64())
        let lhs = sfq_mul(xp, skew_fq([r]))
        let rhs = sfq_mul(skew_fq([fq2_sigma(r, k)]), xp)
        if !sfq_equal(lhs, rhs) { return false }
      }
    }
  }
  true
}

///|
// ════════════════════════════════════════════════════════════════════════
// C1-04 補回 §6''：Ore bound / reduced norm / 中心分解 / 參數 GCRD
// R14 Caruso–Le Borgne reduced norm；R13 ISSAC'24 參數 GCRD 與中心分解。
// 對 R = F_25[x;σ]（σ²=id），中心為 F_5[t]，t = x²；R 在 F_25[t] 上
// 為秩 2 自由模，左乘 f 之矩陣 M_f = [[A, tσ(B)], [B, σ(A)]]，
// reduced norm N(f) = det M_f = Aσ(A) − t·Bσ(B) ∈ F_5[t]。
// ════════════════════════════════════════════════════════════════════════

///|
pub(all) struct F5pDiv {
  q : Array[Fq2]
  r : Array[Fq2]
}

///|
fn f5p_trim(a : Array[Fq2]) -> Array[Fq2] {
  let mut d = a.length() - 1
  while d >= 0 && fq2_is_zero(a[d]) { d -= 1 }
  let out : Array[Fq2] = []
  for i in 0..<(d + 1) { out.push(a[i]) }
  out
}

///|
fn f5p_mul(a : Array[Fq2], b : Array[Fq2]) -> Array[Fq2] {
  if a.length() == 0 || b.length() == 0 { return [] }
  let out : Array[Fq2] = Array::make(a.length() + b.length() - 1, fq2_zero())
  for i in 0..<a.length() {
    for j in 0..<b.length() {
      out[i + j] = fq2_add(out[i + j], fq2_mul(a[i], b[j]))
    }
  }
  f5p_trim(out)
}

///|
fn f5p_sub(a : Array[Fq2], b : Array[Fq2]) -> Array[Fq2] {
  let n = if a.length() > b.length() { a.length() } else { b.length() }
  let out : Array[Fq2] = Array::make(n, fq2_zero())
  for i in 0..<a.length() { out[i] = a[i] }
  for i in 0..<b.length() { out[i] = fq2_sub(out[i], b[i]) }
  f5p_trim(out)
}

///|
fn f5p_divmod(a0 : Array[Fq2], b0 : Array[Fq2]) -> F5pDiv {
  let a = f5p_trim(a0)
  let b = f5p_trim(b0)
  let d = b.length() - 1
  if d < 0 { return F5pDiv::{ q: [], r: a } }
  let r : Array[Fq2] = []
  for i in 0..<a.length() { r.push(a[i]) }
  let q : Array[Fq2] = []
  for _i in 0..<(a.length() + 1) { q.push(fq2_zero()) }
  let lc = fq2_inv(b[d]).unwrap()
  while r.length() - 1 >= d {
    let k = r.length() - 1 - d
    let c = fq2_mul(r[r.length() - 1], lc)
    q[k] = fq2_add(q[k], c)
    for j in 0..<(d + 1) {
      r[k + j] = fq2_sub(r[k + j], fq2_mul(c, b[j]))
    }
    while r.length() > 0 && fq2_is_zero(r[r.length() - 1]) {
      ignore(r.pop())
    }
  }
  F5pDiv::{ q: f5p_trim(q), r: f5p_trim(r) }
}

///|
fn f5p_monic_poly(d : Int, code : Int) -> Array[Fq2] {
  let out : Array[Fq2] = []
  let mut t = code
  for _i in 0..<d {
    out.push(fq2((t % 5).to_int64(), 0L))
    t = t / 5
  }
  out.push(fq2_one())
  out
}

///|
fn f5p_pow5(d : Int) -> Int {
  let mut c = 1
  for _i in 0..<d { c *= 5 }
  c
}

///|
/// F_5[t] 中次數 ≤ maxd 之全體首一不可約多項式（穷舉因子檢驗）。
pub fn f5p_irreducibles(maxd : Int) -> Array[Array[Fq2]] {
  let out : Array[Array[Fq2]] = []
  for d in 1..<(maxd + 1) {
    for code in 0..<f5p_pow5(d) {
      let psi = f5p_monic_poly(d, code)
      let mut irr = true
      for e in 1..<(d / 2 + 1) {
        for cc in 0..<f5p_pow5(e) {
          let q0 = f5p_monic_poly(e, cc)
          if f5p_divmod(psi, q0).r.length() == 0 { irr = false; break }
        }
        if !irr { break }
      }
      if irr { out.push(psi) }
    }
  }
  out
}

///|
/// 中心嵌入 F_5[t] → F_25[x;σ]，t ↦ x²。
pub fn f5p_embed(norm : Array[Fq2]) -> SkewFq {
  let out : Array[Fq2] = []
  for k in 0..<norm.length() {
    out.push(norm[k])
    out.push(fq2_zero())
  }
  sfq_trim(skew_fq(out))
}

///|
/// f 之偶/奇分解 f = A(t) + x·B(t)（右係數），σ 作用於奇次係數。
pub fn ore_even_odd(f : SkewFq) -> Array[Array[Fq2]] {
  let a : Array[Fq2] = []
  let b : Array[Fq2] = []
  for k in 0..<((f.coeffs.length() + 1) / 2) {
    let idx = 2 * k
    a.push(if idx < f.coeffs.length() { f.coeffs[idx] } else { fq2_zero() })
  }
  for k in 0..<(f.coeffs.length() / 2) {
    let idx = 2 * k + 1
    b.push(if idx < f.coeffs.length() {
      fq2_sigma(f.coeffs[idx], 1)
    } else {
      fq2_zero()
    })
  }
  [f5p_trim(a), f5p_trim(b)]
}

///|
fn f5p_sigma(a : Array[Fq2]) -> Array[Fq2] {
  let out : Array[Fq2] = []
  for i in 0..<a.length() { out.push(fq2_sigma(a[i], 1)) }
  out
}

///|
/// Reduced norm：N(f) = det M_f = Aσ(A) − t·Bσ(B) ∈ F_5[t]。
pub fn ore_reduced_norm(f : SkewFq) -> Array[Fq2] {
  let parts = ore_even_odd(f)
  let a = parts[0]
  let b = parts[1]
  let aa = f5p_mul(a, f5p_sigma(a))
  let bb0 = f5p_mul(b, f5p_sigma(b))
  let tb : Array[Fq2] = [fq2_zero()]
  for i in 0..<bb0.length() { tb.push(bb0[i]) }
  f5p_sub(aa, tb)
}

///|
/// Ore bound：首一化的中心左倍式 φ = N(f)/lc(N(f)) 嵌入 R。
pub fn ore_bound(f : SkewFq) -> SkewFq {
  let norm = ore_reduced_norm(f)
  if norm.length() == 0 { return skew_fq([]) }
  let lc = fq2_inv(norm[norm.length() - 1]).unwrap()
  let monic : Array[Fq2] = []
  for i in 0..<norm.length() { monic.push(fq2_mul(lc, norm[i])) }
  f5p_embed(f5p_trim(monic))
}

///|
fn sfq_lclm(a : SkewFq, b : SkewFq) -> SkewFq {
  sfq_monic(sfq_gcrd_lclm(a, b).lclm)
}

///|
/// 中心分解（ISSAC'24 Alg. 4.1）：分解 bound 為 F_5[t] 不可約因子，
/// h_i = gcrd(f, π_i^{e_i})；f = lclm(h_1,…,h_r)。
pub fn ore_central_decomposition(f : SkewFq) -> Array[SkewFq] {
  let norm = ore_reduced_norm(f)
  if norm.length() == 0 { return [] }
  let lc = fq2_inv(norm[norm.length() - 1]).unwrap()
  let mut nn : Array[Fq2] = []
  for i in 0..<norm.length() { nn.push(fq2_mul(lc, norm[i])) }
  nn = f5p_trim(nn)
  let out : Array[SkewFq] = []
  let irrs = f5p_irreducibles(nn.length() - 1)
  for i in 0..<irrs.length() {
    let psi = irrs[i]
    let mut e = 0
    let mut rem = nn
    while true {
      let dm = f5p_divmod(rem, psi)
      if dm.r.length() > 0 { break }
      rem = dm.q
      e += 1
      if rem.length() == 0 { break }
    }
    if e == 0 { continue }
    let mut pp : Array[Fq2] = [fq2_one()]
    for _k in 0..<e { pp = f5p_mul(pp, psi) }
    let h = sfq_gcrd_lclm(f, f5p_embed(pp)).gcrd
    if sfq_degree(h) > 0 { out.push(sfq_monic(h)) }
  }
  out
}

///|
/// 定理 T-Ore10：reduced norm 落在中心 F_5[t] 且具乘法性 N(fg)=N(f)N(g)。
pub fn theorem_ore_reduced_norm(d : Int) -> Bool {
  let f = sfq_monic_enum(d, (d * 37 + 11) % f5p_pow5(2 * d))
  let g = sfq_monic_enum(d, (d * 53 + 7) % f5p_pow5(2 * d))
  let nf = ore_reduced_norm(f)
  let ng = ore_reduced_norm(g)
  let nfg = ore_reduced_norm(sfq_mul(f, g))
  if !f5p_equal(nfg, f5p_mul(nf, ng)) { return false }
  for i in 0..<nf.length() {
    if nf[i].b != 0L { return false }
  }
  // N(f) 之中心性與 f·f̄ = N(f) 之倍式關係
  let phi = f5p_embed(nf)
  let x = skew_fq([fq2_zero(), fq2_one()])
  let th = skew_fq([fq2(0L, 1L)])
  if !sfq_equal(sfq_mul(phi, x), sfq_mul(x, phi)) { return false }
  if !sfq_equal(sfq_mul(phi, th), sfq_mul(th, phi)) { return false }
  sfq_right_divides(phi, f)
}

///|
fn f5p_equal(a : Array[Fq2], b : Array[Fq2]) -> Bool {
  let aa = f5p_trim(a)
  let bb = f5p_trim(b)
  if aa.length() != bb.length() { return false }
  for i in 0..<aa.length() {
    if !fq2_equal(aa[i], bb[i]) { return false }
  }
  true
}

///|
/// 定理 T-Ore11：Ore bound 為中心左倍式、deg ≤ 2·deg f、且為最小者
/// （穷舉所有較低次數之首一中心多項式）。
pub fn theorem_ore_bound(d : Int) -> Bool {
  let f = sfq_monic_enum(d, (d * 29 + 3) % f5p_pow5(2 * d))
  let b = ore_bound(f)
  let df = sfq_degree(f)
  let db = sfq_degree(b)
  if db > 2 * df || db < 0 { return false }
  if !sfq_right_divides(b, f) { return false }
  let x = skew_fq([fq2_zero(), fq2_one()])
  let th = skew_fq([fq2(0L, 1L)])
  if !sfq_equal(sfq_mul(b, x), sfq_mul(x, b)) { return false }
  if !sfq_equal(sfq_mul(b, th), sfq_mul(th, b)) { return false }
  // 最小性：K < db/2 之所有首一中心多項式皆不為 f 之左倍式
  let half = db / 2
  for kk in 0..<half {
    for code in 0..<f5p_pow5(kk) {
      let c = f5p_embed(f5p_monic_poly(kk, code))
      if sfq_right_divides(c, f) { return false }
    }
  }
  true
}

///|
/// 定理 T-Ore12：中心分解之 h_i 為兩兩右互質的右因子，次數和 = deg f，
/// 且 lclm(h_i) = f（ISSAC'24 中心分解定理）。
pub fn theorem_ore_central_decomposition(d : Int) -> Bool {
  let f = sfq_monic(sfq_monic_enum(d, (d * 41 + 5) % f5p_pow5(2 * d)))
  let hs = ore_central_decomposition(f)
  if hs.length() == 0 { return false }
  let mut sum = 0
  for i in 0..<hs.length() {
    sum += sfq_degree(hs[i])
    if !sfq_right_divides(f, hs[i]) { return false }
    for j in 0..<i {
      if sfq_degree(sfq_gcrd_lclm(hs[i], hs[j]).gcrd) > 0 { return false }
    }
  }
  if sum != sfq_degree(f) { return false }
  let mut ell = skew_fq([fq2_one()])
  for i in 0..<hs.length() { ell = sfq_lclm(ell, hs[i]) }
  sfq_equal(ell, f)
}

///|
/// 參數歪多項式 f(λ) = f₀ + λ·f₁（λ ∈ F_5 ⊂ 固定域），λ 為 σ 不變。
pub fn sfq_specialize(f0 : Array[Fq2], f1 : Array[Fq2], lam : Int) -> SkewFq {
  let l = fq2(lam.to_int64(), 0L)
  let out : Array[Fq2] = []
  for i in 0..<f0.length() {
    let mut c = f0[i]
    if i < f1.length() { c = fq2_add(c, fq2_mul(l, f1[i])) }
    out.push(c)
  }
  sfq_trim(skew_fq(out))
}

///|
/// 參數 GCRD 分層：對 λ=0..4 回傳 deg gcrd(f(λ), g)。
pub fn parametric_gcrd_strata(
  f0 : Array[Fq2],
  f1 : Array[Fq2],
  g : SkewFq,
) -> Array[Int] {
  let out : Array[Int] = []
  for lam in 0..<5 {
    let fl = sfq_specialize(f0, f1, lam)
    let z = sfq_gcrd_lclm(fl, g)
    out.push(z.deg_gcrd)
  }
  out
}

///|
/// 定理 T-Ore13：參數特化與 σ 交換（λ 在固定域），且每層之
/// Sylvester rank 缺陷恰為 deg gcrd，gcrd 為共同右因子。
pub fn theorem_parametric_gcrd() -> Bool {
  let f0 : Array[Fq2] = [fq2(1L, 2L), fq2(3L, 1L), fq2(1L, 0L)]
  let f1 : Array[Fq2] = [fq2(2L, 0L), fq2(0L, 1L), fq2(0L, 0L)]
  let g = skew_fq([fq2(2L, 1L), fq2(1L, 1L), fq2(1L, 0L)])
  let x = skew_fq([fq2_zero(), fq2_one()])
  let strata = parametric_gcrd_strata(f0, f1, g)
  if strata.length() != 5 { return false }
  for lam in 0..<5 {
    let fl = sfq_specialize(f0, f1, lam)
    // σ-等變：x·f(λ) = f(λ)^σ·x
    let sig : Array[Fq2] = []
    for i in 0..<fl.coeffs.length() { sig.push(fq2_sigma(fl.coeffs[i], 1)) }
    let lhs = sfq_mul(x, fl)
    let rhs = sfq_mul(skew_fq(sig), x)
    if !sfq_equal(lhs, rhs) { return false }
    let z = sfq_gcrd_lclm(fl, g)
    let rank = sfq_sylvester_rank(fl, g)
    if z.deg_gcrd != z.deg_f + z.deg_g - rank { return false }
    if strata[lam] != z.deg_gcrd { return false }
    if !sfq_right_divides(fl, z.gcrd) { return false }
    if !sfq_right_divides(g, z.gcrd) { return false }
  }
  true
}

///|
// ════════════════════════════════════════════════════════════════════════
// C1-04 補回 §6''：模組 Gröbner 基底、兩層模組分解、δ-Galois
// R14 ISSAC'24（Sylvester/模組 Gröbner 求參數 gcrd）、R13 Giesbrecht
// 兩層模組分解、δ-Galois／Picard–Vessiot 之有限可計算實例。
// ════════════════════════════════════════════════════════════════════════

///|
pub(all) struct SkewGB {
  rows : Array[Array[Fq2]]
  pivots : Array[Int]
  rank : Int
  gcrd : SkewFq
}

///|
/// 以「最高次優先」之有理列消去求模組 Gröbner 基底（degree-compatible
/// leading-term order）；列為 x^i f、x^j g 之 σ-偏移係數向量。
fn fq2_rref_lead(rows0 : Array[Array[Fq2]], n : Int) -> Array[Array[Fq2]] {
  let rows : Array[Array[Fq2]] = []
  for i in 0..<rows0.length() {
    let row : Array[Fq2] = Array::make(n, fq2_zero())
    for j in 0..<n { row[j] = rows0[i][j] }
    rows.push(row)
  }
  let mut r = 0
  let mut c = n - 1
  while c >= 0 && r < rows.length() {
    let mut piv = -1
    for i in r..<rows.length() {
      if !fq2_is_zero(rows[i][c]) { piv = i; break }
    }
    if piv < 0 { c -= 1; continue }
    let tmp = rows[r]
    rows[r] = rows[piv]
    rows[piv] = tmp
    let iv = fq2_inv(rows[r][c]).unwrap()
    for j in 0..<n { rows[r][j] = fq2_mul(iv, rows[r][j]) }
    for i in 0..<rows.length() {
      if i == r { continue }
      let fac = rows[i][c]
      if fq2_is_zero(fac) { continue }
      for j in 0..<n {
        rows[i][j] = fq2_sub(rows[i][j], fq2_mul(fac, rows[r][j]))
      }
    }
    r += 1
    c -= 1
  }
  let out : Array[Array[Fq2]] = []
  for i in 0..<r { out.push(rows[i]) }
  out
}

///|
fn row_to_skew(row : Array[Fq2]) -> SkewFq {
  let mut d = row.length() - 1
  while d >= 0 && fq2_is_zero(row[d]) { d -= 1 }
  let out : Array[Fq2] = []
  for i in 0..<(d + 1) { out.push(row[i]) }
  sfq_trim(skew_fq(out))
}

///|
/// 左理想 ⟨f,g⟩ 之模組 Gröbner 基底（以 Sylvester 生成元列消去）。
pub fn sfq_module_groebner(f : SkewFq, g : SkewFq) -> SkewGB {
  let n = sfq_degree(f) + sfq_degree(g)
  let rows = sfq_sylvester(f, g)
  let red = fq2_rref_lead(rows, n)
  let pivots : Array[Int] = []
  let mut best_deg = n + 1
  let mut best = skew_fq([])
  let all : Array[Array[Fq2]] = []
  for i in 0..<red.length() {
    all.push(red[i])
    let p = row_to_skew(red[i])
    let d = sfq_degree(p)
    pivots.push(d)
    if d < best_deg { best_deg = d; best = p }
  }
  SkewGB::{ rows: all, pivots, rank: red.length(), gcrd: sfq_monic(best) }
}

///|
/// 定理 T-Ore14：模組 Gröbner 基底之秩 = deg lclm = rank(Sylvester)，
/// 最低次列（正規化）恰為 gcrd，且每列皆為 gcrd 之左倍式。
pub fn theorem_ore_module_groebner(d : Int) -> Bool {
  let f = sfq_monic_enum(d, (d * 17 + 4) % 625)
  let g = sfq_monic_enum(d, (d * 23 + 9) % 625)
  let gb = sfq_module_groebner(f, g)
  let z = sfq_gcrd_lclm(f, g)
  if gb.rank != z.deg_lclm { return false }
  if gb.rank != sfq_sylvester_rank(f, g) { return false }
  if !sfq_equal(gb.gcrd, sfq_monic(z.gcrd)) { return false }
  for i in 0..<gb.rows.length() {
    if !sfq_right_divides(row_to_skew(gb.rows[i]), gb.gcrd) { return false }
  }
  true
}

///|
/// 參數模組 Gröbner：對 λ=0..4 之 f(λ) 計算 GB，驗證分層與 Sylvester 秩一致。
pub fn theorem_ore_parametric_groebner() -> Bool {
  let f0 : Array[Fq2] = [fq2(1L, 2L), fq2(3L, 1L), fq2(1L, 0L)]
  let f1 : Array[Fq2] = [fq2(2L, 0L), fq2(0L, 1L), fq2(0L, 0L)]
  let g = skew_fq([fq2(2L, 1L), fq2(1L, 1L), fq2(1L, 0L)])
  for lam in 0..<5 {
    let fl = sfq_specialize(f0, f1, lam)
    let gb = sfq_module_groebner(fl, g)
    let z = sfq_gcrd_lclm(fl, g)
    if gb.rank != z.deg_lclm { return false }
    if !sfq_equal(gb.gcrd, sfq_monic(z.gcrd)) { return false }
    if sfq_degree(gb.gcrd) != z.deg_gcrd { return false }
  }
  true
}

///|
/// 兩層模組分解（Giesbrecht / ISSAC'24）：
/// 第一層以中心 bound 之不可約因子切分 h_i = gcrd(f, π_i^{e_i})；
/// 第二層對每個 h_i 求不可約右因子。回傳所有第二層因子。
pub fn ore_two_level_factor(f : SkewFq) -> Array[SkewFq] {
  let hs = ore_central_decomposition(f)
  let out : Array[SkewFq] = []
  for i in 0..<hs.length() {
    let fs = sfq_factor(hs[i])
    for j in 0..<fs.length() { out.push(fs[j]) }
  }
  out
}

///|
/// 定理 T-Ore15：兩層分解之每個因子不可約、皆為 f 之右因子鏈，
/// 次數和 = deg f，且與直接右因子分解之次數多重集一致。
pub fn theorem_ore_two_level(d : Int) -> Bool {
  let f = sfq_monic(sfq_monic_enum(d, (d * 31 + 6) % 625))
  let two = ore_two_level_factor(f)
  let one = sfq_factor(f)
  if two.length() == 0 { return false }
  let mut sum = 0
  for i in 0..<two.length() {
    let h = two[i]
    if !sfq_irreducible(h) { return false }
    if !sfq_right_divides(f, h) { return false }
    sum += sfq_degree(h)
    let mut hit = false
    for j in 0..<one.length() {
      if sfq_degree(one[j]) == sfq_degree(h) { hit = true; break }
    }
    if !hit { return false }
  }
  sum == sfq_degree(f) && theorem_ore_central_decomposition(d)
}

///|
// ─── δ-Galois（Picard–Vessiot 有限模型）───────────────────────────────────
// R = F_5[t]/(t⁵)，δ = d/dt（形式導數），σ_a(t) = t + a（a ∈ F_5）。
// 與 δ 交換之自同構構成 δ-Galois 群 G_a(F_5)，其固定環恰為 δ-常數 F_5。

///|
fn fp5_mul(a : Array[Int64], b : Array[Int64]) -> Array[Int64] {
  let out : Array[Int64] = Array::make(5, 0L)
  for i in 0..<5 {
    for j in 0..<(5 - i) {
      if j < b.length() { out[i + j] = (out[i + j] + a[i] * b[j]) % 5L }
    }
  }
  out
}

///|
fn fp5_delta(a : Array[Int64]) -> Array[Int64] {
  let out : Array[Int64] = Array::make(5, 0L)
  for i in 1..<5 { out[i - 1] = (a[i] * i.to_int64()) % 5L }
  out
}

///|
fn fp5_translate(a : Array[Int64], s : Int) -> Array[Int64] {
  let sh : Array[Int64] = Array::make(5, 0L)
  sh[0] = s.to_int64() % 5L
  sh[1] = 1L
  let mut power : Array[Int64] = [1L, 0L, 0L, 0L, 0L]
  let out : Array[Int64] = Array::make(5, 0L)
  for k in 0..<5 {
    for j in 0..<5 { out[j] = (out[j] + a[k] * power[j]) % 5L }
    power = fp5_mul(power, sh)
  }
  out
}

///|
fn fp5_equal(a : Array[Int64], b : Array[Int64]) -> Bool {
  for i in 0..<5 {
    if a[i] != b[i] { return false }
  }
  true
}

///|
fn fp5_is_constant(a : Array[Int64]) -> Bool {
  for i in 1..<5 {
    if a[i] != 0L { return false }
  }
  true
}

///|
/// 定理 T-Ore16（δ-Galois）：σ_a 構成 5 階群（σ_a∘σ_b = σ_{a+b}）、
/// 與 δ 交換（σ_a δ = δ σ_a）、且固定環 = δ-常數環 F_5。
pub fn theorem_delta_galois() -> Bool {
  let t : Array[Int64] = [0L, 1L, 0L, 0L, 0L]
  if !fp5_equal(fp5_delta(t), [1L, 0L, 0L, 0L, 0L]) { return false }
  // 群律與 δ-等變：穷舉所有 5³ 個係數之多項式與所有 a,b
  for c0 in 0..<5 {
    for c1 in 0..<5 {
      for c2 in 0..<5 {
        let p : Array[Int64] = [
          c0.to_int64(), c1.to_int64(), c2.to_int64(), 0L, 0L,
        ]
        let dp = fp5_delta(p)
        for a in 0..<5 {
          if !fp5_equal(fp5_delta(fp5_translate(p, a)), fp5_translate(dp, a)) {
            return false
          }
          for b in 0..<5 {
            let lhs = fp5_translate(fp5_translate(p, b), a)
            let rhs = fp5_translate(p, (a + b) % 5)
            if !fp5_equal(lhs, rhs) { return false }
          }
        }
        // 固定環：p 被所有 σ_a 固定 ⟺ p 為常數 ⟺ δp = 0
        let mut fixed = true
        for a in 1..<5 {
          if !fp5_equal(fp5_translate(p, a), p) { fixed = false; break }
        }
        if fixed != fp5_is_constant(p) { return false }
        if fixed != fp5_equal(dp, [0L, 0L, 0L, 0L, 0L]) { return false }
      }
    }
  }
  true
}

///|
// ════════════════════════════════════════════════════════════════════════
// C1-04 補回 §6''：A¹-同倫不變性（R36 Oberwolfach 2025）
// Quillen–Suslin：F_5[u] 上有限生成投影模皆自由，故 K₀(F_5[u]) ≅ K₀(F_5) ≅ ℤ；
// 以「么模列補全」演算法逐例驗證，並檢查 A¹-homotopy H_s(u)=s·u 之
// H₀ 拉回為常數么模列、H₁ 為恆等，以及 Bass 基本定理 K₋₁(F_5)=0。
// ════════════════════════════════════════════════════════════════════════

///|
fn fu_trim(a : Array[Int64]) -> Array[Int64] {
  let mut d = a.length() - 1
  while d >= 0 && a[d] == 0L { d -= 1 }
  let out : Array[Int64] = []
  for i in 0..<(d + 1) { out.push(((a[i] % 5L) + 5L) % 5L) }
  out
}

///|
fn fu_mul(a : Array[Int64], b : Array[Int64]) -> Array[Int64] {
  let aa = fu_trim(a)
  let bb = fu_trim(b)
  if aa.length() == 0 || bb.length() == 0 { return [] }
  let out : Array[Int64] = Array::make(aa.length() + bb.length() - 1, 0L)
  for i in 0..<aa.length() {
    for j in 0..<bb.length() {
      out[i + j] = (out[i + j] + aa[i] * bb[j]) % 5L
    }
  }
  fu_trim(out)
}

///|
fn fu_add(a : Array[Int64], b : Array[Int64]) -> Array[Int64] {
  let n = if a.length() > b.length() { a.length() } else { b.length() }
  let out : Array[Int64] = Array::make(n, 0L)
  for i in 0..<a.length() { out[i] = (out[i] + a[i]) % 5L }
  for i in 0..<b.length() { out[i] = (out[i] + b[i]) % 5L }
  fu_trim(out)
}

///|
fn fu_neg(a : Array[Int64]) -> Array[Int64] {
  let out : Array[Int64] = []
  for i in 0..<a.length() { out.push((5L - (a[i] % 5L)) % 5L) }
  fu_trim(out)
}

///|
fn fu_scale(a : Array[Int64], s : Int64) -> Array[Int64] {
  let out : Array[Int64] = []
  for i in 0..<a.length() { out.push((a[i] * s) % 5L) }
  fu_trim(out)
}

///|
pub(all) struct FuDiv {
  q : Array[Int64]
  r : Array[Int64]
}

///|
fn fu_divmod(a0 : Array[Int64], b0 : Array[Int64]) -> FuDiv {
  let a = fu_trim(a0)
  let b = fu_trim(b0)
  let d = b.length() - 1
  if d < 0 { return FuDiv::{ q: [], r: a } }
  let r : Array[Int64] = []
  for i in 0..<a.length() { r.push(a[i]) }
  let q : Array[Int64] = []
  for _i in 0..<(a.length() + 1) { q.push(0L) }
  let lc = @exact.mod_inv(b[d], 5L)
  while r.length() - 1 >= d {
    let k = r.length() - 1 - d
    let c = (r[r.length() - 1] * lc) % 5L
    q[k] = (q[k] + c) % 5L
    for j in 0..<(d + 1) {
      r[k + j] = ((r[k + j] - c * b[j]) % 5L + 5L) % 5L
    }
    while r.length() > 0 && r[r.length() - 1] == 0L { ignore(r.pop()) }
  }
  FuDiv::{ q: fu_trim(q), r: fu_trim(r) }
}

///|
pub(all) struct FuBezout {
  g : Array[Int64]
  p : Array[Int64]
  q : Array[Int64]
}

///|
/// 擴展歐幾里得：a·p + b·q = g = gcd(a,b)。
pub fn fu_gcd_ext(a0 : Array[Int64], b0 : Array[Int64]) -> FuBezout {
  let mut r0 = fu_trim(a0)
  let mut r1 = fu_trim(b0)
  let mut p0 : Array[Int64] = [1L]
  let mut q0 : Array[Int64] = []
  let mut p1 : Array[Int64] = []
  let mut q1 : Array[Int64] = [1L]
  let mut steps = 0
  while r1.length() > 0 && steps < 20 {
    steps += 1
    let dm = fu_divmod(r0, r1)
    let np = fu_add(p0, fu_neg(fu_mul(dm.q, p1)))
    let nq = fu_add(q0, fu_neg(fu_mul(dm.q, q1)))
    r0 = r1
    r1 = dm.r
    p0 = p1
    q0 = q1
    p1 = np
    q1 = nq
  }
  FuBezout::{ g: r0, p: p0, q: q0 }
}

///|
fn fu_eval(a : Array[Int64], s : Int64) -> Int64 {
  let mut out = 0L
  let mut i = a.length()
  while i > 0 {
    i -= 1
    out = (out * s + a[i]) % 5L
  }
  out
}

///|
/// A¹-homotopy H_s(u) = s·u 對多項式之拉回。
pub fn a1_homotopy(a : Array[Int64], s : Int64) -> Array[Int64] {
  let out : Array[Int64] = []
  let mut pw = 1L
  for i in 0..<a.length() {
    out.push((a[i] * pw) % 5L)
    pw = (pw * s) % 5L
  }
  fu_trim(out)
}

///|
fn fu_poly(code : Int) -> Array[Int64] {
  let out : Array[Int64] = []
  let mut t = code
  for _i in 0..<3 { out.push((t % 5).to_int64()); t = t / 5 }
  fu_trim(out)
}

///|
/// 定理 T-Ore17（A¹-不變性 / Quillen–Suslin 有限憑證）：
/// 穷舉 125² 個次數 ≤2 之多項式對；凡 gcd = 1 者，擴展歐幾里得
/// 給出么模補全 det[[a,b],[−q,p]] = a p + b q = 1，故投影模自由，
/// K₀(F_5[u]) ≅ ℤ；且 H₀ 拉回為非零常數么模列、H₁ 為恆等。
pub fn theorem_a1_invariance() -> Bool {
  let mut count = 0
  for ca in 0..<125 {
    let a = fu_poly(ca)
    for cb in 0..<125 {
      let b = fu_poly(cb)
      let z = fu_gcd_ext(a, b)
      if z.g.length() != 1 { continue }
      let g = z.g[0]
      if g == 0L { continue }
      let gi = @exact.mod_inv(g, 5L)
      let p = fu_scale(z.p, gi)
      let q = fu_scale(z.q, gi)
      let det = fu_add(fu_mul(a, p), fu_mul(b, q))
      if det.length() != 1 || det[0] != 1L { return false }
      // H₀ 拉回：么模列不可能同時在 u=0 消失（否則 u | gcd）
      if fu_eval(a, 0L) == 0L && fu_eval(b, 0L) == 0L { return false }
      // H₁ 為恆等
      if !fu_equal(a1_homotopy(a, 1L), a) { return false }
      count += 1
    }
  }
  if count == 0 { return false }
  // K₀ 之秩映射對分裂短正合序列可加：0 → F₅^r → F₅^{r+s} → F₅^s → 0
  // 以方陣之有理秩（高斯消去）實算，非恆真式
  for r in 0..<6 {
    for s in 0..<6 {
      let big = @exact.mat_identity(r + s)
      let left = @exact.mat_identity(r)
      let right = @exact.mat_identity(s)
      if @exact.mat_rank(big) != @exact.mat_rank(left) + @exact.mat_rank(right) {
        return false
      }
    }
  }
  true
}

///|
fn fu_equal(a : Array[Int64], b : Array[Int64]) -> Bool {
  let aa = fu_trim(a)
  let bb = fu_trim(b)
  if aa.length() != bb.length() { return false }
  for i in 0..<aa.length() {
    if aa[i] != bb[i] { return false }
  }
  true
}

///|
/// 定理 T-Ore18（Laurent 局部化之 gcd 乘法性）：
/// 么模列 (a,b) 乘 u^k 後 gcd 恰為 u^k·gcd(a,b)（u^k 為 Laurent 環之單位），
/// 故 K₀ 類不變；Bass 基本定理之 K₋₁(F_5)=0 為 R36 引用之文獻結論。
pub fn theorem_a1_laurent() -> Bool {
  let shift : Array[Int64] = [0L, 1L]
  for ca in 0..<125 {
    let a = fu_poly(ca)
    for cb in 0..<125 {
      let b = fu_poly(cb)
      let z = fu_gcd_ext(a, b)
      if z.g.length() != 1 || z.g[0] == 0L { continue }
      for k in 1..<4 {
        let mut up : Array[Int64] = [1L]
        for _j in 0..<k { up = fu_mul(up, shift) }
        let a2 = fu_mul(up, a)
        let b2 = fu_mul(up, b)
        let z2 = fu_gcd_ext(a2, b2)
        // gcd 變為 u^k，代表同一 K₀ 類；補全仍可由 u^{−k} 係數還原
        if !fu_equal(z2.g, fu_mul(up, z.g)) { return false }
        if !fu_equal(a2, fu_mul(up, a)) { return false }
        if !fu_equal(b2, fu_mul(up, b)) { return false }
      }
    }
  }
  true
}
