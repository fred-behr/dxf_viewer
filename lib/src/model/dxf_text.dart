import 'package:flutter/material.dart';
import 'xyz.dart';
import '../sections/blocks.dart';
import '../dxf.dart';

class DxfText extends DxfXyz {
  String _textString = '';
  double _textHeight = 3;

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

  DxfText.init(super.codes) : super.init();

  factory DxfText.from(List<Code> codes) {
    final entity = DxfText.init(codes);
    entity.setCodes(codes);
    entity._textString = entity.getCode(1);
    entity._textHeight = entity.getCode(40);
    return entity;
  }

  DxfText(
    DXF dxf, {
    String layerName = '0',
    double x = 0,
    double y = 0,
    double z = 0,
    String textString = '',
    double textHeight = 3,
  })  : _textString = textString,
        _textHeight = textHeight,
        super(dxf, 'TEXT', layerName, 'AcDbText', x, y, z, [
          Code(40, textHeight),
          Code(1, textString),
          Code(100, 'AcDbText'),
        ]);
  @override
  void draw(BlocksSection blocks, Canvas canvas, Paint paint) {
    canvas.save();
    canvas.scale(1, -1);
    final TextPainter textPainter = TextPainter(
        text: TextSpan(
            text: _textString,
            style: TextStyle(
              color: Colors.black,
              fontSize: _textHeight * 1.5,
            )),
        textAlign: TextAlign.justify,
        textDirection: TextDirection.ltr)
      ..layout();
    textPainter.paint(canvas, Offset(coord.x, -(coord.y + _textHeight)));
    canvas.restore();
  }
}
