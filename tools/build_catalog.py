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
ROUND = "C1-01"


def add(kind, id_, stmt, pkg, formula="", verify=""):
    A.append({
        "kind": kind,
        "id": id_,
        "statement": stmt,
        "package": pkg,
        "formula": formula,
        "verification": verify,
        "round": ROUND,
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


ROUND = "C1-02"

# ── C1-02 補回：前沿定理 ────────────────────────────────────────────────
new_theorems = [
    ("T-Ore7", "deg lclm = deg f + deg g − deg gcrd = rank(Sylvester)，lclm 為公共右倍式", "src/algebra"),
    ("T-Ore8", "F_25 上多組非交換實例的 lclm/Sylvester 恆等式穷舉", "src/algebra"),
    ("T-Ore9", "σ ≠ id：x·θ = −θ·x，Ore 環真正非交換", "src/algebra"),
    ("T-G8", "約束閉包算子 c_req 滿足擴張／單調／冪等", "src/galois"),
    ("T-G9", "NextClosures 基數層級平行枚舉與 closed_attributes 一致", "src/galois"),
    ("T-G10", "約束切分之平行 worker 輸出為 intents 的不交劃分", "src/galois"),
    ("T-S9", "Karatsuba 卷積與 school-book 卷積逐項相等", "src/series"),
    ("T-S10", "Bostan–Mori Graeffe 係數抽取與 Newton 反演一致", "src/series"),
    ("T-S11", "Brent–Kung baby-step/giant-step 合成與直接合成一致", "src/series"),
    ("T-C16", "前沿方法一致性：Ore lclm／NextClosures 平行／Karatsuba／Graeffe 同時成立", "src/compose"),
]
for id_, stmt, pkg in new_theorems:
    add("定理", id_, stmt, pkg, "", "局部編譯 + 即寫即驗即刪；Z3／有限穷舉憑證")

# ── C1-02 補回：前沿演算法 ──────────────────────────────────────────────
new_algos = [
    ("AL053", "sfq_gcrd_lclm 擴展右歐幾里得（同時得 gcrd 與 lclm）", "src/algebra", "O(deg²) 於 F_25"),
    ("AL054", "sfq_sylvester_rank Ore Sylvester 矩陣秩（ISSAC'24）", "src/algebra", "O((df+dg)³)"),
    ("AL055", "fq2_rank F_25 高斯消去與 fq2_inv 範數求逆", "src/algebra", "O(r·c·min(r,c))"),
    ("AL056", "sfq_divmod F_25 上 σ^k 修正之右除", "src/algebra", "O(deg²)"),
    ("AL057", "next_closure_constrained 約束閉包算子之 Ganter 枚舉", "src/galois", "O(ny²|B|)"),
    ("AL058", "intents_by_cardinality 基數層級 BFS（層內可平行）", "src/galois", "O(ny·|B|²)"),
    ("AL059", "parallel_intent_partition 無通訊 worker 不交劃分", "src/galois", " embarrassingly parallel"),
    ("AL060", "kar_mul Karatsuba 次二次卷積", "src/series", "O(n^1.585)"),
    ("AL061", "fps_compose_bk Brent–Kung baby-step/giant-step 合成", "src/series", "O((N/B+B)·M(N))"),
    ("AL062", "graeffe_coeff Bostan–Mori Graeffe 係數抽取", "src/series", "O(M(N) log N)"),
]
for id_, stmt, pkg, cx in new_algos:
    add("演算法", id_, stmt, pkg, cx, "局部編譯 + 即時驗題；困難度 P")

# ── C1-02 補回：前沿等式 ────────────────────────────────────────────────
new_eqs = [
    ("E31", "Ore 度數公式", "deg lclm(f,g) = deg f + deg g − deg gcrd(f,g)", "src/algebra"),
    ("E32", "Sylvester 秩", "deg lclm(f,g) = rank Syl(f,g)", "src/algebra"),
    ("E33", "F_25 係數體", "θ² = 2, σ(θ) = θ⁵ = −θ, σ² = id", "src/algebra"),
    ("E34", "約束閉包", "c_req(A) = c(required ∪ A)", "src/galois"),
    ("E35", "平行不交劃分", "Intents(K) = ⊔_{w=0}^{|M|} Worker_w(K)", "src/galois"),
    ("E36", "Karatsuba 遞迴", "T(n) = 3T(n/2) + O(n) = O(n^{log₂3})", "src/series"),
    ("E37", "Graeffe 減半", "[t^N] P/Q = [t^{⌊N/2⌋}] U_{parity}/V", "src/series"),
    ("E38", "BK 合成分解", "f(g) = Σ_i (Σ_{j<B} f_{iB+j} g^j) · g^{iB}", "src/series"),
]
for id_, name, formula, pkg in new_eqs:
    add("等式", id_, name, pkg, formula, "由對應定理憑證驗證")

# ── 前沿文獻（C1-01 R1..R12 + C1-02 R13..R25 + C1-03 R26..R36）────────────────────────
REFS = [
    ("R1", "Bigatti–Caboara–Robbiano, Hilbert–Poincaré series of monomial ideals (1991)", "1991", "https://www.researchgate.net/publication/220537752_On_the_Computation_of_Hilbert-Poincare_Series", "單項式理想 Hilbert 級數演算法 HP"),
    ("R2", "Lezama et al., Ore and Goldie theorems for skew PBW extensions", "2013", "https://www.researchgate.net/publication/256327517_Ore_and_Goldie_theorems_for_skew_PBW_extensions", "skew PBW 廣義 Hilbert 級數可計算"),
    ("R3", "Giesbrecht, On Factoring Quantum-Plane Skew Polynomials over Q(ω)(t)", "2026", "https://arxiv.org/html/2607.02751", "中心界／gcrd 分割／兩層模組分解"),
    ("R4", "Ore extension xr = σ(r)x + δ(r), δ(rs)=δ(r)s+σ(r)δ(s)", "2025", "https://arxiv.org/pdf/2505.21030", "Ore 環為自由右 R-模"),
    ("R5", "Gómez-Torrecillas–Lobillo–Navarro, Computing the bound of an Ore polynomial", "2013", "https://arxiv.org/abs/1307.5529", "bound 快速演算法與不可約判準"),
    ("R6", "Giesbrecht, Factoring in Skew-Polynomial Rings", "1992/98", "https://cs.uwaterloo.ca/~mwg/files/SkewFactor92.pdf", "deg lclm = deg f + deg g − deg gcrd"),
    ("R7", "Brent–Kung, Fast Algorithms for Manipulating Formal Power Series", "1978", "https://dl.acm.org/doi/pdf/10.1145/322092.322099", "composition ≡ reversion, Newton O(M(n) log n)"),
    ("R8", "Johansson, A fast algorithm for reversion of power series", "2011", "https://ar5iv.labs.arxiv.org/html/1108.4772", "Lagrange 反演常數因子改進"),
    ("R9", "Ganter NextClosure / FCA concept lattices", "—", "https://phoenix.inf.upol.cz/esf/ucebni/formal.pdf", "lectic 枚舉 O(|G||M|²|B|)"),
    ("R10", "Zhang / Pratt, Chu spaces, concept lattices, event-state duality", "2004", "https://www.entcs.org/files/mfps19/83018.pdf", "完備格表示與 Chu 對偶"),
    ("R11", "Lovász / EKR, Kneser graph chromatic & independence numbers", "1978/1961", "https://mathworld.wolfram.com/KneserGraph.html", "χ=n−2k+2, α=C(n−1,k−1)"),
    ("R12", "Kriegel, NextClosures with Constraints", "2016", "https://ceur-ws.org/Vol-1624/paper18.pdf", "閉包算子格、約束與平行探索"),
    ("R13", "Giesbrecht, On Factoring Quantum-Plane Skew Polynomials over Q(ω)(t) (CASC 2026)", "2026", "https://arxiv.org/html/2607.02751", "中心 C=K(t^m)[x^m]；monic central bound 由線性代數計算；gcrd 分割；T↦a 特殊化後 inert prime 降到有限域，Caruso–Le Borgne 分解、插值提升、精確右除驗證；代數閉包上可判定"),
    ("R14", "Ding–Wang–Xiao–Zheng, An Algorithm for Computing GCRD of Parametric Ore Polynomials (ISSAC'24)", "2024", "http://www.mmrc.iss.ac.cn/~dwang/papers/24issac.pdf", "定義 Ore Sylvester 矩陣；非參數時行階梯形式直接得 gcrd；參數時以模組 Gröbner 基底求參數 gcrd；Singular 實作"),
    ("R15", "Caruso–Le Borgne, A new faster algorithm for factoring skew polynomials over finite fields", "2017", "https://xavier.caruso.ovh/papers/publis/fastfactor.pdf", "reduced norm N: k[X;σ]→k^σ[X^r]、Azumaya 代數；快速乘法／除法／擴展歐幾里得；§3.2.2 rgcd 與 llcm；SkewFactorization 平均 Õ(d r³ log q + …)"),
    ("R16", "Beckermann–Labahn, Fraction-free Row Reduction of Matrices of Ore Polynomials", "2000s", "https://cs.uwaterloo.ca/~glabahn/Papers/ffshift.pdf", "無分式列消去求左零空間／weak Popov form，同時得 GCRD 與 LCLM；與 subresultants 聯繫"),
    ("R17", "Puchinger–Wachter-Zeh, Fast Operations on Linearized Polynomials", "2017", "https://arxiv.org/abs/1512.06520", "skew 多項式次二次乘法、q-transform、多點求值／插值、Gabidulin 解碼"),
    ("R18", "Lyu, Complete Factorization of Skew-Polynomials over Finite Fields", "2020s", "https://saiyuelyu.github.io/assets/pdf/SkewPolynomialProject.pdf", "KaratsubaSkew 遞迴：低次用 Giesbrecht、高次 3 次半尺寸乘法，O(n^1.58 t^1.41)"),
    ("R19", "Kriegel–Borchmann, NextClosures: Parallel Computation of the Canonical Base (CLA 2015)", "2015", "https://lat.inf.tu-dresden.de/research/papers/2015/KrBo-CLA15.pdf", "NextClosure 本質序列（lectic）無法平行；改以基數遞增層級枚舉 intents/pseudo-intents，同層候選獨立、無需通訊，speedup ∝ CPU 數"),
    ("R20", "Kriegel, NextClosures with Constraints / Parallel Attribute Exploration (CLA/ICCS 2016)", "2016", "https://ceur-ws.org/Vol-1624/paper18.pdf", "閉包算子構成完備格；約束為第二閉包算子 φ⋎ψ；quasi-rank 函數；Algorithm 1 每層候選平行處理；約束不相容時平行探索不可行"),
    ("R21", "Kinoshita–Li, Power Series Composition in Near-Linear Time (FOCS 2024)", "2024", "https://arxiv.org/abs/2404.05177", "基於 Bostan–Mori Graeffe 迭代與轉置原理；任意交換環上 O(M(n) log m + M(m))；改進 Kedlaya–Umans 與 NSSV O(n^1.43)"),
    ("R22", "Bostan–Mori, Graeffe iteration for [x^N] P(x)/Q(x) (SOSA 2021)", "2021", "https://arxiv.org/abs/2404.05177", "Q(x)Q(−x)=V(x²)，U 分偶奇部，N 每輪減半，O(M(n) log N)"),
    ("R23", "de Moraes et al., Parallelism in the Generation of Concepts Through Formal Context Object Partitioning (In-Close 4, OpenMP)", "2023", "https://www.scitepress.org/Papers/2023/119915/119915.pdf", "以物件子脈絡切分工作單元；4 threads 最高 1.425× speedup、71% 效率；冗餘屬性先移除"),
    ("R24", "Bastioni–Micheli–Zhao, On the Characteristic Polynomial of Linearized Polynomials", "2025", "https://arxiv.org/abs/2506.16937", "O(n(log n)^4) F_q 運算，對低次線性化多項式達平方根級改進"),
    ("R25", "Krajca–Outrata–Vychodil, Parallel CbO / FCbO canonicity test", "2010s", "http://outrata.inf.upol.cz/publications.en.html", "改進 canonicity test 減少重複概念；同層 fixpoints 可平行處理"),
]

ROUND = "C1-03"

# ── C1-03：算術譜／三類圖譜／離散微分幾何／泛性質／歪多項式 K 理論 ──────
new_theorems3 = [
    ("T-X1", "Faddeev–LeVerrier 特徵多項式滿足 Cayley–Hamilton 與 det/tr 恆等式", "src/exact"),
    ("T-Gph2", "Newton 恆等式：tr(L^j) 由 det(tI−L) 係數決定", "src/graphs"),
    ("T-Gph3", "Kirchhoff：L·1=0、rank(L)=n−#components、生成樹 >0 ⟺ 連通", "src/graphs"),
    ("T-Gph4", "Chung/Dodziuk–Alon–Milman Cheeger：λ₂/2 ≤ h ≤ √(2λ₂)", "src/graphs"),
    ("T-Gph5", "KG(5,2)=Petersen：L 譜 {0,2⁵,5⁴}，ℒ 譜 {0,(2/3)⁵,(5/3)⁴}", "src/graphs"),
    ("T-Gph6", "BFS 測地距離為度量（對稱、三角不等式）", "src/graphs"),
    ("T-Gph7", "切束維度 Σ_v dim T_v = 2|E|，餘切由 Chu 對偶給出", "src/graphs"),
    ("T-Gph8", "離散 Hodge：Δ⁰=δᵀδ=聯絡 Laplacian，ker Δ⁰=ker δ", "src/graphs"),
    ("T-Gph9", "O(1) 線叢平坦 ⟺ 環 holonomy=+1 ⟺ dim H⁰=1", "src/graphs"),
    ("T-Gph10", "測地線平行移動 holonomy ∈{±1} 且路徑反向不變", "src/graphs"),
    ("T-A1", "算術 ζ/Poincaré 多項式 Σ_{d|n}t^{Ω(d)} = ∏(1+...+t^{e_i})", "src/series"),
    ("T-A2", "算術 spectral triple：χ_D=∏(t−Ω(d))、[D,E_p]=0、[D,T_p]=T_p", "src/series"),
    ("T-A3", "Spec(ℤ/nℤ) 之 Zariski 極性為伽羅瓦對應（伴隨性＋閉包三律）", "src/series"),
    ("T-A4", "Σ_{d|n}φ(d)=n、Σ_{d|n}μ(d)=[n=1]、φ(n)=n∏(1−1/p)", "src/series"),
    ("T-K0-1", "G₀(R/(f)) ≅ ℤ^s，s=相異不可約右因子數；合成因子次數和=deg f", "src/algebra"),
    ("T-K0-2", "Quillen–Grayson 基本定理：H_R(t)=1/(1−t)，秩 1→2→1→0，Euler=0", "src/algebra"),
    ("T-K0-3", "Morita 不變性：2×2 冪等矩陣 tr(e)=rank(e)·1", "src/algebra"),
    ("T-K0-4", "K₀ 函子性：局部化泛性質與基本定理複合為零", "src/algebra"),
    ("T-K0-5", "δ=0 時 x^k r = σ^k(r) x^k（Shin 2024 q-binomial 之 σ²=id 特例）", "src/algebra"),
    ("T-C17", "泛性質：纖維積中介態射唯一、自由么半群 |Hom|=x²、函子性", "src/compose"),
    ("T-C18", "21×14 衍生方向相容矩陣非平凡；GF(2) 秩=12", "src/compose"),
    ("T-C19", "泛性質 × 21 動詞 × 14 手法之一致性", "src/compose"),
]
for id_, stmt, pkg in new_theorems3:
    add("定理", id_, stmt, pkg, "", "局部編譯 + 即寫即驗即刪；有限穷舉/精確有理憑證")

new_algos3 = [
    ("AL063", "mat_det / mat_rank 有理高斯消去", "src/exact", "O(n³)"),
    ("AL064", "mat_charpoly Faddeev–LeVerrier", "src/exact", "O(n⁴)"),
    ("AL065", "poly_from_points Newton 差商插值（無溢位）", "src/exact", "O(n²)"),
    ("AL066", "mat_generalized_charpoly det(A−tB) 求值插值", "src/exact", "O(n⁴)"),
    ("AL067", "poly_smallest_positive_root 1/8 網格根隔離", "src/exact", "O(deg·16)"),
    ("AL068", "spectral_power_sums Newton 恆等式冪和", "src/graphs", "O(k²)"),
    ("AL069", "graph_spanning_trees Kirchhoff 餘子式", "src/graphs", "O(n³)"),
    ("AL070", "graph_conductance 體積加權最小割", "src/graphs", "O(2^n·n)"),
    ("AL071", "graph_normalized_charpoly 廣義特徵多項式", "src/graphs", "O(n⁴)"),
    ("AL072", "geodesic_distances / geodesic_path BFS", "src/graphs", "O(n²)"),
    ("AL073", "tangent_space 切空間基底", "src/graphs", "O(n)"),
    ("AL074", "cycle_basis BFS 樹補邊 + LCA 基本環", "src/graphs", "O(n³)"),
    ("AL075", "holonomy / curvature 平行移動與曲率", "src/graphs", "O(|E|)"),
    ("AL076", "sheaf_coboundary / sheaf_laplacian", "src/graphs", "O(|E|n²)"),
    ("AL077", "connection_laplacian O(1) 線叢", "src/graphs", "O(n²)"),
    ("AL078", "prime_factorization / divisors_of / big_omega", "src/series", "O(n)"),
    ("AL079", "arithmetic_zeta_poly 算術 ζ 多項式", "src/series", "O(τ(n))"),
    ("AL080", "arithmetic_hecke 升階算子 T_p", "src/series", "O(τ(n)²)"),
    ("AL081", "theorem_arithmetic_galois Zariski 極性有限穷舉", "src/series", "O(2^{p+d})"),
    ("AL082", "sfq_factor 歪多項式右因子分解", "src/algebra", "O(25^{d}·deg²)"),
    ("AL083", "sfq_distinct_factors G₀ 生成元", "src/algebra", "O(k²)"),
    ("AL084", "theorem_universal_property_pullback 中介態射枚舉", "src/compose", "O(n^{2q})"),
    ("AL085", "verb_apply 21 衍生方向動詞變換", "src/compose", "O(n²)"),
    ("AL086", "deriv_invariant 14 手法不變量", "src/compose", "O(2^n)"),
    ("AL087", "verb_pattern_matrix / stable_pairs / row_classes", "src/compose", "O(21·14·C)"),
    ("AL088", "verb_composition_closure 441 組動詞複合", "src/compose", "O(441·14·C)"),
]
for id_, stmt, pkg, cx in new_algos3:
    add("演算法", id_, stmt, pkg, cx, "困難度 P；局部編譯 + inspect")

new_eqs3 = [
    ("E39", "特徵多項式", "p_M(t) = det(tI − M) = t^n + c_{n−1}t^{n−1} + ⋯ + c₀", "src/exact"),
    ("E40", "Cayley–Hamilton", "p_M(M) = 0；det(M) = (−1)^n p_M(0)", "src/exact"),
    ("E41", "Newton 冪和", "p_k = e₁p_{k−1} − e₂p_{k−2} + ⋯ + (−1)^{k−1}k e_k", "src/graphs"),
    ("E42", "Kirchhoff", "τ(G) = det L^{(i,i)}；rank L = n − c(G)", "src/graphs"),
    ("E43", "Cheeger", "λ₂/2 ≤ h(G) ≤ √(2λ₂)", "src/graphs"),
    ("E44", "正規化廣義特徵", "det(L − tD) = det(D)·∏(λ_i(ℒ) − t)", "src/graphs"),
    ("E45", "離散 Hodge", "Δ⁰_F = δᵀδ；ker Δ⁰ = H⁰(G;F)", "src/graphs"),
    ("E46", "算術 ζ", "Σ_{d|n} t^{Ω(d)} = ∏_i (1+t+⋯+t^{e_i})", "src/series"),
    ("E47", "Dirac–Hecke 交換子", "[D,E_p]=0；[D,T_p]=T_p；tr D² = Σ_k c_k k²", "src/series"),
    ("E48", "K₀ 基本定理", "K₀(R[t,t⁻¹]) ≅ K₀(R) ⊕ K₋₁(R)；Euler: 1−2+1−0=0", "src/algebra"),
    ("E49", "G₀ 商環", "G₀(R/(f)) ≅ ℤ^{#distinct irreducible right factors}", "src/algebra"),
    ("E50", "衍生相容矩陣", "M[v][p] = [inv_p(V_v(D₀)) = inv_p(D₀)] ∈ F₂^{21×14}", "src/compose"),
]
for id_, name, formula, pkg in new_eqs3:
    add("等式", id_, name, pkg, formula, "由對應定理憑證驗證")

REFS = REFS + [
    ("R26", "Connes–Consani–Moscovici, Zeta Spectral Triples, arXiv:2511.22755 / EMS 2026", "2025/26", "https://arxiv.org/abs/2511.22755", "rank-one 擾動之 scaling spectral triple + p≤λ² 有限 Euler 積；譜逼近 ζ 零點；正則化行列式 → Riemann Ξ；收斂證明等價 RH"),
    ("R27", "Connes–Consani, On the Jacobian of Spec Z, arXiv:2602.15941 / JNCG 2026", "2026", "https://arxiv.org/pdf/2602.15941", "Spec Z 為無限虧格算術曲線；Pic(Spec Z) 么半群、Arakelov 度量除子、adelic Abel–Jacobi；Weil 顯式公式 = Lefschetz 跡公式"),
    ("R28", "Hansen–Ghrist, Toward a Spectral Theory of Cellular Sheaves / Laplacians of Cellular Sheaves", "2010s", "https://jakobhansen.org/publications/spectralsheaves.pdf", "F:(K,≤)→Vect；H⁰=ker δ；Δ⁰=δᵀδ；ker Δ⁰=H⁰；O(n) 向量叢 → Singer–Wu graph connection Laplacian"),
    ("R29", "Wei et al., Persistent Sheaf Laplacians, Foundations of Data Science 7(2) 2025 pp.446–463", "2025", "https://users.math.msu.edu/users/weig/paper/p341.pdf", "多尺度 sheaf Laplacian；π• 導出 persistent sheaf Betti 數；捕捉非幾何標記資訊"),
    ("R30", "Cellular Sheaves on Higher-Dimensional Structures, arXiv:2505.23993", "2025", "https://www.arxiv.org/pdf/2505.23993v1", "環/模值層、張量積層、Kronecker 積還原圖 Laplacian；2-維單純複形之 1-st sheaf Laplacian"),
    ("R31", "Chung 正規化 Laplacian / Kwok–Lau–Lee–Oveis Gharan–Trevisan Improved Cheeger / Kinoshita? 2026 second-gap Cheeger / Re-imagining Spectral Graph Theory arXiv:2504.10624", "1978–2026", "https://cs.uwaterloo.ca/~lapchi/papers/Cheeger.pdf", "λ₂/2≤h≤√(2λ₂)；φ(G)=O(k)λ₂/√λ_k；inner product Laplacian 統一 combinatorial/normalized/hypergraph/directed"),
    ("R32", "Budninskiy et al., Parallel Transport Unfolding (PTU)", "2018", "https://www.geometry.caltech.edu/pubs/BYFTD18.pdf", "離散局部切空間（SVD 基底）、離散度量聯絡之平行移動、測地距離估計；收斂到 Levi-Civita 聯絡"),
    ("R33", "Doña Mateo, Pushforward monads, TAC 44(30) 2025 / arXiv:2406.15256", "2025", "http://tac.mta.ca/tac/volumes/44/30/44-30.pdf", "Ran_G(GT) 給 G♯T 單子；兩個泛性質；Mnd(A)↔Mnd(B) 伴隨；codensity monad 極限完備不變性"),
    ("R34", "Quillen–Grayson 代數 K 理論基本定理 / Skew PBW Extensions (Quillen–Suslin 演算法)", "1976–2020", "https://en.wikipedia.org/wiki/Fundamental_theorem_of_algebraic_K-theory", "G_i(R[t])=G_i(R)；G_i(R[t,t⁻¹])=G_i(R)⊕G_{i−1}(R)；局部化長正合序列；冪等矩陣 → 投影模基底"),
    ("R35", "Shin, Jacobson Radicals of Ore Extensions, arXiv:2405.16342 / Lorensen–Öinert arXiv:2505.21030", "2024/25", "https://arxiv.org/pdf/2405.16342", "q-skew σ-導子與 q-二項式公式 x^k r = Σ [k choose i]_q σ^i D^{k−i}(r) x^i；Ore 擴張之 rank condition"),
    ("R36", "Oberwolfach Report 36/2025: Algebraic K-theory", "2025", "https://publications.mfo.de/bitstream/handle/mfo/4320/OWR_2025_36.pdf", "A¹-不變性、非交換動機、Grayson Γ 函子 K(ΓC)≃ΣK(C)、對數/導出方案之 K 理論"),
]

# ── C1-04：補回 §6'' 最前沿待辦（Kinoshita–Li / NTT / Ore / FCbO / PSL / monad）──
ROUND = "C1-04"

new_defs4 = [
    ("D28", "NTT 環 F_p, p=998244353=119·2²³+1，原根 3", "src/exact"),
    ("D29", "TMVP：Toeplitz 矩陣經 2n 循環嵌入之 NTT 卷積", "src/exact"),
    ("D30", "Ore bound：中心 F_5[t]（t=x²）之首一中心左倍式", "src/algebra"),
    ("D31", "Reduced norm：N(f)=det[[A,tσ(B)],[B,σ(A)]]=Aσ(A)−tBσ(B)", "src/algebra"),
    ("D32", "FCbO 之 Θ¹_{X,Y} 與 offset N_j 失敗記錄", "src/galois"),
    ("D33", "PersistentSheaf：X⊂Y 前 k 頂點誘導子複形 + O(1) 線叢", "src/graphs"),
    ("D34", "FiniteMap / PosetKan：Σ_f⊣f*⊣Π_f 與 Lan_K⊣K*⊣Ran_K", "src/compose"),
    ("D35", "LibraryClustering：33 位元簽章之 Jaccard union-find 聚類", "src/compose"),
    ("D36", "SpectralTriple rank-one 擾動 D_a = D + a|1⟩⟨1|", "src/series"),
    ("D37", "Adelic Abel–Jacobi：Div₀(Spec Z) → ℚ*，AJ(D)=∏p^{e_p}", "src/series"),
    ("D38", "F_5[u] 么模列與 Quillen–Suslin 補全（A¹-不變性）", "src/algebra"),
    ("D39", "δ-Galois：F_5[t]/(t⁵) 之平移群 G_a(F_5) 與 δ-常數", "src/algebra"),
]
for id_, stmt, pkg in new_defs4:
    add("定義", id_, stmt, pkg, "", "moon check --deny-warn + 即寫即驗即刪")

new_theorems4 = [
    ("T-S12", "Kinoshita–Li PowProj：Bostan–Mori Graeffe 迭代之 [x^N]P/Q 正確性", "src/series"),
    ("T-S13", "Kinoshita–Li Comp：O(M(n) log m+M(m)) 合成與直接合成逐項相等", "src/series"),
    ("T-X2", "NTT 正逆變換互逆、卷積 = school-book mod 998244353", "src/exact"),
    ("T-X3", "Toeplitz 循環嵌入 NTT 之矩陣向量乘積 = 直接乘積（TMVP）", "src/exact"),
    ("T-X4", "Toom–Cook 3-way（5 求值點 + Lagrange 插值）= 整數卷積", "src/exact"),
    ("T-X5", "n=3⁹ 時 NTT < Toom-3 < Karatsuba < school-book 之運算量序", "src/exact"),
    ("T-Ore10", "reduced norm 落於中心 F_5[t]、具乘法性且 N(f)=f·f̄", "src/algebra"),
    ("T-Ore11", "Ore bound 為最小首一中心左倍式且 deg ≤ 2deg f", "src/algebra"),
    ("T-Ore12", "中心分解 h_i 兩兩右互質、Σdeg h_i=deg f、lclm(h_i)=f", "src/algebra"),
    ("T-Ore13", "參數 GCRD 特化 σ-等變且每層 Sylvester 秩缺陷 = deg gcrd", "src/algebra"),
    ("T-Ore14", "模組 Gröbner 基底秩 = deg lclm，最低次列 = gcrd", "src/algebra"),
    ("T-Ore15", "兩層模組分解因子不可約、次數和=deg f、與直接分解同譜", "src/algebra"),
    ("T-Ore16", "δ-Galois：G_a(F_5) 與 δ 交換，固定環 = δ-常數 F_5", "src/algebra"),
    ("T-Ore17", "A¹-不變性：F_5[u] 么模列皆可補全，K₀(F_5[u])≅ℤ", "src/algebra"),
    ("T-Ore18", "Laurent 局部化 gcd 乘法性 u^k·gcd(a,b)", "src/algebra"),
    ("T-G11", "FCbO 列舉全部 intent、無重複、皆為閉集", "src/galois"),
    ("T-G12", "FCbO 新 canonicity test 守恆律 closures+skipped=CbO closures", "src/galois"),
    ("T-G13", "FCbO 新測試啟動時嚴格少算閉包（skipped>0）", "src/galois"),
    ("T-G14", "PFCbO worker 輸出為 intents 之不交分割且聯集完備", "src/galois"),
    ("T-Gph11", "ker Δ₀^{X,Y} ≅ π•(H⁰(Y;G))：nullity = persistent Betti", "src/graphs"),
    ("T-Gph12", "Δ₀^{X,Y} 半正定（全主子式 ≥0）且零根重數 = β₀", "src/graphs"),
    ("T-Gph13", "X=Y 時 persistent Laplacian 退化為 δᵀδ", "src/graphs"),
    ("T-Gph14", "Wei–Wei Prop.3.2：譜不依賴 Y 之定向", "src/graphs"),
    ("T-Gph15", "多尺度 filtration 之 β₀ 單調不減、rank+nullity=k", "src/graphs"),
    ("T-Gph16", "Kalai–Meshulam：M⊆X ⇒ ∃τ∈X, ρ(V∖τ) ≤ λ(X)", "src/graphs"),
    ("T-C20", "Σ_f ⊣ f* ⊣ Π_f 三角伴隨（穷舉 2^nx·2^ny）", "src/compose"),
    ("T-C21", "pushforward monad T=Π_f f*=Ran_f f* 滿足單子律", "src/compose"),
    ("T-C22", "Lan_K ⊣ K* ⊣ Ran_K（協變預層之有限穷舉）", "src/compose"),
    ("T-C23", "codensity monad Ran_K K 為 closure operator", "src/compose"),
    ("T-C24", "Π_f 橋接全局公理 G：Π_f P_A = F(A)", "src/compose"),
    ("T-C25", "集庫成群：聚類分割、Jaccard 門檻、單調性與決定性", "src/compose"),
    ("T-A5", "Connes rank-one：χ_{D+aP}=χ_D−a∏_{d≠1}(t−Ω(d))", "src/series"),
    ("T-A6", "det_ζ=∏_{k≥1}k^{c_k}=|[t^{c₀}]χ_D| 且 ζ_D(2)=tr(D⁺²)", "src/series"),
    ("T-A7", "Grothendieck–Lefschetz：exp(Σω t^k/k)=(1−t)^{−ω}", "src/series"),
    ("T-A8", "adelic AJ 單射、div(AJ(D))=D、Pic(Spec Z)=0", "src/series"),
]
for id_, stmt, pkg in new_theorems4:
    add("定理", id_, stmt, pkg, "", "局部 moon test --deny-warn 即寫即驗；精確有理／有限穷舉憑證")

new_algos4 = [
    ("AL089", "kl_pow_proj / kl_comp / kl_compose", "src/series", "O(M(n)log m+M(m))"),
    ("AL090", "ntt / ntt_mul / ntt_cyclic_mul", "src/exact", "O(n log n)"),
    ("AL091", "toeplitz_mvp_ntt 循環嵌入", "src/exact", "O(n log n)"),
    ("AL092", "toom3_mul 五點求值 Lagrange 插值", "src/exact", "O(n^log₃5)"),
    ("AL093", "multiplication_costs 複雜度模型", "src/exact", "O(log n)"),
    ("AL094", "f5p_irreducibles / f5p_embed / f5p_divmod", "src/algebra", "O(5^d·d³)"),
    ("AL095", "ore_even_odd / ore_reduced_norm / ore_bound", "src/algebra", "O(d²)"),
    ("AL096", "ore_central_decomposition / ore_two_level_factor", "src/algebra", "O(5^d·d³)"),
    ("AL097", "sfq_module_groebner（leading-degree RREF）", "src/algebra", "O((df+dg)³)"),
    ("AL098", "sfq_specialize / parametric_gcrd_strata", "src/algebra", "O(5·(df+dg)³)"),
    ("AL099", "fp5_translate / fp5_delta δ-Galois 群", "src/algebra", "O(5³)"),
    ("AL100", "fu_gcd_ext / a1_homotopy / theorem_a1_*", "src/algebra", "O(125²·d²)"),
    ("AL101", "fcbo_run / cbo_closure_count", "src/galois", "O(|concepts|·n²)"),
    ("AL102", "pfcbo_workers 層級 L 之 round-robin 分發", "src/galois", "O(w·|queue|)"),
    ("AL103", "persistent_laplacian_from_delta / kernel_projector", "src/graphs", "O(m³+k²m)"),
    ("AL104", "persistent_sheaf_bars 多尺度 filtration", "src/graphs", "O(n·m³)"),
    ("AL105", "leray_number / induced_complex / kalai_meshulam_witness", "src/graphs", "O(2^n·n³)"),
    ("AL106", "sigma_f / pullback_f / pi_f / pushforward_monad", "src/compose", "O(2^{nx+ny})"),
    ("AL107", "lan_presheaf / ran_presheaf / codensity_value", "src/compose", "O(2^{m+n}mn)"),
    ("AL108", "library_signature / library_clustering", "src/compose", "O(N²)"),
    ("AL109", "connes_rank_one / regularized_determinant / spectral_zeta", "src/series", "O(τ(n)³)"),
    ("AL110", "spec_z_zeta_series / adelic_abel_jacobi", "src/series", "O(cut²+2^p)"),
]
for id_, stmt, pkg, cx in new_algos4:
    add("演算法", id_, stmt, pkg, cx, "困難度 P；局部 moon test --deny-warn + inspect")

new_eqs4 = [
    ("E51", "Kinoshita–Li PowProj", "[x^N] P/Q = 偶部 U(x²)+x·奇部 U(x²)/A(x²)", "src/series"),
    ("E52", "NTT 卷積", "c = NTT⁻¹(NTT(a)·NTT(b)) mod p, p=998244353", "src/exact"),
    ("E53", "Toom–3", "C(z)=Σ_j ℓ_j(z)·A(z_j)B(z_j)，5 次半尺寸乘法", "src/exact"),
    ("E54", "Reduced norm", "N(f)=Aσ(A)−t Bσ(B) ∈ F_5[t]，t=x²", "src/algebra"),
    ("E55", "Ore bound", "deg φ ≤ 2 deg f；φ = N(f)/lc(N(f))", "src/algebra"),
    ("E56", "FCbO 守恆律", "closures(FCbO)+skipped = closures(CbO)", "src/galois"),
    ("E57", "Persistent sheaf Laplacian", "Δ₀^{X,Y}=M Proj_Θ Mᵀ，Proj_Θ=I−Aᵀ(AAᵀ)⁻¹A", "src/graphs"),
    ("E58", "Persistent Betti", "β₀^{X,Y}=(n−rankδ_Y)−((n−k)−rankδ_Y[:,k:])", "src/graphs"),
    ("E59", "Kalai–Meshulam", "M⊆X ⇒ ∃τ∈X: ρ(V∖τ) ≤ λ(X)", "src/graphs"),
    ("E60", "Pushforward monad", "T=Π_f f*=Ran_f f*；T(B)=B∪(Y∖im f)", "src/compose"),
    ("E61", "Ran / codensity", "(Ran_K F)(q)=⋀_{q≤Kp}F(p)；(Ran_K K)(q)=min{Kp|q≤Kp}", "src/compose"),
    ("E62", "Connes rank-one", "det(D+I+aP)=det(D+I)(1+a)", "src/series"),
    ("E63", "Lefschetz zeta", "Z(X,t)=exp(Σ_k #X(F_{q^k})t^k/k)=1/(1−t)^{ω(n)}", "src/series"),
    ("E64", "Adelic Abel–Jacobi", "AJ(D)=∏_p p^{e_p}；div(AJ(D))=D", "src/series"),
    ("E65", "A¹-同倫不變性", "K₀(F_5[u])≅K₀(F_5)≅ℤ；det[[a,b],[−q,p]]=1", "src/algebra"),
]
for id_, name, formula, pkg in new_eqs4:
    add("等式", id_, name, pkg, formula, "由對應定理憑證驗證")

REFS = REFS + [
    ("R37", "Kinoshita–Li, Power Series Composition in Near-Linear Time, FOCS 2024 (arXiv:2404.05177v2, Algorithm 1 PowProj / Algorithm 2 Comp)", "2024", "https://arxiv.org/html/2404.05177v2", "Algorithm 1 Graeffe U=P Q(−x)、A=Q Q(−x)、偶奇壓縮；Algorithm 2 F_{d,m} 反轉多項式、V(x,y) 壓縮、遞迴 W=Comp(⌈n/2⌉,e,m,P,V)、B=W(x²,y)Q(−x,y)；O(M(n)log m+M(m))"),
    ("R38", "Krajča–Outrata–Vychodil, Advances in Algorithms Based on CbO (CLA 2010, CEUR Vol-672 paper29)", "2010", "https://ceur-ws.org/Vol-672/paper29.pdf", "Lemma 1 之新增 canonicity test：N_j∩Y_j⊆B∩Y_j 才計算 D；失敗時 M_j=D 傳遞子樹；PFCbO 在層級 L 分發 queue；Prop.3.2 譜與定向無關"),
    ("R39", "Wei–Wei, Persistent Sheaf Laplacians, arXiv:2112.10906 / Foundations of Data Science 7(2) 2025", "2021/25", "https://arxiv.org/pdf/2112.10906", "Θ^{q+1}_{X,Y}={x∈C^{q+1}(Y;G)|(d_Y^q)*x∈C^q(X;F)}；Δ_q^{X,Y}=D*P⁻¹Dᵀ+d_X^{q−1}(d_X^{q−1})ᵀ；ker Δ_q^{X,Y}≅π•(H^q(Y;G))；Prop.3.1 矩陣式、Prop.3.2 定向不變"),
    ("R40", "Doña Mateo, Pushforward monads, TAC 44(30) 2025", "2025", "http://tac.mta.ca/tac/volumes/44/30/44-30.pdf", "pushforward monad = Ran_G(GT)；Ran 之 end 公式；codensity monad 為 closure operator；極限完備性不變"),
    ("R41", "Connes–Consani–Moscovici, Zeta Spectral Triples (arXiv:2511.22755)", "2025/26", "https://arxiv.org/pdf/2511.22755", "rank-one 擾動 scaling Hamiltonian、有限 Euler 積、正則化行列式 det_ζ、譜 zeta 逼近 Riemann Ξ"),
    ("R42", "Connes–Consani, On the Jacobian of Spec Z (arXiv:2602.15941)", "2026", "https://arxiv.org/pdf/2602.15941", "Arakelov 除子、adelic Abel–Jacobi、Weil 顯式公式 = Lefschetz 跡公式；Pic(Spec Z) 么半群"),
    ("R43", "Kalai–Meshulam, A topological colourful Helly theorem / Intersections of Leray complexes (2005/2006)", "2005/06", "https://www.math.cmu.edu/users/alanlew/files/theses/phd%20thesis.pdf", "X 為 d-Leray、M 為擬陣且 M⊆X ⇒ ∃τ∈X 使 ρ(V∖τ)≤d；λ(X)=max_{U⊆V} top H̃(X[U])+1"),
    ("R44", "Caruso–Le Borgne, Fast factorization of skew polynomials / Gómez-Torrecillas et al., Computing the bound of an Ore polynomial", "2017/2013", "https://xavier.caruso.ovh/papers/publis/fastfactor.pdf", "reduced norm N:k[X;σ]→k^σ[X^r]、Azumaya 代數、最小中心左倍式；Giesbrecht 兩層模組分解；ISSAC'24 模組 Gröbner 求參數 gcrd"),
    ("R45", "Oberwolfach Report 36/2025 Algebraic K-theory / Quillen–Suslin / Bass fundamental theorem", "2025", "https://publications.mfo.de/bitstream/handle/mfo/4320/OWR_2025_36.pdf", "A¹-同倫不變性 K₀(R[t])≅K₀(R)；K₀(R[t,t⁻¹])≅K₀(R)⊕K₋₁(R)；么模列補全；非交換動機"),
]

# ── C1-05：補回 §6''' 剩餘結構（高維 sheaf / Weil / 非交換動機 / 一般 PV）──
ROUND = "C1-05"

new_defs5 = [
    ("D40", "Sheaf2：R=ℚ[ε]/ε² 秩 1 環值層，限制映射 M₂(d)=[[1,0],[d,1]]", "src/graphs"),
    ("D41", "Sheaf1Persistent：q=1 子複形過濾之 persistent 1-st sheaf Laplacian", "src/graphs"),
    ("D42", "AnmSheaf：ANM 剛性模態層，L⁰_F = H_ANM = C⁰(C⁰)ᵀ", "src/graphs"),
    ("D43", "BigRat / Bareiss 任意精度行列式（BigInt 中介子式）", "src/exact"),
    ("D44", "WeilCurve：E/F_q 之 q, ac, bc, a=q+1−N₁, discr=a²−4q", "src/series"),
    ("D45", "Hasse–Weil zeta：Z(E,T)=(1−aT+qT²)/((1−T)(1−qT))", "src/series"),
    ("D46", "NilRing：R_{k,l}=F_p[t,u]/(t^k,u^l) 與 u↦0 求值", "src/compose"),
    ("D47", "U_add：有限生成投影模之泛可加不變（K₀ 關係矩陣之核）", "src/compose"),
    ("D48", "DiffModule：Euler 導數 δ=t d/dt 下之二階 δ-模 ∇=δ−A(t)", "src/algebra"),
    ("D49", "PV gauge 群 G=⋂_k Z_{GL₂}(A_k) 與 Riccati 方程 δu+u²+a₁u+a₀=0", "src/algebra"),
]
for id_, stmt, pkg in new_defs5:
    add("定義", id_, stmt, pkg, "", "moon check --deny-warn + 即寫即驗即刪")

new_theorems5 = [
    ("T-Gph17", "高維環值層：d¹d⁰=0、L¹=d⁰(d⁰)ᵀ+(d¹)ᵀd¹ 對稱 PSD、nullity L¹=β¹", "src/graphs"),
    ("T-Gph18", "persistent q=1 sheaf Laplacian：鏈條件、Hodge nullity=β_p", "src/graphs"),
    ("T-Gph19", "ANM Hessian：L⁰_F=H_ANM、6 rigid modes、rank C⁰=3n−6", "src/graphs"),
    ("T-Gph20", "高維 sheaf 三組憑證合取（環值層 / persistent / ANM）", "src/graphs"),
    ("T-X6", "BigInt Bareiss 行列式無溢位：6×6 中介量 1.5·10¹⁹ 仍給 det=16231235440", "src/exact"),
    ("T-W1", "log Z 導數恆等式 S·P·Q=P′Q−PQ′（mod T^N）", "src/series"),
    ("T-W2", "genus 1 函數方程 Z(E,1/(qT))=Z(E,T)，扭轉算子為對合", "src/series"),
    ("T-W3", "Hasse–Weil 界 |a|≤2√q（a²≤4q）與 a=q+1−N₁", "src/series"),
    ("T-W4", "有限域曲線 RH 之代數憑證 |α|=|β|=√q 與 Newton 恆等式", "src/series"),
    ("T-W5", "Weil 顯式公式 exp(Σ_{n≤N}NₙTⁿ/n)·Q≡P (mod T^{N+1})", "src/series"),
    ("T-W6", "解析極限可計算憑證：4(qt)^{N+1}/((N+1)(1−qt)) 有理餘項界", "src/series"),
    ("T-W7", "六條 F_q 橢圓曲線全套有限精確憑證", "src/series"),
    ("T-NCM1", "K₀ 冪零不變性：Newton 提升 E←E+(1−2E)(E²−E) 且 rank 不變", "src/compose"),
    ("T-NCM2", "導出 K 連續性：塔 R_k→R_{k−1} 之 K₀≅holim K₀≅ℤ", "src/compose"),
    ("T-NCM3", "KH 之 A¹-同倫不變性（有限層）：u↦0 不改變冪等元秩", "src/compose"),
    ("T-NCM4", "U_add 泛性質：關係矩陣秩 5、核一維、Waldhausen 可加與 Morita 穩定", "src/compose"),
    ("T-NCM5", "非交換動機有限層四項憑證合取", "src/compose"),
    ("T-PV1", "一般 δ-模基本解矩陣與 Abel 恆等式 δ(det Y)=tr(A)det Y", "src/algebra"),
    ("T-PV2", "δ-Galois gauge 群精確階數：480 / 20 / 16 / 480 與乘法封閉", "src/algebra"),
    ("T-PV3", "Kovacic 第一型有限 Galois 對應：Riccati 根數 = 不變直線數 = dim V", "src/algebra"),
    ("T-PV4", "C1-04 G_a(F₅) 模型嵌入一般 gauge 群之階 p 加法子群", "src/algebra"),
]
for id_, stmt, pkg in new_theorems5:
    add("定理", id_, stmt, pkg, "", "局部 moon test --deny-warn 即寫即驗；精確有理／有限穷舉憑證")

new_algos5 = [
    ("AL111", "sheaf2_delta0 / sheaf2_delta1 / sheaf2_laplacian1", "src/graphs", "O(|E|²+|T|²)"),
    ("AL112", "psd_principal_minors（BigInt Bareiss 主子式穷舉）", "src/graphs", "O(2^n·n³)"),
    ("AL113", "sheaf1_persistent_betti / sheaf1_persistent_laplacian", "src/graphs", "O(m³·|X|)"),
    ("AL114", "anm_coboundary / anm_hessian / anm_rigid_modes", "src/graphs", "O(n³)"),
    ("AL115", "big_gcd / br_norm / mat_det_bigrat / bigrat_sign", "src/exact", "O(n³·log‖det‖)"),
    ("AL116", "weil_pow_mod / weil_legendre / weil_point_count", "src/series", "O(q log p)"),
    ("AL117", "weil_power_sum / weil_counts（Frobenius 冪和遞推）", "src/series", "O(N)"),
    ("AL118", "weil_log_derivative_identity / weil_poly_mul", "src/series", "O(N²)"),
    ("AL119", "weil_twist / weil_functional_equation", "src/series", "O(deg²)"),
    ("AL120", "weil_explicit_formula（fps_exp 之形式冪級數驗證）", "src/series", "O(N²)"),
    ("AL121", "weil_tail_bound / theorem_weil_explicit_tail", "src/series", "O(N)"),
    ("AL122", "nr_mul（雙變數截斷卷積）/ nr_eval_u0", "src/compose", "O((kl)²)"),
    ("AL123", "idempotent_lift（Newton–Hensel 冪等元提升）", "src/compose", "O(n³·log(kl))"),
    ("AL124", "k0_rref / k0_kernel（關係矩陣回代求 U_add）", "src/compose", "O(n³)"),
    ("AL125", "nm_block_sum（Waldhausen 分裂直和）/ idempotent_rank", "src/compose", "O(n²)"),
    ("AL126", "dr_mul / dr_der（Euler δ=t d/dt 之截斷環）", "src/algebra", "O(m²)"),
    ("AL127", "diff_fundamental（基本解矩陣 Picard 遞推）", "src/algebra", "O(m²)"),
    ("AL128", "diff_solution_nullity（2m×2m F_p 線性映射秩）", "src/algebra", "O(m³)"),
    ("AL129", "dm_gl2 / diff_gauge_group / diff_invariant_lines", "src/algebra", "O(p⁴·m+p²·|G|)"),
    ("AL130", "diff_riccati_roots / theorem_pv_kovacic", "src/algebra", "O(p·m²)"),
]
for id_, stmt, pkg, cx in new_algos5:
    add("演算法", id_, stmt, pkg, cx, "困難度 P；局部 moon test --deny-warn + inspect")

new_eqs5 = [
    ("E66", "高維 sheaf 1-st Laplacian", "L¹_F = C⁰(C⁰)ᵀ + (C¹)ᵀC¹，d¹d⁰=0 ⇒ ker L¹ ≅ H¹", "src/graphs"),
    ("E67", "Hodge–de Rham（有限層）", "nullity L¹ = dim C¹ − rank d⁰ − rank d¹ = β¹", "src/graphs"),
    ("E68", "ANM Hessian", "L⁰_F = H_ANM = C⁰(C⁰)ᵀ，dim H⁰ = 6 rigid modes", "src/graphs"),
    ("E69", "Bareiss 消去", "a_{ij}^{(k)} = (p·a_{ij} − a_{ik}a_{kj}) / prev，中介量恆為子式", "src/exact"),
    ("E70", "Weil 點數", "N₁ = q+1+Σ_x χ_q(x³+ac·x+bc)，a = q+1−N₁", "src/series"),
    ("E71", "Frobenius 冪和", "s₀=2, s₁=a, sₙ=a·sₙ₋₁−q·sₙ₋₂；Nₙ=qⁿ+1−sₙ", "src/series"),
    ("E72", "Hasse–Weil zeta", "Z(E,T)=(1−aT+qT²)/((1−T)(1−qT))，P(T)=1−aT+qT²", "src/series"),
    ("E73", "對數導數恆等式", "S·P·Q = P′Q − PQ′，S(T)=Σ_{n≥1}NₙTⁿ⁻¹", "src/series"),
    ("E74", "Weil 函數方程", "qT²P(1/(qT))=P(T)，qT²Q(1/(qT))=Q(T) ⇒ Z(1/(qT))=Z(T)", "src/series"),
    ("E75", "Weil 顯式公式", "log Z(E,T)=Σ_{n≥1}NₙTⁿ/n；exp(L_N)·Q≡P (mod T^{N+1})", "src/series"),
    ("E76", "顯式公式餘項界", "|Σ_{n>N}Nₙtⁿ/n| ≤ 4(qt)^{N+1}/((N+1)(1−qt))，|qt|<1", "src/series"),
    ("E77", "RH 代數式（有限域曲線）", "α+β=a, αβ=q, a²−4q≤0 ⇒ |α|²=|β|²=q", "src/series"),
    ("E78", "Newton–Hensel 冪等元提升", "E ← E + (1−2E)(E²−E)，(E²−E)∈I^{2^s} ⇒ K₀(R)≅K₀(R/I)", "src/compose"),
    ("E79", "Waldhausen 可加性 / U_add", "[B]=[A]+[C]；K₀=ℤ·[R]，U([R^i])=i；rank(E⊕F)=rank E+rank F", "src/compose"),
    ("E80", "δ-Galois / Abel / Kovacic", "δ(det Y)=tr(A)det Y；G=⋂Z_{GL₂}(A_k)；δu+u²+a₁u+a₀=0", "src/algebra"),
]
for id_, name, formula, pkg in new_eqs5:
    add("等式", id_, name, pkg, formula, "由對應定理憑證驗證")

REFS = REFS + [
    ("R46", "Hansen–Ghrist / Wei–Wei 高維 sheaf Laplacian (arXiv:2505.23993v1)", "2025/26", "https://arxiv.org/pdf/2505.23993v1", "Theorem 1 H^q(K;F)≃ker Δ^q；Example 4/5：L¹_F=C⁰(C⁰)ᵀ+(C¹)ᵀC¹、L⁰_{F⊗G}=L⁰_F⊗I₃；ringed-space module sheaf 與 2-simplex"),
    ("R47", "Pith review of arXiv:2505.23993 / arXiv:2501.06197 (ANM sheaf)", "2026", "https://pith.science/paper/2505.23993", "審查提醒 Hessian recovery 只在 graph Example 3 成立，高維應稱 1-st Laplacian 保留 Hessian-like blocks；ANM 層 L⁰_F=H_ANM、6 rigid modes=H⁰"),
    ("R48", "Bochner/Forman 離散曲率與 H₁^F=δ₀δ₀*+δ₁*δ₁ (arXiv:2610.28455v1)", "2026", "https://arxiv.org/html/2610.28455v1", "高維 cellular sheaf 之 1-st Laplacian 分解；Weitzenböck/Bochner 型曲率恆等式"),
    ("R49", "Weil conjectures / Hasse–Weil zeta of elliptic curves over F_q", "1949/1974", "https://grokipedia.com/page/Weil_conjectures", "Z(E,T)=(1−aT+qT²)/((1−T)(1−qT))、N_n=qⁿ+1−αⁿ−βⁿ、Hasse |a|≤2√q、函數方程與 RH（有限域曲線）"),
    ("R50", "Matsukawa, Higher Noncommutative Motives and Higher K-theory, arXiv:2611.07262", "2026", "https://arxiv.org/abs/2611.07262", "2026-11-05 提交；stable (∞,n)-categories 之 higher additive motives；exact sequences 之泛性質；enriched presheaves 局部化與 weighted Waldhausen S-construction on complete exact flags"),
    ("R51", "Hilman, Parametrised noncommutative motives and equivariant cubical descent (arXiv:2202.02591v3)", "2026", "https://www.sas.rochester.edu/mth/sites/doug-ravenel/otherpapers/hilman-parametrised-motives.pdf", "parametrised perfect–stable categories；NMot^pw corepresents K-theory；additive spectral invariant on Karoubi sequences；Q-construction motivically local"),
    ("R52", "Bachmann–Elmanto–Morrow, A¹-invariant motivic cohomology of schemes, arXiv:2508.09915", "2025", "https://arxiv.org/pdf/2508.09915", "Voevodsky slice filtration、cdh-motivic cohomology、zeroth slice 與 homotopy K-theory KH 之關係；A¹-不變性與 KH(X×A¹)≅KH(X)"),
    ("R53", "Tabuada / Blumberg–Gepner–Tabuada, universal additive invariant U_add (arXiv:1511.03589v3)", "2015/2020", "https://arxiv.org/html/1511.03589v3", "U_add 為 universal additive invariant；Morita equivalences、Waldhausen additivity、K-theory corepresentable、split-exact sequences"),
    ("R54", "Spectral Picard–Vessiot / differential Galois theory, arXiv:2503.03429 & arXiv:2510.07323", "2025", "https://arxiv.org/pdf/2503.03429", "PV extensions、LCLM 與 Wronskian、classical groups 之 direct problem、Levi decomposition 與 G_a-tower"),
    ("R55", "Kovacic algorithm / Picard–Vessiot lecture notes (HAL hal-04117227v1)", "1986/2023", "https://hal.science/hal-04117227v1/document", "Theorem 2.5：Liouvillian solutions ⟺ Riccati 有次數 1/2/{4,6,12} 代數解；Kovacic cases I/II/III 與 SL₂(C) 子群分類"),
]

# ── C1-06：量子二維環面 O_q(T²) / Abel–Jacobi / 21×14 動詞交織 ──────────
ROUND = "C1-06"

new_defs6 = [
    ("D50", "O_q(T²)：VU=qUV 之量子二維環面，單項 q^e U^a V^b", "src/algebra"),
    ("D51", "2-上循環 ω((a,b),(c,d))=b·c 與正則跡 τ、導數 δ₁/δ₂", "src/algebra"),
    ("D52", "QTRoot：qⁿ=1 時 n² 維 root algebra 與 qp∈F_p", "src/algebra"),
    ("D53", "Weil 配對 e_n(x,y)=q^{ad−bc} 與 Heisenberg theta 群交換子", "src/algebra"),
    ("D54", "Rieffel–Schwarz SL₂(ℤ) Morita 作用 θ↦(aθ+b)/(cθ+d)", "src/algebra"),
    ("D55", "ECPoint / AJDivisor：E/F_q 之點與零次除子", "src/series"),
    ("D56", "Abel–Jacobi 映射 AJ : Div⁰(E) → Jac(E)≅E(F_q)", "src/series"),
    ("D57", "Γ-bundle 配對函數 ⟨q^s v(q^m v,u)|q^r u(q^k u,v)⟩=q^{r−s−km}", "src/series"),
    ("D58", "q-商 Abel–Jacobi AJ_q : F_p^* → F_p^*/⟨q⟩", "src/series"),
    ("D59", "Interwoven：21 動詞算子 ρ(v) 與 14 範例狀態 Φ_p 之 W[v][p]=τ(ρ(v)Φ_p)", "src/compose"),
]
for id_, stmt, pkg in new_defs6:
    add("定義", id_, stmt, pkg, "", "moon check --deny-warn + 即寫即驗即刪")

new_theorems6 = [
    ("T-QT1", "定義關係 VU=qUV、U/V 可逆、乘法結合（2-上循環 ω=b·c）", "src/algebra"),
    ("T-QT2", "正則跡 τ 為循環跡 τ(xy)=τ(yx)", "src/algebra"),
    ("T-QT3", "δ₁,δ₂ 滿足 Leibniz／交換／τ∘δᵢ=0；Connes 循環 2-上循環循環不變且非恆零", "src/algebra"),
    ("T-QT4", "qⁿ=1 時中心由 Uⁿ,Vⁿ 生成：U^aV^b 與 U,V 同時交換 ⟺ n|a 且 n|b", "src/algebra"),
    ("T-QT5", "Heisenberg clock/shift 表示 VU=qUV、U³=V³=I、L_U L_V=q⁻¹L_V L_U", "src/algebra"),
    ("T-QT6", "Weil 配對雙線性／交錯／非退化；[g_x,g_y]=q^{bc−ad}=e_n(x,y)⁻¹", "src/algebra"),
    ("T-QT7", "SL₂(ℤ) Morita 作用：么模基底變換、ℤ+θℤ 保持、(gh)·θ=g·(h·θ)", "src/algebra"),
    ("T-QT8", "量子二維環面七項憑證合取", "src/algebra"),
    ("T-AJ1", "E(F_q) 弦切群律為交換群且 |E(F_q)|=N₁=q+1−a（Weil 交織）", "src/series"),
    ("T-AJ2", "AJ 為 Div⁰→Jac(E) 同態且 Abel 定理：主除子 div(x−a)、div(y−lx−m) 之 AJ=0", "src/series"),
    ("T-AJ3", "AJ 滿射、核含主除子、|Jac(E)|=N₁=P(1)（Weil zeta 分子）", "src/series"),
    ("T-AJ4", "Γ-bundle 配對反向互逆、核心雙線性 q^{k·m}、么正不變性指數 0", "src/series"),
    ("T-AJ5", "AJ_q 為滿同態、核=⟨q⟩、陪集數=(p−1)/ord(q)", "src/series"),
    ("T-AJ6", "E(F₇)[3]≅(ℤ/3)²：標號群律、AJ 相容、Weil 配對雙線性／交錯／非退化", "src/series"),
    ("T-AJ7", "Abel–Jacobi 六項憑證合取", "src/series"),
    ("T-IW1", "21×14 交織矩陣非平凡：ℚ-秩 11、GF(7)-秩 3、非零項 185", "src/compose"),
    ("T-IW2", "Gram S=WWᵀ、T=WᵀW 對稱且秩皆為 11、tr S=tr T=ΣW²=2932", "src/compose"),
    ("T-IW3", "Kronecker 自交織 rank(K⊗K)=rank(K)²=9（K 為 4×4 子矩陣）", "src/compose"),
    ("T-IW4", "全局公理 G：交織脈絡之物件／屬性閉集數皆 240 且極性伴隨成立", "src/compose"),
    ("T-IW5", "21 動詞算子代數非交換、滿足 q-Heisenberg、441 複合生成完整 End(A_q) 維度 81", "src/compose"),
    ("T-IW6", "量子環面↔AJ 橋接：Weil 配對與交換子互逆、q^{e₃} 落於 AJ_q 之核 ⟨q⟩", "src/compose"),
    ("T-IW7", "21×14 交織六項憑證與既有 21 動詞相容矩陣之合取", "src/compose"),
]
for id_, stmt, pkg in new_theorems6:
    add("定理", id_, stmt, pkg, "", "局部 moon test --deny-warn 即寫即驗；精確有理／有限穷舉憑證")

new_algos6 = [
    ("AL131", "qt_mul / qt_add / qt_norm（2-上循環 ω=b·c）", "src/algebra", "O(|x|·|y|)"),
    ("AL132", "qt_trace / qt_deriv / qt_star / qt_commutator_mon", "src/algebra", "O(|x|²)"),
    ("AL133", "qt_root_vec / qt_root_mul_vec（n² 維 F_p 代數）", "src/algebra", "O(n⁴)"),
    ("AL134", "qt_root_left_matrix / qt_root_deriv_matrix / qt_root_label_star", "src/algebra", "O(n⁴)"),
    ("AL135", "qt_mat_add / qt_mat_sub / qt_mat_mul / qt_mat_smul", "src/algebra", "O(n⁶)"),
    ("AL136", "qt_root_weil_exp / qt_root_comm_exp", "src/algebra", "O(1)"),
    ("AL137", "theorem_qt_morita_sl2（SL₂(ℤ) 有理分式作用與群律）", "src/algebra", "O(|G|²)"),
    ("AL138", "ec_add / ec_neg / ec_mul（弦切群律）", "src/series", "O(log p)"),
    ("AL139", "ec_all_points（Legendre 快篩逐點列舉 E(F_q)）", "src/series", "O(q²)"),
    ("AL140", "aj_sum / aj_div_add / aj_degree", "src/series", "O(|D|·n)"),
    ("AL141", "aj_vertical_divisor / aj_line_divisor（主除子構造）", "src/series", "O(q²)"),
    ("AL142", "aj_gamma_vu / aj_gamma_uv / aj_gamma_core", "src/series", "O(1)"),
    ("AL143", "aj_q_order / aj_q_coset（q-商之正規代表）", "src/series", "O(ord(q))"),
    ("AL144", "aj_weil_label（E[N] 標號配對）", "src/series", "O(1)"),
    ("AL145", "interwoven_operators（21 動詞 → End(A_q) 算子）", "src/compose", "O(21·n⁴)"),
    ("AL146", "interwoven_state（14 範例 → A_q 狀態向量）", "src/compose", "O(14·n²)"),
    ("AL147", "interwoven_matrix（21×14 交織矩陣 W）", "src/compose", "O(21·14·n⁴)"),
    ("AL148", "iw_rat / iw_mat_mul / iw_transpose / iw_trace", "src/compose", "O(n³)"),
    ("AL149", "theorem_interwoven_kronecker（K⊗K 秩計算）", "src/compose", "O(k⁶)"),
    ("AL150", "theorem_interwoven_galois（2^14 極性閉集枚舉）", "src/compose", "O(2^14·21·14)"),
    ("AL151", "iw_flatten / theorem_interwoven_operator_algebra（441 複合秩）", "src/compose", "O(21²·n⁶)"),
    ("AL152", "theorem_interwoven_aj_bridge（Weil/AJ 橋接穷舉）", "src/compose", "O(n⁴·n²)"),
    ("AL153", "interwoven_stats（秩/非零/概念/張成 inspect）", "src/compose", "O(2^14·21)"),
    ("AL154", "theorem_quantum_torus / theorem_abel_jacobi 合取憑證", "src/algebra,src/series", "O(1)"),
    ("AL155", "qt_root_qshift_matrix / qt_root_trace_projection", "src/algebra", "O(n⁴)"),
]
for id_, stmt, pkg, cx in new_algos6:
    add("演算法", id_, stmt, pkg, cx, "困難度 P；局部 moon test --deny-warn + inspect")

new_eqs6 = [
    ("E81", "量子環面定義關係", "VU = q UV；ω((a,b),(c,d)) = b·c", "src/algebra"),
    ("E82", "單項乘法", "(q^{e₁}U^{a₁}V^{b₁})(q^{e₂}U^{a₂}V^{b₂}) = q^{e₁+e₂+b₁a₂}U^{a₁+a₂}V^{b₁+b₂}", "src/algebra"),
    ("E83", "正則跡", "τ(Σ c_{a,b}U^aV^b) = c_{0,0}；τ(xy)=τ(yx)", "src/algebra"),
    ("E84", "Connes 循環 2-上循環", "φ(x⁰,x¹,x²)=τ(x⁰δ₁x¹δ₂x²−x⁰δ₂x¹δ₁x²)，φ 循環不變", "src/algebra"),
    ("E85", "root of unity 中心", "qⁿ=1 ⇒ Z(A_q)=F[Uⁿ,Vⁿ]；[U^aV^b,U]=0∧[U^aV^b,V]=0 ⟺ n|a,n|b", "src/algebra"),
    ("E86", "Weil pairing", "e_n((a,b),(c,d))=q^{ad−bc}；[g_x,g_y]=q^{bc−ad}=e_n(x,y)⁻¹", "src/algebra"),
    ("E87", "Heisenberg 表示", "U=diag(q^{−i}), V e_i=e_{i+1} ⇒ VU=qUV, Uⁿ=Vⁿ=I", "src/algebra"),
    ("E88", "SL₂(ℤ) Morita", "θ↦(aθ+b)/(cθ+d)；ℤ+θℤ ≅ (cθ+d)⁻¹(ℤ+θℤ)；K₀(A_θ)≅ℤ+θℤ", "src/algebra"),
    ("E89", "Abel–Jacobi 映射", "AJ(Σ n_i[P_i]) = Σ n_i P_i ∈ Jac(E)=ℂ^g/Λ_g（有限域模型：E(F_q)）", "src/series"),
    ("E90", "Abel 定理", "D ∈ PDiv(E) ⇒ AJ(D)=0；div(x−a)=Σ_{x(P)=a} m_P[P] − 2[O]", "src/series"),
    ("E91", "Weil 分子與 Jacobian 階", "|Jac(E)(F_q)| = N₁ = q+1−a = P(1) = 1−a+q", "src/series"),
    ("E92", "Γ-bundle 配對（R56 Prop.3）", "⟨q^s v(q^m v,u)|q^r u(q^k u,v)⟩ = q^{r−s−km}", "src/series"),
    ("E93", "配對反向互逆", "⟨q^r u(q^k u,v)|q^s v(q^m v,u)⟩ = q^{km+s−r} = (q^{r−s−km})⁻¹", "src/series"),
    ("E94", "核心雙線性", "⟨u(q^r u,v)|v(q^s v,u)⟩ = q^{r·s}（么正不變性）", "src/series"),
    ("E95", "q-商 AJ", "AJ_q : F_p^* → F_p^*/⟨q⟩，ker=⟨q⟩，|coker|=(p−1)/ord(q)", "src/series"),
    ("E96", "E[3] 標號 Weil 配對", "E(F₇)[3]≅(ℤ/3)²，e₃((a,b),(c,d))=2^{ad−bc} mod 7", "src/series"),
    ("E97", "21×14 交織矩陣", "W[v][p]=τ(ρ(v)Φ_p)，Φ_p 由 deriv_invariant(p,·) 實算；rank_ℚ W=11", "src/compose"),
    ("E98", "Gram 自交織", "S=WWᵀ, T=WᵀW 對稱；rank S=rank T=rank W；tr S=tr T=ΣW²=2932", "src/compose"),
    ("E99", "Kronecker 自交織", "rank(K⊗K)=rank(K)²=9；441 個 ρ(v)ρ(w) 張成 End(A_q)，dim=81", "src/compose"),
    ("E100", "全局公理 G 於交織脈絡", "R(v,p)⇔W[v][p]≠0 ⇒ |Fix(F∘H)|=|Fix(H∘F)|=240；AJ_q(q^{e_n})=1", "src/compose"),
]
for id_, name, formula, pkg in new_eqs6:
    add("等式", id_, name, pkg, formula, "由對應定理憑證驗證")

REFS = REFS + [
    ("R56", "Itai–Zilber, Notes on a model theory of quantum 2-torus T_q² for generic q, arXiv:1503.06045", "2015", "https://arxiv.org/html/1503.06045", "O_q((F^×)²) 定義 VU=qUV；Γ=q^ℤ 與 Γ-bundle／line-bundle；§2.2 配對函數 Proposition 3：⟨q^s v(q^m v,u)|q^r u(q^k u,v)⟩=q^{r−s−km}、反向互逆 q^{km+s−r}；么正不變性與核心 q^{rs}"),
    ("R57", "Evans–Jones, Quantum Symmetries of Noncommutative Tori, Commun. Math. Phys. 406:167 (2025)", "2025", "https://link.springer.com/article/10.1007/s00220-025-05337-y", "Theorem 3.7/3.8：Haagerup–Izumi 範疇作用於非交換 2-torus；rank-4 非交換環面與 |G| 階矩陣代數；K₀ order unit 映至 ℤ+ℤφ"),
    ("R58", "Cheng, KdV Equation for Theta Functions on Non-commutative Tori, arXiv:2412.03929", "2024", "https://arxiv.org/html/2412.03929", "Definition 2.11 Jacobi variety J(K_g)=ℂ^g/Λ_g；Definition 2.12 Abel–Jacobi map Â_{Q₀}(P)=(∫ω₁,…,∫ω_g) mod Λ_g；Abel 定理與 Pic⁰≅J；量子 theta 向量之 Hirota 雙線性關係"),
    ("R59", "Connes–Consani, On the Jacobian of Spec Z, arXiv:2602.15941", "2026", "https://arxiv.org/pdf/2602.15941", "Jac(Spec Z)=Pic(Spec Z)/R_+^*；算術 Abel–Jacobi 映射 Θ 與 adelic 覆蓋拉回；顯式公式 = 跡公式，AJ 值域落在閉點纖維"),
    ("R60", "Rieffel–Schwarz, Morita equivalence of multidimensional noncommutative tori / Noncommutative torus (K₀=ℤ+θℤ)", "1999/2026", "https://grokipedia.com/page/noncommutative_torus", "A_θ 由 UV=e^{2πiθ}VU 生成；SL₂(ℤ) 分式線性作用 θ↦(aθ+b)/(cθ+d)；K₀(A_θ)≅ℤ² 且 τ_*(K₀)=ℤ+θℤ；Powers–Rieffel 投影"),
    ("R61", "Garoufalidis–Yu, A quantum trace map for 3-manifolds, Adv. Math. 486 (2026) 110735", "2026", "https://people.mpim-bonn.mpg.de/stavros/publications/printed/quantum_trace_map.pdf", "Bonahon–Wong 2d quantum trace map 之 3 維推廣；quantum torus 為 q-交換變數代數 Z[A^{±1}]⟨X_i | X_iX_j=A^{⟨ij⟩}X_jX_i⟩；q=1 特殊化與 character variety"),
    ("R62", "Panitch–Park, 3d quantum trace map, Algebr. Geom. Topol. 26 (2026) 2255–2314", "2026", "https://msp.org/agt/2026/26-6/agt-v26-n6-p09-s.pdf", "triangle algebra（量子環面）之 A-交換變數；stated skein module 分裂映射；T^{⊗2}–B^{⊗3} bimodule 同態；3d quantum gluing module"),
    ("R63", "Frohman–Gelca / skein algebra of the torus traces (Pith review of arXiv:math/0603343)", "2006/2026", "https://pith.science/paper/math/0603343", "環面 skein algebra 之交換子商 5 維、五個跡（Yang–Mills 測度與四個 parity traces）；product-to-sum 公式"),
    ("R64", "Bonahon–Wong quantum trace / localized quantum torus (Geometry & Topology 29 (2025) 1)", "2025", "https://msp.org/gt/2025/29-1/gt-v29-n1-p08-s.pdf", "量子環面定義 Z[A^{±1}]⟨X_i|i∈I⟩/(X_iX_j=A^{⟨ij⟩}X_jX_i)；localized quantum torus 與 skein algebra 嵌入；quantum Teichmüller space"),
    ("R65", "Silverman / Weil pairing on E[N] and theta groups (standard finite model)", "1986/2009", "https://arxiv.org/pdf/2505.13727", "A[N]≅(ℤ/N)^{2g}、Weil 配對雙線性／交錯／非退化；theta group 交換子配對；principal polarization 與 isogeny 核之 isotropic 子群"),
]

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

    from datetime import datetime
    wb = Workbook()
    wb.properties.created = datetime(2026, 11, 8, 0, 0, 0)
    wb.properties.modified = datetime(2026, 11, 8, 0, 0, 0)
    head_font = Font(bold=True, color="FFFFFF")
    head_fill = PatternFill("solid", fgColor="1F4E79")
    wrap = Alignment(wrap_text=True, vertical="top")

    # 索引
    ws = wb.active
    ws.title = "索引"
    ws.append(["C1 algorithm.xlsx", "全局公理：伽羅瓦對應", "回合 C1-06", "2026-11-08"])
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
    ws.append(["前沿文獻", len(REFS), "docs/catalog.json / Dev.txt §2", "聯網查證（C1-01 R1..R12 + C1-02 R13..R25 + C1-03 R26..R36 + C1-04 R37..R45 + C1-05 R46..R55 + C1-06 R56..R65）"])
    ws.column_dimensions["A"].width = 22
    ws.column_dimensions["B"].width = 10
    ws.column_dimensions["C"].width = 36
    ws.column_dimensions["D"].width = 42

    ref_sheet = wb.create_sheet("前沿文獻")
    ref_sheet.append(["ID", "文獻", "年份", "URL", "對 C1 的理論／演算法要點"])
    for c in ref_sheet[1]:
        c.font = head_font
        c.fill = head_fill
    for r in REFS:
        ref_sheet.append(list(r))
    for i, w in enumerate([8, 72, 12, 62, 82], start=1):
        ref_sheet.column_dimensions[get_column_letter(i)].width = w
    for row in ref_sheet.iter_rows(min_row=2):
        for c in row:
            c.alignment = wrap
    ref_sheet.freeze_panes = "A2"
    ref_sheet.auto_filter.ref = ref_sheet.dimensions

    for k in kinds:
        sheet = wb.create_sheet(k)
        sheet.append(["ID", "陳述／名稱", "套件", "公式／複雜度", "驗證方式", "回合"])
        for c in sheet[1]:
            c.font = head_font
            c.fill = head_fill
        for e in A:
            if e["kind"] != k:
                continue
            sheet.append([e["id"], e["statement"], e["package"], e["formula"], e["verification"], e["round"]])
        for i, w in enumerate([12, 58, 20, 62, 40, 10], start=1):
            sheet.column_dimensions[get_column_letter(i)].width = w
        for row in sheet.iter_rows(min_row=2):
            for c in row:
                c.alignment = wrap
        sheet.freeze_panes = "A2"
        sheet.auto_filter.ref = sheet.dimensions

    path = os.path.join(ROOT, "algorithm.xlsx")
    # 固定 zip 時間戳，讓 xlsx 為可重現（byte-identical）之建置產物
    import io
    import re
    import zipfile
    buf = io.BytesIO()
    wb.save(buf)
    buf.seek(0)
    # openpyxl 於 save 時會以當下時間覆寫 dcterms:modified；此處正規化為
    # 固定值，確保整個 xlsx 為 byte-identical 之可重現建置產物。
    fixed_stamp = b"2026-11-08T00:00:00Z"
    with zipfile.ZipFile(path, "w", zipfile.ZIP_DEFLATED) as zout:
        with zipfile.ZipFile(buf) as zin:
            for item in zin.infolist():
                data = zin.read(item.filename)
                if item.filename == "docProps/core.xml":
                    data = re.sub(
                        rb"(<dcterms:(?:created|modified)[^>]*>)[^<]*(</dcterms:(?:created|modified)>)",
                        lambda m: m.group(1) + fixed_stamp + m.group(2),
                        data,
                    )
                zi = zipfile.ZipInfo(item.filename, date_time=(2026, 11, 8, 0, 0, 0))
                zi.compress_type = zipfile.ZIP_DEFLATED
                zi.external_attr = item.external_attr
                zout.writestr(zi, data)
    return path


def main():
    os.makedirs(os.path.join(ROOT, "docs"), exist_ok=True)
    with open(os.path.join(ROOT, "docs/catalog.json"), "w", encoding="utf-8") as f:
        json.dump({"round": "C1-06", "global_axiom": "伽羅瓦對應",
                   "entries": A, "references": REFS}, f, ensure_ascii=False, indent=2)
    generate_mbt()
    p = generate_xlsx()
    counts = {k: sum(1 for e in A if e["kind"] == k) for k in ["公理", "定義", "命題", "引理", "定理", "演算法", "等式"]}
    print("catalog entries:", len(A), counts)
    print("xlsx:", p)


if __name__ == "__main__":
    main()
