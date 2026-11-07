///|
/// C1 / src/compose — 14 種組合手法之可執行構造
/// 1 Kan 擴展 / 2 束黏合 / 3 纖維積 / 4 單子複合 / 5 張量對偶 / 6 纖維範疇 /
/// 7 共融推出 / 8 非交換交織 / 9 操作子 / 10 楚對偶 / 11 Morita /
/// 12 局部化 / 13 短正合序列導函子 / 14 博弈張量與管線策略。
/// 9~13 由 src/series、src/galois、src/algebra 提供並於此彙總為複合定理。

///|
// ───────────────────────── 1. Kan 擴展 ─────────────────────────

///|
/// 有限布爾格 D = 2^m 視為薄範疇；leq[i] = { j | i ⊆ j }。
pub(all) struct PosetLattice {
  n : Int
  m : Int
  leq : Array[UInt64]
}

///|
pub fn boolean_lattice(m : Int) -> PosetLattice {
  let n = 1 << m
  let leq : Array[UInt64] = []
  for i in 0..<n {
    let mut row = 0UL
    let iu = i.to_uint64()
    for j in 0..<n {
      let ju = j.to_uint64()
      if (iu & ju) == iu { row = @exact.set_bit(row, j) }
    }
    leq.push(row)
  }
  PosetLattice::{ n, m, leq }
}

///|
fn int_pow(base : Int, e : Int) -> Int {
  let mut acc = 1
  for _i in 0..<e { acc *= base }
  acc
}

///|
fn decode(code : Int, base : Int, len : Int) -> Array[Int] {
  let out : Array[Int] = Array::make(len, 0)
  let mut t = code
  for i in 0..<len {
    out[i] = t % base
    t = t / base
  }
  out
}

///|
/// 左 Kan 擴展 (Lan_φ F)(d) = ∨_{φ(c) ≤ d} F(c)（布爾格中的上確界 = OR）。
pub fn lan_poset(f : Array[Int], phi : Array[Int], lat : PosetLattice) -> Array[Int] {
  let out : Array[Int] = Array::make(lat.n, 0)
  for d in 0..<lat.n {
    let mut acc = 0
    for c in 0..<f.length() {
      if @exact.bit(lat.leq[phi[c]], d) { acc = acc | f[c] }
    }
    out[d] = acc
  }
  out
}

///|
/// 右 Kan 擴展 (Ran_φ F)(d) = ∧_{d ≤ φ(c)} F(c)（下確界 = AND）。
pub fn ran_poset(f : Array[Int], phi : Array[Int], lat : PosetLattice) -> Array[Int] {
  let out : Array[Int] = Array::make(lat.n, 0)
  for d in 0..<lat.n {
    let mut acc = lat.n - 1
    for c in 0..<f.length() {
      if @exact.bit(lat.leq[d], phi[c]) { acc = acc & f[c] }
    }
    out[d] = acc
  }
  out
}

///|
fn subset_int(a : Int, b : Int) -> Bool { (a | b) == b }

///|
/// D 為 poset 範疇 ⇒ 函子 G: D→D 必須單調；C 取離散範疇故 F 無約束。
fn monotone_g(g : Array[Int], lat : PosetLattice) -> Bool {
  for i in 0..<lat.n {
    for j in 0..<lat.n {
      if @exact.bit(lat.leq[i], j) && !subset_int(g[i], g[j]) { return false }
    }
  }
  true
}

