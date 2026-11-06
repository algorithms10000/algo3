///|
/// C1 / src/series/operad — 操作子代入 (組合範例 9) 與多元多項式商環前置
/// 端omorphism operad：P ∘ (Q_1,...,Q_n) 把每個運算輸出插入另一運算的輸入插槽。

///|
pub(all) struct Monomial {
  exps : Array[Int]
  c : @exact.Rat
}

///|
pub(all) struct MPoly {
  nvars : Int
  terms : Array[Monomial]
}

///|
pub fn monomial(nvars : Int, exps : Array[Int], c : @exact.Rat) -> MPoly {
  MPoly::{ nvars, terms: [Monomial::{ exps, c }] }
}

///|
pub fn mpoly_const(nvars : Int, c : @exact.Rat) -> MPoly {
  let exps : Array[Int] = Array::make(nvars, 0)
  MPoly::{ nvars, terms: [Monomial::{ exps, c }] }
}

///|
fn exps_equal(a : Array[Int], b : Array[Int]) -> Bool {
  if a.length() != b.length() { return false }
  for i in 0..<a.length() {
    if a[i] != b[i] { return false }
  }
  true
}

///|
/// 合併同類項（線性搜尋，保留精確有理係數），去掉零項。
pub fn mpoly_canonical(p : MPoly) -> MPoly {
  let exps : Array[Array[Int]] = []
  let coeffs : Array[@exact.Rat] = []
  for i in 0..<p.terms.length() {
    let t = p.terms[i]
    let mut at = -1
    for j in 0..<exps.length() {
      if exps_equal(exps[j], t.exps) { at = j; break }
    }
    if at < 0 {
      exps.push(t.exps)
      coeffs.push(t.c)
    } else {
      coeffs[at] = coeffs[at].add(t.c)
    }
  }
  let terms : Array[Monomial] = []
  for j in 0..<exps.length() {
    if !coeffs[j].is_zero() { terms.push(Monomial::{ exps: exps[j], c: coeffs[j] }) }
  }
  MPoly::{ nvars: p.nvars, terms }
}

///|
pub fn MPoly::add(self : MPoly, o : MPoly) -> MPoly {
  let terms : Array[Monomial] = []
  for i in 0..<self.terms.length() { terms.push(self.terms[i]) }
  for i in 0..<o.terms.length() { terms.push(o.terms[i]) }
  mpoly_canonical(MPoly::{ nvars: self.nvars, terms })
}

///|
pub fn MPoly::sub(self : MPoly, o : MPoly) -> MPoly {
  self.add(o.scale(rint(-1L)))
}

///|
pub fn MPoly::mul(self : MPoly, o : MPoly) -> MPoly {
  let terms : Array[Monomial] = []
  for i in 0..<self.terms.length() {
    for j in 0..<o.terms.length() {
      let exps : Array[Int] = Array::make(self.nvars, 0)
      for k in 0..<self.nvars {
        exps[k] = self.terms[i].exps[k] + o.terms[j].exps[k]
      }
      terms.push(Monomial::{ exps, c: self.terms[i].c.mul(o.terms[j].c) })
    }
  }
  mpoly_canonical(MPoly::{ nvars: self.nvars, terms })
}

///|
pub fn MPoly::pow(self : MPoly, k : Int) -> MPoly {
  let mut acc = mpoly_const(self.nvars, rat1())
  for _i in 0..<k { acc = acc.mul(self) }
  acc
}

///|
pub fn MPoly::scale(self : MPoly, c : @exact.Rat) -> MPoly {
  let terms : Array[Monomial] = []
  for i in 0..<self.terms.length() {
    terms.push(Monomial::{ exps: self.terms[i].exps, c: self.terms[i].c.mul(c) })
  }
  MPoly::{ nvars: self.nvars, terms }
}

