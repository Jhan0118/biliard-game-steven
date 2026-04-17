import 'package:equatable/equatable.dart';

enum GameOutcome { win, loss, draw }

class GameResult extends Equatable {
  final GameOutcome outcome;
  final String winnerName;
  final int player1Score;
  final int player2Score;
  final int starsEarned;
  final int coinsEarned;
  final String duration;

  const GameResult({
    required this.outcome,
    required this.winnerName,
    required this.player1Score,
    required this.player2Score,
    required this.starsEarned,
    required this.coinsEarned,
    this.duration = '05:00',
  });

  @override
  List<Object?> get props => [
        outcome,
        winnerName,
        player1Score,
        player2Score,
        starsEarned,
        coinsEarned,
        duration,
      ];
}
