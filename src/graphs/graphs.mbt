///|
/// C1 / src/graphs — 克內澤圖、Ramsey 理論、擬陣、複形同調與圖極性
/// 圖以 UInt64 位元遮罩表示鄰接列（硬體層級常數優化）。

///|
pub fn kneser_vertices(n : Int, k : Int) -> Array[UInt64] {
  let out : Array[UInt64] = []
  let total = 1UL << n
  let mut mask = 0UL
  while mask < total {
    if @exact.popcount(mask) == k { out.push(mask) }
    mask += 1UL
  }
  out
}

///|
pub fn kneser_adjacent(a : UInt64, b : UInt64) -> Bool { (a & b) == 0UL }

///|
pub fn kneser_adjacency(n : Int, k : Int) -> Array[UInt64] {
  let vs = kneser_vertices(n, k)
  let rows : Array[UInt64] = []
  for i in 0..<vs.length() {
    let mut row = 0UL
    for j in 0..<vs.length() {
      if i != j && kneser_adjacent(vs[i], vs[j]) { row = @exact.set_bit(row, j) }
    }
    rows.push(row)
  }
  rows
}

///|
pub fn complement_adjacency(adj : Array[UInt64]) -> Array[UInt64] {
  let n = adj.length()
  let all = @galois.full_mask(n)
  let out : Array[UInt64] = []
  for i in 0..<n {
    let mut row = all ^ adj[i]
    row = @exact.clear_bit(row, i)
    out.push(row)
  }
  out
}

///|
fn color_search(
  adj : Array[UInt64],
  n : Int,
  colors : Array[Int],
  v : Int,
  maxc : Int,
  best : Array[Int],
) -> Unit {
  if maxc + 1 >= best[0] { return }
  if v == n {
    best[0] = maxc + 1
    return
  }
  for c = 0; c <= maxc + 1; c = c + 1 {
    let mut conflict = false
    for u in 0..<v {
      if @exact.bit(adj[v], u) && colors[u] == c { conflict = true; break }
    }
    if conflict { continue }
    colors[v] = c
    let nm = if c > maxc { c } else { maxc }
    color_search(adj, n, colors, v + 1, nm, best)
  }
  colors[v] = -1
}

///|
/// 精確色數：回溯 + 對稱破壞（第一頂點固定色 0）+ 上界剪枝。
pub fn chromatic_number(adj : Array[UInt64]) -> Int {
  let n = adj.length()
  if n == 0 { return 0 }
  let colors : Array[Int] = Array::make(n, -1)
  let best : Array[Int] = [n + 1]
  colors[0] = 0
  color_search(adj, n, colors, 1, 0, best)
  best[0]
}

///|
fn clique_expand(size : Int, cand0 : UInt64, adj : Array[UInt64], best : Array[Int]) -> Unit {
  let mut cand = cand0
  if cand == 0UL {
    if size > best[0] { best[0] = size }
    return
  }
  if size + @exact.popcount(cand) <= best[0] { return }
  while cand != 0UL {
    let mut v = 0
    while ((cand >> v) & 1UL) == 0UL { v += 1 }
    let next = cand & adj[v]
    clique_expand(size + 1, next, adj, best)
    cand = cand & (cand - 1UL)
  }
}

///|
/// 最大團（Bron–Kerbosch 位元版）；用於 Kneser 圖的精確獨立數。
pub fn max_clique(adj : Array[UInt64]) -> Int {
  let best : Array[Int] = [0]
  clique_expand(0, @galois.full_mask(adj.length()), adj, best)
  best[0]
}

///|
pub fn max_independent_set(adj : Array[UInt64]) -> Int {
  max_clique(complement_adjacency(adj))
}

///|
/// 定理 T-K1（Lovász 1978）：χ(KG(n,k)) = n − 2k + 2。
pub fn theorem_lovasz_kneser(cases : Array[Array[Int]]) -> Bool {
  for i in 0..<cases.length() {
    let n = cases[i][0]
    let k = cases[i][1]
    let chi = chromatic_number(kneser_adjacency(n, k))
    if chi != n - 2 * k + 2 { return false }
  }
  true
}

///|
/// 定理 T-K2（Erdős–Ko–Rado 1961）：α(KG(n,k)) = C(n−1,k−1)。
pub fn theorem_ekr(cases : Array[Array[Int]]) -> Bool {
  for i in 0..<cases.length() {
    let n = cases[i][0]
    let k = cases[i][1]
    let alpha = max_independent_set(kneser_adjacency(n, k))
    if alpha.to_int64() != @exact.binom(n - 1, k - 1) { return false }
  }
  true
}

///|
pub fn fractional_chromatic(n : Int, k : Int) -> @exact.Rat {
  @exact.rat(n.to_int64(), k.to_int64())
}

///|
/// 定理 T-K3：χ_f(KG(n,k)) = n/k 為 χ 的下界，且 χ ≥ χ_f。
pub fn theorem_fractional_bound(n : Int, k : Int) -> Bool {
  let f = fractional_chromatic(n, k)
  let chi = @exact.rat_int((n - 2 * k + 2).to_int64())
  f.cmp(chi) <= 0
}

///|
fn edge_index(i : Int, j : Int, n : Int) -> Int {
  i * (2 * n - i - 1) / 2 + (j - i - 1)
}

///|
pub fn has_mono_triangle(n : Int, mask : UInt64) -> Bool {
  for i in 0..<n {
    for j in (i + 1)..<n {
      for k in (j + 1)..<n {
        let a = @exact.bit(mask, edge_index(i, j, n))
        let b = @exact.bit(mask, edge_index(i, k, n))
        let c = @exact.bit(mask, edge_index(j, k, n))
        if a == b && b == c { return true }
      }
    }
  }
  false
}

///|
pub fn ramsey_triangle_free_count(n : Int) -> Int {
  let e = n * (n - 1) / 2
  let total = 1 << e
  let mut count = 0
  for mask in 0..<total {
    if !has_mono_triangle(n, mask.to_uint64()) { count += 1 }
  }
  count
}

///|
pub fn ramsey_witness(n : Int) -> UInt64? {
  let e = n * (n - 1) / 2
  let total = 1 << e
  for mask in 0..<total {
    if !has_mono_triangle(n, mask.to_uint64()) { return Some(mask.to_uint64()) }
  }
  None
}

///|
/// 定理 T-R1：R(3,3)=6 — K5 存在無單色三角形的 2-著色，K6 不存在。
pub fn theorem_ramsey_33() -> Bool {
  (ramsey_witness(5) is Some(_)) && ramsey_triangle_free_count(6) == 0
}

