import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Widget to monitor performance metrics for dropdown widgets
class PerformanceMonitor extends StatefulWidget {
  final Widget child;
  final String? debugLabel;
  final bool enabled;
  
  const PerformanceMonitor({
    super.key,
    required this.child,
    this.debugLabel,
    this.enabled = false, // Only enable in debug mode
  });
  
  @override
  State<PerformanceMonitor> createState() => _PerformanceMonitorState();
}

class _PerformanceMonitorState extends State<PerformanceMonitor> {
  int _buildCount = 0;
  Duration? _lastBuildDuration;
  final List<Duration> _buildDurations = [];
  static const int _maxStoredDurations = 20; // Reduced from 50 for better memory efficiency
  
  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }
    
    final startTime = DateTime.now();
    _buildCount++;
    
    // Use more efficient post-frame callback
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final endTime = DateTime.now();
      final buildDuration = endTime.difference(startTime);
      
      // Only update state if there's a significant change to prevent unnecessary rebuilds
      if (_lastBuildDuration == null || 
          (buildDuration.inMicroseconds - _lastBuildDuration!.inMicroseconds).abs() > 100) {
        if (mounted) {
          setState(() {
            _lastBuildDuration = buildDuration;
            _buildDurations.add(buildDuration);
            
            // Keep only recent build times for averaging
            if (_buildDurations.length > _maxStoredDurations) {
              _buildDurations.removeAt(0);
            }
          });
        }
      }
      
      // Debug output with less frequent logging
      if (widget.debugLabel != null && _buildCount % 10 == 0) {
        final avgDuration = _buildDurations.isEmpty 
          ? Duration.zero 
          : Duration(
              microseconds: _buildDurations
                  .map((d) => d.inMicroseconds)
                  .reduce((a, b) => a + b) ~/ _buildDurations.length
            );
            
        debugPrint('${widget.debugLabel}: Build #$_buildCount took ${buildDuration.inMicroseconds}μs (avg: ${avgDuration.inMicroseconds}μs)');
      }
    });
    
    return Stack(
      children: [
        widget.child,
        if (widget.enabled && _lastBuildDuration != null)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'B:$_buildCount T:${_lastBuildDuration!.inMicroseconds}μs',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Frame rate monitor for smooth animations
class FrameRateMonitor extends StatefulWidget {
  final Widget child;
  final bool enabled;
  
  const FrameRateMonitor({
    super.key,
    required this.child,
    this.enabled = false,
  });
  
  @override
  State<FrameRateMonitor> createState() => _FrameRateMonitorState();
}

class _FrameRateMonitorState extends State<FrameRateMonitor> 
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  int _frameCount = 0;
  DateTime _lastSecond = DateTime.now();
  int _currentFPS = 0;
  int _lastUpdateFPS = 0;
  
  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      _ticker = createTicker(_onTick);
      _ticker.start();
    }
  }
  
  void _onTick(Duration elapsed) {
    _frameCount++;
    final now = DateTime.now();
    
    if (now.difference(_lastSecond).inMilliseconds >= 1000) {
      // Only update state if FPS changed significantly to reduce rebuilds
      if ((_frameCount - _lastUpdateFPS).abs() > 2) {
        if (mounted) {
          setState(() {
            _currentFPS = _frameCount;
            _lastUpdateFPS = _frameCount;
            _frameCount = 0;
            _lastSecond = now;
          });
        }
      } else {
        _frameCount = 0;
        _lastSecond = now;
      }
    }
  }
  
  @override
  void dispose() {
    if (widget.enabled && _ticker.isActive) {
      _ticker.dispose();
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }
    
    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 4,
          left: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: _currentFPS < 50 ? Colors.red.withOpacity(0.7) : Colors.green.withOpacity(0.7),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${_currentFPS}fps',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
