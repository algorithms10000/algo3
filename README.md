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
| 登錄表 | 6 公理／20 定義／8 命題／14 引理／63 定理／62 演算法／38 等式 = 211 筆；前沿文獻 25 筆 |
| CI | `.github/workflows/c1-ci.yml` 推送全域編譯與形式化驗證 |

## C1-02：前沿查證與 §6 待辦補回

依《作業規範》「不時聯網搜查及查證最前沿論文」，本回合查證 13 組新文獻（R13..R25），
完整書目、URL 與理論要點見 `algorithm.xlsx` 之「前沿文獻」工作表、`docs/catalog.json`
與 `Dev.txt §2`。重點：

- **Ore 分解新法**：Giesbrecht (CASC 2026, arXiv:2607.02751) 量子平面 `K(t)[x;σ], σ(t)=ωt`
  之中心 `K(t^m)[x^m]`、monic central bound、gcrd 分割、特殊化 → inert prime → 有限域
  Caruso–Le Borgne 分解 → 插值提升；Ding–Wang–Xiao–Zheng (ISSAC'24) 之 Ore Sylvester
  矩陣與模組 Gröbner 基底參數 gcrd；Caruso–Le Borgne (2017) reduced norm 與
  §3.2.2 擴展右歐幾里得；Giesbrecht (1992) 之 `deg lclm = deg f + deg g − deg gcrd`。
- **NextClosure 平行化**：Kriegel–Borchmann (CLA 2015) 指出 lectic 順序本質序列、無法平行；
  改以**基數遞增層級**枚舉 intents/pseudo-intents，同層候選獨立且無需通訊；
  Kriegel (2016) 以第二閉包算子為約束、quasi-rank 函數與平行 Attribute Exploration；
  de Moraes et al. (2023) 以物件子脈絡 + OpenMP 切分 In-Close 4。
- **高階乘法**：Kinoshita–Li (FOCS 2024, arXiv:2404.05177) 以 Bostan–Mori Graeffe
  迭代 + 轉置原理把合成降至 `O(M(n) log m + M(m))`；Puchinger–Wachter-Zeh (2017)
  次二次 skew 乘法；Lyu 之 KaratsubaSkew；Johansson (2011) 快速反演。

據此把 §6 未完成待辦補回為真實演算法：

| §6 待辦 | 本回合補回 | 憑證 |
| --- | --- | --- |
| Ore lclm 完整演算法 | F_25 (θ²=2, σ(θ)=−θ) 上 `sfq_gcrd_lclm` 擴展右歐幾里得、`sfq_sylvester_rank` Ore Sylvester 秩 | T-Ore7/8/9 |
| 高階常數級優化 | `kar_mul` Karatsuba、`fps_compose_bk` BK baby-step/giant-step、`graeffe_coeff` Graeffe 係數抽取 | T-S9/10/11 |
| 後續回合聯網查證前沿論文 | R13..R25 共 13 組（含 2024/2025/2026 新法） | algorithm.xlsx「前沿文獻」 |
| NextClosure 平行化 | `next_closure_constrained`、`intents_by_cardinality`、`parallel_intent_partition` | T-G8/9/10 |

θ²=2 在 F_5 中非平方，故 F_25 為體且 σ ≠ id，實作的是**真正非交換** Ore 環，
非退化為交換多項式環的玩具模型。

## 未完成（誠實標記）

- 5,000,000 行程式碼、10,000 條中階以上演算法、集庫成群：目前仍為早期切片，遠未達成。
- Kinoshita–Li 之**完整近線性合成**（Graeffe + 轉置原理）尚未落地；本回合僅實作
  BK baby-step/giant-step 搭配 Karatsuba，以及 Bostan–Mori 係數抽取之 Graeffe 遞迴。
- FFT/NTT 完整乘法、Ore bound 演算法、Giesbrecht 兩層模組分解、參數 gcrd Gröbner
  基底、FCbO 完整 canonicity test 仍待後續回合。
- 多元優質算法庫之跨回合延伸、δ-Galois 推廣、Kalai–Meshulam 拓樸組合。
- `docs/` 其餘設計文件：依《工程約束》「非首次開發、創建新文檔前需先獲准」，
  本回合不另建新文檔，改以既有 `Dev.txt`、`README.md` 與各資料夾 README 記錄。

## 接入／輸出接口

- 接入：`@c1.report()`、`@catalog.catalog()`、各套件 `pub fn`。
- 輸出：stdout inspect 報表、`algorithm.xlsx`、`docs/catalog.json`、wasm artifact。
