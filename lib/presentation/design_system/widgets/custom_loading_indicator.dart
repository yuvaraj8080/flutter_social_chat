import 'package:flutter/material.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:go_router/go_router.dart';

/// A customizable loading indicator that shows a semi-transparent overlay with a circular progress indicator.
///
/// This indicator blocks user interaction while displayed and can be shown/hidden programmatically.
class CustomLoadingIndicator {
  final BuildContext _context;
  bool _isShowing = false;
  static CustomLoadingIndicator? _instance;

  /// Hides the loading indicator if it's currently showing
  void hide() {
    if (_isShowing) {
      try {
        // Use GoRouter's pop which is compatible with the app's routing system
        if (GoRouter.of(_context).canPop()) {
          _context.pop();
        }
        _isShowing = false;
      } catch (e) {
        debugPrint('Error hiding loading indicator: $e');
        _isShowing = false; // Reset state even if there's an error
      }
    }
  }

  /// Shows the loading indicator as a modal dialog
  void show() {
    if (!_isShowing) {
      _isShowing = true;
      showDialog(
        context: _context,
        barrierDismissible: false,
        useSafeArea: false,
        barrierColor: Colors.transparent,
        builder: (_) => const LoadingIndicator(),
      ).then((_) => _isShowing = false);
    }
  }

  CustomLoadingIndicator._create(this._context);

  /// Factory constructor to create a loading indicator for the given context
  factory CustomLoadingIndicator.of(BuildContext context) {
    _instance ??= CustomLoadingIndicator._create(context);
    return _instance!;
  }
}

/// The widget implementation of the loading indicator
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Container(
        decoration: BoxDecoration(
          color: black.withValues(alpha: 0.3),
        ),
        child: const Center(
          child: Card(
            elevation: 4,
            shape: CircleBorder(),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(customIndigoColor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
