import 'dart:ui';

class SettingItems {
  final String title;
  final String? trailingText;
  final VoidCallback? onTap;

  SettingItems({this.onTap, required this.title, this.trailingText});

  factory SettingItems.fromJson(Map<String, dynamic> json) {
    return SettingItems(
      title: json['title'],
      trailingText: json['trailingText'],
    );
  }
}
