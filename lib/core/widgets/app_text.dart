import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class AppText extends StatelessWidget {
  final String text;

  AppText(
    this.text, {
    this.style,
    super.key,
  });

  final TextStyle? style;

  final RegExp regExp = RegExp(r'(?<=\d)(?=\D)|(?=\d)(?<=\D)');
  final RegExp number = RegExp(r'\d');

  late final List<String> split = text.split(regExp);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: split
            .map(
              (e) => number.hasMatch(e)
                  ? TextSpan(
                      text: e,
                      style:
                          style?.merge(GoogleFonts.prompt()) ??
                          DefaultTextStyle.of(
                            context,
                          ).style.merge(GoogleFonts.prompt()),
                    )
                  : TextSpan(
                      text: e,
                      style: DefaultTextStyle.of(context).style.merge(style),
                    ),
            )
            .toList(),
      ),
    );
  }
}
