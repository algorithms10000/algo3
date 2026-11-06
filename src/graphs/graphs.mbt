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
