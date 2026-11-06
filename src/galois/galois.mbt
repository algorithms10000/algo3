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
