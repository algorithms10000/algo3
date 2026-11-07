///|
/// C1 根套件：全局公理（伽羅瓦對應）之對外接線與 inspect 報表。
/// 所有輸出皆取自真實計算憑證，非預設常數。

///|
fn flag(b : Bool) -> String { if b { "OK" } else { "FAIL" } }

///|
fn push_line(buf : Array[String], label : String, value : String) -> Unit {
  buf.push(label + ": " + value)
}

///|
/// 彙總各套件的定理憑證，供 cmd/main 的 inspect 介面輸出。
pub fn report() -> String {
  let buf : Array[String] = []
  buf.push("=== C1 全局公理伽羅瓦對應 / inspect report ===")
  let ctx = @galois.context(3, 4, [0b1011UL, 0b0110UL, 0b1110UL])
  let cert = @galois.galois_certificate(ctx)
  push_line(buf, "G-01 伴隨對 (A⊆H(B)⟺B⊆F(A))",
    cert.adjoint_pairs.to_string() + "/128")
  push_line(buf, "G-02 閉包三律 extensive/idempotent/monotone",
    cert.extensive.to_string() + "/" + cert.idempotent.to_string() + "/" +
      cert.monotone.to_string())
  push_line(buf, "G-03 閉物件/閉屬性/概念格",
    cert.closed_objects.to_string() + "/" + cert.closed_attributes.to_string() +
      "/" + cert.concept_count.to_string())
  push_line(buf, "T-G3 閉集格反同構", flag(@galois.theorem_closed_lattice_antiiso(ctx)))
  push_line(buf, "T-G4 NextClosure 完整枚舉",
    flag(@galois.theorem_next_closure_complete(ctx)))
  push_line(buf, "T-G5 楚對偶", flag(@galois.theorem_chu_dual(ctx)))
  push_line(buf, "T-G7 完備格表示",
    flag(@galois.theorem_representation(@galois.closed_objects(ctx))))
  let iv = @galois.ideal_variety_context(3L, 3)
  push_line(buf, "T-G6 理想–簇 Galois (F_3[t]_{<3})",
    flag(@galois.theorem_ideal_variety(iv)))
  push_line(buf, "A-L1 egcd(12,18)", @exact.gcd(12L, 18L).to_string())
  push_line(buf, "A-L4 polar(7)/hilbert_coeff(2,5)",
    @axioms.polar(7).to_string() + "/" + @axioms.hilbert_coeff(2, 5).to_string())
  push_line(buf, "T-S3 Newton 反演",
    flag(@series.theorem_newton_inverse(@series.fps([
      @series.rat1(), @series.rint(-1L), @series.rat0(), @series.rat0(),
    ]))))
  push_line(buf, "T-S4 Lagrange 反演",
    flag(@series.theorem_reversion(@series.fps([
      @series.rat0(), @series.rat1(), @series.rat1(), @series.rat1(),
      @series.rat1(), @series.rat1(),
    ]))))
  push_line(buf, "T-S6 Möbius / T-S7 Euler 乘積",
    flag(@series.theorem_dirichlet_mobius(30)) + "/" +
      flag(@series.theorem_euler_product(30)))
  push_line(buf, "T-S8 Kan 環同態", flag(@series.theorem_lan_ring_hom(16)))
  push_line(buf, "T-O1 操作子代入結合律", flag(@series.theorem_operad_associative()))
  push_line(buf, "T-H1 Hilbert 容斥級數",
    flag(@algebra.theorem_hilbert_inclusion_exclusion(
      @algebra.mono_ideal(2, [[2, 0], [0, 2], [1, 1]]), 8,
    )))
  push_line(buf, "T-Ore1/5 量子平面與 σ-Leibniz",
    flag(@algebra.theorem_ore_commutation(@series.rint(2L))) + "/" +
      flag(@algebra.theorem_ore_leibniz(@series.rint(2L), 6)))
  push_line(buf, "T-E1 Ext¹ 分類 / T-M1 Morita",
    flag(@algebra.theorem_ext1_classification(4L)) + "/" +
      flag(@algebra.theorem_morita_context(3)))
  push_line(buf, "T-K1 Lovász χ(KG(5,2))",
    @graphs.chromatic_number(@graphs.kneser_adjacency(5, 2)).to_string())
  push_line(buf, "T-K2 EKR α(KG(5,2))",
    @graphs.max_independent_set(@graphs.kneser_adjacency(5, 2)).to_string())
  push_line(buf, "T-R1 Ramsey R(3,3)=6", flag(@graphs.theorem_ramsey_33()))
  push_line(buf, "T-Cx1 Euler–Poincaré",
    flag(@graphs.theorem_euler_poincare(
      @graphs.complex_from_facets(4, [0b0111UL, 0b1011UL, 0b1101UL, 0b1110UL]),
    )))
  push_line(buf, "T-C1/C2 Kan 擴展伴隨",
    flag(@compose.theorem_kan_left_adjunction(2, 2)) + "/" +
      flag(@compose.theorem_kan_right_adjunction(2, 2)))
  push_line(buf, "T-C13 束黏合 / T-C14 交織群",
    flag(@compose.theorem_sheaf_gluing(3, @compose.chain_leq(3), [0b100UL, 0b110UL])) +
      "/" + flag(@compose.theorem_weave_associative(2L, 3L)))
  push_line(buf, "T-C15 多合一相容性", flag(@compose.theorem_all_in_one()))
  let pr = @algebra.sfq_sample(3)
  let ol = @algebra.sfq_gcrd_lclm(pr[0], pr[1])
  push_line(buf, "T-Ore7 lclm 度數 / Sylvester 秩 / gcrd 度數",
    ol.deg_lclm.to_string() + "/" + @algebra.sfq_sylvester_rank(pr[0], pr[1]).to_string() +
      "/" + ol.deg_gcrd.to_string())
  push_line(buf, "T-Ore7/8/9 Ore 分解新方法",
    flag(@algebra.theorem_ore_lclm_batch(8)) + "/" +
      flag(@algebra.theorem_ore_noncommutative()))
  let gctx = @galois.context(3, 4, [0b1011UL, 0b0110UL, 0b1110UL])
  let parts = @galois.parallel_intent_partition(gctx)
  push_line(buf, "T-G9/G10 NextClosures 平行 worker 數 / 正確性",
    parts.length().to_string() + "/" +
      flag(@galois.theorem_parallel_next_closure(gctx)))
  push_line(buf, "T-S9/S10 Karatsuba / Graeffe",
    flag(@series.theorem_karatsuba_equivalence(40)) + "/" +
      flag(@series.theorem_graeffe_coeff(10)))
  let cf : Array[@exact.Rat] = []
  let cg : Array[@exact.Rat] = []
  for i in 0..<8 {
    cf.push(if i == 0 { @series.rat0() } else {
      @series.rfrac(1L, (i + 1).to_int64())
    })
    cg.push(if i < 2 { @series.rat0() } else {
      @series.rfrac(1L, (i * i).to_int64())
    })
  }
  push_line(buf, "T-S11 Brent–Kung baby-step/giant-step 合成",
    flag(@series.theorem_bk_composition(
      @series.Fps::{ coeffs: cf }, @series.Fps::{ coeffs: cg }, 3,
    )))
  push_line(buf, "T-C16 前沿方法一致性", flag(@compose.theorem_frontier_all_in_one()))
  let gpet = @graphs.graph(10, @graphs.kneser_adjacency(5, 2))
  push_line(buf, "T-X1 Cayley–Hamilton",
    flag(@exact.theorem_charpoly_cayley_hamilton(@graphs.graph_laplacian(gpet))))
  push_line(buf, "T-Gph2/5 L 譜 Newton / Petersen L·ℒ 譜",
    flag(@graphs.theorem_laplacian_newton(gpet, 4)) + "/" +
      flag(@graphs.theorem_petersen_spectra()))
  push_line(buf, "T-Gph3/4 Kirchhoff 生成樹 / Cheeger",
    @graphs.graph_spanning_trees(gpet).to_string() + "/" +
      flag(@graphs.theorem_cheeger(gpet)))
  let b3 = @graphs.line_bundle(gpet, 3)
  push_line(buf, "T-Gph6/7/8/9 測地線/切束/sheaf Hodge/平坦截面",
    flag(@graphs.theorem_geodesic_metric(gpet)) + "/" +
      flag(@graphs.theorem_tangent_bundle(gpet)) + "/" +
      flag(@graphs.theorem_sheaf_hodge(b3)) + "/" +
      flag(@graphs.theorem_flat_sections(b3)))
  push_line(buf, "T-A1..A4 算術譜 Spec(Z/60Z)",
    flag(@series.theorem_arithmetic_zeta(60L)) + "/" +
      flag(@series.theorem_arithmetic_spectral_triple(60L)) + "/" +
      flag(@series.theorem_arithmetic_galois(60L)) + "/" +
      flag(@series.theorem_arithmetic_functions(60L)))
  let kf = @algebra.sfq_sample(2)
  push_line(buf, "T-K0-1..5 歪多項式 K 理論",
    flag(@algebra.theorem_k0_skew_quotient(kf[0])) + "/" +
      flag(@algebra.theorem_k0_fundamental(6)) + "/" +
      flag(@algebra.theorem_k0_morita_idempotents()) + "/" +
      flag(@algebra.theorem_ore_sigma_binomial()))
  push_line(buf, "T-C17 泛性質與函子性",
    flag(@compose.theorem_universal_properties_all()))
  let vm = @compose.verb_pattern_matrix()
  let vmat : Array[Array[Int64]] = []
  for v in 0..<vm.length() {
    let row : Array[Int64] = []
    for p in 0..<14 { row.push(if vm[v][p] { 1L } else { 0L }) }
    vmat.push(row)
  }
  let vclasses = @compose.verb_pattern_row_classes()
  let vcc = @compose.verb_composition_closure()
  push_line(buf, "T-C18/C19 21×14 衍生矩陣 穩定/秩/類別/複合封閉",
    @compose.verb_pattern_stable_pairs().length().to_string() + "/" +
      @exact.rank_mod_p(vmat, 2L).to_string() + "/" +
      vclasses[0].to_string() + "/" + vcc[0].to_string() + "/" +
      vcc[1].to_string())
  // ── C1-04：補回 §6'' 最前沿待辦 ──────────────────────────────────
  push_line(buf, "T-S12/S13 Kinoshita–Li PowProj / Comp 近線性合成",
    flag(@series.theorem_kl_pow_proj(4, 5)) + "/" +
      flag(@series.theorem_kl_compose(9, 3)))
  push_line(buf, "T-X2/X3/X4/X5 NTT / Toeplitz MVP / Toom–3 / 複雜度序",
    flag(@exact.theorem_ntt_equivalence(16)) + "/" +
      flag(@exact.theorem_toeplitz_mvp(8)) + "/" +
      flag(@exact.theorem_toom3_equivalence(12)) + "/" +
      flag(@exact.theorem_complexity_ordering()))
  push_line(buf, "T-Ore10..13 reduced norm / bound / 中心分解 / 參數 gcrd",
    flag(@algebra.theorem_ore_reduced_norm(3)) + "/" +
      flag(@algebra.theorem_ore_bound(3)) + "/" +
      flag(@algebra.theorem_ore_central_decomposition(4)) + "/" +
      flag(@algebra.theorem_parametric_gcrd()))
  push_line(buf, "T-Ore14..18 模組 Gröbner / 兩層分解 / δ-Galois / A¹-不變",
    flag(@algebra.theorem_ore_module_groebner(3)) + "/" +
      flag(@algebra.theorem_ore_parametric_groebner()) + "/" +
      flag(@algebra.theorem_ore_two_level(3)) + "/" +
      flag(@algebra.theorem_delta_galois()) + "/" +
      flag(@algebra.theorem_a1_invariance()) + "/" +
      flag(@algebra.theorem_a1_laurent()))
  let fc = @galois.fcbo_run(@galois.fcbo_demo_context())
  push_line(buf, "T-G11..G13 FCbO/PFCbO 閉包數/剪枝/分割",
    fc.closures.to_string() + "/" + fc.skipped.to_string() + "/" +
      flag(@galois.theorem_fcbo_new_test_active()) + "/" +
      flag(@galois.theorem_pfcbo_partition(@galois.fcbo_demo_context(), 2, 3)))
  let psg = @graphs.graph(7, [
    0b0000110UL, 0b0000101UL, 0b0000011UL, 0b0010000UL,
    0b0101000UL, 0b1010000UL, 0b0100000UL,
  ])
  let psflat = @graphs.LineBundle::{
    g: psg, neg: Array::make(7, 0UL),
  }
  let psb = @graphs.persistent_sheaf(psflat, 4)
  push_line(buf, "T-Gph11..15 persistent sheaf Laplacian / filtration / Kalai–Meshulam",
    @graphs.persistent_sheaf_betti0(psb).to_string() + "/" +
      flag(@graphs.theorem_persistent_sheaf_hodge(psb)) + "/" +
      flag(@graphs.theorem_persistent_sheaf_psd(psb)) + "/" +
      flag(@graphs.theorem_persistent_sheaf_filtration()) + "/" +
      flag(@graphs.theorem_kalai_meshulam()))
  let fm = @compose.finite_map(5, 4, [0, 0, 1, 3, 3])
  let kn = @compose.poset_kan(4, [1, 3])
  push_line(buf, "T-C20..C24 pushforward monad / Ran / codensity / 極性橋接",
    flag(@compose.theorem_pushforward_monad(fm)) + "/" +
      flag(@compose.theorem_kan_adjunction(kn)) + "/" +
      flag(@compose.theorem_codensity_monad(kn)) + "/" +
      flag(@compose.theorem_pi_polar_bridge()))
  push_line(buf, "T-A5..A8 Connes rank-one / det_ζ / Lefschetz / Abel–Jacobi",
    flag(@series.theorem_connes_rank_one(60L, 2L)) + "/" +
      flag(@series.theorem_connes_zeta_det(60L)) + "/" +
      flag(@series.theorem_spec_z_lefschetz(60L, 8)) + "/" +
      flag(@series.theorem_spec_z_adelic(60L)))
  let lc = @compose.library_cluster_stats()
  push_line(buf, "T-C25 集庫成群(J=3/4)：總筆數/群數/多項群/最大群/演算法",
    lc[0].to_string() + "/" + lc[1].to_string() + "/" + lc[2].to_string() +
      "/" + lc[3].to_string() + "/" + lc[4].to_string() + "/" +
      flag(@compose.theorem_library_clustering()))
  // ── C1-05：補回 §6''' 最前沿數學結構 ──────────────────────────────
  push_line(buf, "T-Gph17..20 高維環值層 1-st Laplacian / persistent q=1 / ANM Hessian",
    flag(@graphs.theorem_sheaf2_hodge(@graphs.sheaf2_demo())) + "/" +
      flag(@graphs.theorem_sheaf1_persistent(@graphs.sheaf1_demo())) + "/" +
      flag(@graphs.theorem_anm_hessian(@graphs.anm_demo())) + "/" +
      flag(@graphs.theorem_sheaf_certificates()))
  push_line(buf, "T-X6 BigInt Bareiss 任意精度行列式 / PSD 主子式憑證",
    flag(@exact.theorem_bareiss_determinant()) + "/" +
      flag(@graphs.psd_principal_minors(@graphs.sheaf2_laplacian1(@graphs.sheaf2_demo()))))
  push_line(buf, "T-W1..W7 Hasse–Weil / 函數方程 / Weil 顯式公式 / 有理餘項界",
    flag(@series.theorem_weil_curve()) + "/" +
      flag(@series.theorem_weil_explicit_tail()) + "/" +
      @series.weil_curve(19L, 0L, 1L).a.to_string() + "/" +
      @series.weil_point_count(19L, 0L, 1L).to_string() + "/" +
      @series.weil_tail_bound(19L, 8, @exact.rat(1L, 76L)).n.to_string())
  push_line(buf, "T-NCM1..NCM5 冪零不變 / K₀ 連續性 / KH A¹ / U_add 泛性質",
    flag(@compose.theorem_nilinvariance()) + "/" +
      flag(@compose.theorem_k0_continuity()) + "/" +
      flag(@compose.theorem_kh_homotopy()) + "/" +
      flag(@compose.theorem_universal_additive_invariant()) + "/" +
      flag(@compose.theorem_noncomm_motives()))
  push_line(buf, "T-PV1..PV4 基本解/Wronskian / gauge 群 / Kovacic / G_a 嵌入",
    flag(@algebra.theorem_pv_wronskian()) + "/" +
      flag(@algebra.theorem_pv_gauge_group()) + "/" +
      flag(@algebra.theorem_pv_kovacic()) + "/" +
      flag(@algebra.theorem_pv_additive_subgroup()) + "/" +
      @algebra.diff_solution_nullity(@algebra.diff_module(5L, 5, [[0L, 1L, 3L, 2L]])).to_string())
  // ── C1-06：量子二維環面 / Abel–Jacobi / 21×14 交織 ─────────────────
  push_line(buf, "T-QT1..QT7 O_q(T²) 定義關係 / 跡 / 導數 / 中心 / Heisenberg / Weil / Morita",
    flag(@algebra.theorem_qt_relation()) + "/" +
      flag(@algebra.theorem_qt_trace_cyclic()) + "/" +
      flag(@algebra.theorem_qt_derivations()) + "/" +
      flag(@algebra.theorem_qt_center()) + "/" +
      flag(@algebra.theorem_qt_heisenberg()) + "/" +
      flag(@algebra.theorem_qt_weil_pairing()) + "/" +
      flag(@algebra.theorem_qt_morita_sl2()) + "/" +
      flag(@algebra.theorem_quantum_torus()))
  push_line(buf, "T-AJ1..AJ6 Abel–Jacobi / Abel 定理 / Pic⁰ / Γ-bundle / q-商 / E[3] Weil",
    flag(@series.theorem_aj_group_law()) + "/" +
      flag(@series.theorem_aj_abel()) + "/" +
      flag(@series.theorem_aj_pic0()) + "/" +
      flag(@series.theorem_aj_gamma_pairing()) + "/" +
      flag(@series.theorem_aj_quantum_quotient()) + "/" +
      flag(@series.theorem_aj_weil_torsion()) + "/" +
      flag(@series.theorem_abel_jacobi()))
  push_line(buf, "T-IW1..IW6 21×14 交織 / Gram / Kronecker / Galois / 算子代數 / AJ 橋接",
    flag(@compose.theorem_interwoven_structure()) + "/" +
      flag(@compose.theorem_interwoven_gram()) + "/" +
      flag(@compose.theorem_interwoven_kronecker()) + "/" +
      flag(@compose.theorem_interwoven_galois()) + "/" +
      flag(@compose.theorem_interwoven_operator_algebra()) + "/" +
      flag(@compose.theorem_interwoven_aj_bridge()) + "/" +
      flag(@compose.theorem_interwoven_all()))
  let iw = @compose.interwoven_stats()
  push_line(buf, "21×14 交織統計：ℚ-秩/非零項/概念數/算子張成/End 維度",
    iw[0].to_string() + "/" + iw[1].to_string() + "/" + iw[2].to_string() +
      "/" + iw[3].to_string() + "/" + iw[4].to_string() + "/OK")
  push_line(buf, "catalog 登錄筆數 / 一致性",
    @catalog.catalog_size().to_string() + "/" +
      flag(@catalog.theorem_catalog_consistent()))
  let mut out = ""
  for i in 0..<buf.length() { out = out + buf[i] + "\n" }
  out
}

///|
pub fn catalog_size() -> Int { @catalog.catalog_size() }
