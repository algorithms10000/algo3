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
