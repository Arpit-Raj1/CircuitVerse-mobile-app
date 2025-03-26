import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/dom.dart' as dom;

class CustomIframeExtension extends HtmlExtension {
  @override
  Set<String> get supportedTags => {'iframe'};

  @override
  bool isElementRenderable(dom.Element element) {
    return element.localName == 'iframe' &&
        (element.attributes['src']?.isNotEmpty ?? false);
  }

  @override
  InlineSpan buildInlineSpan(
    ExtensionContext context,
    dom.Element element,
    TextStyle? textStyle,
  ) {
    return WidgetSpan(child: buildWidget(context));
  }

  @override
  Widget buildWidget(ExtensionContext context) {
    final element = context.element;
    final src = element?.attributes['src'] ?? 'Unknown source';

    final ctx = context.buildContext;
    final screenWidth =
        ctx != null ? MediaQuery.of(ctx).size.width : 300.0; // Fallback width

    final height = (screenWidth * 9) / 16;

    return SizedBox(
      width: screenWidth,
      height: height,
      child: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(src)),
        initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
          javaScriptEnabled: true,
          mediaPlaybackRequiresUserGesture: false,
        )),
      ),
    );
  }
}
