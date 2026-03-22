import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/racer.dart';

enum RacingState {
  setup,      // Configuring racers
  countdown,  // 3-2-1 countdown
  racing,     // Race in progress
  finished,   // Race completed
}

class AnimalRacingViewModel extends ChangeNotifier {
  // Configuration
  int _racerCount = 4;
  int get racerCount => _racerCount;
  
  final List<Racer> _racers = [];
  List<Racer> get racers => List.unmodifiable(_racers);
  
  // Racing state
  RacingState _state = RacingState.setup;
  RacingState get state => _state;
  
  int _countdownValue = 3;
  int get countdownValue => _countdownValue;
  
  int _finishedCount = 0;
  int get finishedCount => _finishedCount;
  
  // Animation
  Timer? _gameTimer;
  final Stopwatch _raceStopwatch = Stopwatch();
  
  // Results
  List<Racer> _results = [];
  List<Racer> get results => List.unmodifiable(_results);
  
  Racer? get winner => _results.isNotEmpty ? _results.first : null;
  
  // History
  final List<Map<String, dynamic>> _history = [];
  List<Map<String, dynamic>> get history => List.unmodifiable(_history);
  
  AnimalRacingViewModel() {
    _initializeRacers();
  }
  
  void _initializeRacers() {
    _racers.clear();
    final animals = AnimalOptions.getAnimals(_racerCount);
    
    for (int i = 0; i < _racerCount; i++) {
      final animal = animals[i];
      _racers.add(Racer.create(
        id: 'racer_$i',
        name: animal['name'] as String,
        emoji: animal['emoji'] as String,
        color: animal['color'] as Color,
        trait: animal['trait'] as AnimalTrait?,
      ));
    }
    notifyListeners();
  }
  
  void setRacerCount(int count) {
    if (count < 2 || count > 8) return;
    if (count == _racerCount) return;
    
    _racerCount = count;
    _initializeRacers();
  }
  
  void updateRacerName(int index, String name) {
    if (index < 0 || index >= _racers.length) return;
    _racers[index].name = name.isEmpty ? 'Thú ${index + 1}' : name;
    notifyListeners();
  }
  
  void updateRacerEmoji(int index, String emoji, Color color) {
    if (index < 0 || index >= _racers.length) return;
    final trait = AnimalOptions.getTraitForEmoji(emoji);
    _racers[index] = _racers[index].copyWith(
      emoji: emoji,
      color: color,
      trait: trait,
    );
    notifyListeners();
  }
  
  void shuffleRacers() {
    final animals = AnimalOptions.getAnimals(_racerCount);
    for (int i = 0; i < _racers.length && i < animals.length; i++) {
      _racers[i] = _racers[i].copyWith(
        emoji: animals[i]['emoji'] as String,
        color: animals[i]['color'] as Color,
      );
    }
    notifyListeners();
  }
  
  void startCountdown() {
    if (_state != RacingState.setup) return;
    
    _state = RacingState.countdown;
    _countdownValue = 3;
    notifyListeners();
    
    // Countdown timer
    Timer.periodic(const Duration(seconds: 1), (timer) {
      _countdownValue--;
      notifyListeners();
      
      if (_countdownValue <= 0) {
        timer.cancel();
        _startRace();
      }
    });
  }
  
  void _startRace() {
    _state = RacingState.racing;
    _finishedCount = 0;
    _results = [];
    _raceStopwatch.reset();
    _raceStopwatch.start();
    
    // Reset all racers
    for (final racer in _racers) {
      racer.reset();
      // Give each racer a random base speed (adjusted for 25-30s race)
      racer.baseSpeed = 0.035 + Random().nextDouble() * 0.01; // Range: 0.035-0.045
    }
    
    notifyListeners();
    
    // Game loop - 60 FPS
    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      _updateRace();
    });
  }
  
  void _updateRace() {
    final deltaTime = 0.016; // ~60 FPS
    bool allFinished = true;
    
    for (final racer in _racers) {
      if (!racer.isFinished) {
        allFinished = false;
        // Random factor makes race unpredictable
        final randomFactor = Random().nextDouble() * 0.1 - 0.02;
        racer.update(deltaTime, randomFactor);
        
        if (racer.isFinished && racer.finishRank == null) {
          _finishedCount++;
          racer.finishRank = _finishedCount;
          _results.add(racer);
        }
      }
    }
    
    notifyListeners();
    
    if (allFinished) {
      _finishRace();
    }
  }
  
  void _finishRace() {
    _gameTimer?.cancel();
    _gameTimer = null;
    _raceStopwatch.stop();
    _state = RacingState.finished;
    
    // Add to history
    if (_results.isNotEmpty) {
      _history.insert(0, {
        'timestamp': DateTime.now(),
        'winner': _results.first.name,
        'winnerEmoji': _results.first.emoji,
        'racers': _racers.map((r) => {
          'name': r.name,
          'emoji': r.emoji,
          'rank': r.finishRank,
        }).toList(),
      });
    }
    
    notifyListeners();
  }
  
  void resetRace() {
    _gameTimer?.cancel();
    _gameTimer = null;
    _raceStopwatch.reset();
    _state = RacingState.setup;
    _countdownValue = 3;
    _finishedCount = 0;
    _results = [];
    
    for (final racer in _racers) {
      racer.reset();
    }
    
    notifyListeners();
  }
  
  void clearHistory() {
    _history.clear();
    notifyListeners();
  }
  
  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }
}
