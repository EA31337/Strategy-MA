//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/**
 * @file
 * Implements MA strategy based the Moving Average indicator.
 */

// Includes.
#include <EA31337-classes/Indicators/Indi_MA.mqh>
#include <EA31337-classes/Strategy.mqh>

// User input params.
INPUT string __MA_Parameters__ = "-- MA strategy params --";  // >>> MA <<<
INPUT int MA_Active_Tf = 5;          // Activate timeframes (1-255, e.g. M1=1,M5=2,M15=4,M30=8,H1=16,H2=32...)
INPUT int MA_Period_Fast = 12;       // Period Fast
INPUT int MA_Period_Medium = 12;     // Period Medium
INPUT int MA_Period_Slow = 4;        // Period Slow
INPUT int MA_Shift = 8;              // Shift
INPUT int MA_Shift_Fast = 10;        // Shift Fast (+1)
INPUT int MA_Shift_Medium = 10;      // Shift Medium (+1)
INPUT int MA_Shift_Slow = 5;         // Shift Slow (+1)
INPUT ENUM_MA_METHOD MA_Method = 1;  // MA Method
INPUT ENUM_APPLIED_PRICE MA_Applied_Price = 6;       // Applied Price
INPUT ENUM_TRAIL_TYPE MA_TrailingStopMethod = 23;    // Trail stop method
INPUT ENUM_TRAIL_TYPE MA_TrailingProfitMethod = 16;  // Trail profit method
INPUT double MA_SignalOpenLevel = -0.6;              // Signal open level
INPUT int MA1_SignalBaseMethod = 48;                 // Signal base method (-127-127)
INPUT int MA1_OpenCondition1 = 874;                  // Open condition 1 (0-1023)
INPUT int MA1_OpenCondition2 = 0;                    // Open condition 2 (0-1023)
INPUT ENUM_MARKET_EVENT MA1_CloseCondition = 24;     // Close condition for M1
INPUT double MA_MaxSpread = 6.0;                     // Max spread to trade (pips)

// Struct to define strategy parameters to override.
struct Stg_MA_Params : Stg_Params {
  unsigned int MA_Period;
  ENUM_APPLIED_PRICE MA_Applied_Price;
  int MA_Shift;
  ENUM_TRAIL_TYPE MA_TrailingStopMethod;
  ENUM_TRAIL_TYPE MA_TrailingProfitMethod;
  double MA_SignalOpenLevel;
  long MA_SignalBaseMethod;
  long MA_SignalOpenMethod1;
  long MA_SignalOpenMethod2;
  double MA_SignalCloseLevel;
  ENUM_MARKET_EVENT MA_SignalCloseMethod1;
  ENUM_MARKET_EVENT MA_SignalCloseMethod2;
  double MA_MaxSpread;

  // Constructor: Set default param values.
  Stg_MA_Params()
      : MA_Period(::MA_Period),
        MA_Applied_Price(::MA_Applied_Price),
        MA_Shift(::MA_Shift),
        MA_TrailingStopMethod(::MA_TrailingStopMethod),
        MA_TrailingProfitMethod(::MA_TrailingProfitMethod),
        MA_SignalOpenLevel(::MA_SignalOpenLevel),
        MA_SignalBaseMethod(::MA_SignalBaseMethod),
        MA_SignalOpenMethod1(::MA_SignalOpenMethod1),
        MA_SignalOpenMethod2(::MA_SignalOpenMethod2),
        MA_SignalCloseLevel(::MA_SignalCloseLevel),
        MA_SignalCloseMethod1(::MA_SignalCloseMethod1),
        MA_SignalCloseMethod2(::MA_SignalCloseMethod2),
        MA_MaxSpread(::MA_MaxSpread) {}
};

// Loads pair specific param values.
#include "sets/EURUSD_H1.h"
#include "sets/EURUSD_H4.h"
#include "sets/EURUSD_M1.h"
#include "sets/EURUSD_M15.h"
#include "sets/EURUSD_M30.h"
#include "sets/EURUSD_M5.h"

class Stg_MA : public Strategy {
 public:
  Stg_MA(StgParams &_params, string _name) : Strategy(_params, _name) {}

