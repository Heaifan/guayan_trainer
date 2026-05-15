import 'package:flutter/material.dart';

import '../../data/wuxing_data.dart';
import '../../theme/wuxing_colors.dart';

class WuxingGeneratePage extends StatelessWidget {
  const WuxingGeneratePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('五行相生')),
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
                Text('五行相生详情页正在建设中，敬请期待。',
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
          const Text('木 → 火 → 土 → 金 → 水 → 木\n\n相生顺行，生生不息。',
              style: TextStyle(fontSize: 15, height: 1.6)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: WuxingData.elements.map((e) {
              return Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: WuxingColors.getColor(e),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(e,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