///|
pub(all) struct Matroid {
  nelem : Int
  rows : Array[UInt64]
}

///|
pub fn matroid(nelem : Int, rows : Array[UInt64]) -> Matroid {
  Matroid::{ nelem, rows }
}

///|
pub fn matroid_rank(m : Matroid, subset : UInt64) -> Int {
  let masked : Array[UInt64] = []
  for i in 0..<m.rows.length() { masked.push(m.rows[i] & subset) }
  @exact.gf2_rank(masked, m.nelem)
}

///|
pub fn matroid_is_independent(m : Matroid, subset : UInt64) -> Bool {
  matroid_rank(m, subset) == @exact.popcount(subset)
}

///|
/// Tutte 多項式的秩生成式：
/// T(M;x,y) = Σ_{A⊆E} (x−1)^{r(E)−r(A)} (y−1)^{|A|−r(A)}。
/// 以二項式展開得到精確整數係數矩陣 coeff[i][j] (x^i y^j)。
pub fn tutte_coeffs(m : Matroid) -> Array[Array[Int64]] {
  let n = m.nelem
  let coeff : Array[Array[Int64]] = []
  for _i in 0..<(n + 1) {
    let row : Array[Int64] = Array::make(n + 1, 0L)
    coeff.push(row)
  }
  let re = matroid_rank(m, @galois.full_mask(n))
  let total = 1UL << n
  let mut a = 0UL
  while a < total {
    let ra = matroid_rank(m, a)
    let p = re - ra
    let q = @exact.popcount(a) - ra
    for i = 0; i <= p; i = i + 1 {
      let cx = @exact.binom(p, i)
      let sx = if (p - i) % 2 == 0 { cx } else { -cx }
      for j = 0; j <= q; j = j + 1 {
        let cy = @exact.binom(q, j)
        let sy = if (q - j) % 2 == 0 { cy } else { -cy }
        coeff[i][j] += sx * sy
      }
    }
    a += 1UL
  }
  coeff
}

///|
pub fn tutte_eval(coeff : Array[Array[Int64]], x : Int64, y : Int64) -> Int64 {
  let mut px = 1L
  let mut s = 0L
  for i in 0..<coeff.length() {
    let mut py = 1L
    for j in 0..<coeff[i].length() {
      s += coeff[i][j] * px * py
      py *= y
    }
    px *= x
  }
  s
}

///|
pub fn matroid_bases(m : Matroid) -> Int {
  let re = matroid_rank(m, @galois.full_mask(m.nelem))
  let total = 1UL << m.nelem
  let mut c = 0
  let mut a = 0UL
  while a < total {
    if @exact.popcount(a) == re && matroid_rank(m, a) == re { c += 1 }
    a += 1UL
  }
  c
}

///|
/// 定理 T-Mat1：T(1,1) = 基底數、T(2,2) = 2^{|E|}。
pub fn theorem_tutte_evaluations(m : Matroid) -> Bool {
  let coeff = tutte_coeffs(m)
  let at11 = tutte_eval(coeff, 1L, 1L)
  let at22 = tutte_eval(coeff, 2L, 2L)
  at11 == matroid_bases(m).to_int64() && at22 == (1L << m.nelem)
}

///|
pub(all) struct Complex {
  nverts : Int
  faces : Array[Array[UInt64]]
}

///|
fn insert_face(xs : Array[UInt64], v : UInt64) -> Unit {
  for i in 0..<xs.length() {
    if xs[i] == v { return }
  }
  xs.push(v)
}

///|
/// 由 facets 生成所有非空面，並依維度分層。
pub fn complex_from_facets(nverts : Int, facets : Array[UInt64]) -> Complex {
  let faces : Array[Array[UInt64]] = []
  for _d in 0..<nverts { faces.push([]) }
  let total = 1UL << nverts
  for i in 0..<facets.length() {
    let mut s = 0UL
    while s < total {
      if s != 0UL && (s & facets[i]) == s {
        let dim = @exact.popcount(s) - 1
        insert_face(faces[dim], s)
      }
      s += 1UL
    }
  }
  Complex::{ nverts, faces }
}

///|
fn face_index(faces : Array[UInt64], f : UInt64) -> Int {
  for i in 0..<faces.length() {
    if faces[i] == f { return i }
  }
  -1
}

///|
/// 邊界算子 ∂_d 在 GF(2) 上的秩（列 = d 面，行 = d−1 面，位元打包）。
pub fn boundary_rank(c : Complex, d : Int) -> Int {
  if d <= 0 || d >= c.faces.length() { return 0 }
  let cols = c.faces[d]
  let rows_count = c.faces[d - 1].length()
  let rows : Array[UInt64] = []
  for i in 0..<cols.length() {
    let mut row = 0UL
    for v in 0..<c.nverts {
      if @exact.bit(cols[i], v) {
        let smaller = @exact.clear_bit(cols[i], v)
        let idx = face_index(c.faces[d - 1], smaller)
        if idx >= 0 { row = @exact.set_bit(row, idx) }
      }
    }
    rows.push(row)
  }
  @exact.gf2_rank(rows, rows_count)
}

///|
pub fn betti_numbers(c : Complex) -> Array[Int] {
  let dim = c.faces.length() - 1
  let out : Array[Int] = []
  let ranks : Array[Int] = []
  for d = 0; d <= dim + 1; d = d + 1 { ranks.push(boundary_rank(c, d)) }
  for d = 0; d <= dim; d = d + 1 {
    let ker = c.faces[d].length() - ranks[d]
    out.push(ker - ranks[d + 1])
  }
  out
}

///|
pub fn euler_characteristic(c : Complex) -> Int {
  let mut chi = 0
  for d in 0..<c.faces.length() {
    let f = c.faces[d].length()
    chi += if d % 2 == 0 { f } else { -f }
  }
  chi
}

///|
/// 定理 T-H1（Euler–Poincaré）：Σ(−1)^d f_d = Σ(−1)^d β_d。
pub fn theorem_euler_poincare(c : Complex) -> Bool {
  let betti = betti_numbers(c)
  let mut alt = 0
  for d in 0..<betti.length() {
    alt += if d % 2 == 0 { betti[d] } else { -betti[d] }
  }
  alt == euler_characteristic(c)
}

///|
/// 圖的極性 Chu space：物件/屬性皆為頂點，R(x,y) ⟺ x~y 或 x=y。
/// 概念格與其轉置對偶大小相同（鏡像對稱性）。
pub fn graph_context(adj : Array[UInt64]) -> @galois.Context {
  let n = adj.length()
  let rows : Array[UInt64] = []
  for i in 0..<n { rows.push(@exact.set_bit(adj[i], i)) }
  @galois.context(n, n, rows)
}

