import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/wuxing_colors.dart';
import 'bagua_study_page.dart';
import 'wuxing_study_menu_page.dart';
import 'dizhi_study_page.dart';
import 'relation_study_page.dart';

class StudyPage extends StatelessWidget {
  const StudyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('学习'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            context,
            icon: _SvgStudyIcon(
              _wuxingIconSvg,
              color: WuxingColors.getColor('木'),
            ),
            label: '五行模块',
            subtitle: '认识颜色、意象、生克与关系',
            color: WuxingColors.getColor('木'),
            bgColor: WuxingColors.getSoftColor('木'),
            iconBgColor: const Color(0xFFCDEACF),
            page: const WuxingStudyMenuPage(),
          ),
          const SizedBox(height: 12),
          _card(
            context,
            icon: const _SvgStudyIcon(_baguaIconSvg, color: Color(0xFF0E8C82)),
            label: '八卦模块',
            subtitle: '总览卦象、五行、方位、人体与病象',
            color: const Color(0xFF0F625B),
            bgColor: const Color(0xFFE1F3EF),
            iconBgColor: const Color(0xFFC4EFE7),
            page: const BaguaStudyPage(),
          ),
          const SizedBox(height: 12),
          _card(
            context,
            icon: const Icon(Icons.radio_button_checked),
            label: '十二地支',
            subtitle: '用方位记地支，用颜色记五行',
            color: WuxingColors.getColor('土'),
            bgColor: WuxingColors.getSoftColor('土'),
            iconBgColor: const Color(0xFFFFE19A),
            page: const DizhiStudyPage(),
          ),
          const SizedBox(height: 12),
          _card(
            context,
            icon: const Icon(Icons.compare_arrows),
            label: '六冲六合',
            subtitle: '用对手和朋友记冲合关系',
            color: WuxingColors.getColor('火'),
            bgColor: WuxingColors.getSoftColor('火'),
            iconBgColor: const Color(0xFFFFC8C3),
            page: const RelationStudyPage(),
          ),
        ],
      ),
    );
  }

  Widget _card(
    BuildContext context, {
    required Widget icon,
    required String label,
    required String subtitle,
    required Color color,
    required Color bgColor,
    required Color iconBgColor,
    required Widget page,
  }) {
    return Card(
      color: bgColor,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: iconBgColor,
          child: IconTheme(
            data: IconThemeData(color: color, size: 24),
            child: icon,
          ),
        ),
        title: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w800, color: color),
        ),
        subtitle: Text(subtitle, style: const TextStyle(height: 1.4)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () =>
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => page)),
      ),
    );
  }
}

class _SvgStudyIcon extends StatelessWidget {
  final String svg;
  final Color color;

  const _SvgStudyIcon(this.svg, {required this.color});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      svg,
      width: 27,
      height: 27,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}

const _wuxingIconSvg = '''
<svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
<path d="M491.845818 46.545455a167.703273 167.703273 0 0 1 163.421091 205.451636l81.780364 59.298909a167.703273 167.703273 0 1 1 93.556363 314.088727l-27.136 83.409455a167.703273 167.703273 0 1 1-250.973091 191.767273H457.169455a167.749818 167.749818 0 1 1-271.825455-175.802182l-32.302545-99.560728A167.703273 167.703273 0 1 1 247.621818 310.690909l80.802909-58.693818A167.703273 167.703273 0 0 1 491.845818 46.545455z m220.439273 724.386909a78.661818 78.661818 0 1 0 0 157.323636 78.661818 78.661818 0 0 0 0-157.323636z m-414.906182 0a78.661818 78.661818 0 1 0 0 157.323636 78.661818 78.661818 0 0 0 0-157.323636z m194.466909-388.980364A167.191273 167.191273 0 0 1 371.432727 330.891636l-58.833454 42.728728a167.703273 167.703273 0 0 1-71.214546 235.240727l24.715637 75.915636a167.749818 167.749818 0 0 1 194.653091 126.743273h88.203636a167.749818 167.749818 0 0 1 163.374545-129.629091l6.237091 0.139636 24.110546-74.100363a167.703273 167.703273 0 0 1-70.004364-233.285818l-60.276364-43.752728a167.191273 167.191273 0 0 1-120.506181 51.060364z m-324.142545-2.466909a78.661818 78.661818 0 1 0 0 157.323636 78.661818 78.661818 0 0 0 0-157.323636z m650.379636 0a78.661818 78.661818 0 1 0 0 157.323636 78.661818 78.661818 0 0 0 0-157.323636z m-326.237091-243.898182a78.661818 78.661818 0 1 0 0 157.323636 78.661818 78.661818 0 0 0 0-157.323636z" fill="#B2B2B2"/>
</svg>
''';

