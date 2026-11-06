#!/usr/bin/env python3
"""C1 單一來源目錄產生器：
   docs/catalog.json  ->  機器可讀登錄表
   src/catalog/catalog.mbt -> MoonBit 結構化登錄（由 JSON 生成，保證一致）
   algorithm.xlsx -> 定理／演算法／等式活頁簿
"""
import json
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

A = []  # (id, statement, pkg, formula, verification)


def add(kind, id_, stmt, pkg, formula="", verify=""):
    A.append({
        "kind": kind,
        "id": id_,
        "statement": stmt,
        "package": pkg,
        "formula": formula,
        "verification": verify,
    })


# ── 公理 ────────────────────────────────────────────────────────────────
add("公理", "A-G", "全局公理：伽羅瓦對應（極性伴隨）", "src/galois",
    "A ⊆ H(B) ⟺ B ⊆ F(A)", "galois_certificate 穷舉 128/128 對 + Z3 l_adjoint")
add("公理", "A-L1", "有限支撐公理：精確有理係數 + 明確截斷次數", "src/exact",
    "supp(a) 有限，係數 ∈ ℚ", "Rat 正規化與 gcd 唯一性驗題")
add("公理", "A-L2", "卷積么半群公理：四類環為同一代數之實例", "src/series",
    "(a*b)(m) = Σ_{u*v=m} a(u)b(v)", "theorem_conv_associative 三種么半群")
add("公理", "A-L3", "截斷商公理：π_N 為滿環同態", "src/series",
    "π_N : ℚ[[t]] → ℚ[[t]]/(t^N)", "Z3 l_conv2_associative + fps_mul 驗題")
add("公理", "A-L4", "極性矩陣／楚空間公理：轉置為鏡像對偶", "src/galois",
    "C^⊥ = (C_a, r^op, C_o)", "theorem_chu_dual + theorem_graph_chu_dual")
add("公理", "A-L5", "有限域算術公理：Int64 模運算 + GF(2) 位元打包", "src/exact",
    "a^{-1} = egcd(a,p).x mod p", "mod_inv/gf2_rank/smith_invariants 驗題")

# ── 定義 ────────────────────────────────────────────────────────────────
defs = [
    ("D1", "Rat：正規化精確有理數 (n,d), d>0, gcd(n,d)=1", "src/exact"),
    ("D2", "Bezout：擴展歐幾里得係數 (x,y,g)", "src/exact"),
    ("D3", "Context：關係 R ⊆ X×Y 的列位元遮罩", "src/galois"),
    ("D4", "GaloisCert：伴隨/閉包/概念格計算憑證", "src/galois"),
    ("D5", "Poly：多項式環 ℚ[t] 的稠密係數", "src/series"),
    ("D6", "Fps：形式冪級數環 ℚ[[t]] 截斷至 t^N", "src/series"),
    ("D7", "Laurent：洛朗級數環 ℚ((t))，帶最低次偏移", "src/series"),
    ("D8", "Dirichlet：狄利克雷級數環 DS(ℚ)", "src/series"),
    ("D9", "Quot：多項式商環 ℚ[t]/(m)", "src/series"),
    ("D10", "ConvAlg：卷積么半群代數 (kind/offset/coeffs)", "src/series"),
    ("D11", "MPoly/Monomial：多元單項式與指數向量", "src/series"),
    ("D12", "MonoIdeal：單項式理想的生成元指數向量", "src/algebra"),
    ("D13", "SkewPoly：Ore 擴展 ℚ[u][x;σ] 的左係數", "src/algebra"),
    ("D14", "Localized：S^{-1}ℤ 的元素", "src/algebra"),
    ("D15", "Matroid：GF(2) 可表擬陣", "src/graphs"),
    ("D16", "Complex：由 facets 生成的單純複形分層", "src/graphs"),
    ("D17", "PosetLattice：布爾格視為薄範疇", "src/compose"),
    ("D18", "Fibered：Grothendieck 構造的纖維資料", "src/compose"),
    ("D19", "UnionFind：共融推出的同餘閉包", "src/compose"),
    ("D20", "WeaveElem：2-上循環交織群的元素", "src/compose"),
]
for id_, stmt, pkg in defs:
    add("定義", id_, stmt, pkg, "", "型別定義與構造函數，moon check --deny-warn")