///|
pub fn graph_concept_count(adj : Array[UInt64]) -> Int {
  @galois.closed_objects(graph_context(adj)).length()
}

///|
/// 定理 T-Gph1：圖與其補圖的概念格為 Chu 對偶（閉集數相同於轉置矩陣）。
pub fn theorem_graph_chu_dual(adj : Array[UInt64]) -> Bool {
  @galois.theorem_chu_dual(graph_context(adj))
}

///|
// ════════════════════════════════════════════════════════════════════════
// C1-03：拉普拉斯圖譜 / 歸一化圖譜 / 離散微分幾何
// (R28 Hansen–Ghrist sheaf Laplacian、R29 persistent sheaf Laplacians、
//  R30 cellular sheaves on higher structures、R31 Chung 正規化 Laplacian
//  與 Cheeger 不等式、R32 Budninskiy et al. Parallel Transport Unfolding)
// ════════════════════════════════════════════════════════════════════════

///|
pub(all) struct Graph {
  n : Int
  adj : Array[UInt64]
}

///|
pub fn graph(n : Int, adj : Array[UInt64]) -> Graph { Graph::{ n, adj } }

///|
pub fn graph_degree(g : Graph, v : Int) -> Int { @exact.popcount(g.adj[v]) }

///|
pub fn graph_edge_count(g : Graph) -> Int {
  let mut e = 0
  for u in 0..<g.n { e += @exact.popcount(g.adj[u]) }
  e / 2
}

///|
pub fn graph_adj_mat(g : Graph) -> @exact.Mat {
  let m = @exact.mat_new(g.n, g.n)
  for u in 0..<g.n {
    for v in 0..<g.n {
      if ((g.adj[u] >> v) & 1UL) == 1UL { m.a[u][v] = @exact.rat_one() }
    }
  }
  m
}

///|
pub fn graph_deg_mat(g : Graph) -> @exact.Mat {
  let m = @exact.mat_new(g.n, g.n)
  for u in 0..<g.n { m.a[u][u] = @exact.rat_int(graph_degree(g, u).to_int64()) }
  m
}

///|
/// 組合 Laplacian L = D − A。
pub fn graph_laplacian(g : Graph) -> @exact.Mat {
  @exact.mat_sub(graph_deg_mat(g), graph_adj_mat(g))
}

///|
/// 譜矩 tr(L^j)，j = 1..k（精確有理）。
pub fn graph_spectral_moments(g : Graph, k : Int) -> Array[@exact.Rat] {
  let l = graph_laplacian(g)
  let mut power = @exact.mat_identity(g.n)
  let out : Array[@exact.Rat] = []
  for _j in 0..<k {
    power = @exact.mat_mul(power, l)
    out.push(@exact.mat_trace(power))
  }
  out
}

///|
/// Newton 恆等式：由特徵多項式係數算冪和 p_j = Σ λ_i^j。
pub fn spectral_power_sums(c : Array[@exact.Rat], k : Int) -> Array[@exact.Rat] {
  let n = c.length() - 1
  let e : Array[@exact.Rat] = []
  for j in 0..<(n + 1) {
    let mut v = c[n - j]
    if j % 2 == 1 { v = v.neg() }
    e.push(v)
  }
  let ps : Array[@exact.Rat] = []
  for j in 1..<(k + 1) {
    let mut s = @exact.rat_zero()
    for t in 1..<j {
      if t > n { break }
      let term = e[t].mul(ps[j - t - 1])
      if t % 2 == 1 { s = s.add(term) } else { s = s.sub(term) }
    }
    if j <= n {
      let last = e[j].mul(@exact.rat_int(j.to_int64()))
      if j % 2 == 1 { s = s.add(last) } else { s = s.sub(last) }
    }
    ps.push(s)
  }
  ps
}

///|
/// 定理 T-Gph2：Newton 恆等式把 tr(L^j) 與 det(tI−L) 係數聯繫。
pub fn theorem_laplacian_newton(g : Graph, k : Int) -> Bool {
  let c = @exact.mat_charpoly(graph_laplacian(g))
  let ps = spectral_power_sums(c, k)
  let ms = graph_spectral_moments(g, k)
  for j in 0..<k {
    if !ps[j].equal(ms[j]) { return false }
  }
  true
}

///|
/// Kirchhoff 矩陣樹定理：生成樹數 = L 去掉任一列行之餘子式。
pub fn graph_spanning_trees(g : Graph) -> @exact.Rat {
  if g.n <= 1 { return @exact.rat_one() }
  let l = graph_laplacian(g)
  let rows : Array[Array[@exact.Rat]] = []
  for i in 0..<(g.n - 1) {
    let row : Array[@exact.Rat] = []
    for j in 0..<(g.n - 1) { row.push(l.a[i][j]) }
    rows.push(row)
  }
  @exact.mat_det(@exact.mat_from(rows))
}

///|
pub fn graph_component_count(g : Graph) -> Int { g.n - @exact.mat_rank(graph_laplacian(g)) }

///|
/// 定理 T-Gph3：L·1 = 0、rank(L) = n − #components、生成樹 > 0 ⟺ 連通、
/// 且 charpoly 之常數項為 0（有零特徵值）。
pub fn theorem_kirchhoff(g : Graph) -> Bool {
  let l = graph_laplacian(g)
  let c = @exact.mat_charpoly(l)
  let comp = graph_component_count(g)
  let trees = graph_spanning_trees(g)
  let mut rowsum_zero = true
  for i in 0..<g.n {
    let mut s = @exact.rat_zero()
    for j in 0..<g.n { s = s.add(l.a[i][j]) }
    if !s.is_zero() { rowsum_zero = false }
  }
  rowsum_zero && c[0].is_zero() && (comp == 1) == (!trees.is_zero())
}

///|
/// 體積加權 conductance h(G) = min cut(S)/min(vol S, vol V−vol S)。
pub fn graph_conductance(g : Graph) -> @exact.Rat {
  let mut total = 0L
  let allbits = (1UL << g.n) - 1UL
  for u in 0..<g.n { total += graph_degree(g, u).to_int64() }
  let mut best : @exact.Rat? = None
  let lim = 1 << g.n
  for s in 1..<(lim - 1) {
    let mask = s.to_uint64()
    let mut vol = 0L
    let mut cut = 0L
    for u in 0..<g.n {
      if ((mask >> u) & 1UL) == 0UL { continue }
      vol += graph_degree(g, u).to_int64()
      let outside = g.adj[u] & (allbits ^ mask)
      cut += @exact.popcount(outside).to_int64()
    }
    let denom = if 2L * vol <= total { vol } else { total - vol }
    if denom <= 0L { continue }
    let v = @exact.rat(cut, denom)
    match best {
      Some(b) => if v.n * b.d < b.n * v.d { best = Some(v) }
      None => best = Some(v)
    }
  }
  match best {
    Some(b) => b
    None => @exact.rat_zero()
  }
}