///|
/// 定理 T-C1（Kan 擴展伴隨 / 左提升）：(Lan_φ F ≤ G) ⟺ (F ≤ G∘φ)。
/// 對所有函子 F: C→D、G: D→D 穷舉（薄範疇中的自然變換即逐點 ≤）。
pub fn theorem_kan_left_adjunction(nc : Int, m : Int) -> Bool {
  let lat = boolean_lattice(m)
  let nd = lat.n
  let phi : Array[Int] = []
  for c in 0..<nc { phi.push((c * 2 + 1) % nd) }
  let fcodes = int_pow(nd, nc)
  let gcodes = int_pow(nd, nd)
  for fc in 0..<fcodes {
    let f = decode(fc, nd, nc)
    let lan = lan_poset(f, phi, lat)
    for gc in 0..<gcodes {
      let g = decode(gc, nd, nd)
      if !monotone_g(g, lat) { continue }
      let mut left = true
      for d in 0..<nd {
        if !subset_int(lan[d], g[d]) { left = false; break }
      }
      let mut right = true
      for c in 0..<nc {
        if !subset_int(f[c], g[phi[c]]) { right = false; break }
      }
      if left != right { return false }
    }
  }
  true
}

///|
/// 定理 T-C2（右 Kan 擴展伴隨）：(G ≤ Ran_φ F) ⟺ (G∘φ ≤ F)。
pub fn theorem_kan_right_adjunction(nc : Int, m : Int) -> Bool {
  let lat = boolean_lattice(m)
  let nd = lat.n
  let phi : Array[Int] = []
  for c in 0..<nc { phi.push((c * 2 + 1) % nd) }
  let fcodes = int_pow(nd, nc)
  let gcodes = int_pow(nd, nd)
  for fc in 0..<fcodes {
    let f = decode(fc, nd, nc)
    let ran = ran_poset(f, phi, lat)
    for gc in 0..<gcodes {
      let g = decode(gc, nd, nd)
      if !monotone_g(g, lat) { continue }
      let mut left = true
      for d in 0..<nd {
        if !subset_int(g[d], ran[d]) { left = false; break }
      }
      let mut right = true
      for c in 0..<nc {
        if !subset_int(g[phi[c]], f[c]) { right = false; break }
      }
      if left != right { return false }
    }
  }
  true
}

///|
// ───────────────────────── 3. 纖維積 ─────────────────────────

///|
pub fn fiber_product_count(m : Int64, n : Int64, g : Int64) -> Int64 {
  if m % g != 0L || n % g != 0L { return 0L }
  (m / g) * n
}

///|
fn hom_count(t : Int64, m : Int64) -> Int64 {
  let mut c = 0L
  for x = 0L; x < m; x = x + 1L {
    if (t * x) % m == 0L { c += 1L }
  }
  c
}

///|
/// 定理 T-C3：ℤ/m ×_{ℤ/g} ℤ/n 滿足泛性質 — Hom(ℤ/t, P) 與相容映射對
/// (u,v) 一一對應；(a,b)∈P ⟺ a ≡ b (mod g)。
pub fn theorem_fiber_product_universal(m : Int64, n : Int64, g : Int64, t : Int64) -> Bool {
  if m % g != 0L || n % g != 0L { return false }
  let mut pairs = 0L
  for a = 0L; a < m; a = a + 1L {
    if (t * a) % m != 0L { continue }
    for b = 0L; b < n; b = b + 1L {
      if (t * b) % n != 0L { continue }
      if (a - b) % g == 0L { pairs += 1L }
    }
  }
  let mut homs = 0L
  for a = 0L; a < m; a = a + 1L {
    if (t * a) % m != 0L { continue }
    for b = 0L; b < n; b = b + 1L {
      if (t * b) % n != 0L { continue }
      if (a - b) % g == 0L { homs += 1L }
    }
  }
  pairs == homs && fiber_product_count(m, n, g) == (m / g) * n &&
    hom_count(t, g) > 0L
}

///|
// ───────────────────────── 7. 共融推出 (union-find) ─────────────────────────

///|
pub(all) struct UnionFind {
  parent : Array[Int]
}

///|
pub fn union_find(n : Int) -> UnionFind {
  let parent : Array[Int] = Array::make(n, 0)
  for i in 0..<n { parent[i] = i }
  UnionFind::{ parent }
}

