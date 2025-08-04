import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const SnakeGame());
}

class SnakeGame extends StatelessWidget {
  const SnakeGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Game',
      debugShowCheckedModeBanner: false,
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

enum Direction { up, down, left, right }

class _GameScreenState extends State<GameScreen> {
  static const int rowCount = 20;
  static const int colCount = 20;

  List<Point<int>> snake = [const Point(10, 10)];
  Point<int> food = const Point(5, 5);
  Direction direction = Direction.right;
  Timer? timer;
  int speed = 300; // milliseconds
  int score = 0;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    timer = Timer.periodic(Duration(milliseconds: speed), (Timer timer) {
      setState(() {
        moveSnake();
      });
    });
  }

  void moveSnake() {
    Point<int> newHead = getNewHead();

    // Game Over Conditions
    if (newHead.x < 0 ||
        newHead.y < 0 ||
        newHead.x >= colCount ||
        newHead.y >= rowCount ||
        snake.contains(newHead)) {
      timer?.cancel();
      showGameOverDialog();
      return;
    }

    snake.insert(0, newHead);
    if (newHead == food) {
      score++;
      if (speed > 100) {
        speed -= 20;
        restartTimer();
      }
      generateNewFood();
    } else {
      snake.removeLast();
    }
  }

  void restartTimer() {
    timer?.cancel();
    timer = Timer.periodic(Duration(milliseconds: speed), (Timer timer) {
      setState(() {
        moveSnake();
      });
    });
  }

  Point<int> getNewHead() {
    Point<int> head = snake.first;
    switch (direction) {
      case Direction.up:
        return Point(head.x, head.y - 1);
      case Direction.down:
        return Point(head.x, head.y + 1);
      case Direction.left:
        return Point(head.x - 1, head.y);
      case Direction.right:
        return Point(head.x + 1, head.y);
    }
  }

  void generateNewFood() {
    Random random = Random();
    Point<int> newFood;
    do {
      newFood = Point(random.nextInt(colCount), random.nextInt(rowCount));
    } while (snake.contains(newFood));
    food = newFood;
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Game Over"),
        content: Text("Score: $score"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              resetGame();
            },
            child: const Text("Restart"),
          ),
        ],
      ),
    );
  }

  void resetGame() {
    setState(() {
      snake = [const Point(10, 10)];
      direction = Direction.right;
      speed = 300;
      score = 0;
      generateNewFood();
      startGame();
    });
  }

  void onVerticalDragUpdate(DragUpdateDetails details) {
    if (details.delta.dy < 0 && direction != Direction.down) {
      direction = Direction.up;
    } else if (details.delta.dy > 0 && direction != Direction.up) {
      direction = Direction.down;
    }
  }

  void onHorizontalDragUpdate(DragUpdateDetails details) {
    if (details.delta.dx < 0 && direction != Direction.right) {
      direction = Direction.left;
    } else if (details.delta.dx > 0 && direction != Direction.left) {
      direction = Direction.right;
    }
  }

  Widget buildGrid() {
    List<Widget> gridCells = [];

    for (int y = 0; y < rowCount; y++) {
      for (int x = 0; x < colCount; x++) {
        Point<int> cell = Point(x, y);
        Color color;
        if (snake.first == cell) {
          color = Colors.green.shade900;
        } else if (snake.contains(cell)) {
          color = Colors.green;
        } else if (food == cell) {
          color = Colors.red;
        } else {
          color = Colors.grey.shade200;
        }

        gridCells.add(Container(
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ));
      }
    }

    return GridView.count(
      crossAxisCount: colCount,
      children: gridCells,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: GestureDetector(
          onVerticalDragUpdate: onVerticalDragUpdate,
          onHorizontalDragUpdate: onHorizontalDragUpdate,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Text(
                "Score: $score",
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: colCount / rowCount,
                    child: buildGrid(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
