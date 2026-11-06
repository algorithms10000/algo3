///|
/// C1 inspect 介面：輸出全局公理與各套件定理的真實計算憑證。
/// 以 `moon run cmd/main` 執行；不做白箱／黑箱／冒煙測試。
fn main {
  println(@c1.report())
}
