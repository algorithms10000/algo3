# src/galois — 全局公理 G：有限冪集伽羅瓦對應、NextClosure、楚對偶、完備格表示

> C1-01 首次開發切片／C1-02 補回／C1-03 數學結構落地／C1-04 前沿待辦補齊／C1-05 §6''' 剩餘結構補回／C1-06 量子環面與 21×14 交織／C1-07 黃金比例、陳–西蒙斯與全代碼健檢／C1-08 六項無限維結構之有限精確憑證。本檔由 `tools/build_readmes.py` 自實際程式與登錄表產生。

## 已獲得公理

- **A-G** 全局公理：伽羅瓦對應（極性伴隨）
- **A-L4** 極性矩陣／楚空間公理：轉置為鏡像對偶

## 已獲得定理列表

- **P1** 極性 F,H 為反色調且 c=F∘H 為閉包算子
- **L12** 閉包三律：擴張、單調、冪等（有限冪集穷舉）
- **L13** NextClosure lectic 順序正確性：↑↓ 為閉包算子
- **T-G1** 伽羅瓦對應：伴隨性對所有子集對成立
- **T-G2** 閉包算子三律：擴張／單調／冪等
- **T-G3** 閉物件格與閉屬性格反同構（概念格完備格）
- **T-G4** Ganter NextClosure 完整列舉所有 intent
- **T-G5** 楚空間對偶保持概念格大小（鏡像對稱）
- **T-G6** 有限域上理想–簇 Galois 對應 F(H(V))=V
- **T-G7** 完備格表示定理：閉包系統由 Chu space 產生
- **T-G8** 約束閉包算子 c_req 滿足擴張／單調／冪等
- **T-G9** NextClosures 基數層級平行枚舉與 closed_attributes 一致
- **T-G10** 約束切分之平行 worker 輸出為 intents 的不交劃分
- **T-G11** FCbO 列舉全部 intent、無重複、皆為閉集
- **T-G12** FCbO 新 canonicity test 守恆律 closures+skipped=CbO closures
- **T-G13** FCbO 新測試啟動時嚴格少算閉包（skipped>0）
- **T-G14** PFCbO worker 輸出為 intents 之不交分割且聯集完備

## 已實作演算法列表

- **AL010** polar_obj / polar_attr 極性映射（O(nx+ny)）
- **AL011** closure_obj / closure_attr 閉包算子（O(nx+ny)）
- **AL012** galois_certificate 全子集穷舉憑證（O(2^(nx+ny))）
- **AL013** next_closure_intents Ganter lectic 枚舉（O(ny²|B|)）
- **AL014** concept_covers 概念格覆蓋關係（O(|B|³)）
- **AL015** chu_dual 楚空間轉置（O(nx·ny)）
- **AL016** relation_compose 布林矩陣乘法（O(nx·ny·nz)）
- **AL017** ideal_variety_context 有限域理想–簇脈絡（O(p^d·p·d)）
- **AL018** closure_system_representation 完備格表示（O(|D|²)）
- **AL057** next_closure_constrained 約束閉包算子之 Ganter 枚舉（O(ny²|B|)）
- **AL058** intents_by_cardinality 基數層級 BFS（層內可平行）（O(ny·|B|²)）
- **AL059** parallel_intent_partition 無通訊 worker 不交劃分（ embarrassingly parallel）
- **AL101** fcbo_run / cbo_closure_count（O(|concepts|·n²)）
- **AL102** pfcbo_workers 層級 L 之 round-robin 分發（O(w·|queue|)）
- **AL174** full_mask 取代重複之 lower_mask（O(n)）

## 等式

- **E01** 極性定義：`F(A) = { y | ∀x∈A, R(x,y) }, H(B) = { x | ∀y∈B, R(x,y) }`
- **E02** 伴隨性：`A ⊆ H(B) ⟺ B ⊆ F(A)`
- **E03** 閉包冪等：`c(c(A)) = c(A), c = F∘H`
- **E34** 約束閉包：`c_req(A) = c(required ∪ A)`
- **E35** 平行不交劃分：`Intents(K) = ⊔_{w=0}^{|M|} Worker_w(K)`
- **E56** FCbO 守恆律：`closures(FCbO)+skipped = closures(CbO)`

## 資料夾視角依賴關係圖

```text
[src/galois]
  ├─ 依賴 → src/exact
  └─ 被依賴 ← src/graphs
  └─ 被依賴 ← src/compose
  └─ 被依賴 ← .
```

## 動線

Context(列遮罩) → polar → closure → 閉集格 → NextClosure → Chu dual → 憑證。

## 接入／輸出接口

接入：@galois.context(nx,ny,rows)。輸出：galois_certificate、closed_objects、next_closure_intents、chu_dual、theorem_*。

實際公開符號（擷取自本資料夾 .mbt）：

```text
  context  full_mask  entry  subset
  polar_obj  polar_attr  closure_obj  closure_attr
  adjoint_pair  total_masks  insert_unique  closed_objects
  closed_attributes  next_closure_intents  concept_covers  chu_dual
  relation_compose  galois_certificate  theorem_closed_lattice_antiiso  theorem_next_closure_complete
  theorem_chu_dual  ideal_variety_context  theorem_ideal_variety  closure_system_representation
  theorem_representation  constraint_closure  next_closure_constrained  intents_by_cardinality
  parallel_worker  parallel_intent_partition  theorem_constraint_closure  theorem_next_closures_levelwise
  theorem_parallel_next_closure  fcbo_run  cbo_closure_count  theorem_fcbo_completeness
  theorem_fcbo_pruning  fcbo_demo_context  theorem_fcbo_new_test_active  pfcbo_workers
  theorem_pfcbo_partition  Context  GaloisCert  FCbOTask
```

## 驗證

```bash
export PATH=/tmp/moonhome/bin:$PATH
cd /home/user/c1
moon check src/galois --deny-warn
```