# ── 命題 ────────────────────────────────────────────────────────────────
props = [
    ("P1", "極性 F,H 為反色調且 c=F∘H 為閉包算子", "src/galois", "A ⊆ H(B) ⟺ B ⊆ F(A)"),
    ("P2", "截斷 π_N 保持乘法：π_N(ab)=π_N(a)π_N(b)", "src/series", "fps_mul(a,b,N)"),
    ("P3", "狄利克雷卷積對應么半群 (ℕ≥1,×)", "src/series", "ds_mul O(N log N)"),
    ("P4", "Ore 關係 x·r = σ(r)x + δ(r)", "src/algebra", "x·u = q·u·x"),
    ("P5", "Hilbert 分子為 lcm 格的交錯和", "src/algebra", "Q(t)=Σ_S(−1)^{|S|}t^{deg lcm(S)}"),
    ("P6", "束的匹配族由限制映射兩兩相容定義", "src/compose", "s_i|_{U_i∩U_j} = s_j|_{U_i∩U_j}"),
    ("P7", "Morita 雙模映射為外積與內積", "src/algebra", "Q⊗P → M_n(ℤ), P⊗Q → ℤ"),
    ("P8", "進位函數為正規化 2-上循環", "src/compose", "φ(a,b)=⌊(a+b)/m⌋"),
]
for id_, stmt, pkg, f in props:
    add("命題", id_, stmt, pkg, f, "由所屬套件定理憑證導出")

# ── 引理 ────────────────────────────────────────────────────────────────
lemmas = [
    ("L1", "l_adjoint：極性伴隨性 (x ≤ −y) ⟺ (y ≤ −x)", "src/axioms"),
    ("L2", "l_adjoint_sum：伴隨性的線性等價形式", "src/axioms"),
    ("L3", "l_triple_identity：F∘H∘F = F", "src/axioms"),
    ("L4", "l_chu_involution：H∘F = id", "src/axioms"),
    ("L5", "l_conv2_associative：ℤ[[t]]/(t²) 卷積結合律", "src/axioms"),
    ("L6", "l_ore_leibniz：q-整數恆等式 [5]_q=[2]_q+q²[3]_q", "src/axioms"),
    ("L7", "l_ore_leibniz2：q-整數恆等式 [5]_q=[3]_q+q³[2]_q", "src/axioms"),
    ("L8", "l_newton_step：(1+a)(2−(1+a)) = 1−a²", "src/axioms"),
    ("L9", "l_newton_double：(1−a²)(1+a²) = 1−a⁴", "src/axioms"),
    ("L10", "l_hilbert_geom：(1−t)H(t) = 1−t⁵", "src/axioms"),
    ("L11", "l_compose_assoc：一階複合結合律係數恆等式", "src/axioms"),
    ("L12", "閉包三律：擴張、單調、冪等（有限冪集穷舉）", "src/galois"),
    ("L13", "NextClosure lectic 順序正確性：↑↓ 為閉包算子", "src/galois"),
    ("L14", "GF(2) 秩-零化度：dim ker = ncols − rank", "src/exact"),
]
for id_, stmt, pkg in lemmas:
    add("引理", id_, stmt, pkg, "", "moon prove + Z3（前 11 條）／有限穷舉憑證")

