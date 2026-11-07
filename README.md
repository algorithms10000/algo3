# C1 — 全局公理伽羅瓦對應（C1-01..C1-06 累積切片）

> 依 `工程內容03.md`／`工程約束.md`／`作業規範.md`／`組合範例.md` 建立之首次切片。
> 全局公理 **G = 伽羅瓦對應（極性伴隨）**；局部公理 L1..L5 由本回合代理決定。
> C1-01 為**首次開發**；C1-02..C1-06 逐回合補回前沿待辦。尚未達成 5,000,000 行／10,000 條演算法之最終目標；未完成部分不列為已完成。

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
- `src/catalog`：498 筆定理／演算法／等式登錄
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
| `moon run cmd/main` | 60 行真實 inspect 憑證，全數 OK |
| 登錄表 | 6 公理／52 定義／8 命題／14 引理／163 定理／155 演算法／100 等式 = 498 筆；前沿文獻 65 筆 |
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

## C1-03：最前沿查證與數學結構落地

依《作業規範》「不時聯網搜查及查證最前沿論文」，本回合查證 R26..R36 共 11 組
（2024 ISSAC/FOCS、2025 TAC/Oberwolfach/FDS、2026 CASC/JNCG），完整書目見
`algorithm.xlsx`「前沿文獻」工作表、`docs/catalog.json` 與 `Dev.txt §2''`。重點：

- **算術譜**：Connes–Consani–Moscovici (arXiv:2511.22755) Zeta Spectral Triples 之
  scaling spectral triple、有限 Euler 積與正則化行列式；Connes–Consani (JNCG 2026)
  把 `Spec Z` 視為無限虧格算術曲線、以 Pic 么半群與 Arakelov 除子推廣 Jacobian。
- **圖譜／離散微分幾何**：Hansen–Ghrist sheaf Laplacian 之 `Δ⁰ = δᵀδ`、
  `ker Δ⁰ = H⁰`；2025 Persistent Sheaf Laplacians 與高維 cellular sheaves；
  Chung 正規化 Laplacian 與 Cheeger `λ₂/2 ≤ h ≤ √(2λ₂)`、improved Cheeger；
  Budninskiy et al. 之離散切空間／平行移動／測地線 PTU。
- **泛性質與函子性**：Doña Mateo (TAC 2025) pushforward monads 之兩個泛性質、
  Kan 擴展 `Nat(Lan_K F, G) ≅ Nat(F, G∘K)`。
- **歪多項式 K 理論**：Quillen–Grayson 基本定理與局部化長正合序列、
  Quillen–Suslin 冪等矩陣演算法、Shin (2024) q-binomial、Oberwolfach 2025 報告。

據此落地（全部寫入既有套件，未新增文檔）：

| 結構 | 實作 | 憑證 |
| --- | --- | --- |
| 算術譜 | `Spec(ℤ/nℤ)` 之 divisor 基底 spectral triple：D=diag Ω(d)、E_p、Hecke T_p、ζ 多項式、Zariski 極性 | T-A1..A4 |
| 拉普拉斯圖譜 | `L=D−A`、Faddeev–LeVerrier χ、Newton 冪和、Kirchhoff 生成樹、KG(5,2) 譜 `{0,2⁵,5⁴}` | T-X1, T-Gph2/3/5 |
| 歸一化圖譜 | `det(L−tD) = det(D)∏(λ_i(ℒ)−t)`、conductance、λ₂、Cheeger；Petersen ℒ 譜 `{0,(2/3)⁵,(5/3)⁴}` | T-Gph4/5 |
| 測地線／切空間 | BFS 測地度量、切空間基底、切束維度 2|E|、Chu 對偶餘切 | T-Gph6/7 |
| 聯絡／纖維束 | O(1) 線叢 ±1 轉移函數、BFS 樹補邊環基、holonomy/曲率、sheaf δ 與 connection Laplacian、Hodge 定理、平坦 ⟺ H⁰=1 | T-Gph8/9/10 |
| 泛性質與函子性 | 纖維積中介態射唯一性、自由么半群 `|Hom|=x²`、關係複合函子性與 Chu 反變性 | T-C17 |
| 歪多項式 K 理論 | F_25[x;σ] 右因子分解、`G₀(R/(f))≅ℤ^s`、基本定理秩序列 1→2→1→0、Morita 冪等 `tr=rank`、σ-binomial | T-K0-1..5 |
| 衍生方向 × 14 範例 | 21 動詞具體變換 × 14 手法不變量 → 21×14 相容矩陣 | T-C18/C19 |

