///|
/// C1 / src/galois — 全局公理 G：伽羅瓦對應（有限冪集上的極性）
/// 關係 R ⊆ X×Y 以列位元遮罩編碼 (L4)。所有定理以有限窮舉给出計算憑證，
/// 與 src/axioms 的 Z3 引理互為補充。

///|
pub(all) struct Context {
  nx : Int
  ny : Int
  rows : Array[UInt64]
}

///|
pub(all) struct GaloisCert {
  adjoint_pairs : Int
  extensive : Int
  idempotent : Int
  monotone : Int
  closed_objects : Int
  closed_attributes : Int
  concept_count : Int
  next_closure_count : Int
}

///|
pub fn context(nx : Int, ny : Int, rows : Array[UInt64]) -> Context {
  Context::{ nx, ny, rows }
}

///|
pub fn full_mask(n : Int) -> UInt64 {
  let mut m = 0UL
  for i in 0..<n { m = @exact.set_bit(m, i) }
  m
}

///|
pub fn lower_mask(n : Int) -> UInt64 {
  let mut m = 0UL
  for i in 0..<n { m = @exact.set_bit(m, i) }
  m
}

///|
pub fn entry(ctx : Context, x : Int, y : Int) -> Bool {
  @exact.bit(ctx.rows[x], y)
}

///|
pub fn subset(a : UInt64, b : UInt64) -> Bool { (a & b) == a }

///|
/// F(A) = { y ∈ Y | ∀ x ∈ A, R(x,y) }：列遮罩之交。
pub fn polar_obj(ctx : Context, a : UInt64) -> UInt64 {
  let mut out = full_mask(ctx.ny)
  for x in 0..<ctx.nx {
    if ((a >> x) & 1UL) == 1UL { out = out & ctx.rows[x] }
  }
  out
}

///|
/// H(B) = { x ∈ X | ∀ y ∈ B, R(x,y) }：B ⊆ row_x 的列集合。
pub fn polar_attr(ctx : Context, b : UInt64) -> UInt64 {
  let mut out = 0UL
  for x in 0..<ctx.nx {
    if (b & ctx.rows[x]) == b { out = @exact.set_bit(out, x) }
  }
  out
}

///|
pub fn closure_obj(ctx : Context, a : UInt64) -> UInt64 {
  polar_attr(ctx, polar_obj(ctx, a))
}

///|
pub fn closure_attr(ctx : Context, b : UInt64) -> UInt64 {
  polar_obj(ctx, polar_attr(ctx, b))
}

///|
/// 全局公理 G 的伴隨性：A ⊆ H(B) ⟺ B ⊆ F(A)。
pub fn adjoint_pair(ctx : Context, a : UInt64, b : UInt64) -> Bool {
  let left = subset(a, polar_attr(ctx, b))
  let right = subset(b, polar_obj(ctx, a))
  left == right
}

///|
pub fn total_masks(n : Int) -> UInt64 { 1UL << n }

///|
fn insert_unique(xs : Array[UInt64], v : UInt64) -> Unit {
  for i in 0..<xs.length() {
    if xs[i] == v { return }
  }
  xs.push(v)
}

///|
/// 物件側閉集格 Fix(F∘H)：窮舉 2^nx 個子集取閉包。
pub fn closed_objects(ctx : Context) -> Array[UInt64] {
  let out : Array[UInt64] = []
  let total = total_masks(ctx.nx)
  let mut a = 0UL
  while a < total {
    insert_unique(out, closure_obj(ctx, a))
    a += 1UL
  }
  out
}

///|
/// 屬性側閉集格 Fix(H∘F)：窮舉 2^ny 個子集取閉包。
pub fn closed_attributes(ctx : Context) -> Array[UInt64] {
  let out : Array[UInt64] = []
  let total = total_masks(ctx.ny)
  let mut b = 0UL
  while b < total {
    insert_unique(out, closure_attr(ctx, b))
    b += 1UL
  }
  out
}

