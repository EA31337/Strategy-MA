/**
 * @file
 * Implements MA strategy based the Moving Average indicator.
 */

// User params.
INPUT string __MA_Parameters__ = "-- MA strategy params --";  // >>> MA <<<
INPUT float MA_LotSize = 0;                                   // Lot size
INPUT int MA_SignalOpenMethod = 2;                            // Signal open method (-127-127)
INPUT float MA_SignalOpenLevel = 0.0f;                        // Signal open level
INPUT int MA_SignalOpenFilterMethod = 32;                      // Signal open filter method
INPUT int MA_SignalOpenBoostMethod = 0;                       // Signal open boost method
INPUT int MA_SignalCloseMethod = 2;                           // Signal close method (-127-127)
INPUT float MA_SignalCloseLevel = 0.0f;                       // Signal close level
INPUT int MA_PriceStopMethod = 1;                             // Price stop method
INPUT float MA_PriceStopLevel = 0;                            // Price stop level
INPUT int MA_TickFilterMethod = 1;                            // Tick filter method
INPUT float MA_MaxSpread = 4.0;                               // Max spread to trade (pips)
INPUT short MA_Shift = 0;                                     // Shift
INPUT int MA_OrderCloseTime = -20;                            // Order close time in mins (>0) or bars (<0)
INPUT string __MA_Indi_MA_Parameters__ = "-- MA strategy: MA indicator params --";  // >>> MA strategy: MA indicator <<<
INPUT int MA_Indi_MA_Period = 12;                                                   // Period
INPUT int MA_Indi_MA_MA_Shift = 0;                                                  // MA Shift
INPUT ENUM_MA_METHOD MA_Indi_MA_Method = (ENUM_MA_METHOD)1;                         // MA Method
INPUT ENUM_APPLIED_PRICE MA_Indi_MA_Applied_Price = (ENUM_APPLIED_PRICE)6;          // Applied Price
INPUT int MA_Indi_MA_Shift = 0;                                                     // Shift

// Structs.

// Defines struct with default user indicator values.
struct Indi_MA_Params_Defaults : MAParams {
  Indi_MA_Params_Defaults()
      : MAParams(::MA_Indi_MA_Period, ::MA_Indi_MA_MA_Shift, ::MA_Indi_MA_Method, ::MA_Indi_MA_Applied_Price,
                 ::MA_Indi_MA_Shift) {}
} indi_ma_defaults;

// Defines struct with default user strategy values.
struct Stg_MA_Params_Defaults : StgParams {
  Stg_MA_Params_Defaults()
      : StgParams(::MA_SignalOpenMethod, ::MA_SignalOpenFilterMethod, ::MA_SignalOpenLevel, ::MA_SignalOpenBoostMethod,
                  ::MA_SignalCloseMethod, ::MA_SignalCloseLevel, ::MA_PriceStopMethod, ::MA_PriceStopLevel,
                  ::MA_TickFilterMethod, ::MA_MaxSpread, ::MA_Shift, ::MA_OrderCloseTime) {}
} stg_ma_defaults;

// Struct to define strategy parameters to override.
struct Stg_MA_Params : StgParams {
  MAParams iparams;
  StgParams sparams;

  // Struct constructors.
  Stg_MA_Params(MAParams &_iparams, StgParams &_sparams)
      : iparams(indi_ma_defaults, _iparams.tf.GetTf()), sparams(stg_ma_defaults) {
    iparams = _iparams;
    sparams = _sparams;
  }
};

// Loads pair specific param values.
#include "config/EURUSD_H1.h"
#include "config/EURUSD_H4.h"
#include "config/EURUSD_H8.h"
#include "config/EURUSD_M1.h"
#include "config/EURUSD_M15.h"
#include "config/EURUSD_M30.h"
#include "config/EURUSD_M5.h"

class Stg_MA : public Strategy {
 public:
  Stg_MA(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_MA *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL, ENUM_LOG_LEVEL _log_level = V_INFO) {
    // Initialize strategy initial values.
    MAParams _indi_params(indi_ma_defaults, _tf);
    StgParams _stg_params(stg_ma_defaults);
#ifdef __config__
    SetParamsByTf<MAParams>(_indi_params, _tf, indi_ma_m1, indi_ma_m5, indi_ma_m15, indi_ma_m30, indi_ma_h1, indi_ma_h4,
                            indi_ma_h8);
    SetParamsByTf<StgParams>(_stg_params, _tf, stg_ma_m1, stg_ma_m5, stg_ma_m15, stg_ma_m30, stg_ma_h1, stg_ma_h4,
                             stg_ma_h8);
#endif
    // Initialize indicator.
    MAParams ma_params(_indi_params);
    _stg_params.SetIndicator(new Indi_MA(_indi_params));
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams(_magic_no, _log_level);
    Strategy *_strat = new Stg_MA(_stg_params, _tparams, _cparams, "MA");
    return _strat;
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, float _level = 0.0f, int _shift = 0) {
    Indi_MA *_indi = GetIndicator();
    bool _is_valid = _indi[_shift].IsValid() && _indi[_shift + 1].IsValid() && _indi[_shift + 2].IsValid();
    bool _result = _is_valid;
    if (_is_valid) {
      switch (_cmd) {
        case ORDER_TYPE_BUY:
          _result &= _indi.IsIncreasing(3, 0, _shift);
          _result &= _indi.IsIncByPct(_level, 0, 0, _shift + 3);
          if (_method != 0) {
            if (METHOD(_method, 0)) _result &= _indi.IsIncreasing(2, 0, _shift + 3);
            if (METHOD(_method, 1)) _result &= _indi.IsDecreasing(2, 0, _shift + 5);
          }
          break;
        case ORDER_TYPE_SELL:
          _result &= _indi.IsDecreasing(3, 0, _shift);
          _result &= _indi.IsDecByPct(-_level, 0, 0, _shift + 3);
          if (_method != 0) {
            if (METHOD(_method, 0)) _result &= _indi.IsIncreasing(2, 0, _shift + 3);
            if (METHOD(_method, 1)) _result &= _indi.IsDecreasing(2, 0, _shift + 5);
          }
          break;
      }
    }
    return _result;
  }
};
