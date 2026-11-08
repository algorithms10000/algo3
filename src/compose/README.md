# src/compose — 14 種組合手法：Kan、束、纖維積、單子、張量、纖維範疇、推出、交織、博弈

> C1-01 首次開發切片／C1-02 補回／C1-03 數學結構落地／C1-04 前沿待辦補齊／C1-05 §6''' 剩餘結構補回／C1-06 量子環面與 21×14 交織／C1-07 黃金比例、陳–西蒙斯與全代碼健檢／C1-08 六項無限維結構之有限精確憑證。本檔由 `tools/build_readmes.py` 自實際程式與登錄表產生。

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
- **T-NCM1** K₀ 冪零不變性：Newton 提升 E←E+(1−2E)(E²−E) 且 rank 不變
- **T-NCM2** 導出 K 連續性：塔 R_k→R_{k−1} 之 K₀≅holim K₀≅ℤ
- **T-NCM3** KH 之 A¹-同倫不變性（有限層）：u↦0 不改變冪等元秩
- **T-NCM4** U_add 泛性質：關係矩陣秩 5、核一維、Waldhausen 可加與 Morita 穩定
- **T-NCM5** 非交換動機有限層四項憑證合取
- **T-IW1** 21×14 交織矩陣非平凡：ℚ-秩 11、GF(7)-秩 3、非零項 185
- **T-IW2** Gram S=WWᵀ、T=WᵀW 對稱且秩皆為 11、tr S=tr T=ΣW²=2932
- **T-IW3** Kronecker 自交織 rank(K⊗K)=rank(K)²=9（K 為 4×4 子矩陣）
- **T-IW4** 全局公理 G：交織脈絡之物件／屬性閉集數皆 240 且極性伴隨成立
- **T-IW5** 21 動詞算子代數非交換、滿足 q-Heisenberg、441 複合生成完整 End(A_q) 維度 81
- **T-IW6** 量子環面↔AJ 橋接：Weil 配對與交換子互逆、q^{e₃} 落於 AJ_q 之核 ⟨q⟩
- **T-IW7** 21×14 交織六項憑證與既有 21 動詞相容矩陣之合取
- **T-CS5** 21×14 W₂ 非平凡：ℚ-秩 14、GF(11)-秩 3、非零項 271
- **T-CS6** W₂ Gram S/T 對稱、秩 14、tr S=tr T=ΣW₂²=9615
- **T-CS7** W₂ 之 Kronecker 自交織 rank(K⊗K)=rank(K)²=9
- **T-CS8** 全局公理 G 於 W₂ 脈絡：物件／屬性閉集數皆 1568、極性伴隨成立
- **T-CS9** 21 算子相異；[D,M_x]=M_x、M_x⁵=0、[∂,M_x]=I−5P₄；21 算子張成 12 維、441 複合張成完整 End(A_CS5)=25
- **T-CS10** 跨回合交織：W₁（量子環面）與 W₂（黃金/CS）之堆疊／拼接／聯合 Gram 與兩概念格交集
- **T-CS12** 21×14 黃金/CS 交織六項憑證合取
- **T-C108-1** W₃ 21×14 交織：ℚ-秩 14、GF(11)-秩、非零項 259、值域多於一元素
- **T-C108-2** W₃ 之 Gram S/T 對稱、秩同 W₃、tr S=tr T=ΣW₃²
- **T-C108-3** 全局公理 G 於 W₃ 脈絡之物件／屬性閉集數 396/396 與極性伴隨
- **T-C108-4** 三回合交織：堆疊 63×14、拼接 21×42、聯合 Gram 秩關係；W₁∩W₂=12、W₁∩W₂∩W₃=1 嚴格遞減

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
- **AL122** nr_mul（雙變數截斷卷積）/ nr_eval_u0（O((kl)²)）
- **AL123** idempotent_lift（Newton–Hensel 冪等元提升）（O(n³·log(kl))）
- **AL124** k0_rref / k0_kernel（關係矩陣回代求 U_add）（O(n³)）
- **AL125** nm_block_sum（Waldhausen 分裂直和）/ idempotent_rank（O(n²)）
- **AL145** interwoven_operators（21 動詞 → End(A_q) 算子）（O(21·n⁴)）
- **AL146** interwoven_state（14 範例 → A_q 狀態向量）（O(14·n²)）
- **AL147** interwoven_matrix（21×14 交織矩陣 W）（O(21·14·n⁴)）
- **AL148** iw_rat / iw_mat_mul / iw_transpose / iw_trace（O(n³)）
- **AL149** theorem_interwoven_kronecker（K⊗K 秩計算）（O(k⁶)）
- **AL150** theorem_interwoven_galois（2^14 極性閉集枚舉）（O(2^14·21·14)）
- **AL151** iw_flatten / theorem_interwoven_operator_algebra（441 複合秩）（O(21²·n⁶)）
- **AL152** theorem_interwoven_aj_bridge（Weil/AJ 橋接穷舉）（O(n⁴·n²)）
- **AL153** interwoven_stats（秩/非零/概念/張成 inspect）（O(2^14·21)）
- **AL166** cs_operators（21 動詞 → A_CS5 微分算子）（O(21·n³)）
- **AL167** cs_state / cs_interwoven_matrix（14 範例 × F_{p+1} × L_{p+1}）（O(21·14·n²)）
- **AL168** cs_closed_attrs / theorem_cs_cross_round（O(2^14·21·14)）
- **AL169** cs_flatten / iw_flatten_mod（參數化模數，修復跨回合硬編）（O(n²)）
- **AL175** pub galois.insert_unique 取代 compose.iw_insert_unique（O(n)）
- **AL176** theorem_fiber_product_universal 恆真式清除（O(m·n)）
- **AL178** cs_interwoven_stats（秩/非零/概念/張成 inspect）（O(2^14·21)）
- **AL180** C1-06 W₁ 與 C1-07 W₂ 之堆疊／拼接／聯合 Gram 秩計算（O(21³)）
- **AL195** bigrat_mod11 / c108_state（六結構不變量 → F₁₁ 狀態）（O(14)）
- **AL196** c108_interwoven_matrix（21×14 W₃）（O(21·14·25)）
- **AL197** theorem_c108_cross_three（三回合堆疊／拼接／概念格交集）（O(21³+2^14)）
- **AL198** c108_stats（ℚ-秩/非零/概念 inspect）（O(2^14·21)）

## 等式

- **E24** Kan 伴隨：`Lan_φ ⊣ φ* ⊣ Ran_φ`
- **E25** Kronecker 混合積：`(A⊗B)(C⊗D) = (AC)⊗(BD)`
- **E26** 共融推出泛性質：`|Hom(A ⊔_C B, X)| = |X|^{#classes}`
- **E27** 2-上循環條件：`φ(a,b)+φ(a+b,c) = φ(b,c)+φ(a,b+c)`
- **E28** 束黏合：`匹配族 ↔ F(∪U_i) 為雙射`
- **E50** 衍生相容矩陣：`M[v][p] = [inv_p(V_v(D₀)) = inv_p(D₀)] ∈ F₂^{21×14}`
- **E60** Pushforward monad：`T=Π_f f*=Ran_f f*；T(B)=B∪(Y∖im f)`
- **E61** Ran / codensity：`(Ran_K F)(q)=⋀_{q≤Kp}F(p)；(Ran_K K)(q)=min{Kp|q≤Kp}`
- **E78** Newton–Hensel 冪等元提升：`E ← E + (1−2E)(E²−E)，(E²−E)∈I^{2^s} ⇒ K₀(R)≅K₀(R/I)`
- **E79** Waldhausen 可加性 / U_add：`[B]=[A]+[C]；K₀=ℤ·[R]，U([R^i])=i；rank(E⊕F)=rank E+rank F`
- **E97** 21×14 交織矩陣：`W[v][p]=τ(ρ(v)Φ_p)，Φ_p 由 deriv_invariant(p,·) 實算；rank_ℚ W=11`
- **E98** Gram 自交織：`S=WWᵀ, T=WᵀW 對稱；rank S=rank T=rank W；tr S=tr T=ΣW²=2932`
- **E99** Kronecker 自交織：`rank(K⊗K)=rank(K)²=9；441 個 ρ(v)ρ(w) 張成 End(A_q)，dim=81`
- **E100** 全局公理 G 於交織脈絡：`R(v,p)⇔W[v][p]≠0 ⇒ |Fix(F∘H)|=|Fix(H∘F)|=240；AJ_q(q^{e_n})=1`
- **E118** A_CS5 微分算子：`[D,M_x]=M_x, M_x⁵=0, [∂,M_x]=I−5P₄；dim End=25`
- **E119** 21×14 黃金/CS 交織：`W₂[v][p]=τ(ρ(v)Φ_p)；rank_ℚ=14, ΣW₂²=9615, 概念數 1568, rank(K⊗K)=9`
- **E139** W₃ 交織：`W₃[v][p]=τ(ρ(v)Φ_p)；rank_ℚ W₃=14, 非零項 259, 概念數 396`
- **E140** 三回合交織：`rank(stack)=14, rank(horiz)=21, rank(WWᵀ)=21；|Fix₁∩Fix₂|=12 > |Fix₁∩Fix₂∩Fix₃|=1`

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
  library_clustering  theorem_library_clustering  library_cluster_stats  idempotent_lift
  idempotent_is_exact  idempotent_rank  theorem_nilinvariance  theorem_k0_continuity
  theorem_kh_homotopy  k0_relation_matrix  theorem_universal_additive_invariant  theorem_noncomm_motives
  interwoven_root  interwoven_operators  interwoven_state  interwoven_matrix
  theorem_interwoven_structure  theorem_interwoven_gram  theorem_interwoven_kronecker  theorem_interwoven_galois
  theorem_interwoven_operator_algebra  theorem_interwoven_aj_bridge  interwoven_stats  theorem_interwoven_all
  cs_root  cs_operators  cs_state  cs_interwoven_matrix
  theorem_cs_interwoven_structure  theorem_cs_interwoven_gram  theorem_cs_interwoven_kronecker  theorem_cs_interwoven_galois
  theorem_cs_operator_algebra  theorem_cs_cross_round  theorem_cs_interwoven_all  cs_interwoven_stats
  c108_state  c108_interwoven_matrix  theorem_c108_structure  theorem_c108_gram
  theorem_c108_galois  theorem_c108_cross_three  theorem_c108_interwoven_all  c108_stats
  PosetLattice  UnionFind  Fibered  WeaveElem
  DerivData  FiniteMap  PosetKan  LibraryClustering
  NilRing
```

## 驗證

```bash
export PATH=/tmp/moonhome/bin:$PATH
cd /home/user/c1
moon check src/compose --deny-warn
```