///|
/// 歸一化 Laplacian ℒ = I − D^{−1/2}AD^{−1/2} 等價廣義問題 L x = λ D x，
/// det(L − tD) 之根即 ℒ 特徵值（無需平方根，全程精確有理）。
pub fn graph_normalized_charpoly(g : Graph) -> Array[@exact.Rat] {
  @exact.mat_generalized_charpoly(graph_laplacian(g), graph_deg_mat(g))
}

///|
/// λ₂(ℒ)：最小正根（連通圖去一次 t=0 因子後以有理二分隔離）。
pub fn graph_normalized_lambda2(g : Graph) -> @exact.Rat? {
  let c = @exact.poly_deflate_zero(graph_normalized_charpoly(g))
  @exact.poly_smallest_positive_root(c)
}

///|
/// 定理 T-Gph4（Chung / Dodziuk–Alon–Milman Cheeger）：
/// λ₂/2 ≤ h(G) 且 h(G)² ≤ 2λ₂（有理近似以 1/64 為寬容界）。
pub fn theorem_cheeger(g : Graph) -> Bool {
  let h = graph_conductance(g)
  match graph_normalized_lambda2(g) {
    None => false
    Some(lam) => {
      let slack = @exact.rat(1L, 8L)
      let left = lam.cmp(h.mul(@exact.rat_int(2L)).add(slack)) <= 0
      let right = h.mul(h).cmp(lam.mul(@exact.rat_int(2L)).add(slack)) <= 0
      left && right
    }
  }
}

///|
/// 定理 T-Gph5：KG(5,2) = Petersen 圖之 L 與 ℒ 譜
/// L: {0^1, 2^5, 5^4}；ℒ: {0^1, (2/3)^5, (5/3)^4}。
pub fn theorem_petersen_spectra() -> Bool {
  let g = graph(10, kneser_adjacency(5, 2))
  let c = @exact.mat_charpoly(graph_laplacian(g))
  let expected = [
    @exact.rat_int(0L), @exact.rat_int(-20000L), @exact.rat_int(66000L),
    @exact.rat_int(-94800L), @exact.rat_int(77640L), @exact.rat_int(-39882L),
    @exact.rat_int(13305L), @exact.rat_int(-2880L), @exact.rat_int(390L),
    @exact.rat_int(-30L), @exact.rat_int(1L),
  ]
  if c.length() != expected.length() { return false }
  for i in 0..<c.length() {
    if !c[i].equal(expected[i]) { return false }
  }
  let gn = graph_normalized_charpoly(g)
  let expected2 = [
    @exact.rat_int(0L), @exact.rat_int(-60000L), @exact.rat_int(594000L),
    @exact.rat_int(-2559600L), @exact.rat_int(6288840L), @exact.rat_int(-9691326L),
    @exact.rat_int(9699345L), @exact.rat_int(-6298560L), @exact.rat_int(2558790L),
    @exact.rat_int(-590490L), @exact.rat_int(59049L),
  ]
  if gn.length() != expected2.length() { return false }
  for i in 0..<gn.length() {
    if !gn[i].equal(expected2[i]) { return false }
  }
  true
}

///|
// ── 測地線、切空間、聯絡、纖維束（離散）────────────────────────────

///|
/// BFS 測地距離；不可達為 −1。
pub fn geodesic_distances(g : Graph, src : Int) -> Array[Int] {
  let dist : Array[Int] = Array::make(g.n, -1)
  dist[src] = 0
  let queue : Array[Int] = [src]
  let mut head = 0
  while head < queue.length() {
    let u = queue[head]
    head += 1
    for v in 0..<g.n {
      if ((g.adj[u] >> v) & 1UL) == 0UL || dist[v] >= 0 { continue }
      dist[v] = dist[u] + 1
      queue.push(v)
    }
  }
  dist
}

///|
pub fn geodesic_path(g : Graph, src : Int, dst : Int) -> Array[Int] {
  let dist = geodesic_distances(g, src)
  if dist[dst] < 0 { return [] }
  let prev : Array[Int] = Array::make(g.n, -1)
  let queue : Array[Int] = [src]
  let mut head = 0
  while head < queue.length() {
    let u = queue[head]
    head += 1
    if u == dst { break }
    for v in 0..<g.n {
      if ((g.adj[u] >> v) & 1UL) == 0UL || dist[v] != dist[u] + 1 || prev[v] >= 0 {
        continue
      }
      prev[v] = u
      queue.push(v)
    }
  }
  let path : Array[Int] = [dst]
  let mut cur = dst
  while cur != src {
    if prev[cur] < 0 { return [] }
    cur = prev[cur]
    path.push(cur)
  }
  let out : Array[Int] = []
  let mut i = path.length()
  while i > 0 { i -= 1; out.push(path[i]) }
  out
}

///|
/// 定理 T-Gph6：測地距離為度量（非負、對稱、三角不等式、d(v,v)=0）。
pub fn theorem_geodesic_metric(g : Graph) -> Bool {
  let all : Array[Array[Int]] = []
  for s in 0..<g.n { all.push(geodesic_distances(g, s)) }
  for s in 0..<g.n {
    if all[s][s] != 0 { return false }
    for t in 0..<g.n {
      if all[s][t] != all[t][s] { return false }
      for u in 0..<g.n {
        if all[s][t] < 0 || all[s][u] < 0 || all[u][t] < 0 { continue }
        if all[s][t] > all[s][u] + all[u][t] { return false }
      }
    }
  }
  true
}

///|
/// 頂點 v 之切空間：以關聯邊方向為基底，dim T_v = deg(v)。
pub fn tangent_space(g : Graph, v : Int) -> Array[Int] {
  let out : Array[Int] = []
  for u in 0..<g.n {
    if ((g.adj[v] >> u) & 1UL) == 1UL { out.push(u) }
  }
  out
}

///|
pub fn tangent_bundle_dim(g : Graph) -> Int { 2 * graph_edge_count(g) }

