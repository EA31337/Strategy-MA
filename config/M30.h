/*
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_MA_Params_M30 : IndiMAParams {
  Indi_MA_Params_M30() : IndiMAParams(indi_ma_defaults, PERIOD_M30) {
    period = 20;
    ma_shift = 0;
    ma_method = (ENUM_MA_METHOD)0;
    applied_price = (ENUM_APPLIED_PRICE)0;
    shift = 0;
  }
} indi_ma_m30;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_MA_Params_M30 : StgParams {
  // Struct constructor.
  Stg_MA_Params_M30() : StgParams(stg_ma_defaults) {
    lot_size = 0;
    signal_open_method = 2;
    signal_open_level = (float)0.00;
    signal_open_boost = 0;
    signal_close_method = 2;
    signal_close_level = (float)0.00;
    price_profit_method = 60;
    price_profit_level = (float)6;
    price_stop_method = 60;
    price_stop_level = (float)6;
    tick_filter_method = 1;
    max_spread = 0;
  }
} stg_ma_m30;
