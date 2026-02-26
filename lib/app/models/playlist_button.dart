import 'dart:convert';

import 'package:flutter/material.dart';

class PlaylistButton {
  const PlaylistButton({
    required this.id,
    required this.label,
    required this.spotifyUri,
    required this.baseColorValue,
  });

  final String id;
  final String label;
  final String spotifyUri;
  final int baseColorValue;

  Color get baseColor => Color(baseColorValue);

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'spotifyUri': spotifyUri,
        'baseColorValue': baseColorValue,
      };

  factory PlaylistButton.fromJson(Map<String, dynamic> json) => PlaylistButton(
        id: json['id'] as String,
        label: json['label'] as String,
        spotifyUri: json['spotifyUri'] as String,
        baseColorValue: json['baseColorValue'] as int,
      );

  static String encodeList(List<PlaylistButton> items) =>
      jsonEncode(items.map((item) => item.toJson()).toList());

  static List<PlaylistButton> decodeList(String raw) {
    final parsed = jsonDecode(raw) as List<dynamic>;
    return parsed
        .map((item) => PlaylistButton.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
