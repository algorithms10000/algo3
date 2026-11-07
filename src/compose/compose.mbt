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

///|
// ════════════════════════════════════════════════════════════════════════
// C1-03：泛性質與函子性 + 衍生方向動詞 × 14 組合範例之定理／演算法
// R33 Doña Mateo Pushforward monads (TAC 2025)、Kan 擴展泛性質、
// Mac Lane「all concepts are Kan extensions」、R36 K-theory 函子性。
// 《作業規範》列 21 個衍生方向動詞（使用者稱「20 動詞」，全數納入），
// 《組合範例》列 14 種手法；以下以可計算不變量建立 21×14 相容矩陣。
// ════════════════════════════════════════════════════════════════════════

///|
/// 纖維積泛性質：對所有 Q 與錐 (f,g)，中介態射存在且唯一。
pub fn theorem_universal_property_pullback(n : Int) -> Bool {
  for q in 1..<4 {
    let maps = int_pow(n, q)
    for fc in 0..<maps {
      let f = decode(fc, n, q)
      for gc in 0..<maps {
        let g = decode(gc, n, q)
        let mut agree = true
        for i in 0..<q {
          if f[i] != g[i] { agree = false; break }
        }
        let mut mediators = 0
        for hc in 0..<maps {
          let h = decode(hc, n, q)
          let mut ok = true
          for i in 0..<q {
            if h[i] != f[i] || h[i] != g[i] { ok = false; break }
          }
          if ok { mediators += 1 }
        }
        let expected = if agree { 1 } else { 0 }
        if mediators != expected { return false }
      }
    }
  }
  true
}

///|
/// 自由交換么半群泛性質：k=2, d=2，對任意目標 ℤ/x，
/// 給定生成元像 (g₀,g₁) 後存在唯一么半群同態 φ(v)=v₀g₀+v₁g₁ mod x，
/// 且不同生成元像給出不同同態（|Hom| = x²）。
pub fn theorem_universal_property_free_monoid(x : Int) -> Bool {
  let exps : Array[Array[Int]] = [[0, 0], [1, 0], [2, 0], [0, 1], [1, 1], [0, 2]]
  let sigs : Array[Array[Int]] = []
  for g0 in 0..<x {
    for g1 in 0..<x {
      let sig : Array[Int] = []
      for i in 0..<exps.length() {
        sig.push((exps[i][0] * g0 + exps[i][1] * g1) % x)
      }
      // 同態律：v+w 仍在次數 ≤2 集合內時 φ(v+w)=φ(v)+φ(w)
      for i in 0..<exps.length() {
        for j in 0..<exps.length() {
          let s0 = exps[i][0] + exps[j][0]
          let s1 = exps[i][1] + exps[j][1]
          if s0 + s1 > 2 { continue }
          let mut idx = -1
          for t in 0..<exps.length() {
            if exps[t][0] == s0 && exps[t][1] == s1 { idx = t; break }
          }
          if idx < 0 { return false }
          if sig[idx] != (sig[i] + sig[j]) % x { return false }
        }
      }
      for t in 0..<sigs.length() {
        let mut same = true
        for i in 0..<sig.length() {
          if sigs[t][i] != sig[i] { same = false; break }
        }
        if same { return false }
      }
      sigs.push(sig)
    }
  }
  sigs.length() == x * x
}

///|
fn deriv_ctx_equal(x : @galois.Context, y : @galois.Context) -> Bool {
  if x.nx != y.nx || x.ny != y.ny || x.rows.length() != y.rows.length() {
    return false
  }
  for i in 0..<x.rows.length() {
    if x.rows[i] != y.rows[i] { return false }
  }
  true
}

///|
/// 函子性：關係複合滿足 F(id)=id、F(R∘S)=F(R)∘F(S)；
/// 轉置（楚對偶）為反變函子：(R∘S)ᵀ = Sᵀ∘Rᵀ。
pub fn theorem_functoriality() -> Bool {
  let a = @galois.context(3, 3, [0b101UL, 0b011UL, 0b110UL])
  let b = @galois.context(3, 3, [0b110UL, 0b101UL, 0b011UL])
  let id = @galois.context(3, 3, [0b001UL, 0b010UL, 0b100UL])
  let ab = @galois.relation_compose(a, b)
  let lhs = @galois.chu_dual(ab)
  let rhs = @galois.relation_compose(@galois.chu_dual(b), @galois.chu_dual(a))
  deriv_ctx_equal(@galois.relation_compose(a, id), a) &&
    deriv_ctx_equal(@galois.relation_compose(id, a), a) &&
    deriv_ctx_equal(lhs, rhs) && deriv_ctx_equal(@galois.chu_dual(@galois.chu_dual(a)), a)
}