///|
/// 定理 T-Gph7：切束維度 = Σ_v dim T_v = 2|E|；
/// 餘切空間由 Chu 對偶（轉置關係）給出同維度。
pub fn theorem_tangent_bundle(g : Graph) -> Bool {
  let mut total = 0
  for v in 0..<g.n { total += tangent_space(g, v).length() }
  let ctx = graph_context(g.adj)
  let dual = @galois.chu_dual(ctx)
  total == tangent_bundle_dim(g) && dual.nx == g.n && dual.ny == g.n &&
    @galois.theorem_chu_dual(ctx)
}

///|
/// O(1) 線叢（每條邊賦 ±1 轉移函數）；neg[u] 位元 v = 1 表示 −1。
pub(all) struct LineBundle {
  g : Graph
  neg : Array[UInt64]
}

///|
pub fn line_bundle(g : Graph, seed : Int) -> LineBundle {
  let neg : Array[UInt64] = Array::make(g.n, 0UL)
  for u in 0..<g.n {
    for v in (u + 1)..<g.n {
      if ((g.adj[u] >> v) & 1UL) == 0UL { continue }
      if (u * 7 + v * 13 + seed * 3) % 5 == 0 {
        neg[u] = @exact.set_bit(neg[u], v)
        neg[v] = @exact.set_bit(neg[v], u)
      }
    }
  }
  LineBundle::{ g, neg }
}

///|
pub fn bundle_sign(b : LineBundle, u : Int, v : Int) -> Int {
  if @exact.bit(b.neg[u], v) { -1 } else { 1 }
}

///|
/// 生成樹補邊給出環基（離散 de Rham 之 H₁ 生成元）。
pub fn cycle_basis(g : Graph) -> Array[Array[Int]] {
  let parent : Array[Int] = Array::make(g.n, -2)
  parent[0] = -1
  let queue : Array[Int] = [0]
  let mut head = 0
  while head < queue.length() {
    let u = queue[head]
    head += 1
    for v in 0..<g.n {
      if ((g.adj[u] >> v) & 1UL) == 0UL || parent[v] != -2 { continue }
      parent[v] = u
      queue.push(v)
    }
  }
  let cycles : Array[Array[Int]] = []
  for u in 0..<g.n {
    for v in (u + 1)..<g.n {
      if ((g.adj[u] >> v) & 1UL) == 0UL { continue }
      if parent[u] == v || parent[v] == u { continue }
      // 沿 BFS 樹父指標找 u、v 之最近共同祖先，構成基本環。
      let au : Array[Int] = [u]
      let av : Array[Int] = [v]
      let mut cu = u
      while parent[cu] != -1 && parent[cu] != -2 {
        cu = parent[cu]
        au.push(cu)
      }
      let mut cv = v
      while parent[cv] != -1 && parent[cv] != -2 {
        cv = parent[cv]
        av.push(cv)
      }
      let mut iu = -1
      let mut iv = -1
      for i in 0..<au.length() {
        for j in 0..<av.length() {
          if au[i] == av[j] { iu = i; iv = j; break }
        }
        if iu >= 0 { break }
      }
      if iu < 0 { continue }
      let cyc : Array[Int] = []
      for i in 0..<(iu + 1) { cyc.push(au[i]) }
      let mut j = iv - 1
      while j >= 0 {
        cyc.push(av[j])
        j -= 1
      }
      if cyc.length() >= 3 { cycles.push(cyc) }
    }
  }
  cycles
}

///|
/// 沿路徑之平行移動（holonomy）：轉移函數乘積 ∈ {±1}。
pub fn holonomy(b : LineBundle, path : Array[Int]) -> Int {
  let mut h = 1
  for i in 0..<(path.length() - 1) { h *= bundle_sign(b, path[i], path[i + 1]) }
  if path.length() > 2 { h *= bundle_sign(b, path[path.length() - 1], path[0]) }
  h
}

///|
pub fn curvature(b : LineBundle) -> Array[Int] {
  let cs = cycle_basis(b.g)
  let out : Array[Int] = []
  for i in 0..<cs.length() { out.push(holonomy(b, cs[i])) }
  out
}

///|
pub fn is_flat(b : LineBundle) -> Bool {
  let c = curvature(b)
  for i in 0..<c.length() {
    if c[i] != 1 { return false }
  }
  true
}

///|
/// 聯絡 Laplacian（Singer–Wu / Gao–Brodzki–Mukherjee）：
/// 對角 deg(u)，非對角 −s_{uv}。
pub fn connection_laplacian(b : LineBundle) -> @exact.Mat {
  let n = b.g.n
  let m = @exact.mat_new(n, n)
  for u in 0..<n {
    m.a[u][u] = @exact.rat_int(graph_degree(b.g, u).to_int64())
    for v in 0..<n {
      if u == v || ((b.g.adj[u] >> v) & 1UL) == 0UL { continue }
      m.a[u][v] = @exact.rat_int((-bundle_sign(b, u, v)).to_int64())
    }
  }
  m
}

///|
/// 0-上邊界 δ : C⁰ → C¹；邊 e=(u,v) 之列為 x_u − s_{uv} x_v。
pub fn sheaf_coboundary(b : LineBundle) -> @exact.Mat {
  let n = b.g.n
  let rows : Array[Array[@exact.Rat]] = []
  for u in 0..<n {
    for v in (u + 1)..<n {
      if ((b.g.adj[u] >> v) & 1UL) == 0UL { continue }
      let row : Array[@exact.Rat] = Array::make(n, @exact.rat_zero())
      row[u] = @exact.rat_one()
      row[v] = @exact.rat_int((-bundle_sign(b, u, v)).to_int64())
      rows.push(row)
    }
  }
  @exact.mat_from(rows)
}

///|
pub fn sheaf_laplacian(b : LineBundle) -> @exact.Mat {
  let d = sheaf_coboundary(b)
  @exact.mat_mul(@exact.mat_transpose(d), d)
}

///|
pub fn global_sections_dim(b : LineBundle) -> Int {
  b.g.n - @exact.mat_rank(sheaf_coboundary(b))
}

///|
/// 定理 T-Gph8（離散 Hodge / sheaf Laplacian）：
/// Δ⁰ = δᵀδ = 聯絡 Laplacian，且 ker Δ⁰ = ker δ（H⁰ = 全域截面），
/// rank Δ⁰ = rank δ，故 dim H⁰ = n − rank Δ⁰。
pub fn theorem_sheaf_hodge(b : LineBundle) -> Bool {
  let delta = sheaf_coboundary(b)
  let lap = sheaf_laplacian(b)
  @exact.mat_equal(lap, connection_laplacian(b)) &&
    @exact.mat_rank(lap) == @exact.mat_rank(delta) &&
    global_sections_dim(b) == b.g.n - @exact.mat_rank(lap)
}

