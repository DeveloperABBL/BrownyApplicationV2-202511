import 'package:browny_applications_new/core/data/remote/models/response/introductions_response.dart';
import 'package:flutter/material.dart';

class IntroductionModel extends IntroductionsResponse {
  final String titleDisplay;
  final String suptitleDisplay;
  final Widget icon;

  IntroductionModel({
    required super.imageUrl,
    required this.titleDisplay,
    required this.suptitleDisplay,
    required this.icon,
  });

  @override
  String get imageUrl => super.imageUrl!;
}