# ── 定理 ────────────────────────────────────────────────────────────────
theorems = [
    ("T-G1", "伽羅瓦對應：伴隨性對所有子集對成立", "src/galois"),
    ("T-G2", "閉包算子三律：擴張／單調／冪等", "src/galois"),
    ("T-G3", "閉物件格與閉屬性格反同構（概念格完備格）", "src/galois"),
    ("T-G4", "Ganter NextClosure 完整列舉所有 intent", "src/galois"),
    ("T-G5", "楚空間對偶保持概念格大小（鏡像對稱）", "src/galois"),
    ("T-G6", "有限域上理想–簇 Galois 對應 F(H(V))=V", "src/galois"),
    ("T-G7", "完備格表示定理：閉包系統由 Chu space 產生", "src/galois"),
    ("T-S1", "共性定理：(ℕ,+)/(ℕ≥1,×)/(ℤ,+) 卷積皆結合", "src/series"),
    ("T-S2", "exp∘log = id 且 log∘exp = id (mod t^N)", "src/series"),
    ("T-S3", "Newton 迭代反演正確性", "src/series"),
    ("T-S4", "Lagrange 反演與合成恆等式 f(f^{-1})=t", "src/series"),
    ("T-S5", "洛朗級數賦值可加 val(ab)=val(a)+val(b)", "src/series"),
    ("T-S6", "Möbius 反演 ζ*μ=δ₁ 且 σ=ζ*id", "src/series"),
    ("T-S7", "Euler 乘積：乘法函數由質數冪決定", "src/series"),
    ("T-S8", "Kan 擴展 Lan_φ 保持環結構", "src/series"),
    ("T-O1", "操作子代入結合律 (P∘Q)∘R=P∘(Q∘R)", "src/series"),
    ("T-O2", "多元代入求值同態", "src/series"),
    ("T-H1", "Hilbert–Poincaré 容斥級數 = 標準單項式基底計數", "src/algebra"),
    ("T-H2", "ℚ[t]/(t^d) 的 Hilbert 函數差分遞推", "src/algebra"),
    ("T-H3", "skew PBW 擴展與交換環有相同 Hilbert 級數", "src/algebra"),
    ("T-Ore1", "量子平面交換律 x·u = q·u·x", "src/algebra"),
    ("T-Ore2", "Ore 乘法結合律", "src/algebra"),
    ("T-Ore3", "Ore 環無零因子：deg(fg)=deg f+deg g", "src/algebra"),
    ("T-Ore4", "gcrd 右整除 f 與 g", "src/algebra"),
    ("T-Ore5", "σ-Leibniz 律對所有單項式成立", "src/algebra"),
    ("T-Ore6", "Ore 擴展 Hilbert 級數 = (1−t)^{-n}", "src/algebra"),
    ("T-L1", "局部化 S^{-1}ℤ 的泛性質與唯一延拓", "src/algebra"),
    ("T-E1", "Ext¹ 分類：擴張類 g 個、中間群同構型 τ(g) 個", "src/algebra"),
    ("T-E2", "Baer 和構成 ℤ/g 上的交換群", "src/algebra"),
    ("T-M1", "Morita context 雙模相容性 (q·p)q'=q(p·q')", "src/algebra"),
    ("T-M2", "M_n(ℤ) 為結合環且具單位元", "src/algebra"),
    ("T-K1", "Lovász：χ(KG(n,k)) = n−2k+2", "src/graphs"),
    ("T-K2", "EKR：α(KG(n,k)) = C(n−1,k−1)", "src/graphs"),
    ("T-K3", "分數色數 χ_f=n/k 為 χ 的下界", "src/graphs"),
    ("T-R1", "Ramsey R(3,3)=6", "src/graphs"),
    ("T-Mat1", "Tutte 多項式 T(1,1)=基底數、T(2,2)=2^{|E|}", "src/graphs"),
    ("T-Cx1", "Euler–Poincaré：Σ(−1)^d f_d = Σ(−1)^d β_d", "src/graphs"),
    ("T-Gph1", "圖鄰接極性的 Chu 對偶", "src/graphs"),
    ("T-C1", "左 Kan 擴展伴隨 Lan_φ ⊣ φ*", "src/compose"),
    ("T-C2", "右 Kan 擴展伴隨 φ* ⊣ Ran_φ", "src/compose"),
    ("T-C3", "纖維積 ℤ/m×_{ℤ/g}ℤ/n 泛性質", "src/compose"),
    ("T-C4", "共融推出 union-find 泛性質", "src/compose"),
    ("T-C5", "共融自由交換么半群單項式計數", "src/compose"),
    ("T-C6", "分配律單子複合仍為單子", "src/compose"),
    ("T-C7", "全局公理 G 的閉包算子本身為單子", "src/compose"),
    ("T-C8", "Kronecker 混合積 (A⊗B)(C⊗D)=AC⊗BD", "src/compose"),
    ("T-C9", "Kronecker 秩可乘性", "src/compose"),
    ("T-C10", "管線策略合成結合律", "src/compose"),
    ("T-C11", "博弈張量積交換律", "src/compose"),
    ("T-C12", "Grothendieck 構造給出纖維範疇", "src/compose"),
    ("T-C13", "有限 Alexandrov 拓樸之束黏合唯一性", "src/compose"),
    ("T-C14", "2-上循環交織群結合律與短正合序列", "src/compose"),
    ("T-C15", "多合一相容性：跨套件定理同時成立", "src/compose"),
]
for id_, stmt, pkg in theorems:
    add("定理", id_, stmt, pkg, "", "局部編譯 + 即寫即驗即刪測試題；回合末全域 CI")

