import 'package:flutter/material.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';

/// A customizable loading indicator that shows a semi-transparent overlay with a circular progress indicator.
///
/// This indicator blocks user interaction while displayed and can be shown/hidden programmatically.
/// It uses a singleton pattern to ensure only one indicator is shown at a time, and includes
/// safety checks to prevent common errors related to disposed contexts or navigator state.
///
/// Usage:
/// ```dart
/// // Show loading
/// CustomLoadingIndicator.of(context).show();
///
/// // Hide loading
/// CustomLoadingIndicator.of(context).hide();
///
/// // Reset when signing out or clearing state
/// CustomLoadingIndicator.reset();
/// ```
class CustomLoadingIndicator {
  final BuildContext _context;
  bool _isShowing = false;
  static CustomLoadingIndicator? _instance;

  /// Hides the loading indicator if it's currently showing
  ///
  /// Safely handles cases where the context is no longer valid or the navigator is unavailable.
  void hide() {
    if (_isShowing) {
      try {
        if (!_isNavigatorMounted()) {
          _isShowing = false;
          return;
        }
        
        // Use Navigator.pop with rootNavigator to only pop the dialog
        // This won't interfere with GoRouter navigation stack
        Navigator.of(_context, rootNavigator: true).pop();
        _isShowing = false;
      } catch (e) {
        // Reset state even if there's an error
        _isShowing = false;
      }
    }
  }

  /// Shows the loading indicator as a modal dialog
  ///
  /// Safely handles cases where the context is no longer valid or the navigator is unavailable.
  void show() {
    if (!_isShowing) {
      if (!_isNavigatorMounted()) {
        // Cannot show the indicator if context is not valid
        return;
      }
      
      try {
        _isShowing = true;
        showDialog(
          context: _context,
          barrierDismissible: false,
          useSafeArea: false,
          barrierColor: transparent,
          builder: (_) => const LoadingIndicator(),
        ).then((_) => _isShowing = false);
      } catch (e) {
        // Reset state if showing fails
        _isShowing = false;
      }
    }
  }

  /// Returns whether the loading indicator is currently showing
  bool get isShowing => _isShowing;

  /// Checks if the navigator is still mounted and can be used
  bool _isNavigatorMounted() {
    try {
      if (!_context.mounted) return false;
      
      // This will throw if the Navigator is not available
      final navigator = Navigator.of(_context, rootNavigator: true);
      return navigator.mounted;
    } catch (e) {
      // If any error occurs, consider the navigator not mounted
      return false;
    }
  }

  /// Resets the internal instance
  /// 
  /// This should be called when:
  /// - Signing out
  /// - Major navigation occurs (like going back to login)
  /// - App state is being cleared
  static void reset() {
    if (_instance != null && _instance!._isShowing) {
      try {
        _instance!.hide();
      } catch (e) {
        // Ignore errors when forcibly resetting
      }
    }
    _instance = null;
  }

  /// Private constructor for singleton pattern
  CustomLoadingIndicator._create(this._context);

  /// Factory constructor to create a loading indicator for the given context
  /// 
  /// Always recreates the instance to ensure we have the latest context
  factory CustomLoadingIndicator.of(BuildContext context) {
    // Check for valid context
    if (!context.mounted) {
      throw StateError('Cannot create CustomLoadingIndicator with unmounted context');
    }
    
    _instance = CustomLoadingIndicator._create(context);
    return _instance!;
  }
  
  /// Show a loading indicator temporarily for a specific operation
  /// 
  /// Returns the result of the Future operation
  static Future<T> during<T>(BuildContext context, Future<T> operation) async {
    try {
      if (!context.mounted) return await operation;
      
      final indicator = CustomLoadingIndicator.of(context);
      indicator.show();
      
      try {
        return await operation;
      } finally {
        if (context.mounted) {
          indicator.hide();
        }
      }
    } catch (e) {
      rethrow;
    }
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