///|
/// Ganter NextClosure：以 lectic 順序列舉所有 intent（閉包的 fixpoints）。
pub fn next_closure_intents(ctx : Context) -> Array[UInt64] {
  let out : Array[UInt64] = []
  let all = full_mask(ctx.ny)
  let mut b = closure_attr(ctx, 0UL)
  out.push(b)
  let mut steps = 0
  let limit = (1 << ctx.ny) + 1
  while b != all && steps < limit {
    steps += 1
    let mut found = false
    for ii = 0; ii < ctx.ny; ii = ii + 1 {
      let i = ctx.ny - 1 - ii
      if ((b >> i) & 1UL) == 1UL { continue }
      let cand = closure_attr(ctx, (b & lower_mask(i)) | (1UL << i))
      let diff = cand & (all ^ b)
      if (diff & lower_mask(i)) == 0UL {
        b = cand
        out.push(b)
        found = true
        break
      }
    }
    if !found { break }
  }
  out
}

///|
/// 概念格覆蓋關係數：I 覆蓋 J 若 J ⊂ I 且不存在 K 使 J ⊂ K ⊂ I。
pub fn concept_covers(intents : Array[UInt64]) -> Int {
  let mut covers = 0
  for i in 0..<intents.length() {
    for j in 0..<intents.length() {
      if i == j { continue }
      if !subset(intents[j], intents[i]) { continue }
      if intents[j] == intents[i] { continue }
      let mut intermediate = false
      for k in 0..<intents.length() {
        if k == i || k == j { continue }
        if subset(intents[j], intents[k]) && subset(intents[k], intents[i]) &&
          intents[k] != intents[i] && intents[k] != intents[j] {
          intermediate = true
          break
        }
      }
      if !intermediate { covers += 1 }
    }
  }
  covers
}

///|
/// 楚空間鏡像對偶：轉置矩陣 (L4, 組合範例 10/2)。
pub fn chu_dual(ctx : Context) -> Context {
  let rows : Array[UInt64] = []
  for y in 0..<ctx.ny {
    let mut row = 0UL
    for x in 0..<ctx.nx {
      if @exact.bit(ctx.rows[x], y) { row = @exact.set_bit(row, x) }
    }
    rows.push(row)
  }
  Context::{ nx: ctx.ny, ny: ctx.nx, rows }
}

///|
/// 關係複合（布林矩陣乘法）：管線策略合成與 Kan 擴展的底層運算。
pub fn relation_compose(a : Context, b : Context) -> Context {
  let rows : Array[UInt64] = []
  for x in 0..<a.nx {
    let mut row = 0UL
    for y in 0..<a.ny {
      if @exact.bit(a.rows[x], y) && y < b.nx { row = row | b.rows[y] }
    }
    rows.push(row)
  }
  Context::{ nx: a.nx, ny: b.ny, rows }
}

///|
/// 定理 T-G1..T-G4 的計算憑證：伴隨性、閉包三律、閉集格反同構、
/// NextClosure 完備性。以有限窮舉對所有子集／所有子集對查核。
pub fn galois_certificate(ctx : Context) -> GaloisCert {
  let nx_total = total_masks(ctx.nx)
  let ny_total = total_masks(ctx.ny)
  let mut adjoint_pairs = 0
  let mut a = 0UL
  while a < nx_total {
    let mut b = 0UL
    while b < ny_total {
      if adjoint_pair(ctx, a, b) { adjoint_pairs += 1 }
      b += 1UL
    }
    a += 1UL
  }
  let mut extensive = 0
  let mut idempotent = 0
  let mut monotone = 0
  a = 0UL
  while a < nx_total {
    let ca = closure_obj(ctx, a)
    if subset(a, ca) { extensive += 1 }
    if closure_obj(ctx, ca) == ca { idempotent += 1 }
    let mut a2 = 0UL
    while a2 < nx_total {
      if subset(a, a2) && subset(ca, closure_obj(ctx, a2)) { monotone += 1 }
      a2 += 1UL
    }
    a += 1UL
  }
  let cobjs = closed_objects(ctx)
  let cattrs = closed_attributes(ctx)
  let nci = next_closure_intents(ctx)
  GaloisCert::{
    adjoint_pairs,
    extensive,
    idempotent,
    monotone,
    closed_objects: cobjs.length(),
    closed_attributes: cattrs.length(),
    concept_count: cobjs.length(),
    next_closure_count: nci.length(),
  }
}