///|
pub fn MPoly::equal(self : MPoly, o : MPoly) -> Bool {
  let a = mpoly_canonical(self)
  let b = mpoly_canonical(o)
  if a.nvars != b.nvars || a.terms.length() != b.terms.length() { return false }
  for i in 0..<a.terms.length() {
    let mut hit = false
    for j in 0..<b.terms.length() {
      if exps_equal(a.terms[i].exps, b.terms[j].exps) && a.terms[i].c.equal(b.terms[j].c) {
        hit = true
        break
      }
    }
    if !hit { return false }
  }
  true
}

///|
/// 操作子代入：P(Q_1,...,Q_n) = Σ_m c_m Π_i Q_i^{m_i}。
pub fn mpoly_substitute(p : MPoly, qs : Array[MPoly]) -> MPoly {
  let mut acc = mpoly_const(p.nvars, rat0())
  for i in 0..<p.terms.length() {
    let mut term = mpoly_const(p.nvars, p.terms[i].c)
    for v in 0..<p.nvars {
      let e = p.terms[i].exps[v]
      if e > 0 { term = term.mul(qs[v].pow(e)) }
    }
    acc = acc.add(term)
  }
  mpoly_canonical(acc)
}

///|
pub fn mpoly_eval(p : MPoly, xs : Array[@exact.Rat]) -> @exact.Rat {
  let mut acc = rat0()
  for i in 0..<p.terms.length() {
    let mut v = p.terms[i].c
    for k in 0..<p.nvars {
      v = v.mul(xs[k].pow(p.terms[i].exps[k]))
    }
    acc = acc.add(v)
  }
  acc
}

///|
/// 定理 T-O1（操作子結合律 / 併攏）：(P∘Q)∘R = P∘(Q∘R)。
/// 以具體多元多項式在 ℚ[x,y] 上做代數等式檢查，並在三個點上覆核求值。
pub fn theorem_operad_associative() -> Bool {
  let x = monomial(2, [1, 0], rat1())
  let y = monomial(2, [0, 1], rat1())
  let c2 = mpoly_const(2, rint(2L))
  let p = x.mul(x).add(y.scale(rint(3L))).add(c2)
  let q0 = x.add(y)
  let q1 = x.mul(y).add(mpoly_const(2, rint(5L)))
  let qs : Array[MPoly] = [q0, q1]
  let r0 = y.add(mpoly_const(2, rint(1L)))
  let r1 = x.sub(y)
  let rs : Array[MPoly] = [r0, r1]
  let left_qs : Array[MPoly] = [mpoly_substitute(q0, rs), mpoly_substitute(q1, rs)]
  let left = mpoly_substitute(mpoly_substitute(p, qs), rs)
  let right = mpoly_substitute(p, left_qs)
  let pts : Array[Array[@exact.Rat]] = [
    [rint(1L), rint(2L)],
    [rfrac(1L, 2L), rfrac(3L, 2L)],
    [rint(-2L), rint(3L)],
  ]
  let mut ok = left.equal(right)
  for i in 0..<pts.length() {
    if !mpoly_eval(left, pts[i]).equal(mpoly_eval(right, pts[i])) { ok = false }
  }
  ok
}

///|
/// 定理 T-O2（多元代入求值同態）：eval(P∘Q, z) = eval(P, eval(Q_i, z))。
pub fn theorem_substitution_hom() -> Bool {
  let x = monomial(2, [1, 0], rat1())
  let y = monomial(2, [0, 1], rat1())
  let p = x.mul(x).add(y.scale(rint(4L)))
  let qs : Array[MPoly] = [x.add(y), x.mul(y)]
  let z : Array[@exact.Rat] = [rint(2L), rint(3L)]
  let lhs = mpoly_eval(mpoly_substitute(p, qs), z)
  let vals : Array[@exact.Rat] = [mpoly_eval(qs[0], z), mpoly_eval(qs[1], z)]
  let rhs = mpoly_eval(p, vals)
  lhs.equal(rhs)
}
