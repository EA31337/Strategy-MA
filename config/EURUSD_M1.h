/*
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_MA_Params_M1 : MAParams {
  Indi_MA_Params_M1() : MAParams(indi_ma_defaults, PERIOD_M1) {
    period = 44;
    ma_shift = 0;
    ma_method = (ENUM_MA_METHOD)2;
    applied_price = (ENUM_APPLIED_PRICE)3;
    shift = 0;
  }
} indi_ma_m1;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_MA_Params_M1 : StgParams {
  // Struct constructor.
  Stg_MA_Params_M1() : StgParams(stg_ma_defaults) {
    lot_size = 0;
    signal_open_method = 0;
    signal_open_filter = 1;
    signal_open_level = (float)0.01;
    signal_open_boost = 0;
    signal_close_method = 0;
    signal_close_level = (float)0.01;
    price_stop_method = 0;
    price_stop_level = (float)2;
    tick_filter_method = 1;
    max_spread = 0;
  }
} stg_ma_m1;
