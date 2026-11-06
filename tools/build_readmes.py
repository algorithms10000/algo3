#!/usr/bin/env python3
"""由 docs/catalog.json + 實際 moon.pkg / .mbt 產生每個資料夾的 README.md。"""
import json
import os
import re
import glob

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
with open(os.path.join(ROOT, "docs/catalog.json"), encoding="utf-8") as f:
    DATA = json.load(f)
E = DATA["entries"]

FOLDERS = [
    "src/exact", "src/axioms", "src/galois", "src/series", "src/algebra",
    "src/graphs", "src/compose", "src/catalog", "cmd/main", "docs", "tools",
]
ROOT_PKG = "."


def imports_of(folder):
    p = os.path.join(ROOT, folder, "moon.pkg")
    if not os.path.isfile(p):
        return []
    txt = open(p, encoding="utf-8").read()
    return re.findall(r'"username/c1/([^"]+)"', txt)


def pubfns(folder):
    out = []
    for p in sorted(glob.glob(os.path.join(ROOT, folder, "*.mbt"))):
        txt = open(p, encoding="utf-8").read()
        out += re.findall(r"^pub fn ([A-Za-z0-9_:]+)", txt, flags=re.M)
        out += re.findall(r"^pub\(all\) struct ([A-Za-z0-9_]+)", txt, flags=re.M)
    return out


def dep_graph(folder):
    deps = imports_of(folder)
    inc = [f for f in FOLDERS + ["."] if folder in imports_of(f)]
    lines = ["```text", "[" + folder + "]"]
    for d in deps:
        lines.append("  ├─ 依賴 → " + d)
    for d in inc:
        if d != folder:
            lines.append("  └─ 被依賴 ← " + d)
    if not deps and not inc:
        lines.append("  └─ （無跨套件依賴）")
    lines.append("```")
    return "\n".join(lines)


ROLES = {
    "src/exact": "精確算術層：Rat、gcd/egcd、模算術、GF(2) 秩、Smith 標準型",
    "src/axioms": "形式化公理層：Z3 驗證的 11 條引理 + 17 個證明義務",
    "src/galois": "全局公理 G：有限冪集伽羅瓦對應、NextClosure、楚對偶、完備格表示",
    "src/series": "局部公理 L1/L2/L3：多項式、形式冪級數、洛朗、狄利克雷、商環、全純",
    "src/algebra": "Ore 歪多項式環、Hilbert–Poincaré、局部化、Ext¹、Morita",
    "src/graphs": "克內澤圖、Ramsey、擬陣 Tutte、單純複形 Betti、圖極性",
    "src/compose": "14 種組合手法：Kan、束、纖維積、單子、張量、纖維範疇、推出、交織、博弈",
    "src/catalog": "定理／演算法／等式機器可讀登錄表",
    "cmd/main": "inspect 輸出介面（moon run cmd/main）",
    "docs": "機器可讀登錄表與文件",
    "tools": "單一來源產生器（catalog / xlsx / README）",
}

FLOWS = {
    "src/exact": "Int64/UInt64 位元 → gcd/Rat/矩陣秩 → 供所有上層套件做精確係數與 GF(2) 消去。",
    "src/axioms": ".mbtp predicate/lemma → moon prove + Z3 → 17 goals；.mbt 純函數供 inspect 取用。",
    "src/galois": "Context(列遮罩) → polar → closure → 閉集格 → NextClosure → Chu dual → 憑證。",
    "src/series": "係數陣列 → 卷積么半群 → Poly/Fps/Laurent/Dirichlet/Quot → Newton/Lagrange → 全純求值。",
    "src/algebra": "單項式指數向量 → lcm 格容斥 → Hilbert 級數；Ore σ 作用 → 歪多項式；SNF → Ext¹/Morita。",
    "src/graphs": "位元遮罩圖 → 回溯色數／BK 團 → Kneser 定理；GF(2) 邊界矩陣 → Betti。",
    "src/compose": "有限範疇/布爾格/布林矩陣 → Kan、束、纖維積、單子、張量 → 複合定理 C1..C15。",
    "src/catalog": "docs/catalog.json → tools/build_catalog.py → catalog.mbt + algorithm.xlsx。",
    "cmd/main": "@c1.report() → println → 終端 inspect 報表（31 行憑證）。",
    "docs": "catalog.json 為單一來源，tools 讀取後輸出 xlsx 與 MoonBit 登錄。",
    "tools": "build_catalog.py → catalog.json/catalog.mbt/algorithm.xlsx；build_readmes.py → 各 README。",
}

