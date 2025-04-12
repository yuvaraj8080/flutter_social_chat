import 'package:flutter/material.dart';

class PopScopeScaffold extends StatelessWidget {
  const PopScopeScaffold({
    Key? key,
    this.bottomNavigationBar,
    this.body,
    this.floatingActionButton,
    this.appBar,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.onPopInvokedWithResult,
  }) : super(key: key);

  final Widget? bottomNavigationBar;
  final Widget? body;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? appBar;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final void Function(bool, Object?)? onPopInvokedWithResult;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: onPopInvokedWithResult ?? (didPop, result) {},
      child: Scaffold(
        bottomNavigationBar: bottomNavigationBar,
        body: body,
        appBar: appBar,
        floatingActionButton: floatingActionButton,
        backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      ),
    );
  }
}
