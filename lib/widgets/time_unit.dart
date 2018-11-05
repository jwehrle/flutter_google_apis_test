import 'package:flutter/material.dart';

class TimeBoxMaker {
  List<double> _stops;
  Color _color;

  TimeBoxMaker.from(this._stops, this._color);

  Widget build() {
    return Container(
      width: 76,
      height: 48,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [const Color(0xFFFFFFFF), _color],
              stops: _stops)),
    );
  }
}
