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
    wb.properties.created = datetime(2026, 11, 7, 0, 0, 0)
    wb.properties.modified = datetime(2026, 11, 7, 0, 0, 0)
    head_font = Font(bold=True, color="FFFFFF")
    head_fill = PatternFill("solid", fgColor="1F4E79")
    wrap = Alignment(wrap_text=True, vertical="top")

    # 索引
    ws = wb.active
    ws.title = "索引"
    ws.append(["C1 algorithm.xlsx", "全局公理：伽羅瓦對應", "回合 C1-03", "2026-11-07"])
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
    ws.append(["前沿文獻", len(REFS), "docs/catalog.json / Dev.txt §2", "聯網查證（C1-01 R1..R12 + C1-02 R13..R25 + C1-03 R26..R36）"])
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
            sheet.append([e["id"], e["statement"], e["package"], e["formula"], e["verification"], "C1-03"])
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
    import zipfile
    buf = io.BytesIO()
    wb.save(buf)
    buf.seek(0)
    with zipfile.ZipFile(path, "w", zipfile.ZIP_DEFLATED) as zout:
        with zipfile.ZipFile(buf) as zin:
            for item in zin.infolist():
                zi = zipfile.ZipInfo(item.filename, date_time=(2026, 11, 7, 0, 0, 0))
                zi.compress_type = zipfile.ZIP_DEFLATED
                zi.external_attr = item.external_attr
                zout.writestr(zi, zin.read(item.filename))
    return path


def main():
    os.makedirs(os.path.join(ROOT, "docs"), exist_ok=True)
    with open(os.path.join(ROOT, "docs/catalog.json"), "w", encoding="utf-8") as f:
        json.dump({"round": "C1-03", "global_axiom": "伽羅瓦對應",
                   "entries": A, "references": REFS}, f, ensure_ascii=False, indent=2)
    generate_mbt()
    p = generate_xlsx()
    counts = {k: sum(1 for e in A if e["kind"] == k) for k in ["公理", "定義", "命題", "引理", "定理", "演算法", "等式"]}
    print("catalog entries:", len(A), counts)
    print("xlsx:", p)


if __name__ == "__main__":
    main()