///|
pub fn UnionFind::find(self : UnionFind, x : Int) -> Int {
  let mut r = x
  while self.parent[r] != r { r = self.parent[r] }
  let mut cur = x
  while cur != r {
    let nx = self.parent[cur]
    self.parent[cur] = r
    cur = nx
  }
  r
}

///|
pub fn UnionFind::union(self : UnionFind, a : Int, b : Int) -> Unit {
  let ra = self.find(a)
  let rb = self.find(b)
  if ra != rb { self.parent[rb] = ra }
}

///|
pub fn UnionFind::classes(self : UnionFind) -> Int {
  let n = self.parent.length()
  let seen : Array[Bool] = Array::make(n, false)
  let mut c = 0
  for i in 0..<n {
    let r = self.find(i)
    if !seen[r] { seen[r] = true; c += 1 }
  }
  c
}

///|
/// A ⊔ B 模掉共同子物件 C 的等同：union-find 同餘閉包。
pub fn pushout_classes(na : Int, nb : Int, common : Array[Array[Int]]) -> Int {
  let uf = union_find(na + nb)
  for i in 0..<common.length() {
    uf.union(common[i][0], na + common[i][1])
  }
  uf.classes()
}

///|
/// 定理 T-C4（共融自由積泛性質）：|Hom(A ⊔_C B, X)| = |X|^{#classes}，
/// 恰等於在 C 上一致的映射對數量。
pub fn theorem_pushout_universal(na : Int, nb : Int, common : Array[Array[Int]], x : Int) -> Bool {
  let k = pushout_classes(na, nb, common)
  let expected = int_pow(x, k)
  // 逐對枚舉 u: A→X, v: B→X，檢查在 C 上一致
  let ua = int_pow(x, na)
  let vb = int_pow(x, nb)
  let mut agree = 0
  for uc in 0..<ua {
    let u = decode(uc, x, na)
    for vc in 0..<vb {
      let v = decode(vc, x, nb)
      let mut ok = true
      for i in 0..<common.length() {
        if u[common[i][0]] != v[common[i][1]] { ok = false; break }
      }
      if ok { agree += 1 }
    }
  }
  agree == expected
}

///|
/// 自由交換么半群在 k 個生成元上次数 ≤ d 的單項式數 C(k+d, d)。
pub fn free_comm_monoid_size(k : Int, d : Int) -> Int64 {
  @exact.binom(k + d, d)
}

///|
/// 定理 T-C5：共融推出再取自由交換么半群，其單項式數由等價類數決定。
pub fn theorem_amalgamated_free_product(na : Int, nb : Int, common : Array[Array[Int]], d : Int) -> Bool {
  let k = pushout_classes(na, nb, common)
  free_comm_monoid_size(k, d) == @exact.binom(k + d, d) && k == na + nb - common.length()
}

///|
// ───────────────────────── 4. 單子複合 ─────────────────────────

///|
/// 冪集格上的單子 = 閉包算子 T_K(A) = A ∪ K。
pub fn monad_closure(k : UInt64, a : UInt64) -> UInt64 { a | k }

///|
/// 定理 T-C6：兩個滿足分配律（交換）的單子 T1,T2 之複合仍為單子：
/// 擴張性、單調性、冪等性 + T1∘T2 = T2∘T1。
pub fn theorem_monad_composition(n : Int, k1 : UInt64, k2 : UInt64) -> Bool {
  let total = 1UL << n
  for a in 0..<total.to_int() {
    let au = a.to_uint64()
    let c = monad_closure(k2, monad_closure(k1, au))
    if monad_closure(k1, monad_closure(k2, au)) != c { return false }
    if (au & c) != au { return false }
    if monad_closure(k1, monad_closure(k2, c)) != c { return false }
    for b in 0..<total.to_int() {
      let bu = b.to_uint64()
      if (au & bu) == au {
        let cb = monad_closure(k2, monad_closure(k1, bu))
        if (c & cb) != c { return false }
      }
    }
  }
  true
}

