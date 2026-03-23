import 'package:flutter/material.dart';
import 'dart:math';

class Racer {
  final String id;
  String name;
  final String emoji;
  final Color color;
  
  double position;
  double speed;
  double baseSpeed;
  double acceleration;
  bool isFinished;
  int? finishRank;
  DateTime? finishTime;
  
  // Animal-specific traits
  final AnimalTrait trait;
  double burstEnergy; // For burst speed animals
  double fatigue; // For animals that tire
  bool isPaused; // For animals that pause occasionally
  double pauseTimer; // Track pause duration
  double lastBurstTime; // Cooldown for burst ability
  
  // Animation states
  double bounceOffset;
  double dustIntensity;
  double headBobAngle;
  double tailWagAngle;
  bool isJumping;
  double jumpHeight;
  double stretchFactor;
  
  Racer({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    AnimalTrait? trait,
    this.position = 0.0,
    this.speed = 0.0,
    this.baseSpeed = 0.0,
    this.acceleration = 0.0,
    this.isFinished = false,
    this.finishRank,
    this.finishTime,
    this.burstEnergy = 100.0,
    this.fatigue = 0.0,
    this.isPaused = false,
    this.pauseTimer = 0.0,
    this.lastBurstTime = 0.0,
    this.bounceOffset = 0.0,
    this.dustIntensity = 0.0,
    this.headBobAngle = 0.0,
    this.tailWagAngle = 0.0,
    this.isJumping = false,
    this.jumpHeight = 0.0,
    this.stretchFactor = 0.0,
  }) : trait = trait ?? AnimalTrait.steady;
  
  factory Racer.create({
    required String id,
    required String name,
    required String emoji,
    required Color color,
    AnimalTrait? trait,
  }) {
    final selectedTrait = trait ?? AnimalOptions.getTraitForEmoji(emoji);
    return Racer(
      id: id,
      name: name.isEmpty ? 'Thú $id' : name,
      emoji: emoji,
      color: color,
      trait: selectedTrait,
    );
  }
  
  void reset() {
    position = 0.0;
    speed = 0.0;
    acceleration = 0.0;
    isFinished = false;
    finishRank = null;
    finishTime = null;
    burstEnergy = 100.0;
    fatigue = 0.0;
    isPaused = false;
    pauseTimer = 0.0;
    lastBurstTime = 0.0;
    bounceOffset = 0.0;
    dustIntensity = 0.0;
    headBobAngle = 0.0;
    tailWagAngle = 0.0;
    isJumping = false;
    jumpHeight = 0.0;
    stretchFactor = 0.0;
  }
  
  void update(double deltaTime, double randomFactor) {
    if (isFinished) return;
    
    // Handle pause behavior
    if (isPaused) {
      pauseTimer -= deltaTime;
      if (pauseTimer <= 0) {
        isPaused = false;
      }
      return; // Don't move while paused
    }
    
    // Apply trait-specific behavior
    _applyTraitBehavior(deltaTime, randomFactor);
    
    // Update speed with bounds based on trait
    speed += acceleration * deltaTime;
    speed = speed.clamp(trait.minSpeed, trait.maxSpeed);
    
    // Update position
    position += speed * deltaTime;
    
    // Update bounce animation based on speed
    bounceOffset = sin(position * 20) * (speed * 3);
    
    // Update dust intensity based on speed
    dustIntensity = speed * 0.8;
    
    // Add head bobbing animation
    headBobAngle = sin(position * 30) * 0.15;
    
    // Add tail wagging animation (faster when speeding up)
    tailWagAngle = sin(position * 40) * (0.2 + speed * 0.3);
    
    // Random jump action when speed is high
    if (speed > trait.minSpeed + 0.01 && !isJumping && Random().nextDouble() < 0.003) {
      isJumping = true;
      jumpHeight = 0.5 + Random().nextDouble() * 0.5;
    }
    
    // Jump animation
    if (isJumping) {
      jumpHeight -= deltaTime * 1.5;
      if (jumpHeight <= 0) {
        jumpHeight = 0;
        isJumping = false;
      }
    }
    
    // Stretch effect when accelerating
    stretchFactor = acceleration * 0.5;
    
    // Check finish
    if (position >= 1.0 && !isFinished) {
      position = 1.0;
      isFinished = true;
      finishTime = DateTime.now();
    }
  }
  
