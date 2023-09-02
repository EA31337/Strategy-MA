/**
 * @file
 * Implements MA strategy based the moving average price indicators.
 */

enum ENUM_STG_MA_TYPE {
  STG_MA_TYPE_0_NONE = 0,  // (None)
  STG_MA_TYPE_AMA,         // AMA: Adaptive Moving Average
  STG_MA_TYPE_DEMA,        // DEMA: Double Exponential Moving Average
  STG_MA_TYPE_MA,          // MA: Moving Average
};

// User params.
INPUT_GROUP("MA strategy: main strategy params");
INPUT ENUM_STG_MA_TYPE MA_Type = STG_MA_TYPE_MA;  // Indicator MA type
INPUT_GROUP("MA strategy: strategy params");
INPUT float MA_LotSize = 0;                // Lot size
INPUT int MA_SignalOpenMethod = 0;         // Signal open method (-127-127)
INPUT float MA_SignalOpenLevel = 0.04f;    // Signal open level
INPUT int MA_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT int MA_SignalOpenFilterTime = 3;     // Signal open filter time
INPUT int MA_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT int MA_SignalCloseMethod = 0;        // Signal close method (-127-127)
INPUT int MA_SignalCloseFilter = 0;        // Signal close filter (-127-127)
INPUT float MA_SignalCloseLevel = 0.04f;   // Signal close level
INPUT int MA_PriceStopMethod = 1;          // Price stop method (0-127)
INPUT float MA_PriceStopLevel = 2;         // Price stop level
INPUT int MA_TickFilterMethod = 32;        // Tick filter method
INPUT float MA_MaxSpread = 4.0;            // Max spread to trade (pips)
INPUT short MA_Shift = 0;                  // Shift
INPUT float MA_OrderCloseLoss = 80;        // Order close loss
INPUT float MA_OrderCloseProfit = 80;      // Order close profit
INPUT int MA_OrderCloseTime = -30;         // Order close time in mins (>0) or bars (<0)
INPUT_GROUP("MA strategy: AMA indicator params");
INPUT int MA_Indi_AMA_InpPeriodAMA = 20;                              // AMA period
INPUT int MA_Indi_AMA_InpFastPeriodEMA = 4;                           // Fast EMA period
INPUT int MA_Indi_AMA_InpSlowPeriodEMA = 30;                          // Slow EMA period
INPUT int MA_Indi_AMA_InpShiftAMA = 4;                                // AMA shift
INPUT int MA_Indi_AMA_Shift = 0;                                      // Shift
INPUT ENUM_IDATA_SOURCE_TYPE MA_Indi_AMA_SourceType = IDATA_BUILTIN;  // Source type
INPUT_GROUP("MA strategy: DEMA indicator params");
INPUT int MA_Indi_DEMA_Period = 25;                                    // Period
INPUT int MA_Indi_DEMA_MA_Shift = 6;                                   // MA Shift
INPUT ENUM_APPLIED_PRICE MA_Indi_DEMA_Applied_Price = PRICE_TYPICAL;   // Applied Price
INPUT int MA_Indi_DEMA_Shift = 0;                                      // DEMA Shift
INPUT ENUM_IDATA_SOURCE_TYPE MA_Indi_DEMA_SourceType = IDATA_BUILTIN;  // Source type
INPUT_GROUP("MA strategy: MA indicator params");
INPUT int MA_Indi_MA_Period = 40;                                    // Period
INPUT int MA_Indi_MA_MA_Shift = 0;                                   // MA Shift
INPUT ENUM_MA_METHOD MA_Indi_MA_Method = (ENUM_MA_METHOD)3;          // MA Method
INPUT ENUM_APPLIED_PRICE MA_Indi_MA_Applied_Price = PRICE_OPEN;      // Applied Price
INPUT int MA_Indi_MA_Shift = 0;                                      // Shift
INPUT ENUM_IDATA_SOURCE_TYPE MA_Indi_MA_SourceType = IDATA_BUILTIN;  // Source type

// Structs.