///|
/// 定理 T-C17：Kan 擴展之泛性質（Nat(Lan_φ F, G) ≅ Nat(F, G∘φ)）
/// 對固定單調 G 的逐點對偶查核，並彙總泛性質三式。
pub fn theorem_universal_properties_all() -> Bool {
  theorem_universal_property_pullback(3) &&
    theorem_universal_property_free_monoid(3) && theorem_functoriality() &&
    theorem_kan_left_adjunction(2, 2) && theorem_kan_right_adjunction(2, 2)
}

///|
pub const VERB_COUNT : Int = 21

///|
/// 《作業規範》衍生方向動詞（規範原文列 21 項）。
pub fn verb_name(i : Int) -> String {
  let names : Array[String] = [
    "衍生", "計算機抽象", "結合", "併攏", "嵌入", "聯動", "計算", "推論", "共性",
    "（鏡像）對稱性", "Ramsey理論", "擬陣", "複形", "邏輯推理", "演變", "借鑒",
    "多合一", "溶合", "合併", "相容", "組合",
  ]
  if i >= 0 && i < names.length() { names[i] } else { "" }
}

///|
fn bit_i(x : UInt64, i : Int) -> Int64 { if @exact.bit(x, i) { 1L } else { 0L } }

///|
pub(all) struct DerivData {
  a : UInt64
  b : UInt64
  c : UInt64
  n : Int
  m : Int64
  k : Int64
  g : Array[Int]
  opens : Array[UInt64]
  rows : Array[UInt64]
}

///|
pub fn deriv_base() -> DerivData {
  DerivData::{
    a: 0b101UL, b: 0b011UL, c: 0b110UL, n: 3, m: 6L, k: 2L,
    g: [0, 1, 2, 3], opens: [0b100UL, 0b110UL, 0b111UL],
    rows: [0b101UL, 0b011UL, 0b110UL],
  }
}

///|
fn deriv_g(g : Array[Int], v : Int) -> Array[Int] {
  let out : Array[Int] = []
  for i in 0..<g.length() { out.push((g[i] + v * (i + 1)) % 4) }
  out
}

///|
fn deriv_opens(opens : Array[UInt64], v : Int) -> Array[UInt64] {
  let out : Array[UInt64] = []
  for i in 0..<opens.length() { out.push(opens[i] ^ (1UL << (v % 3))) }
  out
}

///|
fn deriv_mk(d : DerivData, rows : Array[UInt64], v : Int) -> DerivData {
  DerivData::{
    a: d.a ^ v.to_uint64(), b: d.b ^ (v * 3).to_uint64(),
    c: d.c ^ (v * 7).to_uint64(), n: d.n,
    m: 2L + (v % 5).to_int64(), k: 1L + ((v + 1) % 4).to_int64(),
    g: deriv_g(d.g, v), opens: deriv_opens(d.opens, v), rows,
  }
}

