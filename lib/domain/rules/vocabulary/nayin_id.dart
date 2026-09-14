library;

class NaYinId {
  const NaYinId(this.value);
  final String value;

  @override
  bool operator ==(Object other) => identical(this, other) || other is NaYinId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;

  static const haiZhongJin = NaYinId('nayin.hai_zhong_jin');
  static const luZhongHuo = NaYinId('nayin.lu_zhong_huo');
  static const daLinMu = NaYinId('nayin.da_lin_mu');
  static const luPangTu = NaYinId('nayin.lu_pang_tu');
  static const jianFengJin = NaYinId('nayin.jian_feng_jin');
  static const shanTouHuo = NaYinId('nayin.shan_tou_huo');
  static const jianXiaShui = NaYinId('nayin.jian_xia_shui');
  static const chengTouTu = NaYinId('nayin.cheng_tou_tu');
  static const baiLaJin = NaYinId('nayin.bai_la_jin');
  static const yangLiuMu = NaYinId('nayin.yang_liu_mu');
  static const quanZhongShui = NaYinId('nayin.quan_zhong_shui');
  static const wuShangTu = NaYinId('nayin.wu_shang_tu');
  static const piLiHuo = NaYinId('nayin.pi_li_huo');
  static const songBaiMu = NaYinId('nayin.song_bai_mu');
  static const changLiuShui = NaYinId('nayin.chang_liu_shui');
  static const shaZhongJin = NaYinId('nayin.sha_zhong_jin');
  static const shanXiaHuo = NaYinId('nayin.shan_xia_huo');
  static const pingDiMu = NaYinId('nayin.ping_di_mu');
  static const biShangTu = NaYinId('nayin.bi_shang_tu');
  static const jinBoJin = NaYinId('nayin.jin_bo_jin');
  static const fuDengHuo = NaYinId('nayin.fu_deng_huo');
  static const tianHeShui = NaYinId('nayin.tian_he_shui');
  static const daYiTu = NaYinId('nayin.da_yi_tu');
  static const chaiChuanJin = NaYinId('nayin.chai_chuan_jin');
  static const sangZheMu = NaYinId('nayin.sang_zhe_mu');
  static const daXiShui = NaYinId('nayin.da_xi_shui');
  static const shaZhongTu = NaYinId('nayin.sha_zhong_tu');
  static const tianShangHuo = NaYinId('nayin.tian_shang_huo');
  static const shiLiuMu = NaYinId('nayin.shi_liu_mu');
  static const daHaiShui = NaYinId('nayin.da_hai_shui');

  static const List<NaYinId> values = [
    haiZhongJin, luZhongHuo, daLinMu, luPangTu, jianFengJin,
    shanTouHuo, jianXiaShui, chengTouTu, baiLaJin, yangLiuMu,
    quanZhongShui, wuShangTu, piLiHuo, songBaiMu, changLiuShui,
    shaZhongJin, shanXiaHuo, pingDiMu, biShangTu, jinBoJin,
    fuDengHuo, tianHeShui, daYiTu, chaiChuanJin, sangZheMu,
    daXiShui, shaZhongTu, tianShangHuo, shiLiuMu, daHaiShui,
  ];

  static bool isValid(String id) => values.any((e) => e.value == id);
}
