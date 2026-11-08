# src/axioms — 形式化公理層：Z3 驗證的 11 條引理 + 17 個證明義務

> C1-01 首次開發切片／C1-02 補回／C1-03 數學結構落地／C1-04 前沿待辦補齊／C1-05 §6''' 剩餘結構補回／C1-06 量子環面與 21×14 交織／C1-07 黃金比例、陳–西蒙斯與全代碼健檢／C1-08 六項無限維結構之有限精確憑證。本檔由 `tools/build_readmes.py` 自實際程式與登錄表產生。

## 已獲得定理列表

- **L1** l_adjoint：極性伴隨性 (x ≤ −y) ⟺ (y ≤ −x)
- **L2** l_adjoint_sum：伴隨性的線性等價形式
- **L3** l_triple_identity：F∘H∘F = F
- **L4** l_chu_involution：H∘F = id
- **L5** l_conv2_associative：ℤ[[t]]/(t²) 卷積結合律
- **L6** l_ore_leibniz：q-整數恆等式 [5]_q=[2]_q+q²[3]_q
- **L7** l_ore_leibniz2：q-整數恆等式 [5]_q=[3]_q+q³[2]_q
- **L8** l_newton_step：(1+a)(2−(1+a)) = 1−a²
- **L9** l_newton_double：(1−a²)(1+a²) = 1−a⁴
- **L10** l_hilbert_geom：(1−t)H(t) = 1−t⁵
- **L11** l_compose_assoc：一階複合結合律係數恆等式

## 已實作演算法列表

- （無獨立登錄演算法；見依賴套件）

## 等式

- **E04** 三次極性：`F∘H∘F = F 且 H∘F∘H = H`

## 資料夾視角依賴關係圖

```text
[src/axioms]
  └─ 被依賴 ← .
```

## 動線

.mbtp predicate/lemma → moon prove + Z3 → 17 goals；.mbt 純函數供 inspect 取用。

## 接入／輸出接口

接入：整數。輸出：polar、polar_triple、closure_apply、conv2、qint、hilbert_coeff；moon prove 17 goals。

實際公開符號（擷取自本資料夾 .mbt）：

```text
  polar  polar_triple  closure_apply  closure_idempotent_cert
  conv2  qint  hilbert_delta  hilbert_coeff
```

## 驗證

```bash
export PATH=/tmp/moonhome/bin:$PATH
cd /home/user/c1
moon check src/axioms --deny-warn
```
