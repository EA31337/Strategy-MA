//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_MA_EURUSD_M5_Params : Stg_MA_Params {
  Stg_MA_EURUSD_M5_Params() {
    symbol = "EURUSD";
    tf = PERIOD_M5;
    MA_Period = 2;
    MA_Applied_Price = 3;
    MA_Shift = 0;
    MA_TrailingStopMethod = 6;
    MA_TrailingProfitMethod = 11;
    MA_SignalOpenLevel = 36;
    MA_SignalBaseMethod = -61;
    MA_SignalOpenMethod1 = 1;
    MA_SignalOpenMethod2 = 0;
    MA_SignalCloseLevel = 36;
    MA_SignalCloseMethod1 = 1;
    MA_SignalCloseMethod2 = 0;
    MA_MaxSpread = 3;
  }
};
