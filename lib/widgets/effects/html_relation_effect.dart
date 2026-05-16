import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'fire_earth_html.dart';
import 'wood_fire_html.dart';

/// Shows an HTML/SVG effect in a WebView for a given relationship pair.
///
/// Supported pairs:
/// - 木→火: flame animation (wood_fire_html)
/// - 火→土: ash smother fire animation (fire_earth_html)
class HtmlRelationEffect extends StatefulWidget {
  final String? sourceElement;
  final String? targetElement;
  final bool visible;
  final double size;

  const HtmlRelationEffect({
    super.key,
    required this.sourceElement,
    required this.targetElement,
    required this.visible,
    this.size = 92,
  });

  @override
  State<HtmlRelationEffect> createState() => _HtmlRelationEffectState();
}

class _HtmlRelationEffectState extends State<HtmlRelationEffect> {
  WebViewController? _controller;

  String get _htmlContent => _htmlFor(widget.sourceElement, widget.targetElement);

  bool get _shouldShow => widget.visible && _htmlContent.isNotEmpty;

  static String _htmlFor(String? from, String? to) {
    if (from == '木' && to == '火') return woodFireHtml;
    if (from == '火' && to == '土') return fireEarthHtml;
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
  void didUpdateWidget(HtmlRelationEffect old) {
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
