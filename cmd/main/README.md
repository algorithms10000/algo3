# cmd/main — inspect 輸出介面（moon run cmd/main）

> C1-01 首次開發切片／C1-02 補回／C1-03 數學結構落地／C1-04 前沿待辦補齊。本檔由 `tools/build_readmes.py` 自實際程式與登錄表產生。

## 已獲得定理列表

- （本資料夾不直接陳述定理；定理憑證位於依賴的上層套件）

## 已實作演算法列表

- （無獨立登錄演算法；見依賴套件）

## 資料夾視角依賴關係圖

```text
[cmd/main]
  └─ （無跨套件依賴）
```

## 動線

@c1.report() → println → 終端 inspect 報表（51 行憑證）。

## 接入／輸出接口

接入：root @c1.report()。輸出：stdout inspect 報表（51 行憑證）。

## 驗證

```bash
export PATH=/tmp/moonhome/bin:$PATH
cd /home/user/c1
moon check cmd/main --deny-warn
```
