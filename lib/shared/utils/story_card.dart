import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import '../../app/theme/app_palette.dart';
import '../domain/catalogue.dart';
import '../domain/program_terms.dart';
import 'native_share.dart';
import 'share_actions.dart';

/// Draws the 9:16 card a Facebook story is backed by.
///
/// A story cannot carry prefilled text, so everything worth saying — the
/// pitch, the code, the link — is painted into the picture itself. Cards are
/// always drawn in the light palette: a story lives on Facebook, not in the
/// member's theme.
abstract final class StoryCard {
  static const double _w = 1080;
  static const double _h = 1920;
  static const AppPalette _ink = AppPalette.light;

  /// The invite: brand mark, pitch, code and link. Null when drawing fails —
  /// the caller reports the share as failed rather than sending a blank.
  static Future<File?> renderInvite({required String referralCode}) =>
      _render((canvas) async {
        await _drawBrandMark(canvas, size: 300, top: 360);
        var y = _text(
          canvas,
          'Join me on',
          y: 740,
          size: 44,
          weight: 600,
          color: _ink.textMuted,
        );
        y = _text(
          canvas,
          'Falcon Crest Ventures',
          y: y + 8,
          size: 76,
          weight: 800,
          color: _ink.textPrimary,
        );
        y = _text(
          canvas,
          'Share wellness products and earn real money — '
          '${ProgramTerms.earnRate} of every order your friends make. '
          '${ProgramTerms.pointsConversion}.',
          y: y + 48,
          size: 40,
          weight: 500,
          color: _ink.textMuted,
        );
        _text(
          canvas,
          'USE MY REFERRAL CODE',
          y: y + 110,
          size: 34,
          weight: 800,
          color: _ink.accentDeep,
        );
        _codePill(canvas, referralCode, top: y + 180);
        _text(
          canvas,
          '${ShareActions.inviteLink(referralCode)}',
          y: y + 420,
          size: 34,
          weight: 600,
          color: _ink.accentText,
        );
      });

  /// One product: its photo, the price, and the code that credits the sender.
  static Future<File?> renderProduct({
    required Product product,
    required String referralCode,
  }) => _render((canvas) async {
    _text(
      canvas,
      'FALCON CREST VENTURES',
      y: 150,
      size: 34,
      weight: 800,
      color: _ink.accentDeep,
    );
    await _drawPhoto(canvas, product.imageUrl, left: 140, top: 260, size: 800);
    var y = _text(
      canvas,
      product.name,
      y: 1140,
      size: 68,
      weight: 800,
      color: _ink.textPrimary,
    );
    y = _text(
      canvas,
      '${product.price} · Earn ${product.pointsRange} pts per sale',
      y: y + 12,
      size: 44,
      weight: 700,
      color: _ink.accentText,
    );
    _text(
      canvas,
      'USE MY CODE WHEN YOU ORDER',
      y: y + 100,
      size: 34,
      weight: 800,
      color: _ink.accentDeep,
    );
    _codePill(canvas, referralCode, top: y + 170);
  });

  static Future<File?> _render(
    Future<void> Function(ui.Canvas canvas) draw,
  ) async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      canvas.drawRect(
        const ui.Rect.fromLTWH(0, 0, _w, _h),
        ui.Paint()..color = _ink.tint,
      );
      await draw(canvas);
      final image = await recorder.endRecording().toImage(
        _w.toInt(),
        _h.toInt(),
      );
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) return null;
      final file = File('${Directory.systemTemp.path}/story-card.png');
      await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
      return file;
    } catch (_) {
      return null;
    }
  }

  /// Draws centred [text] and returns the y where it ended, so the caller can
  /// stack the next line under whatever this one wrapped to.
  static double _text(
    ui.Canvas canvas,
    String text, {
    required double y,
    required double size,
    required double weight,
    required Color color,
  }) {
    const double width = 880;
    final builder =
        ui.ParagraphBuilder(
            ui.ParagraphStyle(
              textAlign: TextAlign.center,
              fontFamily: 'Figtree',
              fontSize: size,
            ),
          )
          ..pushStyle(
            ui.TextStyle(
              color: color,
              fontSize: size,
              fontFamily: 'Figtree',
              fontVariations: [ui.FontVariation('wght', weight)],
              height: 1.3,
            ),
          )
          ..addText(text);
    final paragraph = builder.build()
      ..layout(const ui.ParagraphConstraints(width: width));
    canvas.drawParagraph(
      paragraph,
      const ui.Offset((_w - width) / 2, 0).translate(0, y),
    );
    return y + paragraph.height;
  }

  /// The white pill the code sits in — the one element every referral story
  /// leads the eye to.
  static void _codePill(ui.Canvas canvas, String code, {required double top}) {
    const double width = 640;
    const double height = 170;
    canvas.drawRRect(
      ui.RRect.fromRectAndRadius(
        const ui.Rect.fromLTWH(
          (_w - width) / 2,
          0,
          width,
          height,
        ).translate(0, top),
        const ui.Radius.circular(999),
      ),
      ui.Paint()..color = _ink.surface,
    );
    _text(
      canvas,
      code,
      y: top + 40,
      size: 72,
      weight: 800,
      color: _ink.accentText,
    );
  }

  static Future<void> _drawBrandMark(
    ui.Canvas canvas, {
    required double size,
    required double top,
  }) async {
    final mark = await NativeShare.resolveImage(
      const AssetImage('assets/images/brand-mark.png'),
    );
    _drawCover(
      canvas,
      mark,
      ui.Rect.fromLTWH((_w - size) / 2, top, size, size),
    );
  }

  /// The product photo, centre-cropped square with softened corners. A photo
  /// that cannot be fetched simply leaves the tinted field — the card still
  /// carries the name, the price and the code.
  static Future<void> _drawPhoto(
    ui.Canvas canvas,
    String url, {
    required double left,
    required double top,
    required double size,
  }) async {
    final ui.Image photo;
    try {
      photo = await NativeShare.resolveImage(NetworkImage(url))
          .timeout(const Duration(seconds: 8));
    } catch (_) {
      return;
    }
    final rect = ui.Rect.fromLTWH(left, top, size, size);
    canvas.save();
    canvas.clipRRect(
      ui.RRect.fromRectAndRadius(rect, const ui.Radius.circular(56)),
    );
    _drawCover(canvas, photo, rect);
    canvas.restore();
  }

  /// Scales [image] to fill [rect], cropping the longer side evenly.
  static void _drawCover(ui.Canvas canvas, ui.Image image, ui.Rect rect) {
    final scale = (rect.width / image.width) > (rect.height / image.height)
        ? rect.width / image.width
        : rect.height / image.height;
    final srcWidth = rect.width / scale;
    final srcHeight = rect.height / scale;
    final src = ui.Rect.fromLTWH(
      (image.width - srcWidth) / 2,
      (image.height - srcHeight) / 2,
      srcWidth,
      srcHeight,
    );
    canvas.drawImageRect(
      image,
      src,
      rect,
      ui.Paint()..filterQuality = ui.FilterQuality.high,
    );
  }
}
