import 'package:flutter/material.dart';

class DraggableFab extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const DraggableFab({
    super.key,
    required this.child,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<DraggableFab> createState() => _DraggableFabState();
}

class _DraggableFabState extends State<DraggableFab> {
  Offset _offset = const Offset(-1, -1); // 초기값 (계산 전)
  bool _isDragging = false;
  final double _fabSize = 56.0;
  final double _margin = 16.0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    // 초기 위치 설정 (우측 하단)
    if (_offset.dx == -1 && _offset.dy == -1) {
      _offset = Offset(
        size.width - _fabSize - _margin,
        size.height - _fabSize - _margin - padding.bottom,
      );
    }

    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: GestureDetector(
        onPanStart: (_) => setState(() => _isDragging = true),
        onPanUpdate: (details) {
          setState(() {
            _offset += details.delta;
            // 화면 밖으로 나가지 않도록 제한
            _offset = Offset(
              _offset.dx.clamp(0, size.width - _fabSize),
              _offset.dy.clamp(padding.top, size.height - _fabSize - padding.bottom),
            );
          });
        },
        onPanEnd: (_) {
          setState(() => _isDragging = false);
          _snapToEdge(size.width);
        },
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _isDragging ? 0.7 : 1.0,
          child: FloatingActionButton(
            onPressed: _isDragging ? null : widget.onPressed,
            backgroundColor: widget.backgroundColor,
            foregroundColor: widget.foregroundColor,
            elevation: _isDragging ? 8 : 4,
            child: widget.child,
          ),
        ),
      ),
    );
  }

  void _snapToEdge(double screenWidth) {
    final double leftEdge = _margin;
    final double rightEdge = screenWidth - _fabSize - _margin;

    // 중앙을 기준으로 가까운 쪽 선택
    final double targetX = (_offset.dx + _fabSize / 2 < screenWidth / 2) ? leftEdge : rightEdge;

    setState(() {
      _offset = Offset(targetX, _offset.dy);
    });
  }
}