# ── 演算法 ──────────────────────────────────────────────────────────────
algos = [
    ("AL001", "gcd / egcd 歐幾里得與擴展歐幾里得", "src/exact", "O(log min(a,b))"),
    ("AL002", "rat 有理數正規化與四則運算", "src/exact", "O(log d)"),
    ("AL003", "Rat::pow 二進位快速冪", "src/exact", "O(log k)"),
    ("AL004", "mod_pow / mod_inv 模冪與模逆", "src/exact", "O(log e)"),
    ("AL005", "binom Pascal 動態規劃", "src/exact", "O(n·k)"),
    ("AL006", "popcount Kernighan 位元計數", "src/exact", "O(#1-bits)"),
    ("AL007", "gf2_rank / gf2_nullity 位元打包消去", "src/exact", "O(rows·cols/64)"),
    ("AL008", "rank_mod_p 素數體矩陣秩", "src/exact", "O(r²c)"),
    ("AL009", "smith_invariants Smith 標準型與可整除鏈", "src/exact", "多項式時間"),
    ("AL010", "polar_obj / polar_attr 極性映射", "src/galois", "O(nx+ny)"),
    ("AL011", "closure_obj / closure_attr 閉包算子", "src/galois", "O(nx+ny)"),
    ("AL012", "galois_certificate 全子集穷舉憑證", "src/galois", "O(2^(nx+ny))"),
    ("AL013", "next_closure_intents Ganter lectic 枚舉", "src/galois", "O(ny²|B|)"),
    ("AL014", "concept_covers 概念格覆蓋關係", "src/galois", "O(|B|³)"),
    ("AL015", "chu_dual 楚空間轉置", "src/galois", "O(nx·ny)"),
    ("AL016", "relation_compose 布林矩陣乘法", "src/galois", "O(nx·ny·nz)"),
    ("AL017", "ideal_variety_context 有限域理想–簇脈絡", "src/galois", "O(p^d·p·d)"),
    ("AL018", "closure_system_representation 完備格表示", "src/galois", "O(|D|²)"),
    ("AL019", "Poly::mul 稀疏跳零卷積", "src/series", "O(|suppA|·|suppB|)"),
    ("AL020", "poly_divmod / poly_gcd 帶餘除法與 gcd", "src/series", "O(deg²)"),
    ("AL021", "quot / Quot::mul 商環算術", "src/series", "O(deg²)"),
    ("AL022", "fps_mul 截斷形式冪級數乘法", "src/series", "O(N²) 帶零剪枝"),
    ("AL023", "fps_inv Newton 倍精度反演", "src/series", "O(M(N) log N)"),
    ("AL024", "fps_compose 冪次展開 + valuation 剪枝", "src/series", "O(N²/v)"),
    ("AL025", "fps_reversion Lagrange 反演", "src/series", "O(N·M(N))"),
    ("AL026", "fps_exp / fps_log 係數遞推", "src/series", "O(N²)"),
    ("AL027", "holomorphic_eval / tail_bound 全純求值與誤差界", "src/series", "O(N)"),
    ("AL028", "laurent_inv 洛朗級數求逆", "src/series", "O(M(N) log N)"),
    ("AL029", "ds_mul O(N log N) 狄利克雷卷積", "src/series", "O(N log N)"),
    ("AL030", "ds_inv / mobius / ds_phi 算術函數", "src/series", "O(N log N)"),
    ("AL031", "conv_mul 三種卷積么半群統一乘法", "src/series", "O(N²) 或 O(N log N)"),
    ("AL032", "lan_along_phi 左 Kan 擴展（纖維和）", "src/series", "O(log N)"),
    ("AL033", "mpoly_substitute 操作子代入", "src/series", "多項式於指數"),
    ("AL034", "hilbert_numerator lcm 格容斥 + 原子化", "src/algebra", "O(2^r·n)"),
    ("AL035", "hilbert_coefficients / direct_count", "src/algebra", "O(N·n)"),
    ("AL036", "quotient_basis 標準單項式基底枚舉", "src/algebra", "O(C(n+d,d))"),
    ("AL037", "ore_mul / ore_divmod / ore_gcrd", "src/algebra", "O(deg²·deg_u)"),
    ("AL038", "q_derivative Jackson q-導子", "src/algebra", "O(deg_u)"),
    ("AL039", "localize / extend_hom 局部化", "src/algebra", "O(log d)"),
    ("AL040", "extension_invariants Ext¹ 的 SNF 分類", "src/algebra", "多項式時間"),
    ("AL041", "outer_product / mat_vec_mul Morita 雙模", "src/algebra", "O(n²)"),
    ("AL042", "chromatic_number 回溯 + 對稱破壞", "src/graphs", "P（分支限界）"),
    ("AL043", "max_clique Bron–Kerbosch 位元版", "src/graphs", "P（分支限界）"),
    ("AL044", "ramsey_triangle_free_count 穷舉證明", "src/graphs", "O(2^E·n³)"),
    ("AL045", "tutte_coeffs 秩生成式二項展開", "src/graphs", "O(2^|E|·|E|²)"),
    ("AL046", "boundary_rank / betti_numbers GF(2) 同調", "src/graphs", "O(f_d·f_{d-1})"),
    ("AL047", "lan_poset / ran_poset 有限格 Kan 擴展", "src/compose", "O(|C|·|D|)"),
    ("AL048", "UnionFind 共融推出同餘閉包", "src/compose", "O(n α(n))"),
    ("AL049", "kronecker / relation_tensor 張量積", "src/compose", "O(r²c²)"),
    ("AL050", "gluing_rec 束匹配族枚舉", "src/compose", "O(Π|F(U_i)|)"),
    ("AL051", "weave_mul 2-上循環交織乘法", "src/compose", "O(1)"),
    ("AL052", "monad_closure 閉包單子", "src/compose", "O(1) 位元運算"),
]
for id_, stmt, pkg, cx in algos:
    add("演算法", id_, stmt, pkg, cx, "局部編譯 + 即時驗題；困難度 P")

