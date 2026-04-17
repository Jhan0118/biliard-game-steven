import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/manga_style.dart';
import '../widgets/manga_components.dart';
import 'result_page.dart';
import '../../domain/entities/game_result.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/scheduler.dart';

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  State<GamePage> createState() => _GamePageState();
}

enum BallType { cue, solid, stripe, eight }
enum GamePhase { openTable, groupAssigned, eightBallPhase, gameOver }

class BilliardBall {
  final int id;
  Offset position;
  Offset velocity;
  final BallType type;
  final Color color;
  bool isInPocket;

  BilliardBall({
    required this.id,
    required this.position,
    this.velocity = Offset.zero,
    required this.type,
    required this.color,
    this.isInPocket = false,
  });
}

class _GamePageState extends State<GamePage> with SingleTickerProviderStateMixin {
  late List<BilliardBall> _balls;
  late Ticker _ticker;
  
  double _power = 0.5;
  double _direction = 0.0;
  bool _isSimulating = false;
  bool _isFreeBallMode = false;
  
  int _activePlayer = 1;
  GamePhase _phase = GamePhase.openTable;
  Map<int, BallType?> _playerGroups = {1: null, 2: null};
  String _gameStatusMessage = "開球階段";

  static const double ballRadius = 14.0;
  static const double friction = 0.985;
  static const double tableWidth = 800.0;
  static const double tableHeight = 400.0;

  @override
  void initState() {
    super.initState();
    _resetGame();
    _ticker = createTicker(_updatePhysics);
  }

  void _resetGame() {
    _balls = [];
    // Cue Ball
    _balls.add(BilliardBall(id: 0, position: const Offset(200, 200), type: BallType.cue, color: Colors.white));
    
    // Professional 8-ball Rack logic
    final rackStartX = 600.0;
    final rackStartY = 200.0;
    
    // Prepare ball list (1-15, excluding 8)
    List<int> solids = [1, 2, 3, 4, 5, 6, 7];
    List<int> stripes = [9, 10, 11, 12, 13, 14, 15];
    solids.shuffle();
    stripes.shuffle();

    // Create a layout map for specific positions
    // We have 15 slots in a triangle (5 rows)
    List<int?> layout = List.filled(15, null);
    
    // Rule: 8-ball at center of 3rd row (index 4 in 0-indexed list for rows)
    // Triangle flattened index: 
    // row 0: 0
    // row 1: 1, 2
    // row 2: 3, 4, 5 (4 is center)
    // row 3: 6, 7, 8, 9
    // row 4: 10, 11, 12, 13, 14 (10 is far left, 14 is far right)
    layout[4] = 8;
    
    // Rule: Bottom corners must be one solid, one stripe
    layout[10] = solids.removeLast();
    layout[14] = stripes.removeLast();
    
    // Fill the rest randomly
    List<int> remaining = [...solids, ...stripes];
    remaining.shuffle();
    for (int i = 0; i < 15; i++) {
      if (layout[i] == null) {
        layout[i] = remaining.removeLast();
      }
    }

    final ballColors = {
      1: Colors.yellow, 2: Colors.blue, 3: Colors.red, 4: Colors.purple, 
      5: Colors.orange, 6: Colors.green, 7: const Color(0xFF800000), 8: Colors.black,
      9: Colors.yellow[200]!, 10: Colors.blue[200]!, 11: Colors.red[200]!, 
      12: Colors.purple[200]!, 13: Colors.orange[200]!, 14: Colors.green[200]!, 
      15: const Color(0xFFA52A2A),
    };

    int currentIdx = 0;
    for (int row = 0; row < 5; row++) {
      for (int col = 0; col <= row; col++) {
        final x = rackStartX + (row * ballRadius * 1.75);
        final y = rackStartY + (col * ballRadius * 2.1) - (row * ballRadius * 1.05);
        
        final id = layout[currentIdx]!;
        BallType type;
        if (id == 8) type = BallType.eight;
        else if (id < 8) type = BallType.solid;
        else type = BallType.stripe;

        _balls.add(BilliardBall(id: id, position: Offset(x, y), type: type, color: ballColors[id]!));
        currentIdx++;
      }
    }
    
    setState(() {
      _phase = GamePhase.openTable;
      _playerGroups = {1: null, 2: null};
      _gameStatusMessage = "開球階段";
      _activePlayer = 1;
    });
  }

