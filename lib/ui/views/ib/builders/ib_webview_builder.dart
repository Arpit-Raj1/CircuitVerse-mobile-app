import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:mobile_app/ui/views/ib/builders/custom_iframe_extension.dart';
import 'package:markdown/markdown.dart' as md;

class IbWebViewBuilder extends MarkdownElementBuilder {
  IbWebViewBuilder();

  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    var textContent = element.textContent;

    return Html(
      data: textContent,
      // in newer version of flutter_html,customRenders has been replaced by extensions:
      extensions: [CustomIframeExtension()],
    );
  }
}