const _baguaIconSvg = '''
<svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
<path d="M217.26204 829.561423a433.115573 433.115573 0 0 0 117.683098 79.034182l6.536601-24.365534a408.887652 408.887652 0 0 1-106.629565-72.258782z m142.364332 89.35513A431.051383 431.051383 0 0 0 500.995036 947.098814v-24.871462a406.523953 406.523953 0 0 1-128.777107-25.122403zM500.995036 106.042688q6.544696-0.226656 13.133913-0.218562t13.129865 0.218562a406.961075 406.961075 0 0 1 127.494071 24.652901l12.623937-21.856127a431.423747 431.423747 0 0 0-140.134197-27.692521q-6.528506-0.198324-13.113676-0.198324t-13.133913 0.206419a431.314466 431.314466 0 0 0-140.296095 27.761328l12.607747 21.856126a406.880126 406.880126 0 0 1 127.688348-24.729802z m-381.348933 587.282213a433.625549 433.625549 0 0 0 79.034182 117.683099l17.590134-17.590134a408.903842 408.903842 0 0 1-72.250688-106.629566zM106.042688 527.254767q-0.226656-6.544696-0.218562-13.129866c0-4.391462 0.068806-8.782925 0.218562-13.146055a406.928696 406.928696 0 0 1 24.458624-126.971953l-21.856126-12.607747a430.828775 430.828775 0 0 0-27.502293 139.583747Q80.948617 507.523542 80.948617 514.124901t0.206419 13.129866a431.342798 431.342798 0 0 0 28.78128 142.971446l21.815652-12.607747a406.718229 406.718229 0 0 1-25.70928-130.363699z m234.945265-383.000285l-6.524459-24.389818a433.423178 433.423178 0 0 0-117.201454 78.811573l17.590134 17.590135a408.960506 408.960506 0 0 1 106.135779-72.01189zM216.282561 234.848126l-17.590134-17.590134a433.184379 433.184379 0 0 0-79.872 119.516585l24.349344 6.524459a408.665043 408.665043 0 0 1 73.11279-108.45091z m595.688728 0a408.503146 408.503146 0 0 1 72.550197 107.256917l24.365534-6.5366a433.32604 433.32604 0 0 0-79.329645-118.302356q-8.981249-9.580269-18.565565-18.581755A433.933154 433.933154 0 0 0 689.27747 117.824759l-6.524458 24.361486a408.474814 408.474814 0 0 1 110.640569 74.067984q9.588364 9.013628 18.577708 18.593897z m0 558.545455q-9.005534 9.596458-18.581755 18.569613a408.932174 408.932174 0 0 1-106.633613 72.258782l6.524458 24.377676a432.775589 432.775589 0 0 0 117.699289-79.046324q9.580269-8.985296 18.581755-18.569613a433.605312 433.605312 0 0 0 79.050371-117.658814l-24.377675-6.536601a408.867415 408.867415 0 0 1-72.246641 106.613376z m85.283415-137.835257l21.827794 12.595605A430.909723 430.909723 0 0 0 947.098814 527.254767h-24.883605a406.863937 406.863937 0 0 1-24.944316 128.311652z m24.940268-154.587573H947.098814a431.395415 431.395415 0 0 0-26.713043-137.5317l-21.856127 12.61989a406.471336 406.471336 0 0 1 23.681518 124.919905z m-266.353328 396.190862a406.637281 406.637281 0 0 1-128.599019 25.053596V947.098814a431.184949 431.184949 0 0 0 141.206766-28.109407l-12.595604-21.815652z" fill="#64D4C7"/>
<path d="M214.513834 512a301.853344 301.853344 0 0 0 300.238419 301.533597 150.766798 150.766798 0 0 1 1.958956-301.533597 150.774893 150.774893 0 0 0 1.958957-301.533597h-2.052047c-1.278988 0-2.545834 0.024285-3.81268 0.056664A301.837154 301.837154 0 0 0 214.513834 512z" fill="#64D4C7"/>
<path d="M486.06420765 667.71606869a34.44597533 34.44597533 0 1 0 34.4413696-34.44597532 34.4413696 34.4413696 0 0 0-34.4413696 34.44597532z" fill="#64D4C7"/>
<path d="M487.31141499 354.30101333a34.44597533 34.44597533 0 1 0 34.44137074-34.44597418 34.44597533 34.44597533 0 0 0-34.44137074 34.44597418z" fill="#ffffff"/>
</svg>
''';
