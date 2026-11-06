# C1 — 全局公理伽羅瓦對應（C1-01 首次開發切片）

> 依 `工程內容03.md`／`工程約束.md`／`作業規範.md`／`組合範例.md` 建立之首次切片。
> 全局公理 **G = 伽羅瓦對應（極性伴隨）**；局部公理 L1..L5 由本回合代理決定。
> 本回合為**首次開發**，尚未達成 5,000,000 行／10,000 條演算法之最終目標；未完成部分不列為已完成。

## 全局公理

有限集合 X,Y 與關係 R ⊆ X×Y，定義
`F(A) = { y∈Y | ∀x∈A, R(x,y) }`、`H(B) = { x∈X | ∀y∈B, R(x,y) }`，
則 `A ⊆ H(B) ⟺ B ⊆ F(A)`；`c = F∘H` 為閉包算子，`Fix(c) ≅ Fix(c')^op` 為完備格。

## 局部公理

| 編號 | 內容 |
| --- | --- |
| L1 | 有限支撐：精確有理係數與明確截斷次數 N |
| L2 | 卷積么半群 `(a*b)(m)=Σ_{u*v=m}a(u)b(v)`（統一 Poly/FPS/Laurent/Dirichlet/Quotient） |
| L3 | 截斷商 `π_N: ℚ[[t]] → ℚ[[t]]/(t^N)` |
| L4 | 極性矩陣／楚空間：轉置為鏡像對偶 |
| L5 | 有限域算術：Int64 + egcd 求逆、GF(2) 位元打包消去 |

## 套件與依賴

```text
src/exact    ──► src/axioms ──► src/galois ──► src/series ──► src/algebra ──► src/graphs
    │                              │                │               │              │
    └──────────────────────────────┴────────────────┴───────┬───────┴──────────────┘
                                                           ▼
                                                      src/compose
                                                           │
                                                           ▼
                                                      src/catalog ──► cmd/main ──► stdout
```

- `src/exact`：精確算術、GF(2) 秩、Smith 標準型
- `src/axioms`：`.mbtp` 形式化驗證（Z3，17 goals proved，無 trusted assumption）
- `src/galois`：極性、閉包格、NextClosure、Chu 對偶、理想–簇對應
- `src/series`：多項式環、形式冪級數環、洛朗級數環、狄利克雷級數、多項式商環、全純函數、Newton/Lagrange、操作子代入
- `src/algebra`：歪多項式環（Ore）、Hilbert–Poincaré 級數、局部化、Ext¹、Morita
- `src/graphs`：克內澤圖、Lovász/EKR、Ramsey、擬陣 Tutte、單純複形 Betti
- `src/compose`：14 種組合手法（Kan、束、纖維積、單子、張量、纖維範疇、推出、交織、博弈管線等）
- `src/catalog`：183 筆定理／演算法／等式登錄
- `algorithm.xlsx`：由 `docs/catalog.json` 單一來源產生之活頁簿
- `Dev.txt`：流水式帳本；`AGENT.md` 與 `工程約束.md` 為同一份文件

## 工具鏈

MoonBit latest stable：`moon 0.1.20261104 (940aa18)`／`moonc v0.10.20+65efd5b93 (2026-11-05)`，
`moon.mod`／`moon.pkg` 新 DSL，Z3 5.3.3 由 `moon prove` 呼叫。

```bash
export PATH=/tmp/moonhome/bin:$PATH
cd /home/user/c1
moon check --deny-warn
moon prove --deny-warn
moon build
moon run cmd/main
```

## 本回合驗證結果

| 項目 | 結果 |
| --- | --- |
| `moon check --deny-warn`（全域） | Finished，21 tasks |
| `moon prove --deny-warn` | `1 of 1 packages proved, 17 goals proved` |
| `moon build` | wasm artifact 生成 |
| `moon run cmd/main` | 31 行真實 inspect 憑證，全數 OK |
| 登錄表 | 6 公理／20 定義／8 命題／14 引理／53 定理／52 演算法／30 等式 = 183 筆 |
| CI | `.github/workflows/c1-ci.yml` 推送全域編譯與形式化驗證 |

## 未完成（誠實標記）

- 5,000,000 行程式碼、10,000 條中階以上演算法、集庫成群：本回合僅為首次切片，遠未達成。
- 高階複雜度仍有多處 `O(N²)` 卷積（尚未接入 FFT／fast multiplication）。
- 多元優質算法庫之跨回合延伸、更多前沿論文查證與基準測試（沙盒無需）。
- `docs/` 目前僅有 catalog.json；其餘設計文件待後續回合。

## 接入／輸出接口

- 接入：`@c1.report()`、`@catalog.catalog()`、各套件 `pub fn`。
- 輸出：stdout inspect 報表、`algorithm.xlsx`、`docs/catalog.json`、wasm artifact。