**21×14 相容矩陣實測結果**（`moon run cmd/main`）：294 組配對中 **111 組穩定**
（動詞保持手法不變量）、GF(2) 秩 **12**、動詞列等價類 **20**、441 組動詞複合中
僅 **1 組**保持全部 14 不變量。此為真實計算之非平凡結構，非恆真判定：
`衍生` 保持 12 項、`計算機抽象` 僅 2 項。

## C1-04：最大責任補齊所需數學結構（§6'' 待辦）

依《作業規範》「不時聯網搜查及查證最前沿論文」，本回合再查證 R37..R45 共 9 組
（FOCS 2024 arXiv:2404.05177v2 之 Algorithm 1/2 偽碼、CLA 2010 CEUR Vol-672 paper29
之 FCbO/PFCbO、arXiv:2112.10906 之 persistent sheaf Laplacian 定義與 Prop. 3.1/3.2、
TAC 44(30) pushforward monads、arXiv:2511.22755 / 2602.15941、Kalai–Meshulam 2005/06、
Oberwolfach 2025、Caruso–Le Borgne / Gómez-Torrecillas），完整書目見
`algorithm.xlsx`「前沿文獻」工作表與 `docs/catalog.json`。所有結構皆寫入既有套件，
未新增任何文檔；每項皆先以 Python 交叉原型驗證、再以 MoonBit 局部
`moon test --deny-warn` 即寫即驗即刪，最後全域 CI 驗證。

| §6'' 待辦 | 本回合補回 | 憑證 |
| --- | --- | --- |
| Kinoshita–Li 完整近線性合成 | `kl_pow_proj`（Graeffe + 偶奇壓縮）、`kl_comp`（F_{d,m} 反轉 + 遞迴）、`kl_compose` | T-S12/S13 |
| FFT/NTT／Toom–Cook／TMVP | p=998244353 原根 3 之迭代 NTT、循環嵌入 Toeplitz MVP、5 點求值 Toom–3、複雜度模型 | T-X2..X5 |
| Ore bound／reduced norm／中心分解／參數 gcrd | `ore_reduced_norm`（秩 2 自由模行列式）、`ore_bound` 最小性穷舉、`ore_central_decomposition`、模組 Gröbner、兩層分解 | T-Ore10..15 |
| FCbO 完整 canonicity test／PFCbO | Algorithm 1 之 `N_j`/`M_j` 傳遞與 Lemma 1 剪枝、CbO 守恆律、層級 L round-robin 分發 | T-G11..G14 |
| Persistent sheaf Laplacian 多尺度 filtration | `persistent_laplacian_from_delta` 以精確有理正交投影 `I−Aᵀ(AAᵀ)⁻¹A`、β₀ 秩公式、PSD 主子式、定向不變、多尺度 bars | T-Gph11..Gph15 |
| Connes rank-one／正則化行列式／Spec Z | `connes_rank_one` 行列式引理、`regularized_determinant`、`spectral_zeta`、Lefschetz `exp(Σωt^k/k)`、adelic `AJ(D)=∏p^{e_p}` | T-A5..A8 |
| pushforward monad／Ran／codensity | `Σ_f⊣f*⊣Π_f` 三角伴隨、`T=Π_f f*` 單子律、`Lan_K⊣K*⊣Ran_K`、`Ran_K K` closure operator、橋接公理 G | T-C20..C24 |
| A¹-不變性／非交換動機 | F_5[u] 么模列補全（Quillen–Suslin）、A¹-homotopy `u↦s·u`、Laurent gcd 乘法性、δ-Galois `G_a(F_5)` | T-Ore16..18 |
| δ-Galois／Kalai–Meshulam | F_5[t]/(t⁵) 之 δ-等變平移群與固定環；誘導子複形 Leray 數與擬陣 ρ(V∖τ)≤λ(X) 憑證 | T-Ore16, T-Gph16 |
| 集庫成群 | 對 355 筆真實登錄項抽取 33 位元簽章，Jaccard + union-find 聚類，驗證分割／門檻單調／決定性 | T-C25 |