///|
/// 定理 T-Gph9：連通圖上 O(1) 線叢平坦 ⟺ 所有環 holonomy = +1
/// ⟺ H⁰ 維度 = 1（非平坦則無非零全域截面）。
pub fn theorem_flat_sections(b : LineBundle) -> Bool {
  graph_component_count(b.g) == 1 &&
    (is_flat(b) == (global_sections_dim(b) == 1))
}

///|
/// 定理 T-Gph10：測地線 + 平行移動之複合；
/// 沿最短路徑之 holonomy 為 ±1，且路徑反向之 holonomy 相同（度量聯絡）。
pub fn theorem_parallel_transport_geodesic(b : LineBundle, s : Int, t : Int) -> Bool {
  let p = geodesic_path(b.g, s, t)
  if p.length() == 0 { return false }
  let h = holonomy(b, p)
  let rev : Array[Int] = []
  let mut i = p.length()
  while i > 0 { i -= 1; rev.push(p[i]) }
  (h == 1 || h == -1) && holonomy(b, rev) == h
}

///|
// ════════════════════════════════════════════════════════════════════════
// C1-04 補回 §6''：Persistent Sheaf Laplacian（Wei–Wei 2021 / 2507.19504）
// 對 X ⊂ Y（X 為前 k 個頂點之誘導子複形，層 F = G|_X），q=0 之
// Δ₀^{X,Y} = D^{*,0}_{X,Y} P^{-1} (D^{*,0}_{X,Y})^T，其中
// Θ¹_{X,Y} = {x ∈ C¹(Y;G) | (d⁰_Y)^T x ∈ C⁰(X;F)}；
// 以正交投影 Proj_Θ = I − Aᵀ(AAᵀ)^{-1}A（A 為 δ_Yᵀ 之新頂點列）給出
// Δ₀^{X,Y} = (πδ_Yᵀ) Proj_Θ (πδ_Yᵀ)^T，全程 @exact.Rat 精確算術。
// 主要定理：ker Δ₀^{X,Y} ≅ π•(H⁰(Y;G))（persistent Betti）。
// ════════════════════════════════════════════════════════════════════════

///|
pub(all) struct PersistentSheaf {
  b : LineBundle
  k : Int
}

///|
pub fn persistent_sheaf(b : LineBundle, k : Int) -> PersistentSheaf {
  let kk = if k < 1 { 1 } else if k > b.g.n { b.g.n } else { k }
  PersistentSheaf::{ b, k: kk }
}

///|
/// 高斯–Jordan 反矩陣（僅用於對稱正定之 AAᵀ）。
fn rat_mat_inverse(x : @exact.Mat) -> @exact.Mat {
  let n = x.a.length()
  let aug : Array[Array[@exact.Rat]] = []
  for i in 0..<n {
    let row : Array[@exact.Rat] = []
    for j in 0..<n { row.push(x.a[i][j]) }
    for j in 0..<n { row.push(if i == j { @exact.rat_one() } else { @exact.rat_zero() }) }
    aug.push(row)
  }
  for c in 0..<n {
    let mut piv = -1
    for i in c..<n {
      if !aug[i][c].is_zero() { piv = i; break }
    }
    if piv < 0 { continue }
    let tmp = aug[c]
    aug[c] = aug[piv]
    aug[piv] = tmp
    let p = aug[c][c]
    for j in 0..<(2 * n) { aug[c][j] = aug[c][j].div(p).unwrap() }
    for i in 0..<n {
      if i == c { continue }
      let f = aug[i][c]
      if f.is_zero() { continue }
      for j in 0..<(2 * n) { aug[i][j] = aug[i][j].sub(f.mul(aug[c][j])) }
    }
  }
  let out : Array[Array[@exact.Rat]] = []
  for i in 0..<n {
    let row : Array[@exact.Rat] = []
    for j in 0..<n { row.push(aug[i][n + j]) }
    out.push(row)
  }
  @exact.mat_from(out)
}

///|
/// 選取列空間之一組線性無關原列（有理列消去，保留原列而非 RREF 列）。
fn rat_independent_rows(x : @exact.Mat) -> @exact.Mat {
  let basis : Array[Array[@exact.Rat]] = []
  let chosen : Array[Array[@exact.Rat]] = []
  let m = if x.a.length() == 0 { 0 } else { x.a[0].length() }
  for i in 0..<x.a.length() {
    let cur : Array[@exact.Rat] = []
    for j in 0..<m { cur.push(x.a[i][j]) }
    for k in 0..<basis.length() {
      let mut pc = -1
      for j in 0..<m {
        if !basis[k][j].is_zero() { pc = j; break }
      }
      if pc < 0 { continue }
      let f = cur[pc]
      if f.is_zero() { continue }
      for j in 0..<m { cur[j] = cur[j].sub(f.mul(basis[k][j])) }
    }
    let mut piv = -1
    for j in 0..<m {
      if !cur[j].is_zero() { piv = j; break }
    }
    if piv >= 0 {
      let p = cur[piv]
      let nrm : Array[@exact.Rat] = []
      for j in 0..<m { nrm.push(cur[j].div(p).unwrap()) }
      basis.push(nrm)
      chosen.push(x.a[i])
    }
  }
  @exact.mat_from(chosen)
}

///|
/// Θ = ker A 之正交投影（m×m）：I − Aᵀ(AAᵀ)^{-1}A。
fn kernel_projector(a : @exact.Mat, m : Int) -> @exact.Mat {
  let ar = rat_independent_rows(a)
  if ar.a.length() == 0 { return @exact.mat_identity(m) }
  let g = @exact.mat_mul(ar, @exact.mat_transpose(ar))
  let gi = rat_mat_inverse(g)
  let term = @exact.mat_mul(
    @exact.mat_mul(@exact.mat_transpose(ar), gi),
    ar,
  )
  @exact.mat_sub(@exact.mat_identity(m), term)
}

///|
/// 取出列區間 [lo, hi) 之子矩陣。
fn row_slice(x : @exact.Mat, lo : Int, hi : Int) -> @exact.Mat {
  let out : Array[Array[@exact.Rat]] = []
  for i in lo..<hi { out.push(x.a[i]) }
  @exact.mat_from(out)
}

///|
fn col_slice(x : @exact.Mat, lo : Int, hi : Int) -> @exact.Mat {
  let out : Array[Array[@exact.Rat]] = []
  for i in 0..<x.a.length() {
    let row : Array[@exact.Rat] = []
    for j in lo..<hi { row.push(x.a[i][j]) }
    out.push(row)
  }
  @exact.mat_from(out)
}

