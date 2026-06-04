import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BaguaStudyPage extends StatelessWidget {
  const BaguaStudyPage({super.key});

  static const _ink = Color(0xFF241A13);
  static const _muted = Color(0xFF725C49);
  static const _paper = Color(0xFFFFF8EA);
  static const _line = Color(0xFFE2C994);
  static const _deep = Color(0xFF2B4A3F);

  static const _items = [
    _BaguaProfile(
      name: '乾',
      symbol: '☰',
      formula: '乾三连',
      nature: '天',
      wuxing: '金',
      yinYang: '阳',
      xiantianNumber: '1',
      direction: '西北',
      nagan: '甲壬',
      colorName: '金黄',
      taste: '辣',
      body: '头',
      organ: '大肠',
      core: '刚健、主动、尊贵、统领',
      illness: '老病、急病、硬化性疾病',
    ),
    _BaguaProfile(
      name: '兑',
      symbol: '☱',
      formula: '兑上缺',
      nature: '泽',
      wuxing: '金',
      yinYang: '阴',
      xiantianNumber: '2',
      direction: '西',
      nagan: '丁',
      colorName: '白',
      taste: '辣',
      body: '口',
      organ: '肺',
      core: '喜悦、口舌、表达、缺口',
      illness: '外伤、血压低、皮肤病',
    ),
    _BaguaProfile(
      name: '离',
      symbol: '☲',
      formula: '离中虚',
      nature: '火',
      wuxing: '火',
      yinYang: '阴',
      xiantianNumber: '3',
      direction: '南',
      nagan: '己',
      colorName: '红',
      taste: '苦',
      body: '眼',
      organ: '心脏',
      core: '光明、附着、文明、显现',
      illness: '烫伤、发烧、血液、妇科病',
    ),
    _BaguaProfile(
      name: '震',
      symbol: '☳',
      formula: '震仰盂',
      nature: '雷',
      wuxing: '木',
      yinYang: '阳',
      xiantianNumber: '4',
      direction: '东',
      nagan: '庚',
      colorName: '绿',
      taste: '酸',
      body: '足',
      organ: '肝',
      core: '发动、惊动、生发、长男',
      illness: '多动症、外伤',
    ),
    _BaguaProfile(
      name: '巽',
      symbol: '☴',
      formula: '巽下断',
      nature: '风',
      wuxing: '木',
      yinYang: '阴',
      xiantianNumber: '5',
      direction: '东南',
      nagan: '辛',
      colorName: '绿、蓝',
      taste: '酸',
      body: '股',
      organ: '胆',
      core: '入、顺、风行、渗透',
      illness: '感冒、中风、忧郁症、传染病',
    ),
    _BaguaProfile(
      name: '坎',
      symbol: '☵',
      formula: '坎中满',
      nature: '水',
      wuxing: '水',
      yinYang: '阳',
      xiantianNumber: '6',
      direction: '北',
      nagan: '戊',
      colorName: '黑',
      taste: '咸',
      body: '耳',
      organ: '肾',
      core: '险陷、流动、智慧、隐伏',
      illness: '性病、中毒、水肿病、免疫系统病',
    ),
    _BaguaProfile(
      name: '艮',
      symbol: '☶',
      formula: '艮覆碗',
      nature: '山',
      wuxing: '土',
      yinYang: '阳',
      xiantianNumber: '7',
      direction: '东北',
      nagan: '丙',
      colorName: '咖啡',
      taste: '甜',
      body: '手',
      organ: '脾',
      core: '停止、阻隔、少男、稳定',
      illness: '肿瘤、结石、皮肤病、气血不通',
    ),
    _BaguaProfile(
      name: '坤',
      symbol: '☷',
      formula: '坤六断',
      nature: '地',
      wuxing: '土',
      yinYang: '阴',
      xiantianNumber: '8',
      direction: '西南',
      nagan: '乙癸',
      colorName: '黄',
      taste: '甜',
      body: '腹',
      organ: '胃',
      core: '承载、包容、顺从、母性',
      illness: '浮肿、皮肤病、慢性病',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF1DF),
      appBar: AppBar(
        title: const Text('八卦模块'),
        backgroundColor: const Color(0xFFFAF1DF),
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        children: [
          _hero(),
          const SizedBox(height: 14),
          _originCard(),
          const SizedBox(height: 12),
          _formulaCard(),
          const SizedBox(height: 14),
          const _BaguaDiagramSection(),
          const SizedBox(height: 14),
          _memorySummary(),
          const SizedBox(height: 14),
          _knowledgeTable(),
          const SizedBox(height: 16),
          const Text(
            '八卦分卡',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: _ink,
            ),
          ),
          const SizedBox(height: 10),
          ..._items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _baguaCard(item),
            ),
          ),
          _usageNote(),
        ],
      ),
    );
  }

  Widget _hero() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _deep,
        borderRadius: BorderRadius.circular(24),
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
            '八卦是一组取象地图',
            style: TextStyle(
              color: Color(0xFFFFDF9F),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '从自然现象，进入五行、方位、人体与病象',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1.28,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _items.map((item) => _guaPill(item)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _guaPill(_BaguaProfile item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: _colorFor(item),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Text(
        '${item.name} ${item.symbol}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _originCard() {
    return _plainCard(
      icon: Icons.auto_awesome_outlined,
      title: '八卦的产生',
      body: '八卦的产生是自然界八种自然现象的反映。古人称乾为天，坤为地，震为雷，巽为风，坎为水，离为火，艮为山，兑为泽。',
    );
  }

  Widget _formulaCard() {
    return _plainCard(
      icon: Icons.format_quote,
      title: '歌诀记忆法',
      body: '乾三连，坤六断，震仰盂，艮覆碗，离中虚，坎中满，兑上缺，巽下断。',
    );
  }

  Widget _plainCard({
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _paper,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _deep, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.55,
                    color: _muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _memorySummary() {
    final rows = [
      ('四正定位', '离南、坎北、震东、兑西', Icons.explore_outlined),
      ('四隅补齐', '巽东南、坤西南、乾西北、艮东北', Icons.open_in_full),
      ('五行归类', '乾兑金，离火，震巽木，坎水，艮坤土', Icons.grass_outlined),
      ('形象歌诀', '乾连、坤断、震仰、艮覆、离虚、坎满、兑缺、巽断', Icons.format_quote),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2B4A3F),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.psychology_alt_outlined, color: Color(0xFFFFDF9F)),
              SizedBox(width: 8),
              Text(
                '八卦速记小结',
                style: TextStyle(
                  color: Color(0xFFFFDF9F),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: _memoryRow(row.$1, row.$2, row.$3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _memoryRow(String title, String body, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFFFD37A), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$title：',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  TextSpan(
                    text: body,
                    style: const TextStyle(
                      color: Color(0xFFF5E8D7),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              style: const TextStyle(height: 1.45, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _knowledgeTable() {
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
              Icon(Icons.table_chart_outlined, color: _deep),
              SizedBox(width: 8),
              Text(
                '八卦知识总卡',
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
              color: const Color(0xFFFFE3A8),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              '横向滑动查看纳干、颜色、五味、人体、脏腑',
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
                DataColumn(label: Text('卦')),
                DataColumn(label: Text('自然')),
                DataColumn(label: Text('五行')),
                DataColumn(label: Text('阴阳')),
                DataColumn(label: Text('先天数')),
                DataColumn(label: Text('方位')),
                DataColumn(label: Text('纳干')),
                DataColumn(label: Text('颜色')),
                DataColumn(label: Text('五味')),
                DataColumn(label: Text('人体')),
                DataColumn(label: Text('脏腑')),
              ],
              rows: _items.map(_dataRow).toList(),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _dataRow(_BaguaProfile item) {
    return DataRow(
      cells: [
        DataCell(_guaMark(item)),
        DataCell(Text(item.nature)),
        DataCell(Text(item.wuxing)),
        DataCell(Text(item.yinYang)),
        DataCell(Text(item.xiantianNumber)),
        DataCell(Text(item.direction)),
        DataCell(Text(item.nagan)),
        DataCell(Text(item.colorName)),
        DataCell(Text(item.taste)),
        DataCell(Text(item.body)),
        DataCell(Text(item.organ)),
      ],
    );
  }

  Widget _guaMark(_BaguaProfile item) {
    return Container(
      width: 44,
      height: 34,
      decoration: BoxDecoration(
        color: _colorFor(item),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          '${item.name} ${item.symbol}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _baguaCard(_BaguaProfile item) {
    final color = _colorFor(item);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEAD8B7)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
        leading: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              item.symbol,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        title: Text(
          '${item.name}为${item.nature}',
          style: TextStyle(
            color: color,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Text(
          '${item.formula} · ${item.wuxing} · ${item.direction} · ${item.core}',
          style: const TextStyle(color: _muted, height: 1.35),
        ),
        children: [
          const Divider(height: 18, color: Color(0xFFEAD8B7)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _detailPanel(
                  title: '取象骨架',
                  color: color,
                  rows: [
                    ('自然', item.nature),
                    ('五行', item.wuxing),
                    ('阴阳', item.yinYang),
                    ('方位', item.direction),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _detailPanel(
                  title: '记忆钩子',
                  color: color,
                  rows: [
                    ('歌诀', item.formula),
                    ('先天数', item.xiantianNumber),
                    ('纳干', item.nagan),
                    ('颜色', item.colorName),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _meaningBox(item, color),
        ],
      ),
    );
  }

  Widget _detailPanel({
    required String title,
    required Color color,
    required List<(String, String)> rows,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.26)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${row.$1}：',
                      style: const TextStyle(
                        color: _muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: row.$2,
                      style: const TextStyle(
                        color: _ink,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                style: const TextStyle(height: 1.3, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _meaningBox(_BaguaProfile item, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0E1).withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFECCCA6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${item.name}卦核心：',
                  style: TextStyle(fontWeight: FontWeight.w900, color: color),
                ),
                TextSpan(
                  text: item.core,
                  style: const TextStyle(color: _muted, height: 1.45),
                ),
              ],
            ),
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _miniTag('人体', item.body, color),
              _miniTag('脏腑', item.organ, color),
              _miniTag('五味', item.taste, color),
            ],
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: '病象：',
                  style: TextStyle(fontWeight: FontWeight.w900, color: _ink),
                ),
                TextSpan(
                  text: item.illness,
                  style: const TextStyle(color: _muted, height: 1.45),
                ),
              ],
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _miniTag(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(color: _muted),
            ),
            TextSpan(
              text: value,
              style: TextStyle(color: color, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _usageNote() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF37271D),
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
            '八卦意象用于给卦爻补充画面：看自然象、方位、身体、人物状态与事情性质。真正判断仍要合参五行生克、世应、六亲、月建日辰与动变。',
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

  Color _colorFor(_BaguaProfile item) {
    switch (item.wuxing) {
      case '金':
        return const Color(0xFF8C8170);
      case '火':
        return const Color(0xFFD84032);
      case '木':
        return const Color(0xFF45884C);
      case '水':
        return const Color(0xFF2F78B7);
      case '土':
        return const Color(0xFFE0AA21);
      default:
        return _deep;
    }
  }
}

class _BaguaDiagramSection extends StatefulWidget {
  const _BaguaDiagramSection();

  @override
  State<_BaguaDiagramSection> createState() => _BaguaDiagramSectionState();
}

class _BaguaDiagramSectionState extends State<_BaguaDiagramSection> {
  var _selectedIndex = 0;

  static const _ink = BaguaStudyPage._ink;
  static const _muted = BaguaStudyPage._muted;
  static const _paper = BaguaStudyPage._paper;
  static const _line = BaguaStudyPage._line;
  static const _deep = BaguaStudyPage._deep;

  @override
  Widget build(BuildContext context) {
    final isHoutian = _selectedIndex == 0;

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
              Icon(Icons.explore_outlined, color: _deep),
              SizedBox(width: 8),
              Text(
                '先天 / 后天八卦图',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: _ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _switcher(),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _diagramFrame(
              key: ValueKey(_selectedIndex),
              svg: isHoutian ? _houtianBaguaSvg : _xiantianBaguaSvg,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isHoutian
                ? '后天八卦重在方位与实用取象：文王卦里看方位、环境、落点时更常用。'
                : '先天八卦重在本源结构与对待关系：适合先记卦序、阴阳相对和天地定位。',
            style: const TextStyle(color: _muted, height: 1.55, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _switcher() {
    return Container(
      height: 42,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE3A8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [_switchButton('后天八卦', 0), _switchButton('先天八卦', 1)],
      ),
    );
  }

  Widget _switchButton(String label, int index) {
    final selected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: () => setState(() => _selectedIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? _deep : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: _deep.withValues(alpha: 0.22),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF6B4E2E),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  Widget _diagramFrame({required Key key, required String svg}) {
    return Container(
      key: key,
      width: double.infinity,
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8D8B9)),
      ),
      child: AspectRatio(
        aspectRatio: 0.94,
        child: SvgPicture.string(svg, fit: BoxFit.contain),
      ),
    );
  }
}

const _baguaSvgDefs = '''
<defs>
  <g id="yang">
    <line x1="-35" y1="0" x2="35" y2="0" stroke="#111111" stroke-width="8" stroke-linecap="square" />
  </g>
  <g id="yin">
    <line x1="-35" y1="0" x2="-8" y2="0" stroke="#111111" stroke-width="8" stroke-linecap="square" />
    <line x1="8" y1="0" x2="35" y2="0" stroke="#111111" stroke-width="8" stroke-linecap="square" />
  </g>
  <g id="taiji">
    <circle cx="0" cy="0" r="100" fill="#ffffff" stroke="#111111" stroke-width="1.5" />
    <path d="M 0,-100 A 100,100 0 0,1 0,100 A 50,50 0 0,1 0,0 A 50,50 0 0,0 0,-100 Z" fill="#111111" />
    <circle cx="0" cy="-50" r="15" fill="#111111" />
    <circle cx="0" cy="50" r="15" fill="#ffffff" />
  </g>
  <g id="gua-qian"><use href="#yang" y="0"/><use href="#yang" y="-18"/><use href="#yang" y="-36"/></g>
  <g id="gua-dui"><use href="#yang" y="0"/><use href="#yang" y="-18"/><use href="#yin" y="-36"/></g>
  <g id="gua-li"><use href="#yang" y="0"/><use href="#yin" y="-18"/><use href="#yang" y="-36"/></g>
  <g id="gua-zhen"><use href="#yang" y="0"/><use href="#yin" y="-18"/><use href="#yin" y="-36"/></g>
  <g id="gua-xun"><use href="#yin" y="0"/><use href="#yang" y="-18"/><use href="#yang" y="-36"/></g>
  <g id="gua-kan"><use href="#yin" y="0"/><use href="#yang" y="-18"/><use href="#yin" y="-36"/></g>
  <g id="gua-gen"><use href="#yin" y="0"/><use href="#yin" y="-18"/><use href="#yang" y="-36"/></g>
  <g id="gua-kun"><use href="#yin" y="0"/><use href="#yin" y="-18"/><use href="#yin" y="-36"/></g>
</defs>
<style>
  .title {
    font-family: "PingFang SC", "Microsoft YaHei", sans-serif;
    font-size: 36px;
    font-weight: 800;
    fill: #A93226;
    text-anchor: middle;
  }
  .label-outer {
    font-family: "PingFang SC", "Microsoft YaHei", sans-serif;
    font-size: 28px;
    font-weight: 900;
    fill: #4F3E30;
    text-anchor: middle;
    dominant-baseline: middle;
  }
  .label-inner {
    font-family: "PingFang SC", "Microsoft YaHei", sans-serif;
    font-size: 34px;
    font-weight: 900;
    fill: #1F1712;
    text-anchor: middle;
    dominant-baseline: middle;
  }
</style>
''';

const _houtianBaguaSvg =
    '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="245 115 510 540">
  <rect width="1000" height="850" rx="40" fill="#FFFDF6"/>
  $_baguaSvgDefs
  <g transform="translate(500, 390)">
    <use href="#taiji" transform="rotate(0)" />
    <g transform="rotate(0) translate(0, -165)">
      <use href="#gua-li" />
      <text x="0" y="58" class="label-inner">离火</text>
      <text x="0" y="-62" class="label-outer">南</text>
    </g>
    <g transform="rotate(45) translate(0, -165)">
      <use href="#gua-kun" />
      <text x="0" y="58" class="label-inner">坤土</text>
      <text x="0" y="-62" class="label-outer">西南</text>
    </g>
    <g transform="rotate(90) translate(0, -165)">
      <use href="#gua-dui" />
      <text x="0" y="58" class="label-inner">兑金</text>
      <text x="0" y="-62" class="label-outer">西</text>
    </g>
    <g transform="rotate(135) translate(0, -165)">
      <use href="#gua-qian" />
      <text x="0" y="58" class="label-inner">乾金</text>
      <text x="0" y="-62" class="label-outer">西北</text>
    </g>
    <g transform="rotate(180) translate(0, -165)">
      <use href="#gua-kan" />
      <text x="0" y="58" class="label-inner" transform="rotate(180 0 58)">坎水</text>
      <text x="0" y="-62" class="label-outer" transform="rotate(180 0 -62)">北</text>
    </g>
    <g transform="rotate(-135) translate(0, -165)">
      <use href="#gua-gen" />
      <text x="0" y="58" class="label-inner">艮土</text>
      <text x="0" y="-62" class="label-outer">东北</text>
    </g>
    <g transform="rotate(-90) translate(0, -165)">
      <use href="#gua-zhen" />
      <text x="0" y="58" class="label-inner">震木</text>
      <text x="0" y="-62" class="label-outer">东</text>
    </g>
    <g transform="rotate(-45) translate(0, -165)">
      <use href="#gua-xun" />
      <text x="0" y="58" class="label-inner">巽木</text>
      <text x="0" y="-62" class="label-outer">东南</text>
    </g>
  </g>
</svg>
''';

const _xiantianBaguaSvg =
    '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="245 115 510 540">
  <rect width="1000" height="850" rx="40" fill="#FFFDF6"/>
  $_baguaSvgDefs
  <g transform="translate(500, 390)">
    <use href="#taiji" transform="rotate(-90)" />
    <g transform="rotate(0) translate(0, -165)">
      <use href="#gua-qian" />
      <text x="0" y="58" class="label-inner">乾一</text>
      <text x="0" y="-62" class="label-outer">天南</text>
      <text x="0" y="-94" class="label-outer">金</text>
    </g>
    <g transform="rotate(-45) translate(0, -165)">
      <use href="#gua-dui" />
      <text x="0" y="58" class="label-inner">兑二</text>
      <text x="0" y="-62" class="label-outer">泽东南</text>
      <text x="0" y="-94" class="label-outer">金</text>
    </g>
    <g transform="rotate(-90) translate(0, -165)">
      <use href="#gua-li" />
      <text x="0" y="58" class="label-inner">离三</text>
      <text x="0" y="-62" class="label-outer">火东</text>
      <text x="0" y="-94" class="label-outer">火</text>
    </g>
    <g transform="rotate(-135) translate(0, -165)">
      <use href="#gua-zhen" />
      <text x="0" y="58" class="label-inner">震四</text>
      <text x="0" y="-62" class="label-outer">雷东北</text>
      <text x="0" y="-94" class="label-outer">木</text>
    </g>
    <g transform="rotate(180) translate(0, -165)">
      <use href="#gua-kun" />
      <text x="0" y="58" class="label-inner" transform="rotate(180 0 58)">坤八</text>
      <text x="0" y="-62" class="label-outer" transform="rotate(180 0 -62)">地北</text>
      <text x="0" y="-94" class="label-outer" transform="rotate(180 0 -94)">土</text>
    </g>
    <g transform="rotate(135) translate(0, -165)">
      <use href="#gua-gen" />
      <text x="0" y="58" class="label-inner">艮七</text>
      <text x="0" y="-62" class="label-outer">山西北</text>
      <text x="0" y="-94" class="label-outer">土</text>
    </g>
    <g transform="rotate(90) translate(0, -165)">
      <use href="#gua-kan" />
      <text x="0" y="58" class="label-inner">坎六</text>
      <text x="0" y="-62" class="label-outer">水西</text>
      <text x="0" y="-94" class="label-outer">水</text>
    </g>
    <g transform="rotate(45) translate(0, -165)">
      <use href="#gua-xun" />
      <text x="0" y="58" class="label-inner">巽五</text>
      <text x="0" y="-62" class="label-outer">风西南</text>
      <text x="0" y="-94" class="label-outer">木</text>
    </g>
  </g>
</svg>
''';

class _BaguaProfile {
  final String name;
  final String symbol;
  final String formula;
  final String nature;
  final String wuxing;
  final String yinYang;
  final String xiantianNumber;
  final String direction;
  final String nagan;
  final String colorName;
  final String taste;
  final String body;
  final String organ;
  final String core;
  final String illness;

  const _BaguaProfile({
    required this.name,
    required this.symbol,
    required this.formula,
    required this.nature,
    required this.wuxing,
    required this.yinYang,
    required this.xiantianNumber,
    required this.direction,
    required this.nagan,
    required this.colorName,
    required this.taste,
    required this.body,
    required this.organ,
    required this.core,
    required this.illness,
  });
}
