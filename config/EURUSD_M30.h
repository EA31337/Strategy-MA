/*
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_MA_Params_M30 : MAParams {
  Indi_MA_Params_M30() : MAParams(indi_ma_defaults, PERIOD_M30) {
    period = 12;
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
    signal_open_method = 0;
    signal_open_filter = 1;
    signal_open_level = (float)10;
    signal_open_boost = 0;
    signal_close_method = 0;
    signal_close_level = (float)10;
    price_stop_method = 0;
    price_stop_level = (float)2;
    tick_filter_method = 1;
    max_spread = 0;
  }
} stg_ma_m30;
