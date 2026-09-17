import 'package:flutter/material.dart';

class RuleCategoryFilter extends StatelessWidget {
  const RuleCategoryFilter({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  static const categories = ['全部', '状态', '关系', '取象', '常用'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final selected = category == value;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category),
              selected: selected,
              onSelected: (_) => onChanged(category),
            ),
          );
        }).toList(),
      ),
    );
  }
}