## C1-05：最大責任補齊 §6''' 剩餘數學結構

依《作業規範》「不時聯網搜查及查證最前沿論文」，本回合再查證 R46..R55 共 10 組
（arXiv:2505.23993v1 高維 sheaf 1-st Laplacian 與 Example 4/5 之 `C⁰(C⁰)ᵀ`、
Pith 對 Hessian recovery 範圍之審查、arXiv:2610.28455v1 之 Bochner/Forman 曲率、
Weil/Hasse–Weil zeta 與顯式公式、arXiv:2611.07262（2026-11-05）higher additive
noncommutative motives、Hilman arXiv:2202.02591v3、Bachmann–Elmanto–Morrow
arXiv:2508.09915、BGT/Tabuada `U_add`、arXiv:2503.03429/2510.07323 之 PV、
Kovacic HAL hal-04117227v1）。完整書目見 `algorithm.xlsx`「前沿文獻」與
`docs/catalog.json`。本回合僅修改既有檔案，未新增任何文檔。

| §6''' 待辦 | 本回合補回 | 憑證 |
| --- | --- | --- |
| 高維 sheaf 1-st persistent Laplacian／環模值層／ANM Hessian | R=ℚ[ε]/ε² 秩 1 環值層之 `d¹d⁰=0`、q=1 persistent 1-st Laplacian、ANM `L⁰_F=H_ANM` 與 6 rigid modes；並以 BigInt Bareiss 修復 12×12 `L¹` 主子式之 Int64 溢位 | T-Gph17..Gph20, T-X6 |
| Connes／Spec Z 解析極限之可計算憑證 | 六條 F_q 橢圓曲線逐條精確算 N₁、a、Nₙ、Z(E,T)、函數方程、Hasse–Weil 界（有限域曲線 RH）、Weil 顯式公式之 `exp(L_N)·Q≡P` 與精確有理餘項界 | T-W1..W7 |
| 非交換動機／導出方案連續 K 理論 | F_p[t,u]/(t^k,u^l) 之 Newton–Hensel 冪等元提升（K₀ 冪零不變）、塔 R_k→R_{k−1} 之連續性、u↦0 之 KH A¹-同倫不變、關係矩陣回代求 `U_add` 之泛性質 | T-NCM1..NCM5 |
| 一般 Picard–Vessiot／δ-Galois | 任意二階 δ-模 ∇=δ−A(t) 之解空間維度、基本解矩陣與 Abel 恆等式、gauge 群精確階數 480/20/16/480、Kovacic 第一型「Riccati 根數＝不變直線數＝dim V」有限 Galois 對應、C1-04 `G_a(F₅)` 嵌入 | T-PV1..PV4 |

## C1-06：量子二維環面 O_q(T²)／Abel–Jacobi／21 動詞 × 14 範例相互交織

依《作業規範》「不時聯網搜查及查證最前沿論文」，本回合查證 R56..R65 共 10 組
（arXiv:1503.06045 之 Γ-bundle 配對 Proposition 3、Evans–Jones CMP 406 (2025)
量子對稱、arXiv:2412.03929 之 Jacobi variety 與 Abel–Jacobi 定義、Connes–Consani
`Jac(Spec Z)=Pic/R_+^*`、Rieffel–Schwarz SL₂(ℤ) Morita 與 `K₀=ℤ+θℤ`、
2026 年 Garoufalidis–Yu／Panitch–Park 之 quantum trace map、Bonahon–Wong
localized quantum torus、Weil pairing/theta group）。完整書目見
`algorithm.xlsx`「前沿文獻」與 `docs/catalog.json`。本回合僅修改既有檔案，未新增文檔。

| 落地結構 | 內容 | 憑證 |
| --- | --- | --- |
| 量子二維環面 `O_q((F^×)²)` | `VU=qUV`、2-上循環 `ω=b·c`、正則循環跡 τ、導數 δ₁/δ₂ 與 Connes 循環 2-上循環、qⁿ=1 之中心、F₇ 上 q=2 之 Heisenberg clock/shift 表示、Weil 配對與交換子互逆、SL₂(ℤ) Morita 分式線性作用 | T-QT1..QT8 |
| Abel–Jacobi 映射 | E/F_q 弦切群律、AJ(`Σn_i[P_i]`) 同態、垂直／直線主除子之 Abel 定理、`\|Jac(E)\|=N₁=P(1)` 與 Weil zeta 交織、Γ-bundle 配對 `q^{r−s−km}`、`AJ_q : F_p^*→F_p^*/⟨q⟩`、E(F₇)[3]≅(ℤ/3)² 標號與 Weil 配對 | T-AJ1..AJ7 |
| 21 動詞 × 14 範例 × 數學結構 × 自身交織 | 21 動詞表示為 End(A_q) 之線性算子 ρ(v)、14 範例以 `deriv_invariant` 實算值造狀態 Φ_p、`W[v][p]=τ(ρ(v)Φ_p)`；與自身交織得 Gram `WWᵀ/WᵀW`（秩 11、跡 2932）、Kronecker `rank(K⊗K)=rank(K)²=9`、441 個複合算子張成完整 `End(A_q)`（維度 81）、全局公理 G 之概念格（物件／屬性閉集皆 240）、Weil 配對 = 交換子互逆且落於 `AJ_q` 之核 | T-IW1..IW7 |

實測：21×14 交織矩陣 ℚ-秩 11／GF(7)-秩 3／非零項 185／概念數 240／
21 算子張成 14 維／441 複合張成 81 維；`moon run cmd/main` 之 inspect 報表
60 行全數 OK。

## 未完成（誠實標記）

- 5,000,000 行程式碼、10,000 條中階以上演算法：目前 **155 / 10,000** 條演算法、
  約 1.4 萬行，仍為早期切片；「集庫成群」已建立聚類演算法與憑證，但庫規模本身未達最終目標。
- Connes 譜 triple 之**無限維解析極限／RH 一般等價證明**、Spec Z 之 archimedean
  adelic Abel–Jacobi 解析：已有逐條有限域曲線與有理餘項界的有限精確憑證，
  以及 q-商 `F_p^*/⟨q⟩` 之有限 Abel–Jacobi；皆非 ℂ 上無限維週期積分或一般解析極限。
- 高階 K 理論、導出方案之 ∞-範疇極限、higher motives（(∞,n)-category 層級）：
  目前只到 K₀ 有限層。
- 無限維複數域 PV 擴張、代數閉包上完整 δ-Galois 群、解析單值群、Kovacic II/III：
  目前為 F_p[t]/(t^p) 上任意二階 δ-模之有限精確模型。
- 量子環面之 C*-範數完備化、無理 θ 之 Powers–Rieffel 投影解析構造、
  q 非單位根之無限維 Γ-bundle（R56 之 uncountably categorical 結構）：
  目前為 qⁿ=1 之 n² 維有限 root algebra 與精確 q-指數配對。
- `docs/` 其餘設計文件：依《工程約束》「非首次開發、創建新文檔前需先獲准」，
  本回合不另建新文檔，改以既有 `Dev.txt`、`README.md` 與各資料夾 README 記錄。
- git 仍無 remote：CI workflow 與 commit 僅本機落地，**未 push**。

## 接入／輸出接口

- 接入：`@c1.report()`、`@catalog.catalog()`、各套件 `pub fn`。
- 輸出：stdout inspect 報表、`algorithm.xlsx`、`docs/catalog.json`、wasm artifact。
