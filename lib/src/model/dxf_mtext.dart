import 'package:flutter/material.dart';
import 'xyz.dart';
import '../sections/blocks.dart';
import '../dxf.dart';

class DxfMText extends DxfXyz {
  String _textString = '';
  double _textHeight = 3;
  double _columnWidth = 20;

  String get textString => _textString;
  set textString(String value) {
    setCode(1, value);
    _textString = value;
  }

  double get textHeight => _textHeight;
  set textHeight(double value) {
    setCode(40, value);
    _textHeight = value;
  }

  double get columnWidth => _columnWidth;
  set columnWidth(double value) {
    setCode(41, value);
    _columnWidth = value;
  }

  DxfMText.init(super.codes) : super.init();

  factory DxfMText.from(List<Code> codes) {
    var entity = DxfMText.init(codes);
    entity.setCodes(codes);
    entity._textString = entity.getCode(1);
    entity._textHeight = entity.getCode(40);
    entity._columnWidth = entity.getCode(41);
    return entity;
  }

  DxfMText(
    DXF dxf, {
    String layerName = '0',
    double x = 0,
    double y = 0,
    double z = 0,
    String textString = '',
    double textHeight = 3,
    double columnWidth = 20.0,
  })  : _textString = textString,
        _textHeight = textHeight,
        _columnWidth = columnWidth,
        super(dxf, 'MTEXT', layerName, 'AcDbMText', x, y, z, [
          Code(40, textHeight),
          Code(41, columnWidth),
          Code(46, 0.0),
          Code(71, 1),
          Code(72, 5),
          Code(1, '{\\fArial|b0|i0|c163|p34;$textString}'),
          Code(73, 1),
          Code(44, 1.0),
          Code(1001, 'ACAD')
        ]);


  @override
  void draw(BlocksSection blocks, Canvas canvas, Paint paint) {
    var displayText = _textString
        .replaceAll(RegExp(r'\\f[^;]*;'), '')
        .replaceAll(RegExp(r'\\[WwTt][^;]*;'), '')
        .replaceAll(RegExp(r'\\[OoLlKk]'), '')
        .replaceAll(r'\P', '\n')
        .replaceAll(r'\~', ' ')
        .replaceAll('{', '')
        .replaceAll('}', '');

    // Read paragraph alignment before removing formatting codes.
    var textAlign = TextAlign.left;

    if (RegExp(r'\\pxqc;').hasMatch(_textString)) {
      textAlign = TextAlign.center;
    } else if (RegExp(r'\\pxqr;').hasMatch(_textString)) {
      textAlign = TextAlign.right;
    }

    displayText =
        displayText.replaceAll(RegExp(r'\\pxq[clr];'), '');

    if (displayText.trim().isEmpty) return;

    final attachment = (getCode(71) as num?)?.toInt() ?? 1;

    final boxWidth = _columnWidth > 0
        ? _columnWidth
        : double.infinity;

    canvas.save();
    canvas.scale(1, -1);

    final textPainter = TextPainter(
      text: TextSpan(
        text: displayText,
        style: TextStyle(
          color: Colors.black,
          fontSize: _textHeight * 1.5,
        ),
      ),
      textAlign: textAlign,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: boxWidth);

    // DXF attachment codes:
    // 1-3 = top, 4-6 = middle, 7-9 = bottom.
    // Columns are left, center, right.
    final horizontal = (attachment - 1) % 3;
    final vertical = (attachment - 1) ~/ 3;

    // Position the layout box relative to its DXF insertion point.
    final dx = switch (horizontal) {
      1 => -textPainter.width / 2,
      2 => -textPainter.width,
      _ => 0.0,
    };

    // TextPainter's origin is its top edge. The canvas is Y-flipped,
    // so the vertical offset must be converted to DXF coordinates.
    final dy = switch (vertical) {
      1 => textPainter.height / 2,
      2 => textPainter.height,
      _ => 0.0,
    };

    final northOffset =
    (attachment >= 4 && attachment <= 6)
        ? _textHeight * 0.5
        : 0.0;

    textPainter.paint(
      canvas,
      Offset(
        coord.x + dx,
        -coord.y - _textHeight + dy - northOffset,
      ),
    );

    canvas.restore();
  }


}
