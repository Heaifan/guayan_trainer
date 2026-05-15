import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'wood_fire_html.dart';

/// Shows an HTML/SVG center effect (火焰 animation) when the current
/// wheel relationship is 木→火.
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

  /// Only show for 木→火 relationship.
  bool get _shouldShow =>
      widget.visible &&
      widget.sourceElement == '木' &&
      widget.targetElement == '火';

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00FFF4DC))
      ..loadHtmlString(woodFireHtml);
  }

  @override
  void didUpdateWidget(HtmlRelationEffect old) {
    super.didUpdateWidget(old);

    // Rebuild WebView when relationship changes into 木→火
    final wasShowing = old.visible && old.sourceElement == '木' && old.targetElement == '火';
    if (_shouldShow && !wasShowing) {
      _controller?.loadHtmlString(woodFireHtml);
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
