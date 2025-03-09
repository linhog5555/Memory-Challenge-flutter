import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(MemoryGame());
}

class MemoryGame extends StatelessWidget {
  const MemoryGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MemoryGameScreen(),
    );
  }
}

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  _MemoryGameScreenState createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  final List<String> _emojis = ['🍎', '🍌', '🍇', '🍉', '🍓', '🥝', '🍍', '🥑'];
  List<String> _gameBoard = [];
  List<bool> _revealed = [];
  int? _firstIndex;
  int? _secondIndex;
  bool _canTap = true;

  DateTime? _startTime;
  double _elapsedSeconds = 0.0;
  Timer? _timer;
  bool _timerStarted = false;

  int _clickCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initializeGame() {
    _gameBoard = [..._emojis, ..._emojis];
    _gameBoard.shuffle();
    _revealed = List.filled(_gameBoard.length, false);
    _firstIndex = null;
    _secondIndex = null;
    _canTap = true;
    _clickCount = 0;
    _elapsedSeconds = 0.0;
    _timerStarted = false;
    _timer?.cancel();
    setState(() {});
  }

  void _startTimer() {
    _startTime = DateTime.now();
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        _elapsedSeconds =
            DateTime.now().difference(_startTime!).inMilliseconds / 1000;
      });
    });
  }

  void _onCardTap(int index) {
    if (!_canTap || _revealed[index]) return;

    // 第一次點擊時啟動計時器
    if (!_timerStarted) {
      _startTimer();
      _timerStarted = true;
    }

    // 累計點擊次數
    _clickCount++;

    setState(() {
      if (_firstIndex == null) {
        _firstIndex = index;
      } else if (_secondIndex == null) {
        _secondIndex = index;
        _canTap = false;

        if (_gameBoard[_firstIndex!] == _gameBoard[_secondIndex!]) {
          _revealed[_firstIndex!] = true;
          _revealed[_secondIndex!] = true;
          _resetSelection();

          // 當所有牌皆被翻開時，遊戲結束
          if (_revealed.every((element) => element)) {
            _timer?.cancel();
            _showGameCompletedDialog();
          }
        } else {
          Timer(Duration(seconds: 1), () {
            _resetSelection();
          });
        }
      }
    });
  }

  void _resetSelection() {
    setState(() {
      _firstIndex = null;
      _secondIndex = null;
      _canTap = true;
    });
  }

  void _showGameCompletedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('遊戲完成！'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('花費時間：${_elapsedSeconds.toStringAsFixed(1)} 秒'),
            SizedBox(height: 8),
            Text('總點擊次數：$_clickCount 次'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _initializeGame();
            },
            child: Text('重新開始遊戲'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Memory Challenge'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            tooltip: '重新開始遊戲',
            icon: Icon(Icons.refresh),
            onPressed: _initializeGame,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade200, Colors.deepPurple.shade500],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // 標題、計時器與點擊次數顯示區
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Memory Challenge',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Time: ${_elapsedSeconds.toStringAsFixed(1)} s',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      Text(
                        'Clicks: $_clickCount',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ],
                  )
                ],
              ),
            ),
            // 遊戲卡片網格
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _gameBoard.length,
                itemBuilder: (context, index) {
                  bool isFaceUp =
                      _revealed[index] || index == _firstIndex || index == _secondIndex;
                  return GestureDetector(
                    onTap: () => _onCardTap(index),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: isFaceUp ? Colors.white : Colors.deepPurple,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            offset: Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          isFaceUp ? _gameBoard[index] : '',
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: '重新開始遊戲',
        backgroundColor: Colors.deepPurple,
        onPressed: _initializeGame,
        child: Icon(Icons.refresh),
      ),
    );
  }
}
