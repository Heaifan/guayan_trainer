import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'earth_water_control_html.dart';
import 'fire_metal_control_html.dart';
import 'metal_wood_control_html.dart';
import 'water_fire_control_html.dart';
import 'wood_earth_control_html.dart';

/// WebView wrapper for 相克 (control) HTML effects.
class ControlRelationEffect extends StatefulWidget {
  final String? sourceElement;
  final String? targetElement;
  final bool visible;
  final double size;

  const ControlRelationEffect({
    super.key,
    required this.sourceElement,
    required this.targetElement,
    required this.visible,
    this.size = 92,
  });

  @override
  State<ControlRelationEffect> createState() => _ControlRelationEffectState();
}

class _ControlRelationEffectState extends State<ControlRelationEffect> {
  WebViewController? _controller;

  String get _htmlContent => _htmlFor(widget.sourceElement, widget.targetElement);
  bool get _shouldShow => widget.visible && _htmlContent.isNotEmpty;

  static String _htmlFor(String? from, String? to) {
    if (from == '木' && to == '土') return woodEarthControlHtml;
    if (from == '土' && to == '水') return earthWaterControlHtml;
    if (from == '水' && to == '火') return waterFireControlHtml;
    if (from == '火' && to == '金') return fireMetalControlHtml;
    if (from == '金' && to == '木') return metalWoodControlHtml;
    return '';
  }

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    final html = _htmlContent;
    if (html.isEmpty) return;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00FFF4DC))
      ..loadHtmlString(html);
  }

  @override
  void didUpdateWidget(ControlRelationEffect old) {
    super.didUpdateWidget(old);
    final oldHtml = _htmlFor(old.sourceElement, old.targetElement);
    final newHtml = _htmlContent;
    if (newHtml != oldHtml && newHtml.isNotEmpty) {
      _controller?.loadHtmlString(newHtml);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldShow || _controller == null) {
      return const SizedBox.shrink();
    }
    return IgnorePointer(
      ignoring: true,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.size / 2),
          child: WebViewWidget(controller: _controller!),
        ),
      ),
    );
  }
}