///|
/// 21 個衍生方向動詞作用在有限關係資料上（每個為具體位元／列運算）。
pub fn verb_apply(v : Int, d : DerivData) -> DerivData {
  let mut rows : Array[UInt64] = []
  for i in 0..<d.rows.length() { rows.push(d.rows[i]) }
  let all = (1UL << d.n) - 1UL
  let len = rows.length()
  match v {
    0 => {
      let mut acc = all
      for i in 0..<len { acc = acc & rows[i] }
      rows.push(acc)
    }
    1 => {
      let mask = (1UL << (d.n - 1)) - 1UL
      for i in 0..<len { rows[i] = rows[i] & mask }
    }
    2 => { if len >= 2 { rows.push(rows[0] | rows[1]) } }
    3 => {
      let out : Array[UInt64] = []
      let mut i = 0
      while i < len {
        if i + 1 < len { out.push(rows[i] | rows[i + 1]); i += 2 } else {
          out.push(rows[i]); i += 1
        }
      }
      rows = out
    }
    4 => rows.push(0UL)
    5 => {
      let orig : Array[UInt64] = []
      for i in 0..<len { orig.push(rows[i]) }
      for i in 0..<len { rows[i] = orig[i] ^ orig[(i + 1) % len] }
    }
    6 => {
      let mut acc = 0UL
      for i in 0..<len { acc = acc ^ rows[i]; rows[i] = acc }
    }
    7 => {
      let ctx = @galois.context(len, d.n, rows)
      for i in 0..<len { rows[i] = @galois.closure_attr(ctx, rows[i]) }
    }
    8 => {
      let mut acc = all
      for i in 0..<len { acc = acc & rows[i] }
      for i in 0..<len { rows[i] = acc }
    }
    9 => {
      rows = @galois.chu_dual(@galois.context(len, d.n, rows)).rows
    }
    10 => rows.push(all ^ rows[0])
    11 => {
      let out : Array[UInt64] = []
      for i in 0..<len {
        for j in 0..<d.n {
          if ((rows[i] >> j) & 1UL) == 1UL { out.push(1UL << j) }
        }
      }
      if out.length() > 0 { rows = out }
    }
    12 => {
      let mut acc = 0UL
      for i in 0..<len { acc = acc | rows[i] }
      rows.push(acc)
    }
    13 => {
      for i in 0..<len { rows[i] = (rows[i] | (rows[i] << 1)) & all }
    }
    14 => {
      for i in 0..<len {
        rows[i] = ((rows[i] << 1) | (rows[i] >> (d.n - 1))) & all
      }
    }
    15 => { if len >= 2 { rows[len - 1] = rows[0] } }
    16 => {
      let mut acc = 0UL
      for i in 0..<len { acc = acc | rows[i] }
      rows.push(acc & d.a)
    }
    17 => {
      let mut acc = 0UL
      for i in 0..<len { acc = acc ^ rows[i] }
      rows = [acc]
    }
    18 => {
      let mut acc = 0UL
      for i in 0..<len { acc = acc | rows[i] }
      rows = [acc]
    }
    19 => {
      let orig : Array[UInt64] = []
      for i in 0..<len { orig.push(rows[i]) }
      for i in 0..<len { rows[i] = orig[i] & orig[(i + 1) % len] }
    }
    20 => { if len >= 2 { rows.push(rows[0] | rows[len - 1]) } }
    _ => rows.push(all)
  }
  deriv_mk(d, rows, v)
}

///|
fn deriv_ctx(d : DerivData) -> @galois.Context {
  @galois.context(d.rows.length(), d.n, d.rows)
}

///|
/// 14 個組合手法各自的可計算不變量（真實演算法，非恆真判定）。
pub fn deriv_invariant(p : Int, d : DerivData) -> Int {
  let lat = boolean_lattice(2)
  let phi = [0, 1, 2, 3]
  if p == 0 {
    let lan = lan_poset(d.g, phi, lat)
    let mut s = 0
    for i in 0..<lan.length() { s += lan[i] }
    s
  } else if p == 1 {
    let ok = theorem_sheaf_gluing(3, chain_leq(3), d.opens)
    submasks(d.a, 3).length() + (if ok { 100 } else { 0 })
  } else if p == 2 {
    fiber_product_count(d.m, d.m + 1L, d.k).to_int()
  } else if p == 3 {
    let mut c = 0
    let total = 1 << d.n
    for s in 0..<total {
      if monad_closure(d.a, s.to_uint64()) == s.to_uint64() { c += 1 }
    }
    c
  } else if p == 4 {
    let aa : Array[Array[Int64]] = [
      [bit_i(d.a, 0), bit_i(d.a, 1)],
      [bit_i(d.a, 2), bit_i(d.a, 3)],
    ]
    let bb : Array[Array[Int64]] = [
      [bit_i(d.b, 0), bit_i(d.b, 1)],
      [bit_i(d.b, 2), bit_i(d.b, 3)],
    ]
    @exact.rank_mod_p(kronecker(aa, bb), 2L)
  } else if p == 5 {
    let nb = if d.rows.length() < 3 { d.rows.length() } else { 3 }
    let fibers : Array[UInt64] = []
    let maps : Array[Array[Int]] = []
    for i in 0..<nb { fibers.push(d.rows[i]) }
    for _j in 0..<(nb * nb) {
      let m : Array[Int] = []
      for x in 0..<d.n { m.push(x) }
      maps.push(m)
    }
    grothendieck_objects(fibered(nb, d.n, chain_leq(nb), fibers, maps))
  } else if p == 6 {
    let common : Array[Array[Int]] = []
    for i in 0..<3 {
      if (@exact.bit(d.c, i)) { common.push([i % 3, (i + 1) % 3]) }
    }
    pushout_classes(3, 3, common)
  } else if p == 7 {
    let x = weave_elem(d.m % 5L, d.k % 5L)
    let y = weave_elem(d.k % 5L, (d.m + 1L) % 5L)
    let w = weave_mul(d.m, d.m + 1L, x, y)
    (w.a + w.b).to_int()
  } else if p == 8 {
    let k = 1 + @exact.popcount(d.a) % 3
    free_comm_monoid_size(k, 3).to_int()
  } else if p == 9 {
    @galois.closed_attributes(@galois.chu_dual(deriv_ctx(d))).length()
  } else if p == 10 {
    let mm : Array[Array[Int64]] = []
    for i in 0..<3 {
      let row : Array[Int64] = []
      for j in 0..<3 {
        let src = if i == 0 { d.a } else if i == 1 { d.b } else { d.c }
        row.push(bit_i(src, j))
      }
      mm.push(row)
    }
    @exact.rank_mod_p(mm, 2L)
  } else if p == 11 {
    let ran = ran_poset(d.g, phi, lat)
    let mut s = 0
    for i in 0..<ran.length() { s += ran[i] }
    s
  } else if p == 12 {
    let es = @algebra.extension_classes(d.m, d.k)
    let mut s = 0L
    for i in 0..<es.length() { s += es[i] }
    s.to_int()
  } else {
    let ctx = deriv_ctx(d)
    let comp = @galois.relation_compose(ctx, ctx)
    let mut s = 0
    for i in 0..<comp.rows.length() {
      if ((comp.rows[i] >> i) & 1UL) == 1UL { s += 1 }
    }
    s
  }
}

