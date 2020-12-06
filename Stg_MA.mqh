/**
 * @file
 * Implements MA strategy based the Moving Average indicator.
 */

// Includes.
#include <EA31337-classes/Indicators/Indi_MA.mqh>
#include <EA31337-classes/Strategy.mqh>

// User params.
INPUT float MA_LotSize = 0;                                                         // Lot size
INPUT int MA_SignalOpenMethod = 48;                                                 // Signal open method (-127-127)
INPUT float MA_SignalOpenLevel = -0.6f;                                             // Signal open level
INPUT int MA_SignalOpenFilterMethod = 0;                                            // Signal open filter method
INPUT int MA_SignalOpenBoostMethod = 0;                                             // Signal open boost method
INPUT int MA_SignalCloseMethod = 48;                                                // Signal close method (-127-127)
INPUT float MA_SignalCloseLevel = -0.6f;                                            // Signal close level
INPUT int MA_PriceStopMethod = 0;                                                   // Price stop method
INPUT float MA_PriceStopLevel = 0;                                                  // Price stop level
INPUT int MA_TickFilterMethod = 0;                                                  // Tick filter method
INPUT float MA_MaxSpread = 6.0f;                                                    // Max spread to trade (pips)
INPUT int MA_Shift = 0;                                                             // Shift
INPUT string __MA_Indi_MA_Parameters__ = "-- MA strategy: MA indicator params --";  // >>> MA strategy: MA indicator <<<
INPUT int Indi_MA_Period = 12;                                                      // Period
INPUT int Indi_MA_MA_Shift = 0;                                                     // MA Shift
INPUT ENUM_MA_METHOD Indi_MA_Method = 1;                                            // MA Method
INPUT ENUM_APPLIED_PRICE Indi_MA_Applied_Price = 6;                                 // Applied Price

// Structs.

// Defines struct with default user indicator values.
struct Indi_MA_Params_Defaults : MAParams {
  Indi_MA_Params_Defaults()
      : MAParams(::Indi_MA_Period, ::Indi_MA_MA_Shift, ::Indi_MA_Method, ::Indi_MA_Applied_Price) {}
} indi_ma_defaults;

// Defines struct to store indicator parameter values.
struct Indi_MA_Params : public MAParams {
  // Struct constructors.
  void Indi_MA_Params(MAParams &_params, ENUM_TIMEFRAMES _tf) : MAParams(_params, _tf) {}
};

// Defines struct with default user strategy values.
struct Stg_MA_Params_Defaults : StgParams {
  Stg_MA_Params_Defaults()
      : StgParams(::MA_SignalOpenMethod, ::MA_SignalOpenFilterMethod, ::MA_SignalOpenLevel, ::MA_SignalOpenBoostMethod,
                  ::MA_SignalCloseMethod, ::MA_SignalCloseLevel, ::MA_PriceStopMethod, ::MA_PriceStopLevel,
                  ::MA_TickFilterMethod, ::MA_MaxSpread, ::MA_Shift) {}
} stg_ma_defaults;

// Struct to define strategy parameters to override.
struct Stg_MA_Params : StgParams {
  Indi_MA_Params iparams;
  StgParams sparams;

