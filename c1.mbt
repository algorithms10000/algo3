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
  push_line(buf, "catalog 登錄筆數 / 一致性",
    @catalog.catalog_size().to_string() + "/" +
      flag(@catalog.theorem_catalog_consistent()))
  let mut out = ""
  for i in 0..<buf.length() { out = out + buf[i] + "\n" }
  out
}

///|
pub fn catalog_size() -> Int { @catalog.catalog_size() }