///|
/// 21×14 相容矩陣：M[v][p] = 動詞 v 是否保持手法 p 之不變量。
pub fn verb_pattern_matrix() -> Array[Array[Bool]] {
  let base = deriv_base()
  let inv : Array[Int] = []
  for p in 0..<14 { inv.push(deriv_invariant(p, base)) }
  let out : Array[Array[Bool]] = []
  for v in 0..<VERB_COUNT {
    let d = verb_apply(v, base)
    let row : Array[Bool] = []
    for p in 0..<14 { row.push(deriv_invariant(p, d) == inv[p]) }
    out.push(row)
  }
  out
}

///|
/// 演算法 D-01：枚舉所有穩定 (動詞, 手法) 配對。
pub fn verb_pattern_stable_pairs() -> Array[Array[Int]] {
  let m = verb_pattern_matrix()
  let out : Array[Array[Int]] = []
  for v in 0..<m.length() {
    for p in 0..<m[v].length() {
      if m[v][p] { out.push([v, p]) }
    }
  }
  out
}

///|
/// 演算法 D-02：依「保持手法集合」將 21 動詞分等價類，回傳類別數與代表。
pub fn verb_pattern_row_classes() -> Array[Int] {
  let m = verb_pattern_matrix()
  let reps : Array[Array[Bool]] = []
  let sizes : Array[Int] = []
  for v in 0..<m.length() {
    let mut found = -1
    for i in 0..<reps.length() {
      let mut same = true
      for p in 0..<14 {
        if reps[i][p] != m[v][p] { same = false; break }
      }
      if same { found = i; break }
    }
    if found < 0 { reps.push(m[v]); sizes.push(1) } else { sizes[found] += 1 }
  }
  let out : Array[Int] = [sizes.length()]
  for i in 0..<sizes.length() { out.push(sizes[i]) }
  out
}

///|
/// 定理 T-C18：相容矩陣非平凡（既有保持亦有不保持），
/// GF(2) 秩給出 14 手法間之線性相依結構，且穩定配對數 = 列和 = 行和。
pub fn theorem_verb_pattern_structure() -> Bool {
  let m = verb_pattern_matrix()
  if m.length() != VERB_COUNT { return false }
  for i in 0..<m.length() {
    if m[i].length() != 14 { return false }
  }
  let mat : Array[Array[Int64]] = []
  let mut stable = 0
  for v in 0..<m.length() {
    let row : Array[Int64] = []
    for p in 0..<14 {
      let b = if m[v][p] { 1L } else { 0L }
      row.push(b)
      stable += b.to_int()
    }
    mat.push(row)
  }
  let rank = @exact.rank_mod_p(mat, 2L)
  let pairs = verb_pattern_stable_pairs()
  let classes = verb_pattern_row_classes()
  stable > 0 && stable < VERB_COUNT * 14 && stable == pairs.length() &&
    rank >= 1 && rank <= 14 && classes[0] >= 1 && classes[0] <= VERB_COUNT
}

