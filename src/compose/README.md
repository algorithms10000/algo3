# src/compose — 14 種組合手法：Kan、束、纖維積、單子、張量、纖維範疇、推出、交織、博弈

> C1-01 首次開發切片／C1-02 補回／C1-03 數學結構落地／C1-04 前沿待辦補齊。本檔由 `tools/build_readmes.py` 自實際程式與登錄表產生。

## 已獲得定理列表

- **P6** 束的匹配族由限制映射兩兩相容定義
- **P8** 進位函數為正規化 2-上循環
- **T-C1** 左 Kan 擴展伴隨 Lan_φ ⊣ φ*
- **T-C2** 右 Kan 擴展伴隨 φ* ⊣ Ran_φ
- **T-C3** 纖維積 ℤ/m×_{ℤ/g}ℤ/n 泛性質
- **T-C4** 共融推出 union-find 泛性質
- **T-C5** 共融自由交換么半群單項式計數
- **T-C6** 分配律單子複合仍為單子
- **T-C7** 全局公理 G 的閉包算子本身為單子
- **T-C8** Kronecker 混合積 (A⊗B)(C⊗D)=AC⊗BD
- **T-C9** Kronecker 秩可乘性
- **T-C10** 管線策略合成結合律
- **T-C11** 博弈張量積交換律
- **T-C12** Grothendieck 構造給出纖維範疇
- **T-C13** 有限 Alexandrov 拓樸之束黏合唯一性
- **T-C14** 2-上循環交織群結合律與短正合序列
- **T-C15** 多合一相容性：跨套件定理同時成立
- **T-C16** 前沿方法一致性：Ore lclm／NextClosures 平行／Karatsuba／Graeffe 同時成立
- **T-C17** 泛性質：纖維積中介態射唯一、自由么半群 |Hom|=x²、函子性
- **T-C18** 21×14 衍生方向相容矩陣非平凡；GF(2) 秩=12
- **T-C19** 泛性質 × 21 動詞 × 14 手法之一致性
- **T-C20** Σ_f ⊣ f* ⊣ Π_f 三角伴隨（穷舉 2^nx·2^ny）
- **T-C21** pushforward monad T=Π_f f*=Ran_f f* 滿足單子律
- **T-C22** Lan_K ⊣ K* ⊣ Ran_K（協變預層之有限穷舉）
- **T-C23** codensity monad Ran_K K 為 closure operator
- **T-C24** Π_f 橋接全局公理 G：Π_f P_A = F(A)
- **T-C25** 集庫成群：聚類分割、Jaccard 門檻、單調性與決定性

## 已實作演算法列表

- **AL047** lan_poset / ran_poset 有限格 Kan 擴展（O(|C|·|D|)）
- **AL048** UnionFind 共融推出同餘閉包（O(n α(n))）
- **AL049** kronecker / relation_tensor 張量積（O(r²c²)）
- **AL050** gluing_rec 束匹配族枚舉（O(Π|F(U_i)|)）
- **AL051** weave_mul 2-上循環交織乘法（O(1)）
- **AL052** monad_closure 閉包單子（O(1) 位元運算）
- **AL084** theorem_universal_property_pullback 中介態射枚舉（O(n^{2q})）
- **AL085** verb_apply 21 衍生方向動詞變換（O(n²)）
- **AL086** deriv_invariant 14 手法不變量（O(2^n)）
- **AL087** verb_pattern_matrix / stable_pairs / row_classes（O(21·14·C)）
- **AL088** verb_composition_closure 441 組動詞複合（O(441·14·C)）
- **AL106** sigma_f / pullback_f / pi_f / pushforward_monad（O(2^{nx+ny})）
- **AL107** lan_presheaf / ran_presheaf / codensity_value（O(2^{m+n}mn)）
- **AL108** library_signature / library_clustering（O(N²)）

## 等式

- **E24** Kan 伴隨：`Lan_φ ⊣ φ* ⊣ Ran_φ`
- **E25** Kronecker 混合積：`(A⊗B)(C⊗D) = (AC)⊗(BD)`
- **E26** 共融推出泛性質：`|Hom(A ⊔_C B, X)| = |X|^{#classes}`
- **E27** 2-上循環條件：`φ(a,b)+φ(a+b,c) = φ(b,c)+φ(a,b+c)`
- **E28** 束黏合：`匹配族 ↔ F(∪U_i) 為雙射`
- **E50** 衍生相容矩陣：`M[v][p] = [inv_p(V_v(D₀)) = inv_p(D₀)] ∈ F₂^{21×14}`
- **E60** Pushforward monad：`T=Π_f f*=Ran_f f*；T(B)=B∪(Y∖im f)`
- **E61** Ran / codensity：`(Ran_K F)(q)=⋀_{q≤Kp}F(p)；(Ran_K K)(q)=min{Kp|q≤Kp}`

## 資料夾視角依賴關係圖

```text
[src/compose]
  ├─ 依賴 → src/exact
  ├─ 依賴 → src/galois
  ├─ 依賴 → src/series
  ├─ 依賴 → src/algebra
  ├─ 依賴 → src/graphs
  ├─ 依賴 → src/catalog
  └─ 被依賴 ← .
```

## 動線

有限範疇/布爾格/布林矩陣 → Kan、束、纖維積、單子、張量 → 複合定理 C1..C15。

## 接入／輸出接口

接入：布爾格、布林矩陣、矩陣、Context。輸出：lan_poset/ran_poset、kronecker、relation_tensor、theorem_C*。

實際公開符號（擷取自本資料夾 .mbt）：

```text
  boolean_lattice  lan_poset  ran_poset  theorem_kan_left_adjunction
  theorem_kan_right_adjunction  fiber_product_count  theorem_fiber_product_universal  union_find
  UnionFind::find  UnionFind::union  UnionFind::classes  pushout_classes
  theorem_pushout_universal  free_comm_monoid_size  theorem_amalgamated_free_product  monad_closure
  theorem_monad_composition  theorem_galois_monad  kronecker  theorem_kronecker_mixed
  theorem_kronecker_rank  relation_tensor  theorem_pipeline_associative  theorem_game_interchange
  fibered  chain_leq  grothendieck_objects  theorem_fibration
  is_alexandrov_open  submasks  theorem_sheaf_gluing  weave_elem
  cocycle  weave_mul  theorem_cocycle_condition  theorem_weave_associative
  theorem_all_in_one  theorem_frontier_all_in_one  theorem_universal_property_pullback  theorem_universal_property_free_monoid
  theorem_functoriality  theorem_universal_properties_all  verb_name  deriv_base
  verb_apply  deriv_invariant  verb_pattern_matrix  verb_pattern_stable_pairs
  verb_pattern_row_classes  theorem_verb_pattern_structure  verb_composition_closure  theorem_derivation_all_in_one
  finite_map  sigma_f  pullback_f  pi_f
  pushforward_monad  theorem_pushforward_adjunction  theorem_pushforward_monad  poset_kan
  ran_presheaf  lan_presheaf  kan_pullback  theorem_kan_adjunction
  codensity_value  theorem_codensity_monad  theorem_pi_polar_bridge  library_signature
  library_clustering  theorem_library_clustering  library_cluster_stats  PosetLattice
  UnionFind  Fibered  WeaveElem  DerivData
  FiniteMap  PosetKan  LibraryClustering
```

## 驗證

```bash
export PATH=/tmp/moonhome/bin:$PATH
cd /home/user/c1
moon check src/compose --deny-warn
```