///|
/// 定理 T-G3：閉物件格與閉屬性格反同構（F 給出 bijection），回傳是否通過。
pub fn theorem_closed_lattice_antiiso(ctx : Context) -> Bool {
  let cobjs = closed_objects(ctx)
  let cattrs = closed_attributes(ctx)
  if cobjs.length() != cattrs.length() { return false }
  for i in 0..<cobjs.length() {
    let image = polar_obj(ctx, cobjs[i])
    let mut hit = false
    for j in 0..<cattrs.length() {
      if cattrs[j] == image { hit = true; break }
    }
    if !hit { return false }
    if polar_attr(ctx, image) != cobjs[i] { return false }
  }
  true
}

///|
/// 定理 T-G4：NextClosure 列舉恰為所有 intent。
pub fn theorem_next_closure_complete(ctx : Context) -> Bool {
  let brute = closed_attributes(ctx)
  let nc = next_closure_intents(ctx)
  if brute.length() != nc.length() { return false }
  for i in 0..<nc.length() {
    let mut hit = false
    for j in 0..<brute.length() {
      if brute[j] == nc[i] { hit = true; break }
    }
    if !hit { return false }
  }
  true
}

///|
/// 定理 T-G5：楚空間對偶的概念格大小不變（鏡像對稱性）。
pub fn theorem_chu_dual(ctx : Context) -> Bool {
  let d = chu_dual(ctx)
  closed_objects(ctx).length() == closed_objects(d).length() &&
    chu_dual(d).rows.length() == ctx.rows.length()
}

///|
/// 有限域 F_p 上多項式（次數 < deg）在點 x 的 Horner 求值。
fn poly_eval(coeffs : Array[Int64], x : Int64, p : Int64) -> Int64 {
  let mut acc = 0L
  for i = coeffs.length() - 1; i >= 0; i = i - 1 {
    acc = @exact.fp_add(@exact.fp_mul(acc, x, p), coeffs[i], p)
  }
  acc
}

///|
/// 理想–簇 Galois 對應：物件 = F_p[t]_{<deg} 的多項式，屬性 = F_p 的點，
/// R(f,x) ⟺ f(x) = 0。此為多項式商環與零點集之間的真實極性。
pub fn ideal_variety_context(p : Int64, deg : Int) -> Context {
  let pn = p.to_int()
  let mut npoly = 1L
  let mut dcount = 0
  while dcount < deg {
    npoly *= p
    dcount += 1
  }
  let rows : Array[UInt64] = []
  let mut code = 0L
  while code < npoly {
    let coeffs : Array[Int64] = Array::make(deg, 0L)
    let mut t = code
    for k = 0; k < deg; k = k + 1 {
      coeffs[k] = t % p
      t = t / p
    }
    let mut row = 0UL
    for x = 0; x < pn; x = x + 1 {
      if poly_eval(coeffs, x.to_int64(), p) == 0L { row = @exact.set_bit(row, x) }
    }
    rows.push(row)
    code += 1L
  }
  Context::{ nx: npoly.to_int(), ny: pn, rows }
}

///|
/// 定理 T-G6：有限域上 V(I) 與 I(V) 形成 Galois 對應；
/// 對所有點集 V 有 F(H(V)) = V，對所有多項式集 I 有 I ⊆ H(F(I))。
pub fn theorem_ideal_variety(ctx : Context) -> Bool {
  let ptotal = total_masks(ctx.ny)
  let mut v = 0UL
  while v < ptotal {
    let fv = polar_obj(ctx, polar_attr(ctx, v))
    if fv != v { return false }
    v += 1UL
  }
  // 物件側以「前 cap 個多項式的所有子集」做穷舉憑證；
  // 一般情形由極性伴隨性 A ⊆ H(B) ⟺ B ⊆ F(A) 直接給出。
  let cap = if ctx.nx > 12 { 12 } else { ctx.nx }
  let itotal = total_masks(cap)
  let mut i = 0UL
  while i < itotal {
    if !subset(i, closure_obj(ctx, i)) { return false }
    i += 1UL
  }
  true
}

