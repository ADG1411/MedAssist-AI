import 'package:flutter/material.dart';
import 'app_background.dart';
import 'glass_app_bar.dart';

class BaseScreen extends StatelessWidget {
  final Widget body;
  final Widget? bottomNavigationBar;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomSheet;
  final bool useSafeArea;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;

  const BaseScreen({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.bottomSheet,
    this.useSafeArea = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPad = MediaQuery.paddingOf(context).top;
    final appBarH = appBar?.preferredSize.height ?? 0.0;

    Widget content = Padding(padding: padding, child: body);

    if (appBar != null) {
      // Push content below glass AppBar (status bar + toolbar height)
      content = Padding(
        padding: EdgeInsets.only(top: topPad + appBarH),
        child: content,
      );
    } else if (useSafeArea) {
      content = SafeArea(top: true, bottom: false, child: content);
    }

    return Scaffold(
      extendBodyBehindAppBar: appBar != null,
      extendBody: true,
      backgroundColor: Colors.transparent,
      appBar: appBar != null ? GlassAppBar(child: appBar!) : null,
      body: Stack(
        children: [
          Positioned.fill(child: AppBackground(isDark: isDark)),
          content,
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      bottomSheet: bottomSheet,
      resizeToAvoidBottomInset: true,
    );
  }
}