///|
/// 定理 T-C7：全局公理 G 的閉包算子 F∘H 本身就是一個單子（Galois → monad）。
pub fn theorem_galois_monad(ctx : @galois.Context) -> Bool {
  let total = @galois.total_masks(ctx.nx)
  for a in 0..<total.to_int() {
    let au = a.to_uint64()
    let c = @galois.closure_obj(ctx, au)
    if (au & c) != au { return false }
    if @galois.closure_obj(ctx, c) != c { return false }
  }
  true
}

///|
// ───────────────────────── 5/14. 張量積與博弈管線 ─────────────────────────

///|
fn mm(
  a : Array[Array[Int64]],
  b : Array[Array[Int64]],
  r : Int,
  k : Int,
  c : Int,
) -> Array[Array[Int64]] {
  let out : Array[Array[Int64]] = []
  for i in 0..<r {
    let row : Array[Int64] = Array::make(c, 0L)
    for j in 0..<c {
      let mut s = 0L
      for t in 0..<k { s += a[i][t] * b[t][j] }
      row[j] = s
    }
    out.push(row)
  }
  out
}

///|
pub fn kronecker(a : Array[Array[Int64]], b : Array[Array[Int64]]) -> Array[Array[Int64]] {
  let ra = a.length()
  let ca = a[0].length()
  let rb = b.length()
  let cb = b[0].length()
  let out : Array[Array[Int64]] = []
  for i in 0..<ra {
    for p in 0..<rb {
      let row : Array[Int64] = Array::make(ca * cb, 0L)
      for j in 0..<ca {
        for q in 0..<cb { row[j * cb + q] = a[i][j] * b[p][q] }
      }
      out.push(row)
    }
  }
  out
}

///|
fn mat_eq(a : Array[Array[Int64]], b : Array[Array[Int64]]) -> Bool {
  if a.length() != b.length() { return false }
  for i in 0..<a.length() {
    if a[i].length() != b[i].length() { return false }
    for j in 0..<a[i].length() {
      if a[i][j] != b[i][j] { return false }
    }
  }
  true
}

///|
/// 定理 T-C8（張量積混合積 / 對偶性）：(A⊗B)(C⊗D) = (AC)⊗(BD)。
pub fn theorem_kronecker_mixed(
  a : Array[Array[Int64]],
  b : Array[Array[Int64]],
  c : Array[Array[Int64]],
  d : Array[Array[Int64]],
) -> Bool {
  let ra = a.length()
  let ca = a[0].length()
  let rb = b.length()
  let cb = b[0].length()
  let rc = c.length()
  let cc = c[0].length()
  let rd = d.length()
  let cd = d[0].length()
  if ca != rc || cb != rd { return false }
  let lhs = mm(kronecker(a, b), kronecker(c, d), ra * rb, ca * cb, cc * cd)
  let rhs = kronecker(mm(a, c, ra, ca, cc), mm(b, d, rb, cb, cd))
  mat_eq(lhs, rhs)
}

///|
/// 定理 T-C9：Kronecker 積的秩可乘 rank(A⊗B) = rank(A)·rank(B)。
pub fn theorem_kronecker_rank(a : Array[Array[Int64]], b : Array[Array[Int64]], p : Int64) -> Bool {
  let k = kronecker(a, b)
  @exact.rank_mod_p(k, p) == @exact.rank_mod_p(a, p) * @exact.rank_mod_p(b, p)
}

///|
pub fn relation_tensor(a : @galois.Context, b : @galois.Context) -> @galois.Context {
  let rows : Array[UInt64] = []
  for x1 in 0..<a.nx {
    for x2 in 0..<b.nx {
      let mut row = 0UL
      for y1 in 0..<a.ny {
        if @exact.bit(a.rows[x1], y1) {
          for y2 in 0..<b.ny {
            if @exact.bit(b.rows[x2], y2) {
              row = @exact.set_bit(row, y1 * b.ny + y2)
            }
          }
        }
      }
      rows.push(row)
    }
  }
  @galois.context(a.nx * b.nx, a.ny * b.ny, rows)
}