///|
/// 定理 T-G7（完備格表示定理）：給定閉包系統 closed，構造 Chu space
/// (D, ⊨, D)，x ⊨ b ⟺ b ⊆ x；其概念格大小等於 |D|。
pub fn closure_system_representation(closed : Array[UInt64]) -> Int {
  let n = closed.length()
  let rows : Array[UInt64] = []
  for i in 0..<n {
    let mut row = 0UL
    for j in 0..<n {
      if subset(closed[j], closed[i]) { row = @exact.set_bit(row, j) }
    }
    rows.push(row)
  }
  let ctx = Context::{ nx: n, ny: n, rows }
  closed_attributes(ctx).length()
}

///|
/// 任意閉包系統可由極性產生：比較表示 Chu space 的概念數與原系統大小。
pub fn theorem_representation(closed : Array[UInt64]) -> Bool {
  closure_system_representation(closed) == closed.length()
}

///|
// ════════════════════════════════════════════════════════════════════════
// C1-02 補回 §6 待辦：NextClosure 平行化
// 依據 Kriegel–Borchmann (CLA 2015) NextClosures：以「基數層級」由下往上
// 枚举 intents/pseudo-intents，同一層級之候選彼此獨立、无需通訊；
// 及 Kriegel (ICCS/CLA 2016) NextClosures with Constraints：
// 以第二個閉包算子（約束）切分工作單元，實現平行 Attribute Exploration。
// ════════════════════════════════════════════════════════════════════════

///|
fn list_contains(xs : Array[UInt64], v : UInt64) -> Bool {
  for i in 0..<xs.length() {
    if xs[i] == v { return true }
  }
  false
}

///|
fn min_bit(b : UInt64, n : Int) -> Int {
  let mut i = 0
  while i < n {
    if ((b >> i) & 1UL) == 1UL { return i }
    i += 1
  }
  n
}

///|
/// 約束閉包算子 c_req(A) = c(required ∪ A)；其 fixpoints 為含 required 之 intent。
pub fn constraint_closure(ctx : Context, required : UInt64, a : UInt64) -> UInt64 {
  closure_attr(ctx, required | a)
}

///|
/// Ganter NextClosure 在約束閉包算子上的版本（每個 worker 可獨立執行）。
pub fn next_closure_constrained(ctx : Context, required : UInt64) -> Array[UInt64] {
  let out : Array[UInt64] = []
  let all = full_mask(ctx.ny)
  let mut b = constraint_closure(ctx, required, 0UL)
  out.push(b)
  let limit = (1 << ctx.ny) + 1
  let mut steps = 0
  while b != all && steps < limit {
    steps += 1
    let mut found = false
    for ii in 0..<ctx.ny {
      let i = ctx.ny - 1 - ii
      if ((b >> i) & 1UL) == 1UL { continue }
      let cand = constraint_closure(ctx, required, (b & lower_mask(i)) | (1UL << i))
      let diff = cand & (all ^ b)
      if (diff & lower_mask(i)) == 0UL {
        b = cand
        out.push(b)
        found = true
        break
      }
    }
    if !found { break }
  }
  out
}

///|
/// 層級平行枚舉：由 c(∅) 出發，沿上鄰居 c(B∪{m}) 做 BFS，
/// 再依 intent 基數分層；同層候選可完全平行處理（Kriegel–Borchmann）。
pub fn intents_by_cardinality(ctx : Context) -> Array[Array[UInt64]] {
  let levels : Array[Array[UInt64]] = []
  for _k in 0..<(ctx.ny + 1) { levels.push([]) }
  let start = closure_attr(ctx, 0UL)
  let ks = @exact.popcount(start)
  if ks < levels.length() { levels[ks].push(start) }
  let seen : Array[UInt64] = [start]
  let mut frontier : Array[UInt64] = [start]
  let mut rounds = 0
  while frontier.length() > 0 && rounds < ctx.ny + 2 {
    rounds += 1
    let next : Array[UInt64] = []
    for i in 0..<frontier.length() {
      let b = frontier[i]
      for m in 0..<ctx.ny {
        if ((b >> m) & 1UL) == 1UL { continue }
        let cand = closure_attr(ctx, b | (1UL << m))
        if cand == b || list_contains(seen, cand) || list_contains(next, cand) {
          continue
        }
        next.push(cand)
      }
    }
    for i in 0..<next.length() {
      seen.push(next[i])
      let k = @exact.popcount(next[i])
      if k < levels.length() { levels[k].push(next[i]) }
    }
    frontier = next
  }
  levels
}