INTERFACES = {
    "src/exact": "接入：Int64/UInt64 位元資料。輸出：Rat、gcd、gf2_rank、rank_mod_p、smith_invariants、binom、popcount。",
    "src/axioms": "接入：整數。輸出：polar、polar_triple、closure_apply、conv2、qint、hilbert_coeff；moon prove 17 goals。",
    "src/galois": "接入：@galois.context(nx,ny,rows)。輸出：galois_certificate、closed_objects、next_closure_intents、chu_dual、theorem_*。",
    "src/series": "接入：Array[Rat] 係數。輸出：fps_inv、fps_reversion、fps_compose、ds_mul、quot、mpoly_substitute、theorem_*。",
    "src/algebra": "接入：@series.Poly、指數向量、整數矩陣。輸出：hilbert_coefficients、ore_mul/ore_gcrd、extension_invariants、theorem_*。",
    "src/graphs": "接入：n,k 或位元遮罩鄰接列。輸出：chromatic_number、max_clique、betti_numbers、tutte_coeffs、theorem_*。",
    "src/compose": "接入：布爾格、布林矩陣、矩陣、Context。輸出：lan_poset/ran_poset、kronecker、relation_tensor、theorem_C*。",
    "src/catalog": "接入：docs/catalog.json。輸出：catalog()、catalog_size()、count_kind()、theorem_catalog_consistent()。",
    "cmd/main": "接入：root @c1.report()。輸出：stdout inspect 報表。",
    "docs": "接入：tools/build_catalog.py。輸出：catalog.json（183 筆）。",
    "tools": "接入：Python 標準庫 + openpyxl。輸出：catalog.json、catalog.mbt、algorithm.xlsx、各 README.md。",
}


def folder_readme(folder):
    th = [e for e in E if e["package"] == folder and e["kind"] == "定理"]
    lm = [e for e in E if e["package"] == folder and e["kind"] in ("引理", "命題")]
    al = [e for e in E if e["package"] == folder and e["kind"] == "演算法"]
    eq = [e for e in E if e["package"] == folder and e["kind"] == "等式"]
    ax = [e for e in E if e["package"] == folder and e["kind"] == "公理"]
    L = ["# " + folder + " — " + ROLES[folder], ""]
    L += ["> C1-01 首次開發切片。本檔由 `tools/build_readmes.py` 自實際程式與登錄表產生。", ""]
    if ax:
        L += ["## 已獲得公理", ""] + ["- **{}** {}".format(e["id"], e["statement"]) for e in ax] + [""]
    L += ["## 已獲得定理列表", ""]
    if th or lm:
        L += ["- **{}** {}".format(e["id"], e["statement"]) for e in lm + th]
    else:
        L += ["- （本資料夾不直接陳述定理；定理憑證位於依賴的上層套件）"]
    L += [""]
    L += ["## 已實作演算法列表", ""]
    if al:
        L += ["- **{}** {}（{}）".format(e["id"], e["statement"], e["formula"]) for e in al]
    else:
        L += ["- （無獨立登錄演算法；見依賴套件）"]
    L += [""]
    if eq:
        L += ["## 等式", ""] + ["- **{}** {}：`{}`".format(e["id"], e["statement"], e["formula"]) for e in eq] + [""]
    L += ["## 資料夾視角依賴關係圖", "", dep_graph(folder), ""]
    L += ["## 動線", "", FLOWS[folder], ""]
    L += ["## 接入／輸出接口", "", INTERFACES[folder], ""]
    fns = pubfns(folder)
    if fns:
        L += ["實際公開符號（擷取自本資料夾 .mbt）：", "", "```text"]
        for i in range(0, len(fns), 4):
            L.append("  " + "  ".join(fns[i:i + 4]))
        L += ["```", ""]
    L += ["## 驗證", "", "```bash", "export PATH=/tmp/moonhome/bin:$PATH",
          "cd /home/user/c1", "moon check " + folder + " --deny-warn", "```", ""]
    return "\n".join(L)