// Defines struct with default user strategy values.
struct Stg_MA_Params_Defaults : StgParams {
  Stg_MA_Params_Defaults()
      : StgParams(::MA_SignalOpenMethod, ::MA_SignalOpenFilterMethod, ::MA_SignalOpenLevel, ::MA_SignalOpenBoostMethod,
                  ::MA_SignalCloseMethod, ::MA_SignalCloseFilter, ::MA_SignalCloseLevel, ::MA_PriceStopMethod,
                  ::MA_PriceStopLevel, ::MA_TickFilterMethod, ::MA_MaxSpread, ::MA_Shift) {
    Set(STRAT_PARAM_LS, MA_LotSize);
    Set(STRAT_PARAM_OCL, MA_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, MA_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, MA_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, MA_SignalOpenFilterTime);
  }
};

class Stg_MA : public Strategy {
 public:
  Stg_MA(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_MA *Init(ENUM_TIMEFRAMES _tf = NULL, EA *_ea = NULL) {
    // Initialize strategy initial values.
    Stg_MA_Params_Defaults stg_ma_defaults;
    StgParams _stg_params(stg_ma_defaults);
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat = new Stg_MA(_stg_params, _tparams, _cparams, "MA");
    return _strat;
  }

  /**
   * Event on strategy's init.
   */
  void OnInit() {
    // Initialize indicators.
    switch (MA_Type) {
      case STG_MA_TYPE_AMA:  // AMA
      {
        IndiAMAParams _indi_params(::MA_Indi_AMA_InpPeriodAMA, ::MA_Indi_AMA_InpFastPeriodEMA,
                                   ::MA_Indi_AMA_InpSlowPeriodEMA, ::MA_Indi_AMA_InpShiftAMA, PRICE_TYPICAL,
                                   ::MA_Indi_AMA_Shift);
        _indi_params.SetDataSourceType(::MA_Indi_AMA_SourceType);
        _indi_params.SetTf(Get<ENUM_TIMEFRAMES>(STRAT_PARAM_TF));
        SetIndicator(new Indi_AMA(_indi_params), ::MA_Type);
        break;
      }
      case STG_MA_TYPE_DEMA:  // DEMA
      {
        IndiDEIndiMAParams _indi_params(::MA_Indi_DEMA_Period, ::MA_Indi_DEMA_MA_Shift, ::MA_Indi_DEMA_Applied_Price,
                                        ::MA_Indi_DEMA_Shift);
        _indi_params.SetDataSourceType(::MA_Indi_DEMA_SourceType);
        _indi_params.SetTf(Get<ENUM_TIMEFRAMES>(STRAT_PARAM_TF));
        SetIndicator(new Indi_DEMA(_indi_params), ::MA_Type);
        break;
      }
      case STG_MA_TYPE_MA:  // MA
      {
        IndiMAParams _indi_params(::MA_Indi_MA_Period, ::MA_Indi_MA_MA_Shift, ::MA_Indi_MA_Method,
                                  ::MA_Indi_MA_Applied_Price, ::MA_Indi_MA_Shift);
        _indi_params.SetDataSourceType(::MA_Indi_MA_SourceType);
        _indi_params.SetTf(Get<ENUM_TIMEFRAMES>(STRAT_PARAM_TF));
        SetIndicator(new Indi_MA(_indi_params), ::MA_Type);
        break;
      }
      case STG_MA_TYPE_0_NONE:  // (None)
      default:
        break;
    }
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, float _level = 0.0f, int _shift = 0) {
    Chart *_chart = trade.GetChart();
    IndicatorBase *_indi = GetIndicator(::MA_Type);
    uint _ishift = _shift;  // @todo: _indi.GetShift();
    // bool _result = _indi.GetFlag(INDI_ENTRY_FLAG_IS_VALID, _shift); // @fixme
    bool _result = true;
    if (!_result) {
      // Returns false when indicator data is not valid.
      return false;
    }
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        _result &= _indi[_shift][0] < _chart.GetOpen(_ishift);
        _result &= _indi.IsIncreasing(1, 0, _shift);
        _result &= _indi.IsIncByPct(_level, 0, _shift, 3);
        break;
      case ORDER_TYPE_SELL:
        _result &= _indi[_shift][0] > _chart.GetOpen(_ishift);
        _result &= _indi.IsDecreasing(1, 0, _shift);
        _result &= _indi.IsDecByPct(-_level, 0, _shift, 3);
        break;
    }
    return _result;
  }
};
