# src/catalog — 定理／演算法／等式機器可讀登錄表

> C1-01 首次開發切片／C1-02 補回更新。本檔由 `tools/build_readmes.py` 自實際程式與登錄表產生。

## 已獲得定理列表

- （本資料夾不直接陳述定理；定理憑證位於依賴的上層套件）

## 已實作演算法列表

- （無獨立登錄演算法；見依賴套件）

## 資料夾視角依賴關係圖

```text
[src/catalog]
  └─ 被依賴 ← .
```

## 動線

docs/catalog.json → tools/build_catalog.py → catalog.mbt + algorithm.xlsx。

## 接入／輸出接口

接入：docs/catalog.json。輸出：catalog()、catalog_size()、count_kind()、theorem_catalog_consistent()。

實際公開符號（擷取自本資料夾 .mbt）：

```text
  catalog  catalog_size  count_kind  theorem_catalog_consistent
  Entry
```

## 驗證

```bash
export PATH=/tmp/moonhome/bin:$PATH
cd /home/user/c1
moon check src/catalog --deny-warn
```
