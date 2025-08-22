// MODELS/TILE.DART:
import 'package:flutter/material.dart';

class Tile {
  final int id;
  final String? assetPath;
  final IconData fallbackIcon;
  final bool isFlipped;
  final bool isMatched;
  final bool isHinted;

  const Tile({
    required this.id,
    this.assetPath,
    required this.fallbackIcon,
    this.isFlipped = false,
    this.isMatched = false,
    this.isHinted = false,
  });

  Tile copyWith({
    int? id,
    String? assetPath,
    IconData? fallbackIcon,
    bool? isFlipped,
    bool? isMatched,
    bool? isHinted,
  }) {
    return Tile(
      id: id ?? this.id,
      assetPath: assetPath ?? this.assetPath,
      fallbackIcon: fallbackIcon ?? this.fallbackIcon,
      isFlipped: isFlipped ?? this.isFlipped,
      isMatched: isMatched ?? this.isMatched,
      isHinted: isHinted ?? this.isHinted,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Tile &&
        other.id == id &&
        other.assetPath == assetPath &&
        other.fallbackIcon == fallbackIcon &&
        other.isFlipped == isFlipped &&
        other.isMatched == isMatched &&
        other.isHinted == isHinted;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      assetPath,
      fallbackIcon,
      isFlipped,
      isMatched,
      isHinted,
    );
  }

  @override
  String toString() {
    return 'Tile(id: $id, assetPath: $assetPath, fallbackIcon: $fallbackIcon, '
        'isFlipped: $isFlipped, isMatched: $isMatched, isHinted: $isHinted)';
  }
}
