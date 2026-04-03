import 'package:flutter/material.dart';

class BaseScreen extends StatelessWidget {
  final Widget body;
  final Widget? bottomNavigationBar;
  final PreferredSizeWidget? appBar;
  final FloatingActionButton? floatingActionButton;
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
    Widget content = Padding(
      padding: padding,
      child: body,
    );

    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      body: content,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      bottomSheet: bottomSheet,
      resizeToAvoidBottomInset: true,
    );
  }
}