  void _updatePhysics(Duration elapsed) {
    if (!_isSimulating) return;

    bool anyMoving = false;
    for (var ball in _balls) {
      if (ball.isInPocket) continue;
      
      // Update position
      ball.position += ball.velocity;
      // Apply friction
      ball.velocity *= friction;
      if (ball.velocity.distance < 0.1) ball.velocity = Offset.zero;

      // Wall collision (Exempt if ball is near a pocket to allow it to "sink" in)
      if (!_checkPocket(ball.position)) {
        if (ball.position.dx < ballRadius || ball.position.dx > tableWidth - ballRadius) {
          ball.velocity = Offset(ball.velocity.dx * -0.8, ball.velocity.dy);
          ball.position = Offset(ball.position.dx.clamp(ballRadius, tableWidth - ballRadius), ball.position.dy);
        }
        if (ball.position.dy < ballRadius || ball.position.dy > tableHeight - ballRadius) {
          ball.velocity = Offset(ball.velocity.dx, ball.velocity.dy * -0.8);
          ball.position = Offset(ball.position.dx, ball.position.dy.clamp(ballRadius, tableHeight - ballRadius));
        }
      }

      // Pocket detection
      if (_checkPocket(ball.position)) {
        ball.isInPocket = true;
        ball.velocity = Offset.zero;
        _handleBallPocketed(ball);
      }

      if (ball.velocity != Offset.zero) anyMoving = true;
    }

    // Ball-to-ball collision
    for (int i = 0; i < _balls.length; i++) {
      for (int j = i + 1; j < _balls.length; j++) {
        var b1 = _balls[i];
        var b2 = _balls[j];
        if (b1.isInPocket || b2.isInPocket) continue;

        final delta = b2.position - b1.position;
        final dist = delta.distance;
        if (dist < ballRadius * 2) {
          final overlap = ballRadius * 2 - dist;
          final mtd = delta * (overlap / dist);
          b1.position -= mtd * 0.5;
          b2.position += mtd * 0.5;

          final normal = delta / dist;
          final relativeVelocity = b1.velocity - b2.velocity;
          final velocityAlongNormal = relativeVelocity.dx * normal.dx + relativeVelocity.dy * normal.dy;

          if (velocityAlongNormal > 0) {
            final impulse = velocityAlongNormal * 0.9;
            final impulseVec = normal * impulse;
            b1.velocity -= impulseVec;
            b2.velocity += impulseVec;
          }
        }
      }
    }

    if (!anyMoving) {
      _stopSimulation();
    }
    setState(() {});
  }

  bool _checkPocket(Offset pos) {
    final pockets = [
      const Offset(0, 0), const Offset(tableWidth, 0),
      const Offset(0, tableHeight), const Offset(tableWidth, tableHeight),
      const Offset(tableWidth / 2, 0), const Offset(tableWidth / 2, tableHeight)
    ];
    for (var pocket in pockets) {
      if ((pos - pocket).distance < 32) return true;
    }
    return false;
  }

  void _handleBallPocketed(BilliardBall ball) {
    if (ball.type == BallType.cue) {
      _isFoulThisTurn = true;
    } else if (ball.type == BallType.eight) {
      _eightBallPocketedThisTurn = true;
    } else {
      _pocketedBallsThisTurn.add(ball);
    }
  }

  bool _isFoulThisTurn = false;
  bool _eightBallPocketedThisTurn = false;
  List<BilliardBall> _pocketedBallsThisTurn = [];

