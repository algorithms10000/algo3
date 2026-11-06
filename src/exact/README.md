# src/exact — 精確算術層：Rat、gcd/egcd、模算術、GF(2) 秩、Smith 標準型

> C1-01 首次開發切片。本檔由 `tools/build_readmes.py` 自實際程式與登錄表產生。

## 已獲得公理

- **A-L1** 有限支撐公理：精確有理係數 + 明確截斷次數
- **A-L5** 有限域算術公理：Int64 模運算 + GF(2) 位元打包

## 已獲得定理列表

- **L14** GF(2) 秩-零化度：dim ker = ncols − rank

## 已實作演算法列表

- **AL001** gcd / egcd 歐幾里得與擴展歐幾里得（O(log min(a,b))）
- **AL002** rat 有理數正規化與四則運算（O(log d)）
- **AL003** Rat::pow 二進位快速冪（O(log k)）
- **AL004** mod_pow / mod_inv 模冪與模逆（O(log e)）
- **AL005** binom Pascal 動態規劃（O(n·k)）
- **AL006** popcount Kernighan 位元計數（O(#1-bits)）
- **AL007** gf2_rank / gf2_nullity 位元打包消去（O(rows·cols/64)）
- **AL008** rank_mod_p 素數體矩陣秩（O(r²c)）
- **AL009** smith_invariants Smith 標準型與可整除鏈（多項式時間）

## 資料夾視角依賴關係圖

```text
[src/exact]
  └─ 被依賴 ← src/galois
  └─ 被依賴 ← src/series
  └─ 被依賴 ← src/algebra
  └─ 被依賴 ← src/graphs
  └─ 被依賴 ← src/compose
  └─ 被依賴 ← .
```

## 動線

Int64/UInt64 位元 → gcd/Rat/矩陣秩 → 供所有上層套件做精確係數與 GF(2) 消去。

## 接入／輸出接口

接入：Int64/UInt64 位元資料。輸出：Rat、gcd、gf2_rank、rank_mod_p、smith_invariants、binom、popcount。

實際公開符號（擷取自本資料夾 .mbt）：

```text
  gcd  egcd  lcm  rat
  rat_checked  rat_zero  rat_one  rat_int
  Rat::add  Rat::sub  Rat::neg  Rat::mul
  Rat::inv  Rat::div  Rat::cmp  Rat::equal
  Rat::is_zero  Rat::pow  Rat::to_string  mod_pow
  mod_inv  fp_add  fp_mul  fp_sub
  binom  factorial  popcount  bit
  set_bit  clear_bit  gf2_rank  gf2_nullity
  rank_mod_p  smith_invariants  det2  Rat
  Bezout
```

## 驗證

```bash
export PATH=/tmp/moonhome/bin:$PATH
cd /home/user/c1
moon check src/exact --deny-warn
```