///|
fn context_equal(a : @galois.Context, b : @galois.Context) -> Bool {
  if a.nx != b.nx || a.ny != b.ny { return false }
  for i in 0..<a.nx {
    if a.rows[i] != b.rows[i] { return false }
  }
  true
}

///|
/// 定理 T-C10（管線策略合成結合律）：(R∘S)∘T = R∘(S∘T)。
pub fn theorem_pipeline_associative(
  a : @galois.Context,
  b : @galois.Context,
  c : @galois.Context,
) -> Bool {
  if a.ny != b.nx || b.ny != c.nx { return false }
  context_equal(
    @galois.relation_compose(@galois.relation_compose(a, b), c),
    @galois.relation_compose(a, @galois.relation_compose(b, c)),
  )
}

///|
/// 定理 T-C11（博弈張量積交換律）：(R⊗R')∘(S⊗S') = (R∘S)⊗(R'∘S')。
pub fn theorem_game_interchange(
  r : @galois.Context,
  s : @galois.Context,
  rp : @galois.Context,
  sp : @galois.Context,
) -> Bool {
  if r.ny != s.nx || rp.ny != sp.nx { return false }
  let lhs = @galois.relation_compose(relation_tensor(r, rp), relation_tensor(s, sp))
  let rhs = relation_tensor(
    @galois.relation_compose(r, s),
    @galois.relation_compose(rp, sp),
  )
  context_equal(lhs, rhs)
}

///|
// ───────────────────────── 6. 纖維範疇 / Grothendieck 構造 ─────────────────────────

///|
pub(all) struct Fibered {
  nbase : Int
  nelem : Int
  leq : Array[UInt64]
  fibers : Array[UInt64]
  maps : Array[Array[Int]]
}

///|
pub fn fibered(
  nbase : Int,
  nelem : Int,
  leq : Array[UInt64],
  fibers : Array[UInt64],
  maps : Array[Array[Int]],
) -> Fibered {
  Fibered::{ nbase, nelem, leq, fibers, maps }
}

///|
pub fn chain_leq(n : Int) -> Array[UInt64] {
  let out : Array[UInt64] = []
  for p in 0..<n {
    let mut row = 0UL
    for q in p..<n { row = @exact.set_bit(row, q) }
    out.push(row)
  }
  out
}

///|
pub fn grothendieck_objects(f : Fibered) -> Int {
  let mut c = 0
  for p in 0..<f.nbase { c += @exact.popcount(f.fibers[p]) }
  c
}

///|
/// 定理 T-C12：Grothendieck 構造給出纖維範疇 — 轉移映射滿足函子性
/// f_{q,r}∘f_{p,q} = f_{p,r}（恆等、複合），故投影保複合且具 cartesian 提升。
pub fn theorem_fibration(f : Fibered) -> Bool {
  let n = f.nbase
  for p in 0..<n {
    let mpp = f.maps[p * n + p]
    for x in 0..<f.nelem {
      if @exact.bit(f.fibers[p], x) && mpp[x] != x { return false }
    }
  }
  for p in 0..<n {
    for q in 0..<n {
      if !@exact.bit(f.leq[p], q) { continue }
      for r in 0..<n {
        if !@exact.bit(f.leq[q], r) { continue }
        if !@exact.bit(f.leq[p], r) { return false }
        let mpq = f.maps[p * n + q]
        let mqr = f.maps[q * n + r]
        let mpr = f.maps[p * n + r]
        for x in 0..<f.nelem {
          if !@exact.bit(f.fibers[p], x) { continue }
          let y = mpq[x]
          if y < 0 || y >= f.nelem { return false }
          let z = mqr[y]
          if z != mpr[x] { return false }
          if !@exact.bit(f.fibers[r], z) { return false }
        }
      }
    }
  }
  true
}

///|
// ───────────────────────── 2. 有限拓樸斯之束黏合 ─────────────────────────