# ── 等式 ────────────────────────────────────────────────────────────────
eqs = [
    ("E01", "極性定義", "F(A) = { y | ∀x∈A, R(x,y) }, H(B) = { x | ∀y∈B, R(x,y) }", "src/galois"),
    ("E02", "伴隨性", "A ⊆ H(B) ⟺ B ⊆ F(A)", "src/galois"),
    ("E03", "閉包冪等", "c(c(A)) = c(A), c = F∘H", "src/galois"),
    ("E04", "三次極性", "F∘H∘F = F 且 H∘F∘H = H", "src/axioms"),
    ("E05", "卷積么半群", "(a*b)(m) = Σ_{u*v=m} a(u)b(v)", "src/series"),
    ("E06", "截斷商同態", "π_N(a·b) = π_N(a)·π_N(b)", "src/series"),
    ("E07", "Newton 迭代", "g ← g(2 − a·g)", "src/series"),
    ("E08", "Lagrange 反演", "[t^k] f^{-1}(t) = (1/k)[t^{k-1}] h(t)^{-k}", "src/series"),
    ("E09", "複合反演", "f(f^{-1}(t)) ≡ t (mod t^N)", "src/series"),
    ("E10", "Möbius 反演", "ζ * μ = δ₁，即 Σ_{d|n} μ(d) = [n=1]", "src/series"),
    ("E11", "Euler 乘積", "f(n) = Π_{p^e || n} f(p^e)", "src/series"),
    ("E12", "Hilbert–Poincaré", "H_{R/I}(t) = (Σ_S (−1)^{|S|} t^{deg lcm(S)})/(1−t)^n", "src/algebra"),
    ("E13", "商環 Hilbert 遞推", "h(n) − h(n−1) = δ_{n,0} − δ_{n,d}", "src/algebra"),
    ("E14", "Ore 交換律", "x·u = q·u·x", "src/algebra"),
    ("E15", "σ-Leibniz", "δ(rs) = δ(r)s + σ(r)δ(s)", "src/algebra"),
    ("E16", "q-整數恆等式", "[i+j]_q = [i]_q + q^i [j]_q", "src/algebra"),
    ("E17", "Ext¹", "Ext¹(ℤ/m, ℤ/n) ≅ ℤ/gcd(m,n)", "src/algebra"),
    ("E18", "Morita context", "(q·p)q' = q(p·q') 且 (q·p)² = (p·q)(q·p)", "src/algebra"),
    ("E19", "Lovász 色數", "χ(KG(n,k)) = n − 2k + 2", "src/graphs"),
    ("E20", "EKR 獨立數", "α(KG(n,k)) = C(n−1, k−1)", "src/graphs"),
    ("E21", "Tutte 秩生成式", "T(M;x,y) = Σ_A (x−1)^{r(E)−r(A)} (y−1)^{|A|−r(A)}", "src/graphs"),
    ("E22", "Betti 數", "β_d = dim ker ∂_d − rank ∂_{d+1}", "src/graphs"),
    ("E23", "Euler–Poincaré", "Σ(−1)^d f_d = Σ(−1)^d β_d", "src/graphs"),
    ("E24", "Kan 伴隨", "Lan_φ ⊣ φ* ⊣ Ran_φ", "src/compose"),
    ("E25", "Kronecker 混合積", "(A⊗B)(C⊗D) = (AC)⊗(BD)", "src/compose"),
    ("E26", "共融推出泛性質", "|Hom(A ⊔_C B, X)| = |X|^{#classes}", "src/compose"),
    ("E27", "2-上循環條件", "φ(a,b)+φ(a+b,c) = φ(b,c)+φ(a,b+c)", "src/compose"),
    ("E28", "束黏合", "匹配族 ↔ F(∪U_i) 為雙射", "src/compose"),
    ("E29", "Ramsey", "R(3,3) = 6", "src/graphs"),
    ("E30", "分數色數", "χ_f(KG(n,k)) = n/k ≤ χ", "src/graphs"),
]
for id_, name, formula, pkg in eqs:
    add("等式", id_, name, pkg, formula, "由對應定理憑證驗證")


