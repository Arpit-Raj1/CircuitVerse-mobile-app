import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:mobile_app/models/failure_model.dart';
import 'package:mobile_app/viewmodels/ib/ib_page_viewmodel.dart';
import 'package:webview_flutter/webview_flutter.dart';

class IbInteractionBuilder extends MarkdownElementBuilder {
  IbInteractionBuilder({required this.model});

  final IbPageViewModel model;

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    var id = element.textContent;

    return FutureBuilder<dynamic>(
      future: model.fetchHtmlInteraction(id),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.data is Failure) {
          return const Text('Error Loading Interaction');
        } else if (!snapshot.hasData) {
          return const Text('Loading Interaction...');
        }

        var _textContent = snapshot.data.toString();
        var _streamController = StreamController<double>();

        // using webview_flutter we can use  WebViewWidget(controller: ...) instead of WebView().

        return StreamBuilder<double>(
          initialData: 100,
          stream: _streamController.stream,
          builder: (context, heightSnapshot) {
            // uncomment for using webview_flutter
            // late final WebViewController _webController;
            //
            // _webController = WebViewController()
            //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
            //   ..setNavigationDelegate(
            //     NavigationDelegate(
            //       onPageFinished: (url) async {
            //         try {
            //           final result =
            //               await _webController.runJavaScriptReturningResult(
            //                   'document.documentElement.scrollHeight');
            //           final height = double.tryParse(
            //                   result.toString().replaceAll('"', '')) ??
            //               100;
            //           _streamController.add(height);
            //         } catch (e) {
            //           _streamController.add(100); // fallback height
            //         }
            //       },
            //     ),
            //   )
            //   ..loadHtmlString(_textContent);

            return SizedBox(
                height: heightSnapshot.data,
                child: InAppWebView(
                    initialData: InAppWebViewInitialData(data: _textContent),
                    initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(
                        javaScriptEnabled: true,
                        transparentBackground: true,
                      ),
                    ),
                    onLoadStop: (controller, url) async {
                      try {
                        final heightStr = await controller.evaluateJavascript(
                          source: 'document.documentElement.scrollHeight;',
                        );
                        final height =
                            double.tryParse(heightStr.toString()) ?? 100;
                        _streamController.add(height);
                      } catch (e) {
                        _streamController.add(100); // fallback height
                      }
                    }));
          },
        );
      },
    );
  }
}