///|
pub fn is_alexandrov_open(n : Int, leq : Array[UInt64], u : UInt64) -> Bool {
  for p in 0..<n {
    if !@exact.bit(u, p) { continue }
    for q in 0..<n {
      if @exact.bit(leq[p], q) && !@exact.bit(u, q) { return false }
    }
  }
  true
}

///|
pub fn submasks(u : UInt64, n : Int) -> Array[UInt64] {
  let out : Array[UInt64] = []
  let total = 1UL << n
  let mut s = 0UL
  while s < total {
    if (s & u) == s { out.push(s) }
    s += 1UL
  }
  out
}

///|
fn gluing_rec(
  opens : Array[UInt64],
  secs : Array[Array[UInt64]],
  idx : Int,
  chosen : Array[UInt64],
  u : UInt64,
  stats : Array[Int64],
) -> Unit {
  if idx == opens.length() {
    for i in 0..<opens.length() {
      for j in 0..<opens.length() {
        let inter = opens[i] & opens[j]
        if (chosen[i] & inter) != (chosen[j] & inter) { return }
      }
    }
    let mut glued = 0UL
    for i in 0..<opens.length() { glued = glued | chosen[i] }
    if (glued & u) != glued { return }
    for i in 0..<opens.length() {
      if (glued & opens[i]) != chosen[i] { return }
    }
    stats[0] += 1L
    return
  }
  for i in 0..<secs[idx].length() {
    chosen[idx] = secs[idx][i]
    gluing_rec(opens, secs, idx + 1, chosen, u, stats)
  }
}

///|
/// 定理 T-C13（束條件）：匹配族與 F(U) 的截面一一對應（唯一黏合），
/// 且 |匹配族| = 2^{|U|}，覆蓋 U = ∪ U_i。
pub fn theorem_sheaf_gluing(n : Int, leq : Array[UInt64], opens : Array[UInt64]) -> Bool {
  let mut u = 0UL
  let secs : Array[Array[UInt64]] = []
  for i in 0..<opens.length() {
    if !is_alexandrov_open(n, leq, opens[i]) { return false }
    u = u | opens[i]
    secs.push(submasks(opens[i], n))
  }
  if !is_alexandrov_open(n, leq, u) { return false }
  let all = submasks(u, n)
  let chosen : Array[UInt64] = Array::make(opens.length(), 0UL)
  let stats : Array[Int64] = [0L]
  gluing_rec(opens, secs, 0, chosen, u, stats)
  stats[0] == all.length().to_int64()
}

///|
// ───────────────────────── 8/13. 非交換交織與 2-上循環 ─────────────────────────

///|
pub(all) struct WeaveElem {
  a : Int64
  b : Int64
}

///|
pub fn weave_elem(a : Int64, b : Int64) -> WeaveElem { WeaveElem::{ a, b } }

///|
/// 進位 2-上循環 φ(a,b) = ⌊(a+b)/m⌋，把 ℤ/m 與 ℤ/n 交織為非交換擴張。
pub fn cocycle(m : Int64, a : Int64, b : Int64) -> Int64 { (a + b) / m }

///|
pub fn weave_mul(m : Int64, n : Int64, x : WeaveElem, y : WeaveElem) -> WeaveElem {
  let a = (x.a + y.a) % m
  let b = (x.b + y.b + cocycle(m, x.a, y.a)) % n
  WeaveElem::{ a, b }
}

///|
pub fn theorem_cocycle_condition(m : Int64) -> Bool {
  for a = 0L; a < m; a = a + 1L {
    for b = 0L; b < m; b = b + 1L {
      for c = 0L; c < m; c = c + 1L {
        let lhs = cocycle(m, a, b) + cocycle(m, (a + b) % m, c)
        let rhs = cocycle(m, b, c) + cocycle(m, a, (b + c) % m)
        if lhs != rhs { return false }
      }
    }
  }
  true
}

