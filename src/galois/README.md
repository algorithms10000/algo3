# src/galois — 全局公理 G：有限冪集伽羅瓦對應、NextClosure、楚對偶、完備格表示

> C1-01 首次開發切片。本檔由 `tools/build_readmes.py` 自實際程式與登錄表產生。

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

## 等式

- **E01** 極性定義：`F(A) = { y | ∀x∈A, R(x,y) }, H(B) = { x | ∀y∈B, R(x,y) }`
- **E02** 伴隨性：`A ⊆ H(B) ⟺ B ⊆ F(A)`
- **E03** 閉包冪等：`c(c(A)) = c(A), c = F∘H`

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
  context  full_mask  lower_mask  entry
  subset  polar_obj  polar_attr  closure_obj
  closure_attr  adjoint_pair  total_masks  closed_objects
  closed_attributes  next_closure_intents  concept_covers  chu_dual
  relation_compose  galois_certificate  theorem_closed_lattice_antiiso  theorem_next_closure_complete
  theorem_chu_dual  ideal_variety_context  theorem_ideal_variety  closure_system_representation
  theorem_representation  Context  GaloisCert
```

## 驗證

```bash
export PATH=/tmp/moonhome/bin:$PATH
cd /home/user/c1
moon check src/galois --deny-warn
```