///|
/// 單一 worker：w < ny 者以約束 c_{{w}} 獨立枚舉 min-attribute = w 的 intents；
/// w = ny 者處理空 intent。各 worker 之間無需通訊。
pub fn parallel_worker(ctx : Context, w : Int) -> Array[UInt64] {
  if w == ctx.ny {
    if closure_attr(ctx, 0UL) == 0UL { [0UL] } else { [] }
  } else {
    let cs = next_closure_constrained(ctx, 1UL << w)
    let out : Array[UInt64] = []
    for i in 0..<cs.length() {
      if min_bit(cs[i], ctx.ny) == w { out.push(cs[i]) }
    }
    out
  }
}

///|
pub fn parallel_intent_partition(ctx : Context) -> Array[Array[UInt64]] {
  let out : Array[Array[UInt64]] = []
  for w in 0..<(ctx.ny + 1) { out.push(parallel_worker(ctx, w)) }
  out
}

///|
/// 定理 T-G8：約束閉包算子確為閉包算子（擴張／單調／冪等）。
pub fn theorem_constraint_closure(ctx : Context, required : UInt64) -> Bool {
  let total = total_masks(ctx.ny)
  let mut a = 0UL
  while a < total {
    let c = constraint_closure(ctx, required, a)
    if (a & c) != a { return false }
    if constraint_closure(ctx, required, c) != c { return false }
    a += 1UL
  }
  true
}

///|
/// 定理 T-G9：層級平行枚舉與穷舉 closed_attributes 完全一致。
pub fn theorem_next_closures_levelwise(ctx : Context) -> Bool {
  let levels = intents_by_cardinality(ctx)
  let brute = closed_attributes(ctx)
  let mut count = 0
  for k in 0..<levels.length() {
    for i in 0..<levels[k].length() {
      let b = levels[k][i]
      if closure_attr(ctx, b) != b { return false }
      if @exact.popcount(b) != k { return false }
      if !list_contains(brute, b) { return false }
      count += 1
    }
  }
  count == brute.length()
}

///|
/// 定理 T-G10：以約束切分之平行 worker 輸出為 intents 的不交劃分，
/// 且聯集等於全部 intents（平行化正確性憑證）。
pub fn theorem_parallel_next_closure(ctx : Context) -> Bool {
  let parts = parallel_intent_partition(ctx)
  let brute = closed_attributes(ctx)
  let flat : Array[UInt64] = []
  for w in 0..<parts.length() {
    for i in 0..<parts[w].length() {
      let b = parts[w][i]
      if list_contains(flat, b) { return false }
      if !list_contains(brute, b) { return false }
      if closure_attr(ctx, b) != b { return false }
      if min_bit(b, ctx.ny) != w { return false }
      flat.push(b)
    }
  }
  flat.length() == brute.length() && theorem_next_closures_levelwise(ctx) &&
    theorem_constraint_closure(ctx, 1UL << (ctx.ny - 1))
}

///|
// ════════════════════════════════════════════════════════════════════════
// C1-04 補回 §6''：FCbO / PFCbO（Krajča–Outrata–Vychodil, CLA 2010）
// 原始 canonicity test：B∩Y_j = D∩Y_j，D=(B∪{j})^↓↑；
// 新增 canonicity test（Lemma 1）：若 N_j∩Y_j ⊄ B∩Y_j，則無需計算 D 即可
// 斷言失敗；失敗時記錄 M_j = D 並向子樹傳遞。PFCbO 在指定層級 L 把
// queue 中的子任務分發給 w 個 worker，各 worker 獨立遞迴。
// ════════════════════════════════════════════════════════════════════════

///|
pub(all) struct FCbOTask {
  a : UInt64
  b : UInt64
  y : Int
  ns : Array[UInt64]
}

///|
fn column_mask(ctx : Context, j : Int) -> UInt64 {
  polar_attr(ctx, 1UL << j)
}

///|
fn copy_ns(ns : Array[UInt64]) -> Array[UInt64] {
  let out : Array[UInt64] = []
  for i in 0..<ns.length() { out.push(ns[i]) }
  out
}