  static Stg_MA *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL, ENUM_LOG_LEVEL _log_level = V_INFO) {
    // Initialize strategy initial values.
    Stg_MA_Params _params;
    switch (_tf) {
      case PERIOD_M1: {
        Stg_MA_EURUSD_M1_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_M5: {
        Stg_MA_EURUSD_M5_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_M15: {
        Stg_MA_EURUSD_M15_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_M30: {
        Stg_MA_EURUSD_M30_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_H1: {
        Stg_MA_EURUSD_H1_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_H4: {
        Stg_MA_EURUSD_H4_Params _new_params;
        _params = _new_params;
      }
    }
    // Initialize strategy parameters.
    ChartParams cparams(_tf);
    MA_Params adx_params(_params.MA_Period, _params.MA_Applied_Price);
    IndicatorParams adx_iparams(10, INDI_MA);
    StgParams sparams(new Trade(_tf, _Symbol), new Indi_MA(adx_params, adx_iparams, cparams), NULL, NULL);
    sparams.logger.SetLevel(_log_level);
    sparams.SetMagicNo(_magic_no);
    sparams.SetSignals(_params.MA_SignalBaseMethod, _params.MA_SignalOpenMethod1, _params.MA_SignalOpenMethod2,
                       _params.MA_SignalCloseMethod1, _params.MA_SignalCloseMethod2, _params.MA_SignalOpenLevel,
                       _params.MA_SignalCloseLevel);
    sparams.SetStops(_params.MA_TrailingProfitMethod, _params.MA_TrailingStopMethod);
    sparams.SetMaxSpread(_params.MA_MaxSpread);
    // Initialize strategy instance.
    Strategy *_strat = new Stg_MA(sparams, "MA");
    return _strat;
  }

  /**
   * Check if MA indicator is on buy.
   *
   * @param
   *   _cmd (int) - type of trade order command
   *   period (int) - period to check for
   *   _signal_method (int) - signal method to use by using bitwise AND operation
   *   _signal_level1 (double) - signal level to consider the signal
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, long _signal_method = EMPTY, double _signal_level = EMPTY) {
    bool _result = false;
    double ma_0_fast = ma_fast[this.Chart().TfToIndex()][CURR];
    double ma_0_medium = ma_medium[this.Chart().TfToIndex()][CURR];
    double ma_0_slow = ma_slow[this.Chart().TfToIndex()][CURR];
    double ma_1_fast = ma_fast[this.Chart().TfToIndex()][PREV];
    double ma_1_medium = ma_medium[this.Chart().TfToIndex()][PREV];
    double ma_1_slow = ma_slow[this.Chart().TfToIndex()][PREV];
    double ma_2_fast = ma_fast[this.Chart().TfToIndex()][FAR];
    double ma_2_medium = ma_medium[this.Chart().TfToIndex()][FAR];
    double ma_2_slow = ma_slow[this.Chart().TfToIndex()][FAR];
    /*
    @todo:
    double ma_0 = ((Indi_MA *) this.Data()).GetValue(0);
    double ma_1 = ((Indi_MA *) this.Data()).GetValue(1);
    double ma_2 = ((Indi_MA *) this.Data()).GetValue(2);
    */
    if (_signal_method == EMPTY) _signal_method = GetSignalBaseMethod();
    if (_signal_level1 == EMPTY) _signal_level1 = GetSignalLevel1();
    if (_signal_level2 == EMPTY) _signal_level2 = GetSignalLevel2();
    double gap = _signal_level1 * pip_size;

    switch (_cmd) {
      case ORDER_TYPE_BUY:
        _result = ma_0_fast > ma_0_medium + gap;
        _result &= ma_0_medium > ma_0_slow;
        if (_signal_method != 0) {
          if (METHOD(_signal_method, 0)) _result &= ma_0_fast > ma_0_slow + gap;
          if (METHOD(_signal_method, 1)) _result &= ma_0_medium > ma_0_slow;
          if (METHOD(_signal_method, 2)) _result &= ma_0_slow > ma_1_slow;
          if (METHOD(_signal_method, 3)) _result &= ma_0_fast > ma_1_fast;
          if (METHOD(_signal_method, 4)) _result &= ma_0_fast - ma_0_medium > ma_0_medium - ma_0_slow;
          if (METHOD(_signal_method, 5)) _result &= (ma_1_medium < ma_1_slow || ma_2_medium < ma_2_slow);
          if (METHOD(_signal_method, 6)) _result &= (ma_1_fast < ma_1_medium || ma_2_fast < ma_2_medium);
        }
        break;
      case ORDER_TYPE_SELL:
        _result = ma_0_fast < ma_0_medium - gap;
        _result &= ma_0_medium < ma_0_slow;
        if (_signal_method != 0) {
          if (METHOD(_signal_method, 0)) _result &= ma_0_fast < ma_0_slow - gap;
          if (METHOD(_signal_method, 1)) _result &= ma_0_medium < ma_0_slow;
          if (METHOD(_signal_method, 2)) _result &= ma_0_slow < ma_1_slow;
          if (METHOD(_signal_method, 3)) _result &= ma_0_fast < ma_1_fast;
          if (METHOD(_signal_method, 4)) _result &= ma_0_medium - ma_0_fast > ma_0_slow - ma_0_medium;
          if (METHOD(_signal_method, 5)) _result &= (ma_1_medium > ma_1_slow || ma_2_medium > ma_2_slow);
          if (METHOD(_signal_method, 6)) _result &= (ma_1_fast > ma_1_medium || ma_2_fast > ma_2_medium);
        }
        break;
    }
    return _result;
  }

  /**
   * Check strategy's closing signal.
   */
  bool SignalClose(ENUM_ORDER_TYPE _cmd, long _signal_method = EMPTY, double _signal_level = EMPTY) {
    if (_signal_level == EMPTY) _signal_level = GetSignalCloseLevel();
    return SignalOpen(Order::NegateOrderType(_cmd), _signal_method, _signal_level);
  }
};
