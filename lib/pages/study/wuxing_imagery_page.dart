import 'package:flutter/material.dart';

import '../../theme/wuxing_colors.dart';
import 'wuxing_generate_page.dart';

class WuxingImageryPage extends StatelessWidget {
  const WuxingImageryPage({super.key});

  static const _ink = Color(0xFF261A12);
  static const _muted = Color(0xFF735D4B);
  static const _paper = Color(0xFFFFF9EC);
  static const _line = Color(0xFFE3C997);
  static const _deepGreen = Color(0xFF245B4A);

  static const _items = [
    _WuxingProfile(
      element: '水',
      colorName: '黑 / 蓝',
      taste: '咸',
      organ: '肾',
      direction: '北',
      virtue: '智',
      numbers: '1、6',
      season: '冬',
      branches: '亥、子',
      nature: '润下、寒凉、流动、隐伏',
    ),
    _WuxingProfile(
      element: '火',
      colorName: '红',
      taste: '苦',
      organ: '心',
      direction: '南',
      virtue: '礼',
      numbers: '2、7',
      season: '夏',
      branches: '巳、午',
      nature: '炎上、光明、热烈、显露',
    ),
    _WuxingProfile(
      element: '木',
      colorName: '青 / 绿',
      taste: '酸',
      organ: '肝',
      direction: '东',
      virtue: '仁',
      numbers: '3、8',
      season: '春',
      branches: '寅、卯',
      nature: '生发、伸展、条达、向上',
    ),
    _WuxingProfile(
      element: '金',
      colorName: '白',
      taste: '辛',
      organ: '肺',
      direction: '西',
      virtue: '义',
      numbers: '4、9',
      season: '秋',
      branches: '申、酉',
      nature: '收敛、肃降、坚硬、规则',
    ),
    _WuxingProfile(
      element: '土',
      colorName: '黄',
      taste: '甘',
      organ: '脾胃',
      direction: '中',
      virtue: '信',
      numbers: '5、10',
      season: '四季末月',
      branches: '辰、戌、丑、未',
      nature: '承载、稳定、中介、包容',
    ),
  ];