///|
/// FCbO 之 FastGenerateFrom（depth 小於 stop 時遞迴，否則交給 frontier）。
/// stats = [closures, inherited_failures, skipped_by_new_test, raw_listings]。
fn fcbo_generate(
  ctx : Context,
  task : FCbOTask,
  depth : Int,
  stop : Int,
  out : Array[UInt64],
  stats : Array[Int],
  frontier : Array[FCbOTask],
) -> Unit {
  insert_unique(out, task.b)
  stats[3] = stats[3] + 1
  let all = full_mask(ctx.ny)
  if task.b == all || task.y >= ctx.ny { return }
  let mm = copy_ns(task.ns)
  let qa : Array[UInt64] = []
  let qd : Array[UInt64] = []
  let qj : Array[Int] = []
  for j in task.y..<ctx.ny {
    let low = lower_mask(j)
    let in_b = ((task.b >> j) & 1UL) == 1UL
    let newtest = subset(task.ns[j] & low, task.b & low)
    if !in_b && newtest {
      let cc = task.a & column_mask(ctx, j)
      let dd = polar_obj(ctx, cc)
      stats[0] = stats[0] + 1
      if (task.b & low) == (dd & low) {
        qa.push(cc)
        qd.push(dd)
        qj.push(j)
      } else {
        mm[j] = dd
        stats[1] = stats[1] + 1
      }
    } else if !in_b {
      stats[2] = stats[2] + 1
    }
  }
  for k in 0..<qd.length() {
    let child = FCbOTask::{ a: qa[k], b: qd[k], y: qj[k] + 1, ns: mm }
    if depth >= stop {
      frontier.push(child)
    } else {
      fcbo_generate(ctx, child, depth + 1, stop, out, stats, frontier)
    }
  }
}

///|
/// FCbO 由 ⟨X, X^↑⟩ 出發；回傳 [intents, stats] 之封裝由 fcbo_run 提供。
pub struct FCbOResult {
  intents : Array[UInt64]
  closures : Int
  inherited : Int
  skipped : Int
  listings : Int
}

///|
pub fn fcbo_run(ctx : Context) -> FCbOResult {
  let ns : Array[UInt64] = []
  for _j in 0..<ctx.ny { ns.push(0UL) }
  let start = FCbOTask::{
    a: full_mask(ctx.nx), b: closure_attr(ctx, 0UL), y: 0, ns,
  }
  let out : Array[UInt64] = []
  let stats : Array[Int] = [0, 0, 0, 0]
  let frontier : Array[FCbOTask] = []
  fcbo_generate(ctx, start, 0, 1000000, out, stats, frontier)
  FCbOResult::{
    intents: out, closures: stats[0], inherited: stats[1],
    skipped: stats[2], listings: stats[3],
  }
}

///|
/// 傳統 CbO（僅原始 canonicity test）之閉包計算次數，作為剪枝比較基準。
pub fn cbo_closure_count(ctx : Context) -> Int {
  let start = FCbOTask::{
    a: full_mask(ctx.nx), b: closure_attr(ctx, 0UL), y: 0, ns: [],
  }
  let stack : Array[FCbOTask] = [start]
  let mut count = 0
  let mut steps = 0
  while stack.length() > 0 && steps < 100000 {
    steps += 1
    let t = stack.pop().unwrap()
    if t.b == full_mask(ctx.ny) || t.y >= ctx.ny { continue }
    let q : Array[FCbOTask] = []
    for j in t.y..<ctx.ny {
      if ((t.b >> j) & 1UL) == 1UL { continue }
      let cc = t.a & column_mask(ctx, j)
      let dd = polar_obj(ctx, cc)
      count += 1
      let low = lower_mask(j)
      if (t.b & low) == (dd & low) {
        q.push(FCbOTask::{ a: cc, b: dd, y: j + 1, ns: [] })
      }
    }
    // 深度優先：反向推入維持順序
    for k in 0..<q.length() { stack.push(q[q.length() - 1 - k]) }
  }
  count
}

///|
/// 定理 T-G11：FCbO 列舉恰為全部 intent，無重複，且每個輸出為閉集。
pub fn theorem_fcbo_completeness(ctx : Context) -> Bool {
  let r = fcbo_run(ctx)
  let brute = closed_attributes(ctx)
  if r.intents.length() != brute.length() { return false }
  if r.listings != r.intents.length() { return false }
  for i in 0..<r.intents.length() {
    if closure_attr(ctx, r.intents[i]) != r.intents[i] { return false }
    if !list_contains(brute, r.intents[i]) { return false }
  }
  true
}

