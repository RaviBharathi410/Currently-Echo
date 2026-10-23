import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'split_horizon_layer.dart';

/// Overlay widget wrapped around the application that presents the "Split Horizon"
/// cold-start intro sequence without altering the GoRouter route table or route count.
///
/// Features:
/// - Minimum 1.8s display, dismisses when [initializationFuture] resolves, 4.0s hard cap
/// - Interactive tap-to-skip immediately triggers the retraction reveal
/// - Blocks pointer and focus/semantic traversal to underlying app while visible
/// - Dedicated Reduce Motion path: shows static frame for 800ms, then cuts cleanly
/// - Accessible semantics: "ECHO, loading" with progress, announces "ECHO ready" on exit
class EchoSplashGate extends StatefulWidget {
  final Widget child;
  final Widget? backdrop;
  final Future<void>? initializationFuture;
  final Duration duration;
  final Duration minDuration;
  final Duration maxDuration;
  final Duration reduceMotionHoldDuration;
  final bool disableOverlay;
  final VoidCallback? onDismissed;

  const EchoSplashGate({
    super.key,
    required this.child,
    this.backdrop,
    this.initializationFuture,
    this.duration = const Duration(milliseconds: 2600),
    this.minDuration = const Duration(milliseconds: 1800),
    this.maxDuration = const Duration(milliseconds: 4000),
    this.reduceMotionHoldDuration = const Duration(milliseconds: 800),
    this.disableOverlay = false,
    this.onDismissed,
  });

  @override
  State<EchoSplashGate> createState() => _EchoSplashGateState();
}

class _EchoSplashGateState extends State<EchoSplashGate>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _minTimer;
  Timer? _maxTimer;
  Timer? _reduceMotionTimer;

  bool _isDismissed = false;
  bool _isRevealing = false;
  bool _minDurationElapsed = false;
  bool _isInitialized = false;
  bool _introSettled = false;
  bool _hasAnnouncedReady = false;
  double _readinessProgress = 0.0;

  @override
  void initState() {
    super.initState();

    if (widget.disableOverlay) {
      _isDismissed = true;
      return;
    }

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _controller.addListener(() {
      setState(() {});
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && _controller.value >= 1.0) {
        _dismissSplash();
      }
    });

    _startColdStartLifecycle();
  }

  void _startColdStartLifecycle() {
    // 1. Minimum display timer
    _minTimer = Timer(widget.minDuration, () {
      if (!mounted) return;
      _minDurationElapsed = true;
      _checkReadiness();
    });

    // 2. Maximum hard cap timer
    _maxTimer = Timer(widget.maxDuration, () {
      if (!mounted) return;
      _skipToReveal();
    });

    // 3. Listen to initialization future if supplied
    if (widget.initializationFuture != null) {
      widget.initializationFuture!.then((_) {
        if (!mounted) return;
        _isInitialized = true;
        _readinessProgress = 1.0;
        _checkReadiness();
      }).catchError((_) {
        if (!mounted) return;
        _isInitialized = true;
        _checkReadiness();
      });
    } else {
      // Internal default: marks readiness as advancing
      _isInitialized = true;
      _readinessProgress = 1.0;
    }

    // Animate through intro phases and hold at settled state until ready
    _controller.animateTo(
      0.8462,
      duration: const Duration(milliseconds: 2200),
      curve: Curves.linear,
    ).then((_) {
      if (mounted) {
        _introSettled = true;
        _checkReadiness();
      }
    });
  }

  void _checkReadiness() {
    if (_minDurationElapsed && _isInitialized && !_isRevealing && _introSettled) {
      _isRevealing = true;
      _controller.animateTo(
        1.0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _skipToReveal() {
    if (_isDismissed) return;
    _minTimer?.cancel();
    _maxTimer?.cancel();
    _reduceMotionTimer?.cancel();

    _isInitialized = true;
    _minDurationElapsed = true;

    _controller.animateTo(
      1.0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  void _dismissSplash() {
    if (_isDismissed) return;
    _minTimer?.cancel();
    _maxTimer?.cancel();
    _reduceMotionTimer?.cancel();

    _announceReady();

    setState(() {
      _isDismissed = true;
    });

    widget.onDismissed?.call();
  }

  void _announceReady() {
    if (!_hasAnnouncedReady && mounted) {
      _hasAnnouncedReady = true;
      try {
        SemanticsService.sendAnnouncement(
          View.of(context),
          'ECHO ready',
          TextDirection.ltr,
        );
      } catch (_) {
        // Safe fallback for headless test bindings without active View
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isDismissed || widget.disableOverlay) return;

    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    if (disableAnimations && _reduceMotionTimer == null) {
      _controller.stop();
      _reduceMotionTimer = Timer(widget.reduceMotionHoldDuration, () {
        if (mounted) {
          _dismissSplash();
        }
      });
    }
  }

  @override
  void dispose() {
    _minTimer?.cancel();
    _maxTimer?.cancel();
    _reduceMotionTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    // Compute backdrop fade-in opacity:
    // - If dismissed: 1.0
    // - Under Reduce Motion: 1.0 (no fade)
    // - As blue half retracts (value >= 0.8462): fades in from 0.0 to 1.0 over ~400ms
    // - While splash is in intro (value < 0.8462): 0.0 (hidden behind splash)
    final double backdropOpacity;
    if (_isDismissed || widget.disableOverlay || disableAnimations) {
      backdropOpacity = 1.0;
    } else if (_controller.value >= 0.8462) {
      final tRetract = ((_controller.value - 0.8462) / (1.0 - 0.8462)).clamp(0.0, 1.0);
      backdropOpacity = Curves.easeOut.transform(tRetract);
    } else {
      backdropOpacity = 0.0;
    }

    if (_isDismissed || widget.disableOverlay) {
      if (widget.backdrop == null) {
        return widget.child;
      }
      return Stack(
        fit: StackFit.expand,
        children: [
          widget.backdrop!,
          widget.child,
        ],
      );
    }

    final progressPercent = ((_controller.value * 100).toInt()).clamp(0, 100);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Layer 1: Backdrop (fades in over ~400ms as top half retracts)
        if (widget.backdrop != null)
          Opacity(
            opacity: backdropOpacity,
            child: widget.backdrop!,
          ),

        // Layer 2: Underlying application Navigator (input/semantics gated while splash active)
        IgnorePointer(
          ignoring: true,
          child: ExcludeSemantics(
            excluding: true,
            child: widget.child,
          ),
        ),

        // Layer 3: EchoSplashGate Split Horizon overlay (top)
        Semantics(
          label: 'ECHO, loading',
          value: '$progressPercent%',
          liveRegion: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _skipToReveal,
            child: SplitHorizonLayer(
              animationValue: _controller.value,
              readinessProgress: _readinessProgress,
              isReduceMotion: disableAnimations,
            ),
          ),
        ),
      ],
    );
  }
}