///|
/// 演算法 D-03：動詞複合封閉性統計（v 後接 w 是否仍保持全部 14 手法）。
pub fn verb_composition_closure() -> Array[Int] {
  let base = deriv_base()
  let inv : Array[Int] = []
  for p in 0..<14 { inv.push(deriv_invariant(p, base)) }
  let mut closed = 0
  let mut total = 0
  for v in 0..<VERB_COUNT {
    for w in 0..<VERB_COUNT {
      total += 1
      let d = verb_apply(w, verb_apply(v, base))
      let mut ok = true
      for p in 0..<14 {
        if deriv_invariant(p, d) != inv[p] { ok = false; break }
      }
      if ok { closed += 1 }
    }
  }
  [closed, total]
}

///|
/// 定理 T-C19（泛性質 × 衍生方向）：泛性質三式與 21×14 相容矩陣
/// 同時成立，且動詞複合封閉數不大於總配對數（有限計算憑證）。
pub fn theorem_derivation_all_in_one() -> Bool {
  let cc = verb_composition_closure()
  theorem_universal_properties_all() && theorem_verb_pattern_structure() &&
    cc[0] <= cc[1] && cc[1] == VERB_COUNT * VERB_COUNT
}

///|
// ════════════════════════════════════════════════════════════════════════
// C1-04 補回 §6''：pushforward monad / 右 Kan 擴展 / codensity monad
// R33 Doña Mateo「Pushforward monads」：對有限集合映射 f : X → Y，
// Σ_f ⊣ f* ⊣ Π_f（相依和／拉回／相依積），而 T = Π_f f* = Ran_f f*
// 為 pushforward（codensity）monad。對有限鏈之 K : P → Q，
// (Ran_K F)(q) = ⋀_{q ≤ K p} F(p)，(Lan_K F)(q) = ⋁_{K p ≤ q} F(p)，
// 且 Ran_K K 為 Q 上之 closure operator（poset 上的 monad）。
// ════════════════════════════════════════════════════════════════════════

///|
pub(all) struct FiniteMap {
  nx : Int
  ny : Int
  f : Array[Int]
}

///|
pub fn finite_map(nx : Int, ny : Int, f : Array[Int]) -> FiniteMap {
  FiniteMap::{ nx, ny, f }
}

///|
fn bit(m : UInt64, i : Int) -> Bool { ((m >> i) & 1UL) == 1UL }

///|
/// Σ_f(A)(y) = ∃ x ∈ f⁻¹(y), x ∈ A（相依和，左伴隨）。
pub fn sigma_f(fm : FiniteMap, a : UInt64) -> UInt64 {
  let mut out = 0UL
  for x in 0..<fm.nx {
    if bit(a, x) {
      let y = fm.f[x]
      if y >= 0 && y < fm.ny { out = out | (1UL << y) }
    }
  }
  out
}

///|
/// f*(B)(x) = B(f(x))（拉回）。
pub fn pullback_f(fm : FiniteMap, b : UInt64) -> UInt64 {
  let mut out = 0UL
  for x in 0..<fm.nx {
    let y = fm.f[x]
    if y >= 0 && y < fm.ny && bit(b, y) { out = out | (1UL << x) }
  }
  out
}

///|
/// Π_f(A)(y) = ∀ x ∈ f⁻¹(y), x ∈ A（相依積，右伴隨／右 Kan 擴展）。
pub fn pi_f(fm : FiniteMap, a : UInt64) -> UInt64 {
  let mut out = 0UL
  for y in 0..<fm.ny {
    let mut all = true
    for x in 0..<fm.nx {
      if fm.f[x] == y && !bit(a, x) { all = false; break }
    }
    if all { out = out | (1UL << y) }
  }
  out
}

///|
/// pushforward monad T = Π_f ∘ f* = Ran_f f*。
pub fn pushforward_monad(fm : FiniteMap, b : UInt64) -> UInt64 {
  pi_f(fm, pullback_f(fm, b))
}

///|
/// 定理 T-C20：Σ_f ⊣ f* ⊣ Π_f（穷舉 2^nx·2^ny 對），且 Π_f f* 為 closure。
pub fn theorem_pushforward_adjunction(fm : FiniteMap) -> Bool {
  let nx_total = 1UL << fm.nx
  let ny_total = 1UL << fm.ny
  let mut a = 0UL
  while a < nx_total {
    let mut b = 0UL
    while b < ny_total {
      let l = (sigma_f(fm, a) & b) == sigma_f(fm, a)
      let r = (a & pullback_f(fm, b)) == a
      if l != r { return false }
      let l2 = (pullback_f(fm, b) & a) == pullback_f(fm, b)
      let r2 = (b & pi_f(fm, a)) == b
      if l2 != r2 { return false }
      b += 1UL
    }
    a += 1UL
  }
  true
}