def mb_escape(s: str) -> str:
    return s.replace("\\", "\\\\").replace('"', '\\"').replace("\n", " ")


def generate_mbt():
    lines = [
        "///|",
        "/// C1 / src/catalog — 定理／演算法／等式之機器可讀登錄表",
        "/// 由 tools/build_catalog.py 自 docs/catalog.json 生成，请勿手改。",
        "",
        "///|",
        "pub(all) struct Entry {",
        "  id : String",
        "  kind : String",
        "  statement : String",
        "  pkg : String",
        "  formula : String",
        "  verification : String",
        "}",
        "",
        "///|",
        "pub fn catalog() -> Array[Entry] {",
        "  [",
    ]
    for e in A:
        lines.append("    Entry::{{ id: \"{}\", kind: \"{}\", statement: \"{}\", pkg: \"{}\", formula: \"{}\", verification: \"{}\" }},".format(
            mb_escape(e["id"]), mb_escape(e["kind"]), mb_escape(e["statement"]),
            mb_escape(e["package"]), mb_escape(e["formula"]), mb_escape(e["verification"])))
    lines += [
        "  ]",
        "}",
        "",
        "///|",
        "pub fn catalog_size() -> Int { catalog().length() }",
        "",
        "///|",
        "pub fn count_kind(k : String) -> Int {",
        "  let mut c = 0",
        "  for i in 0..<catalog().length() {",
        "    if catalog()[i].kind == k { c += 1 }",
        "  }",
        "  c",
        "}",
        "",
        "///|",
        "/// 登錄表一致性：各類筆數皆為正且總數吻合。",
        "pub fn theorem_catalog_consistent() -> Bool {",
        "  let kinds : Array[String] = [\"公理\", \"定義\", \"命題\", \"引理\", \"定理\", \"演算法\", \"等式\"]",
        "  let mut total = 0",
        "  for i in 0..<kinds.length() {",
        "    let c = count_kind(kinds[i])",
        "    if c <= 0 { return false }",
        "    total += c",
        "  }",
        "  total == catalog_size()",
        "}",
    ]
    with open(os.path.join(ROOT, "src/catalog/catalog.mbt"), "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")


