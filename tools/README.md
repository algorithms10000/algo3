# tools — 單一來源產生器（catalog / xlsx / README）

> C1-01 首次開發切片／C1-02 補回／C1-03 數學結構落地。本檔由 `tools/build_readmes.py` 自實際程式與登錄表產生。

## 已獲得定理列表

- （本資料夾不直接陳述定理；定理憑證位於依賴的上層套件）

## 已實作演算法列表

- （無獨立登錄演算法；見依賴套件）

## 資料夾視角依賴關係圖

```text
[tools]
  └─ （無跨套件依賴）
```

## 動線

build_catalog.py → catalog.json/catalog.mbt/algorithm.xlsx；build_readmes.py → 各 README。

## 接入／輸出接口

接入：Python 標準庫 + openpyxl。輸出：catalog.json、catalog.mbt、algorithm.xlsx、各 README.md。

## 驗證

```bash
export PATH=/tmp/moonhome/bin:$PATH
cd /home/user/c1
moon check tools --deny-warn
```
