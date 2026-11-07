# docs — 機器可讀登錄表與文件

> C1-01 首次開發切片／C1-02 補回／C1-03 數學結構落地／C1-04 前沿待辦補齊。本檔由 `tools/build_readmes.py` 自實際程式與登錄表產生。

## 已獲得定理列表

- （本資料夾不直接陳述定理；定理憑證位於依賴的上層套件）

## 已實作演算法列表

- （無獨立登錄演算法；見依賴套件）

## 資料夾視角依賴關係圖

```text
[docs]
  └─ （無跨套件依賴）
```

## 動線

catalog.json 為單一來源，tools 讀取後輸出 xlsx 與 MoonBit 登錄。

## 接入／輸出接口

接入：tools/build_catalog.py。輸出：catalog.json（355 筆）。

## 驗證

```bash
export PATH=/tmp/moonhome/bin:$PATH
cd /home/user/c1
moon check docs --deny-warn
```
