# src/graphs — 克內澤圖、Ramsey、擬陣 Tutte、單純複形 Betti、圖極性

> C1-01 首次開發切片／C1-02 補回／C1-03 數學結構落地／C1-04 前沿待辦補齊／C1-05 §6''' 剩餘結構補回／C1-06 量子環面與 21×14 交織／C1-07 黃金比例、陳–西蒙斯與全代碼健檢。本檔由 `tools/build_readmes.py` 自實際程式與登錄表產生。

## 已獲得定理列表

- **T-K1** Lovász：χ(KG(n,k)) = n−2k+2
- **T-K2** EKR：α(KG(n,k)) = C(n−1,k−1)
- **T-K3** 分數色數 χ_f=n/k 為 χ 的下界
- **T-R1** Ramsey R(3,3)=6
- **T-Mat1** Tutte 多項式 T(1,1)=基底數、T(2,2)=2^{|E|}
- **T-Cx1** Euler–Poincaré：Σ(−1)^d f_d = Σ(−1)^d β_d
- **T-Gph1** 圖鄰接極性的 Chu 對偶
- **T-Gph2** Newton 恆等式：tr(L^j) 由 det(tI−L) 係數決定
- **T-Gph3** Kirchhoff：L·1=0、rank(L)=n−#components、生成樹 >0 ⟺ 連通
- **T-Gph4** Chung/Dodziuk–Alon–Milman Cheeger：λ₂/2 ≤ h ≤ √(2λ₂)
- **T-Gph5** KG(5,2)=Petersen：L 譜 {0,2⁵,5⁴}，ℒ 譜 {0,(2/3)⁵,(5/3)⁴}
- **T-Gph6** BFS 測地距離為度量（對稱、三角不等式）
- **T-Gph7** 切束維度 Σ_v dim T_v = 2|E|，餘切由 Chu 對偶給出
- **T-Gph8** 離散 Hodge：Δ⁰=δᵀδ=聯絡 Laplacian，ker Δ⁰=ker δ
- **T-Gph9** O(1) 線叢平坦 ⟺ 環 holonomy=+1 ⟺ dim H⁰=1
- **T-Gph10** 測地線平行移動 holonomy ∈{±1} 且路徑反向不變
- **T-Gph11** ker Δ₀^{X,Y} ≅ π•(H⁰(Y;G))：nullity = persistent Betti
- **T-Gph12** Δ₀^{X,Y} 半正定（全主子式 ≥0）且零根重數 = β₀
- **T-Gph13** X=Y 時 persistent Laplacian 退化為 δᵀδ
- **T-Gph14** Wei–Wei Prop.3.2：譜不依賴 Y 之定向
- **T-Gph15** 多尺度 filtration 之 β₀ 單調不減、rank+nullity=k
- **T-Gph16** Kalai–Meshulam：M⊆X ⇒ ∃τ∈X, ρ(V∖τ) ≤ λ(X)
- **T-Gph17** 高維環值層：d¹d⁰=0、L¹=d⁰(d⁰)ᵀ+(d¹)ᵀd¹ 對稱 PSD、nullity L¹=β¹
- **T-Gph18** persistent q=1 sheaf Laplacian：鏈條件、Hodge nullity=β_p
- **T-Gph19** ANM Hessian：L⁰_F=H_ANM、6 rigid modes、rank C⁰=3n−6
- **T-Gph20** 高維 sheaf 三組憑證合取（環值層 / persistent / ANM）

## 已實作演算法列表

- **AL042** chromatic_number 回溯 + 對稱破壞（P（分支限界））
- **AL043** max_clique Bron–Kerbosch 位元版（P（分支限界））
- **AL044** ramsey_triangle_free_count 穷舉證明（O(2^E·n³)）
- **AL045** tutte_coeffs 秩生成式二項展開（O(2^|E|·|E|²)）
- **AL046** boundary_rank / betti_numbers GF(2) 同調（O(f_d·f_{d-1})）
- **AL068** spectral_power_sums Newton 恆等式冪和（O(k²)）
- **AL069** graph_spanning_trees Kirchhoff 餘子式（O(n³)）
- **AL070** graph_conductance 體積加權最小割（O(2^n·n)）
- **AL071** graph_normalized_charpoly 廣義特徵多項式（O(n⁴)）
- **AL072** geodesic_distances / geodesic_path BFS（O(n²)）
- **AL073** tangent_space 切空間基底（O(n)）
- **AL074** cycle_basis BFS 樹補邊 + LCA 基本環（O(n³)）
- **AL075** holonomy / curvature 平行移動與曲率（O(|E|)）
- **AL076** sheaf_coboundary / sheaf_laplacian（O(|E|n²)）
- **AL077** connection_laplacian O(1) 線叢（O(n²)）
- **AL103** persistent_laplacian_from_delta / kernel_projector（O(m³+k²m)）
- **AL104** persistent_sheaf_bars 多尺度 filtration（O(n·m³)）
- **AL105** leray_number / induced_complex / kalai_meshulam_witness（O(2^n·n³)）
- **AL111** sheaf2_delta0 / sheaf2_delta1 / sheaf2_laplacian1（O(|E|²+|T|²)）
- **AL112** psd_principal_minors（BigInt Bareiss 主子式穷舉）（O(2^n·n³)）
- **AL113** sheaf1_persistent_betti / sheaf1_persistent_laplacian（O(m³·|X|)）
- **AL114** anm_coboundary / anm_hessian / anm_rigid_modes（O(n³)）

## 等式

- **E19** Lovász 色數：`χ(KG(n,k)) = n − 2k + 2`
- **E20** EKR 獨立數：`α(KG(n,k)) = C(n−1, k−1)`
- **E21** Tutte 秩生成式：`T(M;x,y) = Σ_A (x−1)^{r(E)−r(A)} (y−1)^{|A|−r(A)}`
- **E22** Betti 數：`β_d = dim ker ∂_d − rank ∂_{d+1}`
- **E23** Euler–Poincaré：`Σ(−1)^d f_d = Σ(−1)^d β_d`
- **E29** Ramsey：`R(3,3) = 6`
- **E30** 分數色數：`χ_f(KG(n,k)) = n/k ≤ χ`
- **E41** Newton 冪和：`p_k = e₁p_{k−1} − e₂p_{k−2} + ⋯ + (−1)^{k−1}k e_k`
- **E42** Kirchhoff：`τ(G) = det L^{(i,i)}；rank L = n − c(G)`
- **E43** Cheeger：`λ₂/2 ≤ h(G) ≤ √(2λ₂)`
- **E44** 正規化廣義特徵：`det(L − tD) = det(D)·∏(λ_i(ℒ) − t)`
- **E45** 離散 Hodge：`Δ⁰_F = δᵀδ；ker Δ⁰ = H⁰(G;F)`
- **E57** Persistent sheaf Laplacian：`Δ₀^{X,Y}=M Proj_Θ Mᵀ，Proj_Θ=I−Aᵀ(AAᵀ)⁻¹A`
- **E58** Persistent Betti：`β₀^{X,Y}=(n−rankδ_Y)−((n−k)−rankδ_Y[:,k:])`
- **E59** Kalai–Meshulam：`M⊆X ⇒ ∃τ∈X: ρ(V∖τ) ≤ λ(X)`
- **E66** 高維 sheaf 1-st Laplacian：`L¹_F = C⁰(C⁰)ᵀ + (C¹)ᵀC¹，d¹d⁰=0 ⇒ ker L¹ ≅ H¹`
- **E67** Hodge–de Rham（有限層）：`nullity L¹ = dim C¹ − rank d⁰ − rank d¹ = β¹`
- **E68** ANM Hessian：`L⁰_F = H_ANM = C⁰(C⁰)ᵀ，dim H⁰ = 6 rigid modes`

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
  graph_concept_count  theorem_graph_chu_dual  graph  graph_degree
  graph_edge_count  graph_adj_mat  graph_deg_mat  graph_laplacian
  graph_spectral_moments  spectral_power_sums  theorem_laplacian_newton  graph_spanning_trees
  graph_component_count  theorem_kirchhoff  graph_conductance  graph_normalized_charpoly
  graph_normalized_lambda2  theorem_cheeger  theorem_petersen_spectra  geodesic_distances
  geodesic_path  theorem_geodesic_metric  tangent_space  tangent_bundle_dim
  theorem_tangent_bundle  line_bundle  bundle_sign  cycle_basis
  holonomy  curvature  is_flat  connection_laplacian
  sheaf_coboundary  sheaf_laplacian  global_sections_dim  theorem_sheaf_hodge
  theorem_flat_sections  theorem_parallel_transport_geodesic  persistent_sheaf  persistent_laplacian_from_delta
  persistent_sheaf_laplacian  persistent_sheaf_betti0  persistent_sheaf_nullity  psd_principal_minors
  theorem_persistent_sheaf_hodge  theorem_persistent_sheaf_psd  theorem_persistent_sheaf_limit  negate_coboundary_row
  theorem_persistent_sheaf_orientation  persistent_sheaf_bars  theorem_persistent_sheaf_filtration  induced_complex
  is_face  reduced_homology_top  leray_number  kalai_meshulam_witness
  theorem_kalai_meshulam  sheaf2  sheaf2_delta0  sheaf2_delta1
  sheaf2_laplacian1  sheaf2_betti1  sheaf2_demo  theorem_sheaf2_hodge
  sheaf1_persistent  sheaf1_demo  sheaf1_persistent_laplacian  sheaf1_persistent_betti
  theorem_sheaf1_persistent  anm_sheaf  anm_demo  anm_coboundary
  anm_hessian  anm_rigid_modes  anm_down_laplacian  theorem_anm_hessian
  theorem_sheaf_certificates  Matroid  Complex  Graph
  LineBundle  PersistentSheaf  Sheaf2  Sheaf1Persistent
  AnmSheaf
```

## 驗證

```bash
export PATH=/tmp/moonhome/bin:$PATH
cd /home/user/c1
moon check src/graphs --deny-warn
```