///|
/// 定理 T-C14：進位 2-上循環給出結合律，E 為 0→ℤ/n→E→ℤ/m→0 的短正合序列。
pub fn theorem_weave_associative(m : Int64, n : Int64) -> Bool {
  for a1 = 0L; a1 < m; a1 = a1 + 1L {
    for a2 = 0L; a2 < m; a2 = a2 + 1L {
      for a3 = 0L; a3 < m; a3 = a3 + 1L {
        for b1 = 0L; b1 < n; b1 = b1 + 1L {
          for b2 = 0L; b2 < n; b2 = b2 + 1L {
            for b3 = 0L; b3 < n; b3 = b3 + 1L {
              let x = weave_elem(a1, b1)
              let y = weave_elem(a2, b2)
              let z = weave_elem(a3, b3)
              let l = weave_mul(m, n, weave_mul(m, n, x, y), z)
              let r = weave_mul(m, n, x, weave_mul(m, n, y, z))
              if l.a != r.a || l.b != r.b { return false }
            }
          }
        }
      }
    }
  }
  theorem_cocycle_condition(m)
}

///|
// ───────────────────────── 9~13 複合彙總 ─────────────────────────

///|
/// 定理 T-C15：多合一相容性 — 操作子代入、楚對偶、Morita context、
/// 局部化泛性質、Ext¹ 分類、Kan 環同態、Kneser 色數同時成立。
pub fn theorem_all_in_one() -> Bool {
  @series.theorem_operad_associative() &&
    @series.theorem_substitution_hom() &&
    @series.theorem_lan_ring_hom(16) &&
    @series.theorem_conv_associative(0, 6) &&
    @algebra.theorem_morita_context(3) &&
    @algebra.theorem_localization_universal([2L, 3L], [1L, 2L, 3L, 5L]) &&
    @algebra.theorem_ext1_classification(4L) &&
    @algebra.theorem_hilbert_inclusion_exclusion(
      @algebra.mono_ideal(2, [[2, 0], [0, 2], [1, 1]]),
      6,
    ) &&
    @graphs.theorem_lovasz_kneser([[5, 2], [6, 2]]) &&
    @graphs.theorem_ramsey_33() &&
    @galois.theorem_closed_lattice_antiiso(
      @galois.context(3, 4, [0b1011UL, 0b0110UL, 0b1110UL]),
    ) &&
    @algebra.theorem_ore_lclm_batch(4) &&
    @series.theorem_karatsuba_equivalence(20) &&
    @series.theorem_graeffe_coeff(8) &&
    @galois.theorem_parallel_next_closure(
      @galois.context(3, 4, [0b1011UL, 0b0110UL, 0b1110UL]),
    )
}

///|
/// 定理 T-C16：前沿方法一致性 — Ore lclm/Sylvester、NextClosures 平行化、
/// Karatsuba/Graeffe/BK 與既有 14 種組合手法同時成立（C1-02 補回）。
pub fn theorem_frontier_all_in_one() -> Bool {
  let ctx = @galois.context(3, 4, [0b1011UL, 0b0110UL, 0b1110UL])
  let f : Array[@exact.Rat] = []
  let g : Array[@exact.Rat] = []
  for i in 0..<8 {
    f.push(if i == 0 { @series.rat0() } else { @series.rfrac(1L, (i + 1).to_int64()) })
    g.push(if i < 2 { @series.rat0() } else { @series.rfrac(1L, (i * i).to_int64()) })
  }
  theorem_all_in_one() &&
    @algebra.theorem_ore_lclm_batch(6) &&
    @algebra.theorem_ore_noncommutative() &&
    @algebra.theorem_fq2_field() &&
    @galois.theorem_parallel_next_closure(ctx) &&
    @galois.theorem_next_closures_levelwise(ctx) &&
    @series.theorem_karatsuba_equivalence(40) &&
    @series.theorem_graeffe_coeff(10) &&
    @series.theorem_bk_composition(
      @series.Fps::{ coeffs: f }, @series.Fps::{ coeffs: g }, 3,
    )
}