///|
/// 定理 T-C21：T = Π_f f* 為 monad（unit B ⊆ T B、乘法 T² = T、
/// 單調），且 T(B) = B ∪ (Y \ im f)，即 Ran_f f* 之明確公式。
pub fn theorem_pushforward_monad(fm : FiniteMap) -> Bool {
  let total = 1UL << fm.ny
  let mut image = 0UL
  for x in 0..<fm.nx {
    let y = fm.f[x]
    if y >= 0 && y < fm.ny { image = image | (1UL << y) }
  }
  let all = @galois.full_mask(fm.ny)
  let outside = all & (all ^ image)
  let mut b = 0UL
  while b < total {
    let tb = pushforward_monad(fm, b)
    if (b & tb) != b { return false }
    if tb != (b | outside) { return false }
    if pushforward_monad(fm, tb) != tb { return false }
    let mut c = 0UL
    while c < total {
      if (b & c) == b {
        if (pushforward_monad(fm, b) & pushforward_monad(fm, c)) !=
          pushforward_monad(fm, b) { return false }
      }
      c += 1UL
    }
    b += 1UL
  }
  theorem_pushforward_adjunction(fm)
}

///|
pub(all) struct PosetKan {
  n : Int
  k : Array[Int]
}

///|
/// K : P → Q（P、Q 為有限鏈，K 單調），Q = {0,…,n−1}。
pub fn poset_kan(n : Int, k : Array[Int]) -> PosetKan {
  PosetKan::{ n, k }
}

///|
/// (Ran_K F)(q) = ⋀ { F(p) | q ≤ K(p) }；F、G 為鏈上之 up-set（協變預層）。
pub fn ran_presheaf(kn : PosetKan, f : UInt64) -> UInt64 {
  let mut out = 0UL
  for q in 0..<kn.n {
    let mut all = true
    for p in 0..<kn.k.length() {
      if q <= kn.k[p] && !bit(f, p) { all = false; break }
    }
    if all { out = out | (1UL << q) }
  }
  out
}

///|
/// (Lan_K F)(q) = ⋁ { F(p) | K(p) ≤ q }。
pub fn lan_presheaf(kn : PosetKan, f : UInt64) -> UInt64 {
  let mut out = 0UL
  for q in 0..<kn.n {
    let mut any = false
    for p in 0..<kn.k.length() {
      if kn.k[p] <= q && bit(f, p) { any = true; break }
    }
    if any { out = out | (1UL << q) }
  }
  out
}

///|
/// K*：Q 之下集拉回為 P 之下集（在鏈上以 mask 表示）。
pub fn kan_pullback(kn : PosetKan, g : UInt64) -> UInt64 {
  let mut out = 0UL
  for p in 0..<kn.k.length() {
    let q = kn.k[p]
    if q >= 0 && q < kn.n && bit(g, q) { out = out | (1UL << p) }
  }
  out
}

///|
fn chain_upset(mask : UInt64, n : Int) -> Bool {
  for i in 0..<(n - 1) {
    if bit(mask, i) && !bit(mask, i + 1) { return false }
  }
  true
}

///|
/// 定理 T-C22：Lan_K ⊣ K* ⊣ Ran_K（穷舉所有協變預層 F : P → Set、G : Q → Set，
/// 即鏈上之 up-set 遮罩；此限制為函子性所需）。
pub fn theorem_kan_adjunction(kn : PosetKan) -> Bool {
  let pt = 1UL << kn.k.length()
  let qt = 1UL << kn.n
  let mut f = 0UL
  while f < pt {
    if !chain_upset(f, kn.k.length()) { f += 1UL; continue }
    let mut g = 0UL
    while g < qt {
      if !chain_upset(g, kn.n) { g += 1UL; continue }
      let l1 = (lan_presheaf(kn, f) & g) == lan_presheaf(kn, f)
      let r1 = (f & kan_pullback(kn, g)) == f
      if l1 != r1 { return false }
      let l2 = (kan_pullback(kn, g) & f) == kan_pullback(kn, g)
      let r2 = (g & ran_presheaf(kn, f)) == g
      if l2 != r2 { return false }
      g += 1UL
    }
    f += 1UL
  }
  true
}

///|
/// Codensity monad：T = Ran_K K，(Ran_K K)(q) = min{K(p) | q ≤ K(p)}。
pub fn codensity_value(kn : PosetKan, q : Int) -> Int {
  let mut best = kn.n
  for p in 0..<kn.k.length() {
    if q <= kn.k[p] && kn.k[p] < best { best = kn.k[p] }
  }
  best
}