  // Struct constructors.
  Stg_MA_Params(Indi_MA_Params &_iparams, StgParams &_sparams)
      : iparams(indi_ma_defaults, _iparams.tf), sparams(stg_ma_defaults) {
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
  Stg_MA(StgParams &_params, string _name) : Strategy(_params, _name) {}

  static Stg_MA *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL, ENUM_LOG_LEVEL _log_level = V_INFO) {
    // Initialize strategy initial values.
    Indi_MA_Params _indi_params(indi_ma_defaults, _tf);
    StgParams _stg_params(stg_ma_defaults);
    if (!Terminal::IsOptimization()) {
      SetParamsByTf<Indi_MA_Params>(_indi_params, _tf, indi_ma_m1, indi_ma_m5, indi_ma_m15, indi_ma_m30, indi_ma_h1,
                                    indi_ma_h4, indi_ma_h8);
      SetParamsByTf<StgParams>(_stg_params, _tf, stg_ma_m1, stg_ma_m5, stg_ma_m15, stg_ma_m30, stg_ma_h1, stg_ma_h4,
                               stg_ma_h8);
    }
    // Initialize indicator.
    MAParams ma_params(_indi_params);
    _stg_params.SetIndicator(new Indi_MA(_indi_params));
    // Initialize strategy parameters.
    _stg_params.GetLog().SetLevel(_log_level);
    _stg_params.SetMagicNo(_magic_no);
    _stg_params.SetTf(_tf, _Symbol);
    // Initialize strategy instance.
    Strategy *_strat = new Stg_MA(_stg_params, "MA");
    _stg_params.SetStops(_strat, _strat);
    return _strat;
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, float _level = 0.0f, int _shift = 0) {
    Indi_MA *_indi = Data();
    bool _is_valid = _indi[CURR].IsValid() && _indi[PREV].IsValid() && _indi[PPREV].IsValid();
    bool _result = _is_valid;
    double _level_pips = _level * Chart().GetPipSize();
    if (_is_valid) {
      switch (_cmd) {
        case ORDER_TYPE_BUY:
          _result = _indi[CURR][0] > _indi[PREV][0];
          if (_method != 0) {
            if (METHOD(_method, 0)) _result &= _indi[PREV][0] < _indi[PPREV][0];  // ... 2 consecutive columns are red.
            if (METHOD(_method, 1)) _result &= _indi[PPREV][0] < _indi[3][0];     // ... 3 consecutive columns are red.
            if (METHOD(_method, 2)) _result &= _indi[3][0] < _indi[4][0];         // ... 4 consecutive columns are red.
            if (METHOD(_method, 3))
              _result &= _indi[PREV][0] > _indi[PPREV][0];                     // ... 2 consecutive columns are green.
            if (METHOD(_method, 4)) _result &= _indi[PPREV][0] > _indi[3][0];  // ... 3 consecutive columns are green.
            if (METHOD(_method, 5)) _result &= _indi[3][0] < _indi[4][0];      // ... 4 consecutive columns are green.
          }
          break;
        case ORDER_TYPE_SELL:
          _result = _indi[CURR][0] < _indi[PREV][0];
          if (_method != 0) {
            if (METHOD(_method, 0)) _result &= _indi[PREV][0] < _indi[PPREV][0];  // ... 2 consecutive columns are red.
            if (METHOD(_method, 1)) _result &= _indi[PPREV][0] < _indi[3][0];     // ... 3 consecutive columns are red.
            if (METHOD(_method, 2)) _result &= _indi[3][0] < _indi[4][0];         // ... 4 consecutive columns are red.
            if (METHOD(_method, 3))
              _result &= _indi[PREV][0] > _indi[PPREV][0];                     // ... 2 consecutive columns are green.
            if (METHOD(_method, 4)) _result &= _indi[PPREV][0] > _indi[3][0];  // ... 3 consecutive columns are green.
            if (METHOD(_method, 5)) _result &= _indi[3][0] < _indi[4][0];      // ... 4 consecutive columns are green.
          }
          break;
      }
    }
    return _result;
  }

  /**
   * Gets price stop value for profit take or stop loss.
   */
  float PriceStop(ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode, int _method = 0, float _level = 0.0) {
    Indi_MA *_indi = Data();
    double _trail = _level * Market().GetPipSize();
    int _direction = Order::OrderDirection(_cmd, _mode);
    double _default_value = Market().GetCloseOffer(_cmd) + _trail * _method * _direction;
    double _result = _default_value;
    switch (_method) {
      case 1:
        _result = _indi[PPREV][0] + _trail * _direction;
        break;
      case 2: {
        int _bar_count = (int)_level * (int)_indi.GetPeriod();
        _result = _direction < 0 ? _indi.GetPrice(PRICE_HIGH, _indi.GetHighest<double>(_bar_count))
                                 : _indi.GetPrice(PRICE_LOW, _indi.GetLowest<double>(_bar_count));
        break;
      }
    }
    return (float)_result;
  }
};