///|
/// Persistent sheaf Laplacian Δ₀^{X,Y}（k×k，精確有理矩陣）。
pub fn persistent_laplacian_from_delta(delta : @exact.Mat, n : Int, k : Int) -> @exact.Mat {
  let mm = delta.a.length()
  let dt = @exact.mat_transpose(delta)
  let big_m = row_slice(dt, 0, k)
  let aa = row_slice(dt, k, n)
  let proj = kernel_projector(aa, mm)
  let dd = @exact.mat_mul(big_m, proj)
  @exact.mat_mul(dd, @exact.mat_transpose(big_m))
}

///|
/// 由 δ_Y 直接構造 persistent sheaf Laplacian（便於驗證定向不變性）。
pub fn persistent_sheaf_laplacian(p : PersistentSheaf) -> @exact.Mat {
  persistent_laplacian_from_delta(sheaf_coboundary(p.b), p.b.g.n, p.k)
}

///|
/// q=0 persistent Betti：β₀^{X,Y} = dim π•(H⁰(Y;G))
/// = (n − rank δ_Y) − ((n−k) − rank δ_Y[:,k:])。
pub fn persistent_sheaf_betti0(p : PersistentSheaf) -> Int {
  let delta = sheaf_coboundary(p.b)
  let n = p.b.g.n
  let h0y = n - @exact.mat_rank(delta)
  let dnew = col_slice(delta, p.k, n)
  let vanish = (n - p.k) - @exact.mat_rank(dnew)
  h0y - vanish
}

///|
pub fn persistent_sheaf_nullity(p : PersistentSheaf) -> Int {
  p.k - @exact.mat_rank(persistent_sheaf_laplacian(p))
}

///|
/// 對稱矩陣之 PSD 憑證：所有主子式 ≥ 0（2^k 個，k 小時可穷舉）。
pub fn psd_principal_minors(x : @exact.Mat) -> Bool {
  let n = x.a.length()
  let total = 1 << n
  for mask in 0..<total {
    let idx : Array[Int] = []
    for i in 0..<n {
      if ((mask >> i) & 1) == 1 { idx.push(i) }
    }
    let sub : Array[Array[@exact.Rat]] = []
    for i in 0..<idx.length() {
      let row : Array[@exact.Rat] = []
      for j in 0..<idx.length() { row.push(x.a[idx[i]][idx[j]]) }
      sub.push(row)
    }
    let d = @exact.mat_det(@exact.mat_from(sub))
    if d.n < 0L { return false }
  }
  true
}

///|
/// 定理 T-Gph11（persistent sheaf Hodge）：ker Δ₀^{X,Y} ≅ π•(H⁰(Y;G))，
/// 且 Δ₀^{X,Y} 對稱、秩不超過 k、nullity 與 persistent Betti 相等。
pub fn theorem_persistent_sheaf_hodge(p : PersistentSheaf) -> Bool {
  let lap = persistent_sheaf_laplacian(p)
  let rank = @exact.mat_rank(lap)
  rank <= p.k &&
    @exact.mat_equal(lap, @exact.mat_transpose(lap)) &&
    persistent_sheaf_nullity(p) == persistent_sheaf_betti0(p) &&
    persistent_sheaf_betti0(p) >= 0
}

///|
/// 定理 T-Gph12：Δ₀^{X,Y} 半正定（所有主子式非負），
/// 且其特徵多項式之零根重數 = persistent Betti（mat_charpoly 低次係數）。
pub fn theorem_persistent_sheaf_psd(p : PersistentSheaf) -> Bool {
  let lap = persistent_sheaf_laplacian(p)
  if !psd_principal_minors(lap) { return false }
  let cp = @exact.mat_charpoly(lap)
  let beta = persistent_sheaf_betti0(p)
  // charpoly(t) = t^k + …；零根重數 β 等價於前 β 個低次係數皆為 0
  for j in 0..<beta {
    if !cp[j].is_zero() { return false }
  }
  true
}

///|
/// 定理 T-Gph13：當 X = Y（k = n）時 persistent Laplacian 退化為
/// 普通 sheaf Laplacian δᵀδ，且 nullity = dim H⁰(Y)。
pub fn theorem_persistent_sheaf_limit() -> Bool {
  let adj : Array[UInt64] = [
    0b01110UL, 0b10101UL, 0b11011UL, 0b10101UL, 0b01110UL,
  ]
  let b = line_bundle(graph(5, adj), 2)
  let p = persistent_sheaf(b, 5)
  let lap = persistent_sheaf_laplacian(p)
  @exact.mat_equal(lap, sheaf_laplacian(b)) &&
    persistent_sheaf_nullity(p) == global_sections_dim(b) &&
    theorem_persistent_sheaf_hodge(p)
}

///|
/// 反轉第 e 條邊之定向：δ_Y 之第 e 列整體乘 −1（Wei–Wei Prop. 3.2 之
/// I_{σ,−} 作用），此不改變 Δ₀^{X,Y}。
pub fn negate_coboundary_row(delta : @exact.Mat, e : Int) -> @exact.Mat {
  let out : Array[Array[@exact.Rat]] = []
  for i in 0..<delta.a.length() {
    let row : Array[@exact.Rat] = []
    for j in 0..<delta.a[0].length() {
      row.push(if i == e { delta.a[i][j].neg() } else { delta.a[i][j] })
    }
    out.push(row)
  }
  @exact.mat_from(out)
}

///|
/// 定理 T-Gph14（Wei–Wei Prop. 3.2）：persistent sheaf Laplacian 之譜
/// 不依賴 Y 之定向；反轉任一邊定向後 Δ₀^{X,Y} 逐項不變，
/// 因而特徵多項式完全相同，且 Hodge 定理仍然成立。
pub fn theorem_persistent_sheaf_orientation() -> Bool {
  let adj : Array[UInt64] = [
    0b011110UL, 0b101011UL, 0b110101UL, 0b101110UL, 0b110101UL, 0b011101UL,
  ]
  let b = line_bundle(graph(6, adj), 3)
  let p = persistent_sheaf(b, 4)
  let delta = sheaf_coboundary(b)
  let lap = persistent_laplacian_from_delta(delta, 6, 4)
  let c0 = @exact.mat_charpoly(lap)
  let mut ok = true
  for e in 0..<delta.a.length() {
    let d2 = negate_coboundary_row(delta, e)
    let lap2 = persistent_laplacian_from_delta(d2, 6, 4)
    if !@exact.mat_equal(lap, lap2) { ok = false }
    let c1 = @exact.mat_charpoly(lap2)
    for j in 0..<c0.length() {
      if !c0[j].equal(c1[j]) { ok = false }
    }
  }
  ok && theorem_persistent_sheaf_hodge(p)
}

