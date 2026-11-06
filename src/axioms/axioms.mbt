///|
/// C1 / src/axioms — 程式側：與 .mbtp 述詞共用之純函數與帶規格的可執行函數。

///|
/// 單項式商環 ℤ[t]/(t^d) 的 Hilbert 函數：h(n,d) = [0 ≤ n < d]。
#proof_pure
fn hcoeff(n : Int32, d : Int32) -> Int32 {
  if 0 <= n && n < d { 1 } else { 0 }
}

///|
/// 全局公理 G 之反色調極性（整數模型）：F(x) = -x。
pub fn polar(x : Int32) -> Int32 where {
  proof_ensure: result => result + x == 0,
} {
  -x
}

///|
/// F∘H∘F：極性三次合成，規格要求等於 F。
pub fn polar_triple(x : Int32) -> Int32 where {
  proof_ensure: result => result + x == 0,
} {
  polar(polar(polar(x)))
}

///|
/// 閉包算子 c = H∘F 在整數模型上的可執行實例 c(x) = max(x,0)。
pub fn closure_apply(x : Int32) -> Int32 where {
  proof_ensure: result => result >= x,
  proof_ensure: result => result >= 0,
} {
  if x >= 0 { x } else { 0 }
}

///|
/// 閉包冪等性之可執行憑證：回傳 1 表示 c(c(x)) = c(x)。
pub fn closure_idempotent_cert(x : Int32) -> Int32 where {
  proof_ensure: result => result == 0 || result == 1,
} {
  if closure_apply(closure_apply(x)) == closure_apply(x) { 1 } else { 0 }
}

///|
/// ℤ[[t]]/(t²) 卷積（截斷商環乘法），供上層套件與憑證查核使用。
pub fn conv2(a0 : Int32, a1 : Int32, b0 : Int32, b1 : Int32) -> Array[Int32] {
  [a0 * b0, a0 * b1 + a1 * b0]
}

///|
/// q-整數 [i]_q（i ≤ 6）以 Horner 展開，對應 Ore 環 σ(t)=qt 之 δ(t^i)=[i]_q t^{i-1}。
pub fn qint(i : Int32, q : Int32) -> Int32 {
  let mut acc = 0
  for k = 0; k < i; k = k + 1 { acc = acc * q + 1 }
  acc
}

///|
/// 右手遞推量 δ_{n,0} − δ_{n,d}。
#proof_pure
pub fn hilbert_delta(n : Int32, d : Int32) -> Int32 {
  (if n == 0 { 1 } else { 0 }) - (if n == d { 1 } else { 0 })
}

///|
/// Hilbert 函數查表（hcoeff 的對外封裝）。
pub fn hilbert_coeff(n : Int32, d : Int32) -> Int32 { hcoeff(n, d) }
