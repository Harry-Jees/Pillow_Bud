import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pillow_bud/theme/app_colors.dart';

class PacmanGameScreen extends StatefulWidget {
  const PacmanGameScreen({super.key});

  @override
  State<PacmanGameScreen> createState() => _PacmanGameScreenState();
}

class _PacmanGameScreenState extends State<PacmanGameScreen> {
  static const int gridSize = 9;
  static const Duration tickRate = Duration(milliseconds: 220);

  final Random _random = Random();
  Timer? _timer;

  late final Set<Point<int>> _walls;
  late final Set<Point<int>> _pellets;
  late Point<int> _pacman;
  late Point<int> _ghost;
  Direction _direction = Direction.right;
  int _score = 0;
  bool _gameOver = false;
  bool _won = false;

  @override
  void initState() {
    super.initState();
    _buildMaze();
    _resetGame();
    _timer = Timer.periodic(tickRate, (_) => _step());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _buildMaze() {
    _walls = {
      for (var i = 0; i < gridSize; i++) Point(i, 0),
      for (var i = 0; i < gridSize; i++) Point(i, gridSize - 1),
      for (var i = 0; i < gridSize; i++) Point(0, i),
      for (var i = 0; i < gridSize; i++) Point(gridSize - 1, i),
      const Point(2, 2),
      const Point(3, 2),
      const Point(5, 2),
      const Point(2, 4),
      const Point(3, 4),
      const Point(5, 4),
      const Point(2, 6),
      const Point(3, 6),
      const Point(5, 6),
    };
  }

  void _resetGame() {
    _pacman = const Point(1, 1);
    _direction = Direction.right;
    _ghost = const Point(7, 7);
    _score = 0;
    _gameOver = false;
    _won = false;

    _pellets = <Point<int>>{};
    for (var y = 1; y < gridSize - 1; y++) {
      for (var x = 1; x < gridSize - 1; x++) {
        final point = Point(x, y);
        if (!_walls.contains(point) && point != _pacman && point != _ghost) {
          _pellets.add(point);
        }
      }
    }
  }

  void _step() {
    if (_gameOver || _won) return;

    final nextPacman = _nextPoint(_pacman, _direction);
    final updatedPacman = _canMoveTo(nextPacman) ? nextPacman : _pacman;
    final updatedGhost = _moveGhostToward(updatedPacman);

    setState(() {
      _pacman = updatedPacman;
      if (_pellets.remove(_pacman)) {
        _score += 10;
        if (_pellets.isEmpty) {
          _won = true;
        }
      }
      _ghost = updatedGhost;
      if (_ghost == _pacman) {
        _gameOver = true;
      }
    });
  }

  Point<int> _moveGhostToward(Point<int> target) {
    final candidates = [
      Direction.up,
      Direction.down,
      Direction.left,
      Direction.right,
    ]
        .map((direction) => _nextPoint(_ghost, direction))
        .where(_canMoveTo)
        .toList()
      ..shuffle(_random);

    if (candidates.isEmpty) return _ghost;
    candidates.sort(
      (a, b) => _manhattan(a, target).compareTo(_manhattan(b, target)),
    );
    return candidates.first;
  }

  bool _canMoveTo(Point<int> point) => _isInside(point) && !_walls.contains(point);

  Point<int> _nextPoint(Point<int> point, Direction direction) {
    return switch (direction) {
      Direction.up => Point(point.x, point.y - 1),
      Direction.down => Point(point.x, point.y + 1),
      Direction.left => Point(point.x - 1, point.y),
      Direction.right => Point(point.x + 1, point.y),
    };
  }

  int _manhattan(Point<int> a, Point<int> b) {
    return (a.x - b.x).abs() + (a.y - b.y).abs();
  }

  bool _isInside(Point<int> point) {
    return point.x >= 0 &&
        point.y >= 0 &&
        point.x < gridSize &&
        point.y < gridSize;
  }

  void _setDirection(Direction direction) {
    setState(() => _direction = direction);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Mini Pac Bud'),
        actions: [
          TextButton(
            onPressed: () => setState(_resetGame),
            child: const Text('Reset'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statTile('Score', '$_score'),
                  _statTile('Pellets', '${_pellets.length}'),
                  _statTile(
                    'State',
                    _won
                        ? 'Won'
                        : _gameOver
                            ? 'Caught'
                            : 'Play',
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        final delta = details.delta;
                        if (delta.dx.abs() > delta.dy.abs()) {
                          _setDirection(delta.dx > 0 ? Direction.right : Direction.left);
                        } else {
                          _setDirection(delta.dy > 0 ? Direction.down : Direction.up);
                        }
                      },
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final cellSize = constraints.maxWidth / gridSize;
                          return Stack(
                            children: [
                              for (var y = 0; y < gridSize; y++)
                                for (var x = 0; x < gridSize; x++)
                                  Positioned(
                                    left: x * cellSize,
                                    top: y * cellSize,
                                    width: cellSize,
                                    height: cellSize,
                                    child: _walls.contains(Point(x, y))
                                        ? Container(
                                            margin: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.deepPurple.withValues(alpha: 0.55),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          )
                                        : Center(
                                            child: _pellets.contains(Point(x, y))
                                                ? Container(
                                                    width: cellSize * 0.16,
                                                    height: cellSize * 0.16,
                                                    decoration: const BoxDecoration(
                                                      color: Colors.amber,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  )
                                                : null,
                                          ),
                                  ),
                              Positioned(
                                left: _pacman.x * cellSize,
                                top: _pacman.y * cellSize,
                                width: cellSize,
                                height: cellSize,
                                child: AnimatedRotation(
                                  duration: const Duration(milliseconds: 120),
                                  turns: switch (_direction) {
                                    Direction.right => 0,
                                    Direction.down => 0.25,
                                    Direction.left => 0.5,
                                    Direction.up => 0.75,
                                  },
                                  child: const Icon(
                                    Icons.circle,
                                    color: Colors.amber,
                                    size: 34,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: _ghost.x * cellSize,
                                top: _ghost.y * cellSize,
                                width: cellSize,
                                height: cellSize,
                                child: const Icon(
                                  Icons.emoji_emotions,
                                  color: Colors.pinkAccent,
                                  size: 30,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_won || _gameOver)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  _won ? 'Nice run. You cleared the maze.' : 'The ghost caught you. Try again.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _padButton(Icons.arrow_upward, () => _setDirection(Direction.up)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _padButton(Icons.arrow_back, () => _setDirection(Direction.left)),
                      const SizedBox(width: 12),
                      _padButton(Icons.circle_outlined, () => setState(_resetGame)),
                      const SizedBox(width: 12),
                      _padButton(Icons.arrow_forward, () => _setDirection(Direction.right)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _padButton(Icons.arrow_downward, () => _setDirection(Direction.down)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _padButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 52,
          height: 52,
          child: Icon(icon, color: AppColors.primary),
        ),
      ),
    );
  }
}

enum Direction { up, down, left, right }
