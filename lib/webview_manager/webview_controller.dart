import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart'; // For generating unique IDs
import 'package:vaelix/webview_manager/models/tab_model.dart';

// Represents the state of our tabs: a list of tabs and the ID of the currently active tab.
class TabState {
  final List<TabModel> tabs;
  final String? activeTabId;

  TabState({required this.tabs, this.activeTabId});

  // Helper to create a new state with modified properties.
  TabState copyWith({List<TabModel>? tabs, String? activeTabId}) {
    return TabState(
      tabs: tabs ?? this.tabs,
      activeTabId: activeTabId ?? this.activeTabId,
    );
  }
}

// Notifier to manage the state of our tabs.
class WebViewController extends Notifier<TabState> {
  final Uuid _uuid = const Uuid();

  @override
  TabState build() {
    // Initialize with one default blank tab.
    final initialTab = TabModel(id: _uuid.v4());
    return TabState(tabs: [initialTab], activeTabId: initialTab.id);
  }

  // Adds a new tab and makes it active.
  void addTab({String? url}) {
    final newTab = TabModel(id: _uuid.v4(), url: url ?? 'about:blank');
    state = state.copyWith(
      tabs: [...state.tabs, newTab],
      activeTabId: newTab.id,
    );
  }

  // Removes a tab by its ID.
  void removeTab(String tabId) {
    final updatedTabs = state.tabs.where((tab) => tab.id != tabId).toList();
    String? newActiveTabId = state.activeTabId;

    if (updatedTabs.isEmpty) {
      // If no tabs are left, create a new one.
      addTab();
    } else if (state.activeTabId == tabId) {
      // If the removed tab was active, switch to the first available tab.
      newActiveTabId = updatedTabs.first.id;
    }

    state = state.copyWith(tabs: updatedTabs, activeTabId: newActiveTabId);
  }

  // Sets the active tab by its ID.
  void setActiveTab(String tabId) {
    if (state.tabs.any((tab) => tab.id == tabId)) {
      state = state.copyWith(activeTabId: tabId);
    }
  }

  // Updates the properties of a specific tab.
  void updateTab(
    String tabId, {
    String? url,
    String? title,
    ImageProvider? favicon,
  }) {
    final updatedTabs = state.tabs.map((tab) {
      if (tab.id == tabId) {
        return tab.copyWith(url: url, title: title, favicon: favicon);
      }
      return tab;
    }).toList();
    state = state.copyWith(tabs: updatedTabs);
  }

  // Get the active tab's controller. This will be used by WebViewContainer to control the webview.
  InAppWebViewController? getActiveTabController() {
    return state.tabs
        .firstWhere(
          (tab) => tab.id == state.activeTabId,
          orElse: () => throw Exception('No active tab'),
        )
        .webViewController;
  }

  // Set the controller for a tab
  void setTabWebViewController(
    String tabId,
    InAppWebViewController controller,
  ) {
    final updatedTabs = state.tabs.map((tab) {
      if (tab.id == tabId) {
        return tab.copyWith(webViewController: controller);
      }
      return tab;
    }).toList();
    state = state.copyWith(tabs: updatedTabs);
  }
}

// The provider for our WebViewController.
final webviewControllerProvider = NotifierProvider<WebViewController, TabState>(
  WebViewController.new,
);
