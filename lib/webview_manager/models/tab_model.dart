import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

// A model representing a single browser tab.
class TabModel {
  final String id; // Unique ID for the tab
  String url; // Current URL of the tab
  String title; // Title of the web page
  ImageProvider? favicon; // Favicon of the web page
  InAppWebViewController? webViewController; // Controller for the InAppWebView

  TabModel({
    required this.id,
    this.url = 'about:blank',
    this.title = 'New Tab',
    this.favicon,
    this.webViewController,
  });

  // Method to update tab properties.
  TabModel copyWith({
    String? url,
    String? title,
    ImageProvider? favicon,
    InAppWebViewController? webViewController,
  }) {
    return TabModel(
      id: id,
      url: url ?? this.url,
      title: title ?? this.title,
      favicon: favicon ?? this.favicon,
      webViewController: webViewController ?? this.webViewController,
    );
  }
}