  void _shoot() {
    if (_isSimulating || _isFreeBallMode) return;
    
    setState(() {
      _isSimulating = true;
      _isFoulThisTurn = false;
      _eightBallPocketedThisTurn = false;
      _pocketedBallsThisTurn = [];
      
      final cueBall = _balls.firstWhere((b) => b.type == BallType.cue);
      final shotVelocity = Offset(math.cos(_direction), math.sin(_direction)) * (_power * 35);
      cueBall.velocity = shotVelocity;
      _gameStatusMessage = "比賽進行中...";
    });
    _ticker.start();
  }

  void _stopSimulation() {
    _ticker.stop();
    _processTurnResults();
  }

  void _processTurnResults() {
    bool groupJustAssigned = false;
    bool switchTurn = true;
    String message = "";

    final cueBall = _balls.firstWhere((b) => b.type == BallType.cue);

    // 1. Check Foul (Cue Ball Scratch)
    if (_isFoulThisTurn) {
      _isFreeBallMode = true;
      cueBall.isInPocket = false;
      cueBall.position = const Offset(200, 200); 
      cueBall.velocity = Offset.zero;

      if (_eightBallPocketedThisTurn) {
        message = "8 號球與母球同時入袋！玩家 $_activePlayer 輸了";
        _phase = GamePhase.gameOver;
      } else {
        message = "犯規：母球落袋！對手獲得自由球";
      }
      switchTurn = true;
    } 
    // 2. Check 8-Ball
    else if (_eightBallPocketedThisTurn) {
      bool hasClearedGroup = _checkIfGroupCleared(_activePlayer);
      if (hasClearedGroup) {
        message = "恭喜！玩家 $_activePlayer 將黑 8 擊入袋，博得勝利！";
        _phase = GamePhase.gameOver;
      } else {
        message = "判負：清光子球前黑 8 提前入袋！玩家 $_activePlayer 輸了";
        _phase = GamePhase.gameOver;
      }
      switchTurn = false;
    }
    // 3. Regular Ball Pocketed
    else if (_pocketedBallsThisTurn.isNotEmpty) {
      if (_phase == GamePhase.openTable) {
        final firstBall = _pocketedBallsThisTurn.first;
        _playerGroups[_activePlayer] = firstBall.type;
        _playerGroups[_activePlayer == 1 ? 2 : 1] = (firstBall.type == BallType.solid ? BallType.stripe : BallType.solid);
        _phase = GamePhase.groupAssigned;
        groupJustAssigned = true;
        message = "分組確定：玩家 $_activePlayer 是 ${firstBall.type == BallType.solid ? '小花' : '大花'}";
      }

      bool pocketedOwnGroup = false;
      for (var b in _pocketedBallsThisTurn) {
        if (b.type == _playerGroups[_activePlayer]) pocketedOwnGroup = true;
      }

      if (pocketedOwnGroup || groupJustAssigned) {
        switchTurn = false;
        if (message.isEmpty) message = "好球！持續進攻中";
      } else {
        message = "進了對方的球。換人打擊";
      }
    } else {
      message = "沒進球。交換回合";
    }

    setState(() {
      if (_phase != GamePhase.gameOver) {
        if (switchTurn) _activePlayer = (_activePlayer == 1 ? 2 : 1);
        _gameStatusMessage = message;
      } else {
        _gameStatusMessage = "遊戲結束";
        // Calculate winner
        String winner = "P1";
        if (_isFoulThisTurn && _eightBallPocketedThisTurn) {
          // Foul scratch on 8-ball
          winner = _activePlayer == 1 ? "P2" : "P1";
        } else if (_eightBallPocketedThisTurn) {
          bool hasClearedGroup = _checkIfGroupCleared(_activePlayer);
          if (hasClearedGroup) {
            winner = _activePlayer == 1 ? "P1" : "P2";
          } else {
            // Early 8-ball pocketed
            winner = _activePlayer == 1 ? "P2" : "P1";
          }
        }

        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => ResultPage(
                  result: GameResult(
                    outcome: GameOutcome.win, // 暫定贏家
                    winnerName: winner,
                    player1Score: 0,
                    player2Score: 0,
                    starsEarned: 3,
                    coinsEarned: 150,
                    duration: "05:00",
                  ),
                ),
              ),
            );
          }
        });
      }
      _isSimulating = false;
    });
  }

  bool _checkIfGroupCleared(int player) {
    BallType? group = _playerGroups[player];
    if (group == null) return false;
    return !_balls.any((b) => !b.isInPocket && b.type == group);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MangaColors.background,
      body: Stack(
        children: [
          _buildBackgroundDecor(),
          Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: 1280,
                height: 720,
                child: Stack(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 80),
                        child: _buildTable(context),
                      ),
                    ),
                    Positioned(left: 110, top: 100, bottom: 180, child: _buildPowerSlider()),
                    Positioned(right: 10, top: 80, bottom: 180, child: _buildInteractionCluster(context)),
                    Positioned(bottom: 20, left: 0, right: 0, child: Center(child: _buildBottomHUD())),
                    Positioned(top: 20, left: 0, right: 0, child: Center(child: _buildHeader())),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(top: 0, left: 0, bottom: 0, child: MangaSidebar()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: MangaStyle.mangaBoxDecoration(color: MangaColors.secondary, borderRadius: 99),
      child: Text(
        _gameStatusMessage,
        style: const TextStyle(fontWeight: FontWeight.w900, color: MangaColors.purple, fontSize: 16),
      ),
    );
  }

  Widget _buildBackgroundDecor() {
    return Stack(
      children: [
        Positioned(
          top: 40, left: 120,
          child: Opacity(
            opacity: 0.1,
            child: Text('BRAZIL', style: GoogleFonts.plusJakartaSans(fontSize: 120, fontWeight: FontWeight.w900, color: Colors.black)),
          ),
        ),
        Positioned(
          left: 0, top: 0, bottom: 0,
          child: Container(
            width: 8,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Color(0xFF009739), Color(0xFFFEDD00), Color(0xFF012169)],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTable(BuildContext context) {
    return Container(
      width: 820, height: 420,
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1B),
        borderRadius: BorderRadius.circular(45),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF009640),
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: Colors.black.withOpacity(0.3), width: 2),
        ),
        child: RepaintBoundary(
          child: GestureDetector(
            onTapDown: (details) {
              if (_isSimulating) return;
              
              // Compensate for 10px table padding offset
              final tappedPos = details.localPosition - const Offset(10, 10);
              BilliardBall? targetBall;
              double minSelectDist = 40.0;

              for (var ball in _balls) {
                if (ball.isInPocket) continue;
                final dist = (ball.position - tappedPos).distance;
                if (dist < minSelectDist) {
                  // If it's the cue ball, we don't aim at it
                  if (ball.type != BallType.cue) {
                    targetBall = ball;
                    break;
                  }
                }
              }

              if (targetBall != null) {
                // Aim logic
                final cueBall = _balls.firstWhere((b) => b.type == BallType.cue);
                setState(() {
                  _direction = math.atan2(targetBall!.position.dy - cueBall.position.dy, targetBall!.position.dx - cueBall.position.dx);
                });
              } else if (_isFreeBallMode) {
                // Move cue ball to empty spot
                setState(() {
                  final cueBall = _balls.firstWhere((b) => b.type == BallType.cue);
                  cueBall.position = Offset(tappedPos.dx.clamp(ballRadius, tableWidth - ballRadius), tappedPos.dy.clamp(ballRadius, tableHeight - ballRadius));
                });
              }
            },
            onPanUpdate: _isFreeBallMode ? (details) {
              setState(() {
                final tappedPos = details.localPosition - const Offset(10, 10);
                final cueBall = _balls.firstWhere((b) => b.type == BallType.cue);
                cueBall.position = Offset(tappedPos.dx.clamp(ballRadius, tableWidth - ballRadius), tappedPos.dy.clamp(ballRadius, tableHeight - ballRadius));
              });
            } : null,
            onPanEnd: _isFreeBallMode ? (details) => setState(() => _isFreeBallMode = false) : null,
            child: Stack(
              children: [
                ..._buildDiamonds(),
                ...[Alignment.topLeft, Alignment.topRight, Alignment.bottomLeft, Alignment.bottomRight, Alignment.topCenter, Alignment.bottomCenter].map((alignment) => Align(
                  alignment: alignment,
                  child: Container(width: 48, height: 48, decoration: const BoxDecoration(color: Color(0xFF0A0A0A), shape: BoxShape.circle)),
                )),
                Center(child: CustomPaint(size: const Size(800, 400), painter: PhysicsTablePainter(balls: _balls, direction: _direction, isSimulating: _isSimulating, isFreeBallMode: _isFreeBallMode))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDiamonds() {
    return [for (int i = 1; i < 4; i++) _diamondAt(Alignment(-1 + i * 0.5, -1.05)), for (int i = 1; i < 4; i++) _diamondAt(Alignment(-1 + i * 0.5, 1.05))];
  }

  Widget _diamondAt(Alignment alignment) {
    return Align(alignment: alignment, child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white54, shape: BoxShape.circle)));
  }

  Widget _buildPowerSlider() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onVerticalDragUpdate: (details) {
            setState(() {
              _power = (_power - details.primaryDelta! / 320).clamp(0.0, 1.0);
            });
          },
          child: Container(
            width: 56, height: 320,
            decoration: MangaStyle.mangaBoxDecoration(color: Colors.white.withOpacity(0.6), borderRadius: 99),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                FractionallySizedBox(
                  heightFactor: _power,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      gradient: const LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xFF4ADE80), Color(0xFF22C55E)]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildLabel('動力滑桿'),
      ],
    );
  }

  Widget _buildInteractionCluster(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildLabel('方向調整桿'),
          const SizedBox(height: 8),
          GestureDetector(
            onHorizontalDragUpdate: (details) {
              setState(() => _direction += details.primaryDelta! / 50);
            },
            child: Container(
              width: 180, height: 40,
              decoration: MangaStyle.mangaBoxDecoration(color: Colors.white, borderRadius: 99),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(width: 140, height: 4, color: MangaColors.surfaceContainer),
                  Transform.translate(
                    offset: Offset((math.sin(_direction) * 60).clamp(-70, 70), 0),
                    child: Container(width: 32, height: 32, decoration: MangaStyle.mangaBoxDecoration(color: MangaColors.secondary, borderRadius: 99, hasShadow: false), child: const Icon(Icons.unfold_more_rounded, color: MangaColors.purple, size: 20)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomHUD() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          width: 260,
          decoration: MangaStyle.mangaBoxDecoration(color: Colors.white, borderRadius: 20),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: MangaStyle.mangaBoxDecoration(color: MangaColors.secondary, borderRadius: 10, hasShadow: false),
                child: const Icon(Icons.person_rounded, color: MangaColors.purple, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('PLAYER $_activePlayer', style: const TextStyle(fontWeight: FontWeight.w900, color: MangaColors.purple, fontSize: 12)),
                    Text(_playerGroups[_activePlayer] == BallType.solid ? '群組：小花' : _playerGroups[_activePlayer] == BallType.stripe ? '群組：大花' : '尚未選球', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: MangaColors.secondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        GestureDetector(
          onTap: _isSimulating ? null : _shoot,
          child: Container(
            width: 80, height: 80,
            decoration: MangaStyle.mangaBoxDecoration(color: _isSimulating ? Colors.grey : MangaColors.yellow, borderRadius: 99),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bolt_rounded, color: MangaColors.purple, size: 32),
                Text('擊球!', style: TextStyle(fontWeight: FontWeight.w900, color: MangaColors.purple, fontSize: 14)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: MangaStyle.mangaBoxDecoration(color: MangaColors.purple, borderRadius: 8, hasShadow: false),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10)),
    );
  }
}

class PhysicsTablePainter extends CustomPainter {
  final List<BilliardBall> balls;
  final double direction;
  final bool isSimulating;
  final bool isFreeBallMode;
  
  const PhysicsTablePainter({required this.balls, required this.direction, required this.isSimulating, required this.isFreeBallMode});

  @override
  void paint(Canvas canvas, Size size) {
    final ballRadius = 14.0;
    final ballOutlinePaint = Paint()..color = Colors.black45..style = PaintingStyle.stroke..strokeWidth = 1.5;

    for (var ball in balls) {
      if (ball.isInPocket) continue;

      canvas.drawCircle(ball.position + const Offset(2, 2), ballRadius, Paint()..color = Colors.black26);
      canvas.drawCircle(ball.position, ballRadius, Paint()..color = ball.color);
      canvas.drawCircle(ball.position, ballRadius, ballOutlinePaint);

      if (ball.type != BallType.cue) {
        canvas.drawCircle(ball.position, ballRadius * 0.5, Paint()..color = Colors.white);
        TextPainter(
          text: TextSpan(text: '${ball.id}', style: const TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)),
          textDirection: TextDirection.ltr,
        )..layout()..paint(canvas, ball.position - const Offset(4, 5));
      } else if (ball.type == BallType.cue) {
         _drawStar(canvas, ball.position, 6, Paint()..color = const Color(0xFF009640));
      }
      canvas.drawCircle(ball.position - const Offset(4, 4), 3, Paint()..color = Colors.white.withOpacity(0.3));
    }

    if (!isSimulating) {
      final cueBall = balls.firstWhere((b) => b.type == BallType.cue);
      _drawCueStick(canvas, cueBall.position, direction);
    }
    
    if (isFreeBallMode) {
       final cueBall = balls.firstWhere((b) => b.type == BallType.cue);
       final pulsePaint = Paint()..color = Colors.white.withOpacity(0.5)..style = PaintingStyle.stroke..strokeWidth = 2;
       canvas.drawCircle(cueBall.position, ballRadius + 5, pulsePaint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
        double angle = i * math.pi * 0.4 - math.pi / 2;
        path.lineTo(center.dx + math.cos(angle) * radius, center.dy + math.sin(angle) * radius);
        angle += math.pi * 0.2;
        path.lineTo(center.dx + math.cos(angle) * (radius * 0.4), center.dy + math.sin(angle) * (radius * 0.4));
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawCueStick(Canvas canvas, Offset cueBallPos, double angle) {
    final stickLength = 300.0;
    final stickWidthNear = 8.0;
    final stickWidthFar = 12.0;
    final gap = 20.0;

    canvas.save();
    canvas.translate(cueBallPos.dx, cueBallPos.dy);
    canvas.rotate(angle);

    final stickPath = Path()..moveTo(-gap, -stickWidthNear/2)..lineTo(-gap-stickLength, -stickWidthFar/2)..lineTo(-gap-stickLength, stickWidthFar/2)..lineTo(-gap, stickWidthNear/2)..close();
    final stickPaint = Paint()..shader = ui.Gradient.linear(Offset(-gap, 0), Offset(-gap-stickLength, 0), [const Color(0xFFD4A76A), const Color(0xFF4B2E1D)]);
    canvas.drawPath(stickPath, stickPaint);
    canvas.drawRect(Rect.fromLTWH(-gap-5, -stickWidthNear/2, 5, stickWidthNear), Paint()..color = const Color(0xFF64B5F6));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant PhysicsTablePainter oldDelegate) => true;
}