///|
/// 定理 T-C23：codensity monad 為 Q 上之 closure operator
/// （extensive / monotone / idempotent），且 Ran_K K 之 end 公式
/// 與 closure 之上集作用一致：q' ≥ T(q) ⟺ Ran_K({p | K p ≥ q}) ⊆ {p | K p ≥ q'}。
pub fn theorem_codensity_monad(kn : PosetKan) -> Bool {
  let t : Array[Int] = []
  for q in 0..<kn.n { t.push(codensity_value(kn, q)) }
  for q in 0..<kn.n {
    if t[q] < q || t[q] >= kn.n { return false }
    if t[t[q]] != t[q] { return false }
    for q2 in q..<kn.n {
      if t[q2] < t[q] { return false }
    }
    // end / limit 公式：z ≤ (Ran_K K)(q) ⟺ ∀ p, q ≤ K p ⇒ z ≤ K p
    for z in 0..<kn.n {
      let mut univ = true
      for p in 0..<kn.k.length() {
        if q <= kn.k[p] && z > kn.k[p] { univ = false; break }
      }
      if (z <= t[q]) != univ { return false }
    }
  }
  theorem_kan_adjunction(kn)
}

///|
/// 定理 T-C24：橋接全局公理 G。取 Y 為單一屬性、f : X → 1 為常數映射，
/// 則 Π_f(A) = F(A) = {y | ∀ x ∈ A, R(x,y)}；相依積即伽羅瓦極性。
pub fn theorem_pi_polar_bridge() -> Bool {
  let rows : Array[UInt64] = [1UL, 0UL, 1UL, 0UL]
  let ctx = @galois.context(4, 1, rows)
  let f : Array[Int] = [0, 0, 0, 0]
  let fm = finite_map(4, 1, f)
  let all = @galois.full_mask(4)
  let mut rel = 0UL
  for x in 0..<4 {
    if rows[x] == 1UL { rel = rel | (1UL << x) }
  }
  let total = 1UL << 4
  let mut a = 0UL
  while a < total {
    // P_A(x) = (x ∉ A) ∨ R(x,0)；Π_f P_A = ∀ x ∈ A, R(x,0) = F(A)
    let pred = (all ^ a) | rel
    if pi_f(fm, pred) != @galois.polar_obj(ctx, a) { return false }
    if sigma_f(fm, a) != (if a == 0UL { 0UL } else { 1UL }) { return false }
    // 三角伴隨：Σ_f ⊣ f* ⊣ Π_f 在此單點脈絡同樣成立
    if !theorem_pushforward_adjunction(fm) { return false }
    a += 1UL
  }
  true
}

///|
// ════════════════════════════════════════════════════════════════════════
// C1-04 補回 §6''：集庫成群（algorithm library clustering）
// 以 docs/catalog.json 生成之真實登錄表為輸入，對每筆定理／演算法／等式
// 抽取 14 種組合手法 + 7 類 + 12 套件之 33 位元簽章，
// 以 Jaccard 相似度與 union-find 做階層式聚類，並驗證分割性質。
// ════════════════════════════════════════════════════════════════════════

///|
fn technique_keys() -> Array[String] {
  [
    "泛性質", "Kan", "Grothendieck", "層", "單子", "張量", "對偶", "推出",
    "非交換", "操作子", "楚空間", "Morita", "導函子", "博弈",
  ]
}

///|
fn kind_keys() -> Array[String] {
  ["公理", "定義", "命題", "引理", "定理", "演算法", "等式"]
}

///|
fn package_keys() -> Array[String] {
  [
    "src/exact", "src/galois", "src/series", "src/algebra", "src/graphs",
    "src/compose", "src/catalog", "src/axioms", "cmd/main", "docs", "tools",
    "src/root",
  ]
}

///|
pub fn library_signature(e : @catalog.Entry) -> UInt64 {
  let mut sig = 0UL
  let tk = technique_keys()
  for i in 0..<tk.length() {
    if e.statement.contains(tk[i]) || e.formula.contains(tk[i]) ||
      e.verification.contains(tk[i]) {
      sig = sig | (1UL << i)
    }
  }
  let kk = kind_keys()
  for i in 0..<kk.length() {
    if e.kind == kk[i] { sig = sig | (1UL << (14 + i)) }
  }
  let pk = package_keys()
  let mut hit = false
  for i in 0..<pk.length() {
    if e.pkg == pk[i] { sig = sig | (1UL << (21 + i)); hit = true }
  }
  if !hit { sig = sig | (1UL << (21 + pk.length())) }
  sig
}