  void _applyTraitBehavior(double deltaTime, double randomFactor) {
    lastBurstTime += deltaTime;
    
    switch (trait) {
      case AnimalTrait.burst:
        _handleBurstBehavior(deltaTime, randomFactor);
        break;
      case AnimalTrait.steady:
        _handleSteadyBehavior(deltaTime, randomFactor);
        break;
      case AnimalTrait.slowStart:
        _handleSlowStartBehavior(deltaTime, randomFactor);
        break;
      case AnimalTrait.eratic:
        _handleEraticBehavior(deltaTime, randomFactor);
        break;
      case AnimalTrait.tiring:
        _handleTiringBehavior(deltaTime, randomFactor);
        break;
      case AnimalTrait.paused:
        _handlePausedBehavior(deltaTime, randomFactor);
        break;
    }
  }
  
  void _handleBurstBehavior(double deltaTime, double randomFactor) {
    // Rabbit/Hare: Bursts of speed followed by rest
    if (burstEnergy > 0 && lastBurstTime > 3.0 && Random().nextDouble() < 0.02) {
      // Burst mode!
      acceleration = 0.8 + Random().nextDouble() * 0.4;
      burstEnergy -= deltaTime * 20;
      lastBurstTime = 0;
    } else if (burstEnergy <= 0) {
      // Resting to recover energy
      acceleration = -0.02 + randomFactor;
      burstEnergy += deltaTime * 15;
      if (burstEnergy > 100) burstEnergy = 100;
    } else {
      // Normal running
      acceleration = (Random().nextDouble() - 0.3) * 0.5 + randomFactor;
    }
  }
  
  void _handleSteadyBehavior(double deltaTime, double randomFactor) {
    // Horse/Dog: Consistent pace with minor variations
    acceleration = (Random().nextDouble() - 0.2) * 0.3 + randomFactor * 0.5;
    // Maintain steady speed
    if (speed < baseSpeed * 0.9) {
      acceleration += 0.1;
    } else if (speed > baseSpeed * 1.1) {
      acceleration -= 0.1;
    }
  }
  
  void _handleSlowStartBehavior(double deltaTime, double randomFactor) {
    // Turtle/Cat: Starts slow but gets faster over time
    double progressBonus = position * 0.08; // Gets 8% faster as race progresses
    acceleration = (Random().nextDouble() - 0.3) * 0.5 + randomFactor + progressBonus;
    
    // Occasional sudden dash
    if (Random().nextDouble() < 0.01 && position > 0.3) {
      acceleration += 0.3;
    }
  }
  
  void _handleEraticBehavior(double deltaTime, double randomFactor) {
    // Monkey/Fox: Unpredictable movements
    if (Random().nextDouble() < 0.03) {
      // Sudden stop or slowdown
      acceleration = -0.1;
    } else if (Random().nextDouble() < 0.05) {
      // Sudden burst
      acceleration = 0.6 + Random().nextDouble() * 0.3;
    } else {
      // Normal erratic movement
      acceleration = (Random().nextDouble() - 0.5) * 0.8 + randomFactor;
    }
  }
  
  void _handleTiringBehavior(double deltaTime, double randomFactor) {
    // Pig/Cow: Strong start but tires over time
    double tirednessFactor = 1.0 - (position * 0.6); // Loses 60% effectiveness
    acceleration = ((Random().nextDouble() - 0.3) * 0.5 + randomFactor) * tirednessFactor;
    
    // Fatigue accumulates
    fatigue += deltaTime * 0.1;
    if (fatigue > 1.0) fatigue = 1.0;
    
    // Occasional recovery moment
    if (Random().nextDouble() < 0.02) {
      fatigue -= 0.3;
      if (fatigue < 0) fatigue = 0;
      acceleration += 0.2; // Brief energy boost
    }
  }
  
  void _handlePausedBehavior(double deltaTime, double randomFactor) {
    // Cat/Independent animals: Random pauses
    if (!isPaused && Random().nextDouble() < 0.008) { // 0.8% chance per frame
      isPaused = true;
      pauseTimer = 0.5 + Random().nextDouble() * 1.0; // Pause for 0.5-1.5 seconds
    }
    
    if (!isPaused) {
      acceleration = (Random().nextDouble() - 0.25) * 0.6 + randomFactor;
      // When moving, moves faster to compensate
      acceleration *= 1.3;
    }
  }
  
