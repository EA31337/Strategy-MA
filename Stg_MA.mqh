/**
 * @file
 * Implements MA strategy based the Moving Average indicator.
 */

// User params.
int MA_Period = 12;                       // Period
int MA_MA_Shift = 0;                      // MA Shift
ENUM_MA_METHOD MA_Method = 1;             // MA Method
ENUM_APPLIED_PRICE MA_Applied_Price = 6;  // Applied Price
int MA_Shift = 0;                         // Shift
int MA_SignalOpenMethod = 48;             // Signal open method (-127-127)
float MA_SignalOpenLevel = -0.6f;         // Signal open level
int MA_SignalOpenFilterMethod = 0;        // Signal open filter method
int MA_SignalOpenBoostMethod = 0;         // Signal open boost method
int MA_SignalCloseMethod = 48;            // Signal close method (-127-127)
float MA_SignalCloseLevel = -0.6f;        // Signal close level
int MA_PriceLimitMethod = 0;              // Price limit method
float MA_PriceLimitLevel = 0;             // Price limit level
float MA_MaxSpread = 6.0f;                // Max spread to trade (pips)

// Includes.
#include <EA31337-classes/Indicators/Indi_MA.mqh>
#include <EA31337-classes/Strategy.mqh>

// Struct to define strategy parameters to override.
struct Stg_MA_Params : StgParams {
  unsigned int MA_Period;
  int MA_MA_Shift;
  ENUM_MA_METHOD MA_Method;
  ENUM_APPLIED_PRICE MA_Applied_Price;
  int MA_Shift;
  int MA_SignalOpenMethod;
  float MA_SignalOpenLevel;
  int MA_SignalOpenFilterMethod;
  int MA_SignalOpenBoostMethod;
  int MA_SignalCloseMethod;
  float MA_SignalCloseLevel;
  int MA_PriceLimitMethod;
  float MA_PriceLimitLevel;
  float MA_MaxSpread;

  // Constructor: Set default param values.
  Stg_MA_Params()
      : MA_Period(::MA_Period),
        MA_MA_Shift(::MA_MA_Shift),
        MA_Method(::MA_Method),
        MA_Applied_Price(::MA_Applied_Price),
        MA_Shift(::MA_Shift),
        MA_SignalOpenMethod(::MA_SignalOpenMethod),
        MA_SignalOpenLevel(::MA_SignalOpenLevel),
        MA_SignalOpenFilterMethod(::MA_SignalOpenFilterMethod),
        MA_SignalOpenBoostMethod(::MA_SignalOpenBoostMethod),
        MA_SignalCloseMethod(::MA_SignalCloseMethod),
        MA_SignalCloseLevel(::MA_SignalCloseLevel),
        MA_PriceLimitMethod(::MA_PriceLimitMethod),
        MA_PriceLimitLevel(::MA_PriceLimitLevel),
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
    if (!Terminal::IsOptimization()) {
      SetParamsByTf<Stg_MA_Params>(_params, _tf, stg_ma_m1, stg_ma_m5, stg_ma_m15, stg_ma_m30, stg_ma_h1, stg_ma_h4,
                                   stg_ma_h4);
    }
    // Initialize strategy parameters.
    MAParams ma_params(_params.MA_Period, _params.MA_MA_Shift, _params.MA_Method, _params.MA_Applied_Price);
    ma_params.SetTf(_tf);
    StgParams sparams(new Trade(_tf, _Symbol), new Indi_MA(ma_params), NULL, NULL);
    sparams.logger.Ptr().SetLevel(_log_level);
    sparams.SetMagicNo(_magic_no);
    sparams.SetSignals(_params.MA_SignalOpenMethod, _params.MA_SignalOpenLevel, _params.MA_SignalCloseMethod,
                       _params.MA_SignalOpenFilterMethod, _params.MA_SignalOpenBoostMethod,
                       _params.MA_SignalCloseLevel);
    sparams.SetPriceLimits(_params.MA_PriceLimitMethod, _params.MA_PriceLimitLevel);
    sparams.SetMaxSpread(_params.MA_MaxSpread);
    // Initialize strategy instance.
    Strategy *_strat = new Stg_MA(sparams, "MA");
    return _strat;
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, float _level = 0.0) {
    Indi_MA *_indi = Data();
    bool _is_valid = _indi[CURR].IsValid() && _indi[PREV].IsValid() && _indi[PPREV].IsValid();
    bool _result = _is_valid;
    double _level_pips = _level * Chart().GetPipSize();
    if (_is_valid) {
      switch (_cmd) {
        case ORDER_TYPE_BUY:
          _result = _indi[CURR].value[0] > _indi[PREV].value[0];
          if (_method != 0) {
            if (METHOD(_method, 0))
              _result &= _indi[PREV].value[0] < _indi[PPREV].value[0];  // ... 2 consecutive columns are red.
            if (METHOD(_method, 1))
              _result &= _indi[PPREV].value[0] < _indi[3].value[0];  // ... 3 consecutive columns are red.
            if (METHOD(_method, 2))
              _result &= _indi[3].value[0] < _indi[4].value[0];  // ... 4 consecutive columns are red.
            if (METHOD(_method, 3))
              _result &= _indi[PREV].value[0] > _indi[PPREV].value[0];  // ... 2 consecutive columns are green.
            if (METHOD(_method, 4))
              _result &= _indi[PPREV].value[0] > _indi[3].value[0];  // ... 3 consecutive columns are green.
            if (METHOD(_method, 5))
              _result &= _indi[3].value[0] < _indi[4].value[0];  // ... 4 consecutive columns are green.
          }
          break;
        case ORDER_TYPE_SELL:
          _result = _indi[CURR].value[0] < _indi[PREV].value[0];
          if (_method != 0) {
            if (METHOD(_method, 0))
              _result &= _indi[PREV].value[0] < _indi[PPREV].value[0];  // ... 2 consecutive columns are red.
            if (METHOD(_method, 1))
              _result &= _indi[PPREV].value[0] < _indi[3].value[0];  // ... 3 consecutive columns are red.
            if (METHOD(_method, 2))
              _result &= _indi[3].value[0] < _indi[4].value[0];  // ... 4 consecutive columns are red.
            if (METHOD(_method, 3))
              _result &= _indi[PREV].value[0] > _indi[PPREV].value[0];  // ... 2 consecutive columns are green.
            if (METHOD(_method, 4))
              _result &= _indi[PPREV].value[0] > _indi[3].value[0];  // ... 3 consecutive columns are green.
            if (METHOD(_method, 5))
              _result &= _indi[3].value[0] < _indi[4].value[0];  // ... 4 consecutive columns are green.
          }
          break;
      }
    }
    return _result;
  }

  /**
   * Gets price limit value for profit take or stop loss.
   */
  float PriceLimit(ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode, int _method = 0, float _level = 0.0) {
    Indi_MA *_indi = Data();
    double _trail = _level * Market().GetPipSize();
    int _direction = Order::OrderDirection(_cmd, _mode);
    double _default_value = Market().GetCloseOffer(_cmd) + _trail * _method * _direction;
    double _result = _default_value;
    switch (_method) {
      case 0:
        _result = _indi[PPREV].value[0] + _trail * _direction;
        break;
      case 1: {
        int _bar_count = (int)_level * (int)_indi.GetPeriod();
        _result = _direction < 0 ? _indi.GetPrice(PRICE_HIGH, _indi.GetHighest(_bar_count))
                                 : _indi.GetPrice(PRICE_LOW, _indi.GetLowest(_bar_count));
        break;
      }
    }
    return (float)_result;
  }
};
