import 'package:chart_app/src/models/chart_config.dart';
import 'package:chart_app/src/models/chart_feed.dart';
import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';

/// Gets the data series
DataSeries<Tick> getDataSeries(
    ChartFeedModel feedModel, ChartConfigModel configModel) {
  final List<Tick> ticks = feedModel.ticks;
  final double opacity = configModel.isSymbolClosed ? 0.32 : 1;

  if (ticks is List<Candle>) {
    final CandleStyle? style = configModel.theme is ChartDefaultLightTheme
        ? CandleStyle(
            positiveColor: Color.fromRGBO(76, 175, 79, opacity),
            negativeColor: Color.fromRGBO(249, 83, 83, opacity),
            neutralColor: Color.fromRGBO(62, 62, 62, opacity),
          )
        : CandleStyle(
            positiveColor: Color.fromRGBO(0, 167, 159, opacity),
            negativeColor: Color.fromRGBO(204, 46, 62, opacity),
            neutralColor: Color.fromRGBO(110, 110, 110, opacity),
          );

    switch (configModel.style) {
      case ChartStyle.candles:
        return CandleSeries(ticks, style: style);
      case ChartStyle.hollow:
        return HollowCandleSeries(ticks, style: style);
      case ChartStyle.ohlc:
        return OhlcCandleSeries(ticks, style: style);
      default:
        break;
    }
  }
  return LineSeries(
    ticks,
    style: LineStyle(
      color: Color.fromRGBO(133, 172, 176, opacity),
      hasArea: true,
    ),
  );
}