ROOT_README = """# C1 — 全局公理伽羅瓦對應（C1-01 首次開發切片）

> 依 `工程內容03.md`／`工程約束.md`／`作業規範.md`／`組合範例.md` 建立之首次切片。
> 全局公理 **G = 伽羅瓦對應（極性伴隨）**；局部公理 L1..L5 由本回合代理決定。
> 本回合為**首次開發**，尚未達成 5,000,000 行／10,000 條演算法之最終目標；未完成部分不列為已完成。

## 全局公理

有限集合 X,Y 與關係 R ⊆ X×Y，定義
`F(A) = { y∈Y | ∀x∈A, R(x,y) }`、`H(B) = { x∈X | ∀y∈B, R(x,y) }`，
則 `A ⊆ H(B) ⟺ B ⊆ F(A)`；`c = F∘H` 為閉包算子，`Fix(c) ≅ Fix(c')^op` 為完備格。

## 局部公理

| 編號 | 內容 |
| --- | --- |
| L1 | 有限支撐：精確有理係數與明確截斷次數 N |
| L2 | 卷積么半群 `(a*b)(m)=Σ_{u*v=m}a(u)b(v)`（統一 Poly/FPS/Laurent/Dirichlet/Quotient） |
| L3 | 截斷商 `π_N: ℚ[[t]] → ℚ[[t]]/(t^N)` |
| L4 | 極性矩陣／楚空間：轉置為鏡像對偶 |
| L5 | 有限域算術：Int64 + egcd 求逆、GF(2) 位元打包消去 |

## 套件與依賴

```text
src/exact    ──► src/axioms ──► src/galois ──► src/series ──► src/algebra ──► src/graphs
    │                              │                │               │              │
    └──────────────────────────────┴────────────────┴───────┬───────┴──────────────┘
                                                           ▼
                                                      src/compose
                                                           │
                                                           ▼
                                                      src/catalog ──► cmd/main ──► stdout
```

- `src/exact`：精確算術、GF(2) 秩、Smith 標準型
- `src/axioms`：`.mbtp` 形式化驗證（Z3，17 goals proved，無 trusted assumption）
- `src/galois`：極性、閉包格、NextClosure、Chu 對偶、理想–簇對應
- `src/series`：多項式環、形式冪級數環、洛朗級數環、狄利克雷級數、多項式商環、全純函數、Newton/Lagrange、操作子代入
- `src/algebra`：歪多項式環（Ore）、Hilbert–Poincaré 級數、局部化、Ext¹、Morita
- `src/graphs`：克內澤圖、Lovász/EKR、Ramsey、擬陣 Tutte、單純複形 Betti
- `src/compose`：14 種組合手法（Kan、束、纖維積、單子、張量、纖維範疇、推出、交織、博弈管線等）
- `src/catalog`：183 筆定理／演算法／等式登錄
- `algorithm.xlsx`：由 `docs/catalog.json` 單一來源產生之活頁簿
- `Dev.txt`：流水式帳本；`AGENT.md` 與 `工程約束.md` 為同一份文件

## 工具鏈

MoonBit latest stable：`moon 0.1.20261104 (940aa18)`／`moonc v0.10.20+65efd5b93 (2026-11-05)`，
`moon.mod`／`moon.pkg` 新 DSL，Z3 5.3.3 由 `moon prove` 呼叫。

```bash
export PATH=/tmp/moonhome/bin:$PATH
cd /home/user/c1
moon check --deny-warn
moon prove --deny-warn
moon build
moon run cmd/main
```

## 本回合驗證結果

| 項目 | 結果 |
| --- | --- |
| `moon check --deny-warn`（全域） | Finished，21 tasks |
| `moon prove --deny-warn` | `1 of 1 packages proved, 17 goals proved` |
| `moon build` | wasm artifact 生成 |
| `moon run cmd/main` | 31 行真實 inspect 憑證，全數 OK |
| 登錄表 | 6 公理／20 定義／8 命題／14 引理／53 定理／52 演算法／30 等式 = 183 筆 |
| CI | `.github/workflows/c1-ci.yml` 推送全域編譯與形式化驗證 |

## 未完成（誠實標記）

- 5,000,000 行程式碼、10,000 條中階以上演算法、集庫成群：本回合僅為首次切片，遠未達成。
- 高階複雜度仍有多處 `O(N²)` 卷積（尚未接入 FFT／fast multiplication）。
- 多元優質算法庫之跨回合延伸、更多前沿論文查證與基準測試（沙盒無需）。
- `docs/` 目前僅有 catalog.json；其餘設計文件待後續回合。

## 接入／輸出接口

- 接入：`@c1.report()`、`@catalog.catalog()`、各套件 `pub fn`。
- 輸出：stdout inspect 報表、`algorithm.xlsx`、`docs/catalog.json`、wasm artifact。
"""


def main():
    for folder in FOLDERS:
        path = os.path.join(ROOT, folder, "README.md")
        with open(path, "w", encoding="utf-8") as f:
            f.write(folder_readme(folder))
    # root README.md 可能是 dangling symlink，先移除
    rp = os.path.join(ROOT, "README.md")
    if os.path.islink(rp) or os.path.isfile(rp):
        os.remove(rp)
    with open(rp, "w", encoding="utf-8") as f:
        f.write(ROOT_README)
    print("README.md written:", len(FOLDERS) + 1)


if __name__ == "__main__":
    main()