  static const _sections = [
    _ImagerySection(
      title: '颜色意象',
      icon: Icons.palette_outlined,
      summary: '颜色是最快的记忆入口，用来建立五行第一印象。',
      rows: [
        _MiniRow('木', '青 / 绿', '生发、草木、舒展'),
        _MiniRow('火', '红', '光热、显露、热烈'),
        _MiniRow('土', '黄', '大地、承载、稳定'),
        _MiniRow('金', '白', '金石、肃降、规则'),
        _MiniRow('水', '黑 / 蓝', '寒凉、流动、隐伏'),
      ],
    ),
    _ImagerySection(
      title: '五味意象',
      icon: Icons.restaurant_outlined,
      summary: '五味适合辅助取象，尤其用于身体、饮食、感受类问题。',
      rows: [
        _MiniRow('木', '酸', '收涩、筋肝、曲直'),
        _MiniRow('火', '苦', '清泄、心火、焦灼'),
        _MiniRow('土', '甘', '滋养、脾胃、缓和'),
        _MiniRow('金', '辛', '发散、肺气、锐利'),
        _MiniRow('水', '咸', '软坚、肾水、下行'),
      ],
    ),
    _ImagerySection(
      title: '脏腑意象',
      icon: Icons.favorite_border,
      summary: '脏腑不只用于身体，也能帮助理解五行的内在功能。',
      rows: [
        _MiniRow('木', '肝', '疏泄、谋划、筋目'),
        _MiniRow('火', '心', '神明、血脉、礼仪'),
        _MiniRow('土', '脾胃', '运化、承载、消化'),
        _MiniRow('金', '肺', '呼吸、肃降、皮毛'),
        _MiniRow('水', '肾', '藏精、寒水、根基'),
      ],
    ),
    _ImagerySection(
      title: '方位意象',
      icon: Icons.explore_outlined,
      summary: '方位是预测法的重要手段之一，可辅助判断人、物、事的所在。',
      rows: [
        _MiniRow('木', '东', '如测卦中某人临木，可取东方之象'),
        _MiniRow('火', '南', '明处、前方、热闹处'),
        _MiniRow('土', '中', '中央、本地、原处、交界处'),
        _MiniRow('金', '西', '西方、规则处、金属器物处'),
        _MiniRow('水', '北', '北方、低处、水边、隐蔽处'),
      ],
    ),
    _ImagerySection(
      title: '品质意象',
      icon: Icons.workspace_premium_outlined,
      summary: '仁礼信义智是五行在人事德性上的取象。',
      rows: [
        _MiniRow('木', '仁', '生发、扶助、仁和'),
        _MiniRow('火', '礼', '礼仪、名声、表达'),
        _MiniRow('土', '信', '守信、稳定、承诺'),
        _MiniRow('金', '义', '原则、决断、规矩'),
        _MiniRow('水', '智', '智慧、变通、谋略'),
      ],
    ),
    _ImagerySection(
      title: '数字意象',
      icon: Icons.pin_outlined,
      summary: '数字可作为辅助象，不宜替代生克、旺衰、世应等主线判断。',
      rows: [
        _MiniRow('水', '1、6', '一六共宗，先记水数'),
        _MiniRow('火', '2、7', '二七同道，火象成组'),
        _MiniRow('木', '3、8', '三八为木，生发伸展'),
        _MiniRow('金', '4、9', '四九为金，收敛成器'),
        _MiniRow('土', '5、10', '五十居中，承载四方'),
      ],
    ),
    _ImagerySection(
      title: '四季意象',
      icon: Icons.wb_sunny_outlined,
      summary: '春木、夏火、秋金、冬水。土在每个季节的最后一个月。',
      rows: [
        _MiniRow('木', '春', '寅卯辰为春，木气当令'),
        _MiniRow('火', '夏', '巳午未为夏，火气当令'),
        _MiniRow('金', '秋', '申酉戌为秋，金气当令'),
        _MiniRow('水', '冬', '亥子丑为冬，水气当令'),
        _MiniRow('土', '辰、未、戌、丑', '四季末月皆归土'),
      ],
    ),
    _ImagerySection(
      title: '文王卦常用：地支五行',
      icon: Icons.grid_view_outlined,
      summary: '六爻纳甲看的是爻上地支，地支五行是进入生克旺衰的桥。',
      rows: [
        _MiniRow('木', '寅、卯', '东方木，春令木旺'),
        _MiniRow('火', '巳、午', '南方火，夏令火旺'),
        _MiniRow('土', '辰、戌、丑、未', '四库土，承载收藏'),
        _MiniRow('金', '申、酉', '西方金，秋令金旺'),
        _MiniRow('水', '亥、子', '北方水，冬令水旺'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF3E3),
      appBar: AppBar(
        title: const Text('五行意象'),
        backgroundColor: const Color(0xFFFBF3E3),
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        children: [
          _hero(),
          const SizedBox(height: 16),
          _knowledgeCard(),
          const SizedBox(height: 16),
          const Text(
            '分板块意象',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: _ink,
            ),
          ),
          const SizedBox(height: 10),
          ..._sections.map(
            (section) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _sectionTile(section),
            ),
          ),
          const SizedBox(height: 8),
          _usageNote(),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const WuxingGeneratePage()),
              );
            },
            icon: const Icon(Icons.arrow_forward),
            label: const Text('进入五行相生'),
          ),
        ],
      ),
    );
  }

  Widget _hero() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _deepGreen,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '先总览，再拆解',
            style: TextStyle(
              color: Color(0xFFFFE9B4),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '把五行当作一组可取象的语言',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w900,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '颜色、五味、脏腑、方位、品质、数字、四季与地支，先合成一张地图，再按板块记忆。',
            style: TextStyle(
              color: Color(0xFFE7F1E8),
              fontSize: 14.5,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _items.map((item) => _elementPill(item.element)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _elementPill(String element) {
    final color = WuxingColors.getColor(element);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Text(
        element,
        style: TextStyle(
          color: WuxingColors.textOnColor(element),
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _knowledgeCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _paper,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.table_chart_outlined, color: _deepGreen),
              SizedBox(width: 8),
              Text(
                '五行知识总卡',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: _ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE9B4),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              '横向滑动查看四季、地支与核心性质',
              style: TextStyle(
                color: Color(0xFF6B4E2E),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 38,
              dataRowMinHeight: 46,
              dataRowMaxHeight: 54,
              horizontalMargin: 10,
              columnSpacing: 18,
              border: TableBorder.all(
                color: const Color(0xFFE8D8B9),
                borderRadius: BorderRadius.circular(10),
              ),
              columns: const [
                DataColumn(label: Text('五行')),
                DataColumn(label: Text('颜色')),
                DataColumn(label: Text('五味')),
                DataColumn(label: Text('脏腑')),
                DataColumn(label: Text('方位')),
                DataColumn(label: Text('品质')),
                DataColumn(label: Text('数字')),
                DataColumn(label: Text('四季')),
                DataColumn(label: Text('地支')),
                DataColumn(label: Text('性质')),
              ],
              rows: _items.map((item) => _dataRow(item)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _dataRow(_WuxingProfile item) {
    final color = WuxingColors.getColor(item.element);
    return DataRow(
      cells: [
        DataCell(_roundMark(item.element)),
        DataCell(
          Text(
            item.colorName,
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
        ),
        DataCell(Text(item.taste)),
        DataCell(Text(item.organ)),
        DataCell(Text(item.direction)),
        DataCell(Text(item.virtue)),
        DataCell(Text(item.numbers)),
        DataCell(Text(item.season)),
        DataCell(Text(item.branches)),
        DataCell(Text(item.nature)),
      ],
    );
  }

  Widget _roundMark(String element) {
    final color = WuxingColors.getColor(element);
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(
        child: Text(
          element,
          style: TextStyle(
            color: WuxingColors.textOnColor(element),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _sectionTile(_ImagerySection section) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEAD8B7)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFFFE5B3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(section.icon, color: const Color(0xFF8A5A00), size: 21),
        ),
        title: Text(
          section.title,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: _ink,
          ),
        ),
        subtitle: Text(
          section.summary,
          style: const TextStyle(color: _muted, height: 1.35),
        ),
        children: [
          const Divider(height: 18, color: Color(0xFFEAD8B7)),
          ...section.rows.map(_miniRow),
        ],
      ),
    );
  }

  Widget _miniRow(_MiniRow row) {
    final color = WuxingColors.getColor(row.element);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Center(
              child: Text(
                row.element,
                style: TextStyle(
                  color: WuxingColors.textOnColor(row.element),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 76,
            child: Text(
              row.value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              row.meaning,
              style: const TextStyle(color: _muted, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _usageNote() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF35261C),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '文王卦里怎么用',
            style: TextStyle(
              color: Color(0xFFFFE0A3),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '这些意象用于补充画面与细节。真正断吉凶仍要回到五行生克、地支五行、月建日辰、旺相休囚、世应、六亲与动变。',
            style: TextStyle(
              color: Color(0xFFF5E8D7),
              height: 1.55,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _WuxingProfile {
  final String element;
  final String colorName;
  final String taste;
  final String organ;
  final String direction;
  final String virtue;
  final String numbers;
  final String season;
  final String branches;
  final String nature;

  const _WuxingProfile({
    required this.element,
    required this.colorName,
    required this.taste,
    required this.organ,
    required this.direction,
    required this.virtue,
    required this.numbers,
    required this.season,
    required this.branches,
    required this.nature,
  });
}

class _ImagerySection {
  final String title;
  final IconData icon;
  final String summary;
  final List<_MiniRow> rows;

  const _ImagerySection({
    required this.title,
    required this.icon,
    required this.summary,
    required this.rows,
  });
}

class _MiniRow {
  final String element;
  final String value;
  final String meaning;

  const _MiniRow(this.element, this.value, this.meaning);
}
