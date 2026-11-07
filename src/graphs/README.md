# src/graphs — 克內澤圖、Ramsey、擬陣 Tutte、單純複形 Betti、圖極性

> C1-01 首次開發切片／C1-02 補回更新。本檔由 `tools/build_readmes.py` 自實際程式與登錄表產生。

## 已獲得定理列表

- **T-K1** Lovász：χ(KG(n,k)) = n−2k+2
- **T-K2** EKR：α(KG(n,k)) = C(n−1,k−1)
- **T-K3** 分數色數 χ_f=n/k 為 χ 的下界
- **T-R1** Ramsey R(3,3)=6
- **T-Mat1** Tutte 多項式 T(1,1)=基底數、T(2,2)=2^{|E|}
- **T-Cx1** Euler–Poincaré：Σ(−1)^d f_d = Σ(−1)^d β_d
- **T-Gph1** 圖鄰接極性的 Chu 對偶

## 已實作演算法列表

- **AL042** chromatic_number 回溯 + 對稱破壞（P（分支限界））
- **AL043** max_clique Bron–Kerbosch 位元版（P（分支限界））
- **AL044** ramsey_triangle_free_count 穷舉證明（O(2^E·n³)）
- **AL045** tutte_coeffs 秩生成式二項展開（O(2^|E|·|E|²)）
- **AL046** boundary_rank / betti_numbers GF(2) 同調（O(f_d·f_{d-1})）

## 等式

- **E19** Lovász 色數：`χ(KG(n,k)) = n − 2k + 2`
- **E20** EKR 獨立數：`α(KG(n,k)) = C(n−1, k−1)`
- **E21** Tutte 秩生成式：`T(M;x,y) = Σ_A (x−1)^{r(E)−r(A)} (y−1)^{|A|−r(A)}`
- **E22** Betti 數：`β_d = dim ker ∂_d − rank ∂_{d+1}`
- **E23** Euler–Poincaré：`Σ(−1)^d f_d = Σ(−1)^d β_d`
- **E29** Ramsey：`R(3,3) = 6`
- **E30** 分數色數：`χ_f(KG(n,k)) = n/k ≤ χ`

## 資料夾視角依賴關係圖

```text
[src/graphs]
  ├─ 依賴 → src/exact
  ├─ 依賴 → src/galois
  └─ 被依賴 ← src/compose
  └─ 被依賴 ← .
```

## 動線

位元遮罩圖 → 回溯色數／BK 團 → Kneser 定理；GF(2) 邊界矩陣 → Betti。

## 接入／輸出接口

接入：n,k 或位元遮罩鄰接列。輸出：chromatic_number、max_clique、betti_numbers、tutte_coeffs、theorem_*。

實際公開符號（擷取自本資料夾 .mbt）：

```text
  kneser_vertices  kneser_adjacent  kneser_adjacency  complement_adjacency
  chromatic_number  max_clique  max_independent_set  theorem_lovasz_kneser
  theorem_ekr  fractional_chromatic  theorem_fractional_bound  has_mono_triangle
  ramsey_triangle_free_count  ramsey_witness  theorem_ramsey_33  matroid
  matroid_rank  matroid_is_independent  tutte_coeffs  tutte_eval
  matroid_bases  theorem_tutte_evaluations  complex_from_facets  boundary_rank
  betti_numbers  euler_characteristic  theorem_euler_poincare  graph_context
  graph_concept_count  theorem_graph_chu_dual  Matroid  Complex
```

## 驗證

```bash
export PATH=/tmp/moonhome/bin:$PATH
cd /home/user/c1
moon check src/graphs --deny-warn
```