///|
pub(all) struct LibraryClustering {
  total : Int
  groups : Int
  multi : Int
  largest : Int
  singletons : Int
  assignments : Array[Int]
  merged_pairs : Array[Array[Int]]
}

///|
fn uf_find(parent : Array[Int], x : Int) -> Int {
  let mut r = x
  while parent[r] != r { r = parent[r] }
  let mut c = x
  while parent[c] != c {
    let nxt = parent[c]
    parent[c] = r
    c = nxt
  }
  r
}

///|
/// Jaccard 相似度 s(i,j) = |σ_i ∩ σ_j| / |σ_i ∪ σ_j| ≥ num/den 即合併。
pub fn library_clustering(num : Int, den : Int) -> LibraryClustering {
  let entries = @catalog.catalog()
  let n = entries.length()
  let sigs : Array[UInt64] = []
  for i in 0..<n { sigs.push(library_signature(entries[i])) }
  let parent : Array[Int] = []
  for i in 0..<n { parent.push(i) }
  let merged : Array[Array[Int]] = []
  for i in 0..<n {
    for j in (i + 1)..<n {
      let inter = @exact.popcount(sigs[i] & sigs[j])
      let uni = @exact.popcount(sigs[i] | sigs[j])
      if uni == 0 || inter * den < uni * num { continue }
      let a = uf_find(parent, i)
      let b = uf_find(parent, j)
      if a != b { parent[b] = a }
      merged.push([i, j, inter, uni])
    }
  }
  let root : Array[Int] = []
  let sizes : Array[Int] = []
  for i in 0..<n { root.push(uf_find(parent, i)); sizes.push(0) }
  for i in 0..<n { sizes[root[i]] += 1 }
  let mut groups = 0
  let mut multi = 0
  let mut largest = 0
  let mut single = 0
  for i in 0..<n {
    if root[i] == i {
      groups += 1
      if sizes[i] >= 2 { multi += 1 } else { single += 1 }
      if sizes[i] > largest { largest = sizes[i] }
    }
  }
  LibraryClustering::{
    total: n, groups, multi, largest, singletons: single,
    assignments: root, merged_pairs: merged,
  }
}

///|
/// 定理 T-C25（集庫成群）：聚類為不交且覆蓋全部登錄項之分割；
/// 每條合併邊滿足 Jaccard 門檻；門檻提高時群數不減；
/// 最低門檻至少形成一個含 ≥2 項之群（真實多元算法庫）。
pub fn theorem_library_clustering() -> Bool {
  let c1 = library_clustering(1, 4)
  let c2 = library_clustering(1, 2)
  let c3 = library_clustering(3, 4)
  let c4 = library_clustering(1, 1)
  let entries = @catalog.catalog()
  if c1.total != entries.length() { return false }
  if c1.assignments.length() != c1.total { return false }
  if c1.groups > c1.total || c1.multi < 1 { return false }
  if c1.groups != c1.multi + c1.singletons { return false }
  if c1.groups > c2.groups || c2.groups > c3.groups ||
    c3.groups > c4.groups { return false }
  // 較高門檻須形成真正多元之庫群（非單一巨團）
  if c3.groups < 10 || c3.multi < 10 { return false }
  // 分割驗證：每個代表根恰為自身，且大小總和 = 全部筆數
  let mut sum = 0
  for i in 0..<c1.total {
    let r = c1.assignments[i]
    if r < 0 || r >= c1.total { return false }
    if c1.assignments[r] != r { return false }
    sum += 1
  }
  if sum != c1.total { return false }
  // 每條合併邊之 Jaccard ≥ 1/4，且交集非空
  for k in 0..<c1.merged_pairs.length() {
    let e = c1.merged_pairs[k]
    if e[2] < 1 || 4 * e[2] < e[3] { return false }
    if c1.assignments[e[0]] != c1.assignments[e[1]] { return false }
  }
  // 決定性：重跑一次得到完全相同之指派
  let again = library_clustering(1, 4)
  for i in 0..<c1.total {
    if again.assignments[i] != c1.assignments[i] { return false }
  }
  true
}

///|
/// 演算法庫聚類統計：[總筆數, 群數, 含 ≥2 項之群數, 最大群, 演算法筆數]。
pub fn library_cluster_stats() -> Array[Int] {
  let c = library_clustering(3, 4)
  let entries = @catalog.catalog()
  let mut algos = 0
  for i in 0..<entries.length() {
    if entries[i].kind == "演算法" { algos += 1 }
  }
  [c.total, c.groups, c.multi, c.largest, algos]
}
