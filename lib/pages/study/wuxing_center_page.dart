import 'package:flutter/material.dart';

import '../../theme/wuxing_colors.dart';

class WuxingCenterPage extends StatelessWidget {
  const WuxingCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('以我为中心')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4DC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE0C28A)),
            ),
            child: const Column(
              children: [
                Icon(Icons.construction, size: 48, color: Color(0xFFB8863B)),
                SizedBox(height: 16),
                Text('即将开放',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                SizedBox(height: 8),
                Text('"以我为中心"详情页正在建设中，敬请期待。',
                    style: TextStyle(fontSize: 15, height: 1.5, color: Color(0xFF6B4E2E))),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _previewSection(),
        ],
      ),
    );
  }

  Widget _previewSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0C28A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('内容预告', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('以某个五行为中心，练习：生我、我生、克我、我克、同我。\n\n例如以"木"为中心：\n生我者：水\n我生者：火\n克我者：金\n我克者：土\n同我者：木',
              style: TextStyle(fontSize: 15, height: 1.6)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _chip('水'),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text('生', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
              ),
              _chip('木'),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text('生', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
              ),
              _chip('火'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String element) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: WuxingColors.getColor(element),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(element,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
    );
  }
}