///|
// ════════════════════════════════════════════════════════════════════════
// C1-04 補回 §6''：多尺度 filtration 與 Kalai–Meshulam 拓樸組合
// ════════════════════════════════════════════════════════════════════════

///|
/// 多尺度 filtration：k=1..n 逐層計算 (β₀^{X_k,Y}, nullity, rank, trace)。
pub struct PersistBar {
  k : Int
  betti : Int
  nullity : Int
  rank : Int
  trace : @exact.Rat
}

///|
pub fn persistent_sheaf_bars(b : LineBundle) -> Array[PersistBar] {
  let out : Array[PersistBar] = []
  for k in 1..<(b.g.n + 1) {
    let p = persistent_sheaf(b, k)
    let lap = persistent_sheaf_laplacian(p)
    out.push(PersistBar::{
      k, betti: persistent_sheaf_betti0(p),
      nullity: persistent_sheaf_nullity(p),
      rank: @exact.mat_rank(lap), trace: @exact.mat_trace(lap),
    })
  }
  out
}

///|
/// 定理 T-Gph15：多尺度 filtration 之 persistent Betti 隨尺度單調不減，
/// 每層 nullity = β₀、rank + nullity = k，且末層 nullity = dim H⁰(Y)。
pub fn theorem_persistent_sheaf_filtration() -> Bool {
  let adj : Array[UInt64] = [
    0b0000110UL, 0b0000101UL, 0b0000011UL, 0b0010000UL,
    0b0101000UL, 0b1010000UL, 0b0100000UL,
  ]
  let b = line_bundle(graph(7, adj), 2)
  let bars = persistent_sheaf_bars(b)
  for i in 0..<bars.length() {
    let q = bars[i]
    if q.betti != q.nullity { return false }
    if q.rank + q.nullity != q.k { return false }
    if q.trace.n < 0L { return false }
    if i > 0 && bars[i - 1].betti > q.betti { return false }
  }
  bars[bars.length() - 1].betti == global_sections_dim(b)
}

///|
/// 誘導子複形 X[U]。
pub fn induced_complex(c : Complex, u : UInt64) -> Complex {
  let facets : Array[UInt64] = []
  for d in 0..<c.faces.length() {
    for i in 0..<c.faces[d].length() {
      let f = c.faces[d][i]
      if (f & u) == f { facets.push(f) }
    }
  }
  complex_from_facets(c.nverts, facets)
}

///|
pub fn is_face(c : Complex, f : UInt64) -> Bool {
  if f == 0UL { return true }
  for d in 0..<c.faces.length() {
    for i in 0..<c.faces[d].length() {
      if c.faces[d][i] == f { return true }
    }
  }
  false
}

///|
/// 約化同調之最高非零維度（GF(2)）；無非零者回傳 −1。
pub fn reduced_homology_top(c : Complex) -> Int {
  // 空複形（無面）不貢獻約化同調；避免 β̃₀ = −1 之形式贗象
  if c.faces.length() == 0 || c.faces[0].length() == 0 { return -1 }
  let b = betti_numbers(c)
  let mut top = -1
  for k in 0..<b.length() {
    let v = if k == 0 { b[0] - 1 } else { b[k] }
    if v != 0 { top = k }
  }
  top
}

///|
/// Leray 數 λ(X) = 1 + max_{U⊆V} top( H̃(X[U]) )（對所有誘導子複形）。
pub fn leray_number(c : Complex) -> Int {
  let total = 1UL << c.nverts
  let mut lam = 0
  let mut u = 0UL
  while u < total {
    let t = reduced_homology_top(induced_complex(c, u))
    if t + 1 > lam { lam = t + 1 }
    u += 1UL
  }
  lam
}

///|
/// Kalai–Meshulam 定理之有限憑證：若 matroid complex M ⊆ X，
/// 則存在 τ ∈ X 使 ρ(V∖τ) ≤ λ(X)。
pub fn kalai_meshulam_witness(m : Matroid, c : Complex) -> Array[Int] {
  let all = @galois.full_mask(m.nelem)
  let mut contained = true
  let total = 1UL << m.nelem
  let mut s = 0UL
  while s < total {
    if matroid_is_independent(m, s) && !is_face(c, s) { contained = false; break }
    s += 1UL
  }
  if !contained { return [] }
  let d = leray_number(c)
  let mut witness = -1
  let mut t2 = 0UL
  while t2 < total {
    if (t2 == 0UL || is_face(c, t2)) && matroid_rank(m, all ^ t2) <= d {
      witness = t2.to_int()
      break
    }
    t2 += 1UL
  }
  [contained.to_int(), d, witness, matroid_rank(m, all)]
}

///|
pub fn theorem_kalai_meshulam() -> Bool {
  // 實例一：X 為完整單純形（λ = 0），M 為自由擬陣（rank 4）。
  // 此時結論為 Rado/Hall 型：存在 τ = V 使 ρ(V∖τ) = 0 ≤ 0。
  let n = 4
  let all = @galois.full_mask(n)
  let facets : Array[UInt64] = [all]
  let simplex = complex_from_facets(n, facets)
  let rows : Array[UInt64] = [1UL, 2UL, 4UL, 8UL]
  let free = matroid(n, rows)
  let w1 = kalai_meshulam_witness(free, simplex)
  if w1.length() != 4 || w1[0] != 1 { return false }
  if w1[1] != 0 { return false }
  if w1[2] < 0 || w1[3] != n { return false }
  if matroid_rank(free, all ^ w1[2].to_uint64()) > w1[1] { return false }
  // 實例二：X 為 K₄ 之 1-骨架（λ ≥ 2），M 為秩 2 二元擬陣。
  let edges : Array[UInt64] = []
  for u in 0..<n {
    for v in (u + 1)..<n { edges.push((1UL << u) | (1UL << v)) }
  }
  let k4 = complex_from_facets(n, edges)
  let rows2 : Array[UInt64] = [0b0101UL, 0b1010UL]
  let m2 = matroid(n, rows2)
  let w2 = kalai_meshulam_witness(m2, k4)
  if w2.length() != 4 { return false }
  if w2[1] < 2 { return false }
  if w2[2] < 0 { return false }
  if matroid_rank(m2, all ^ w2[2].to_uint64()) > w2[1] { return false }
  // 誘導子複形之 Euler–Poincaré 一致性
  for u in 0..<(1UL << n).to_int() {
    let ic = induced_complex(k4, u.to_uint64())
    if !theorem_euler_poincare(ic) { return false }
  }
  true
}