  Racer copyWith({
    String? name,
    String? emoji,
    Color? color,
    AnimalTrait? trait,
  }) {
    return Racer(
      id: id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
      trait: trait ?? this.trait,
      position: position,
      speed: speed,
      baseSpeed: baseSpeed,
      acceleration: acceleration,
      isFinished: isFinished,
      finishRank: finishRank,
      finishTime: finishTime,
      burstEnergy: burstEnergy,
      fatigue: fatigue,
      isPaused: isPaused,
      pauseTimer: pauseTimer,
      lastBurstTime: lastBurstTime,
      bounceOffset: bounceOffset,
      dustIntensity: dustIntensity,
      headBobAngle: headBobAngle,
      tailWagAngle: tailWagAngle,
      isJumping: isJumping,
      jumpHeight: jumpHeight,
      stretchFactor: stretchFactor,
    );
  }
}

// Animal personality traits
enum AnimalTrait {
  burst,      // Rabbit: Fast bursts, then rests
  steady,     // Horse: Consistent pace
  slowStart,  // Turtle: Slow start, finishes strong
  eratic,     // Monkey: Unpredictable, sudden stops/starts
  tiring,     // Pig: Strong start, weak finish
  paused,     // Cat: Random pauses during race
}

// Trait configuration for each animal type
extension AnimalTraitExtension on AnimalTrait {
  double get minSpeed {
    switch (this) {
      case AnimalTrait.burst:
        return 0.025;
      case AnimalTrait.steady:
        return 0.035;
      case AnimalTrait.slowStart:
        return 0.028;
      case AnimalTrait.eratic:
        return 0.02;
      case AnimalTrait.tiring:
        return 0.03;
      case AnimalTrait.paused:
        return 0.032;
    }
  }
  
  double get maxSpeed {
    switch (this) {
      case AnimalTrait.burst:
        return 0.08; // Can reach very high speeds in bursts
      case AnimalTrait.steady:
        return 0.045;
      case AnimalTrait.slowStart:
        return 0.055; // Faster at the end
      case AnimalTrait.eratic:
        return 0.07; // High peaks but inconsistent
      case AnimalTrait.tiring:
        return 0.05; // Starts fast, slows down
      case AnimalTrait.paused:
        return 0.05; // Fast when actually moving
    }
  }
}

// Available animal options with unique traits
class AnimalOptions {
  static const List<Map<String, dynamic>> animals = [
    {'emoji': '🐷', 'name': 'Heo', 'color': Color(0xFFFFB6C1), 'trait': AnimalTrait.tiring},
    {'emoji': '🐔', 'name': 'Gà', 'color': Color(0xFFFFD700), 'trait': AnimalTrait.eratic},
    {'emoji': '🐶', 'name': 'Chó', 'color': Color(0xFFD2691E), 'trait': AnimalTrait.steady},
    {'emoji': '🐱', 'name': 'Mèo', 'color': Color(0xFFFFA500), 'trait': AnimalTrait.paused},
    {'emoji': '🐰', 'name': 'Thỏ', 'color': Color(0xFFFFFFFF), 'trait': AnimalTrait.burst},
    {'emoji': '🐸', 'name': 'Ếch', 'color': Color(0xFF32CD32), 'trait': AnimalTrait.slowStart},
    {'emoji': '🐯', 'name': 'Hổ', 'color': Color(0xFFFF8C00), 'trait': AnimalTrait.burst},
    {'emoji': '🐮', 'name': 'Bò', 'color': Color(0xFF8B4513), 'trait': AnimalTrait.tiring},
    {'emoji': '🐹', 'name': 'Hamster', 'color': Color(0xFFDDA0DD), 'trait': AnimalTrait.eratic},
    {'emoji': '🦊', 'name': 'Cáo', 'color': Color(0xFFFF6347), 'trait': AnimalTrait.slowStart},
    {'emoji': '🐼', 'name': 'Gấu Trúc', 'color': Color(0xFFFFFFFF), 'trait': AnimalTrait.steady},
    {'emoji': '🦁', 'name': 'Sư Tử', 'color': Color(0xFFFFA500), 'trait': AnimalTrait.steady},
  ];
  
  static List<Map<String, dynamic>> getAnimals(int count) {
    final random = Random();
    final selected = <Map<String, dynamic>>[];
    final available = List<Map<String, dynamic>>.from(animals);
    
    for (int i = 0; i < count && available.isNotEmpty; i++) {
      final index = random.nextInt(available.length);
      selected.add(available.removeAt(index));
    }
    
    return selected;
  }
  
  // Get trait for a specific animal emoji
  static AnimalTrait getTraitForEmoji(String emoji) {
    final animal = animals.firstWhere(
      (a) => a['emoji'] == emoji,
      orElse: () => {'trait': AnimalTrait.steady},
    );
    return animal['trait'] as AnimalTrait? ?? AnimalTrait.steady;
  }
}