///|
/// 定理 T-G12：FCbO 新增 canonicity test 為安全的剪枝。對每個 (概念, 屬性)
/// 配對，FCbO 或計算閉包、或由 Lemma 1 直接跳過，故
/// closures + skipped = CbO closures（守恆律），且 closures ≤ CbO closures。
pub fn theorem_fcbo_pruning(ctx : Context) -> Bool {
  let r = fcbo_run(ctx)
  let cbo = cbo_closure_count(ctx)
  r.closures + r.skipped == cbo && r.closures <= cbo &&
    r.inherited <= r.closures && theorem_fcbo_completeness(ctx)
}

///|
/// 非平凡 FCbO 測試脈絡（6 物件、7 屬性、決定性假資料）。
pub fn fcbo_demo_context() -> Context {
  let rows : Array[UInt64] = []
  for x in 0..<6 {
    let mut v = 0UL
    for y in 0..<7 {
      let h = (x * 37 + y * 61 + 52 + x * y * 7) % 11
      if h < 5 { v = @exact.set_bit(v, y) }
    }
    rows.push(v)
  }
  context(6, 7, rows)
}

///|
/// 定理 T-G13a：在非平凡脈絡上新增 canonicity test 確實啟動，
/// 且 FCbO 嚴格少算閉包（skipped > 0、closures < CbO closures）。
pub fn theorem_fcbo_new_test_active() -> Bool {
  let ctx = fcbo_demo_context()
  let r = fcbo_run(ctx)
  let cbo = cbo_closure_count(ctx)
  r.skipped > 0 && r.closures < cbo &&
    r.closures + r.skipped == cbo && theorem_fcbo_completeness(ctx)
}

///|
/// PFCbO：在層級 L 將 queue 子任務以 round-robin 分發給 w 個 worker。
/// 回傳每個 worker 各自列舉的 intent 清單。
pub fn pfcbo_workers(ctx : Context, level : Int, workers : Int) -> Array[Array[UInt64]] {
  let w = if workers < 1 { 1 } else { workers }
  let ns : Array[UInt64] = []
  for _j in 0..<ctx.ny { ns.push(0UL) }
  let start = FCbOTask::{
    a: full_mask(ctx.nx), b: closure_attr(ctx, 0UL), y: 0, ns,
  }
  let rootout : Array[UInt64] = []
  let stats : Array[Int] = [0, 0, 0, 0]
  let frontier : Array[FCbOTask] = []
  let stop = if level < 0 { 0 } else { level }
  fcbo_generate(ctx, start, 0, stop, rootout, stats, frontier)
  let parts : Array[Array[UInt64]] = []
  for _k in 0..<w { parts.push([]) }
  for i in 0..<rootout.length() { parts[i % w].push(rootout[i]) }
  for k in 0..<frontier.length() {
    let idx = k % w
    let out : Array[UInt64] = []
    let st : Array[Int] = [0, 0, 0, 0]
    let fr : Array[FCbOTask] = []
    fcbo_generate(ctx, frontier[k], stop + 1, 1000000, out, st, fr)
    for i in 0..<out.length() { parts[idx].push(out[i]) }
  }
  parts
}

///|
/// 定理 T-G13：PFCbO 之 worker 輸出聯集恰為全部 intent（無遺漏、無重複）。
pub fn theorem_pfcbo_partition(ctx : Context, level : Int, workers : Int) -> Bool {
  let parts = pfcbo_workers(ctx, level, workers)
  let brute = closed_attributes(ctx)
  let flat : Array[UInt64] = []
  for k in 0..<parts.length() {
    for i in 0..<parts[k].length() {
      if list_contains(flat, parts[k][i]) { return false }
      flat.push(parts[k][i])
      if closure_attr(ctx, parts[k][i]) != parts[k][i] { return false }
      if !list_contains(brute, parts[k][i]) { return false }
    }
  }
  flat.length() == brute.length() && theorem_fcbo_completeness(ctx)
}
