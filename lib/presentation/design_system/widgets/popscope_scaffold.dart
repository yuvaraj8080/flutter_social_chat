import 'package:flutter/material.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/keyboard_dismiss_wrapper.dart';

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
    this.enableKeyboardDismiss = true,
  }) : super(key: key);

  final Widget? bottomNavigationBar;
  final Widget? body;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? appBar;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final void Function(bool, Object?)? onPopInvokedWithResult;
  final bool enableKeyboardDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Wrap the body in KeyboardDismissWrapper if enabled
    final wrappedBody = enableKeyboardDismiss && body != null ? KeyboardDismissWrapper(child: body!) : body;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: onPopInvokedWithResult ?? (didPop, result) {},
      child: Scaffold(
        bottomNavigationBar: bottomNavigationBar,
        body: wrappedBody,
        appBar: appBar,
        floatingActionButton: floatingActionButton,
        backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      ),
    );
  }
}
