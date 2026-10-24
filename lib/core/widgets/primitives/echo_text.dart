import 'package:flutter/material.dart';
import '../../theme/app_typography.dart';

enum EchoTextStyleVariant {
  frequencyDisplay,
  displayLarge,
  titleLarge,
  titleMedium,
  heading,
  bodyLarge,
  bodyMedium,
  bodyMediumBold,
  labelLarge,
  labelMedium,
  labelBold,
  caption,
  captionBold,
  statDisplay,
  statLabel,
  cardTitle,
  sectionHeader,
}

class EchoText extends StatelessWidget {
  final String text;
  final EchoTextStyleVariant variant;
  final Color? color;
  final FontWeight? fontWeight;
  final double? fontSize;
  final double? letterSpacing;
  final double? height;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final String? semanticLabel;

  const EchoText(
    this.text, {
    super.key,
    this.variant = EchoTextStyleVariant.bodyMedium,
    this.color,
    this.fontWeight,
    this.fontSize,
    this.letterSpacing,
    this.height,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle style;
    switch (variant) {
      case EchoTextStyleVariant.frequencyDisplay:
        style = AppTypography.frequencyDisplay;
        break;
      case EchoTextStyleVariant.displayLarge:
        style = AppTypography.displayLarge;
        break;
      case EchoTextStyleVariant.titleLarge:
        style = AppTypography.titleLarge;
        break;
      case EchoTextStyleVariant.titleMedium:
        style = AppTypography.titleMedium;
        break;
      case EchoTextStyleVariant.heading:
        style = AppTypography.heading;
        break;
      case EchoTextStyleVariant.bodyLarge:
        style = AppTypography.bodyLarge;
        break;
      case EchoTextStyleVariant.bodyMedium:
        style = AppTypography.bodyMedium;
        break;
      case EchoTextStyleVariant.bodyMediumBold:
        style = AppTypography.bodyMediumBold;
        break;
      case EchoTextStyleVariant.labelLarge:
        style = AppTypography.labelLarge;
        break;
      case EchoTextStyleVariant.labelMedium:
        style = AppTypography.labelMedium;
        break;
      case EchoTextStyleVariant.labelBold:
        style = AppTypography.labelBold;
        break;
      case EchoTextStyleVariant.caption:
        style = AppTypography.caption;
        break;
      case EchoTextStyleVariant.captionBold:
        style = AppTypography.captionBold;
        break;
      case EchoTextStyleVariant.statDisplay:
        style = AppTypography.statDisplay;
        break;
      case EchoTextStyleVariant.statLabel:
        style = AppTypography.statLabel;
        break;
      case EchoTextStyleVariant.cardTitle:
        style = AppTypography.cardTitle;
        break;
      case EchoTextStyleVariant.sectionHeader:
        style = AppTypography.sectionHeader;
        break;
    }

    if (color != null ||
        fontWeight != null ||
        fontSize != null ||
        letterSpacing != null ||
        height != null) {
      style = style.copyWith(
        color: color,
        fontWeight: fontWeight,
        fontSize: fontSize,
        letterSpacing: letterSpacing,
        height: height,
      );
    }

    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      semanticsLabel: semanticLabel,
    );
  }
}