def generate_xlsx():
    from openpyxl import Workbook
    from openpyxl.styles import Font, PatternFill, Alignment
    from openpyxl.utils import get_column_letter

    wb = Workbook()
    head_font = Font(bold=True, color="FFFFFF")
    head_fill = PatternFill("solid", fgColor="1F4E79")
    wrap = Alignment(wrap_text=True, vertical="top")

    # 索引
    ws = wb.active
    ws.title = "索引"
    ws.append(["C1 algorithm.xlsx", "全局公理：伽羅瓦對應", "回合 C1-01", "2026-11-07"])
    ws.append([])
    ws.append(["類別", "筆數", "來源", "驗證"])
    for c in ws[3]:
        c.font = head_font
        c.fill = head_fill
    kinds = ["公理", "定義", "命題", "引理", "定理", "演算法", "等式"]
    for k in kinds:
        n = sum(1 for e in A if e["kind"] == k)
        ws.append([k, n, "docs/catalog.json / src/catalog", "moon check + moon prove + 即時驗題"])
    ws.append(["合計", len(A), "", ""])
    ws.column_dimensions["A"].width = 22
    ws.column_dimensions["B"].width = 10
    ws.column_dimensions["C"].width = 36
    ws.column_dimensions["D"].width = 42

    for k in kinds:
        sheet = wb.create_sheet(k)
        sheet.append(["ID", "陳述／名稱", "套件", "公式／複雜度", "驗證方式", "回合"])
        for c in sheet[1]:
            c.font = head_font
            c.fill = head_fill
        for e in A:
            if e["kind"] != k:
                continue
            sheet.append([e["id"], e["statement"], e["package"], e["formula"], e["verification"], "C1-01"])
        for i, w in enumerate([12, 58, 20, 62, 40, 10], start=1):
            sheet.column_dimensions[get_column_letter(i)].width = w
        for row in sheet.iter_rows(min_row=2):
            for c in row:
                c.alignment = wrap
        sheet.freeze_panes = "A2"
        sheet.auto_filter.ref = sheet.dimensions

    path = os.path.join(ROOT, "algorithm.xlsx")
    wb.save(path)
    return path


def main():
    os.makedirs(os.path.join(ROOT, "docs"), exist_ok=True)
    with open(os.path.join(ROOT, "docs/catalog.json"), "w", encoding="utf-8") as f:
        json.dump({"round": "C1-01", "global_axiom": "伽羅瓦對應", "entries": A}, f, ensure_ascii=False, indent=2)
    generate_mbt()
    p = generate_xlsx()
    counts = {k: sum(1 for e in A if e["kind"] == k) for k in ["公理", "定義", "命題", "引理", "定理", "演算法", "等式"]}
    print("catalog entries:", len(A), counts)
    print("xlsx:", p)


if __name__ == "__main__":
    main()
