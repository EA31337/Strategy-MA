//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                       Copyright 2016-2017, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
    This file is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// Properties.
#property strict

/**
 * @file
 * Strategy based on the Moving Average indicator.
 *
 * @docs
 * - https://docs.mql4.com/indicators/ima
 * - https://www.mql5.com/en/docs/indicators/ima
 */

// Includes.
#include <EA31337-classes\Indicator.mqh>
#include <EA31337-classes\Strategy.mqh>
#include <EA31337-classes\Strategies.mqh>

// User inputs.
#ifdef __input__ input #endif string __MA_Parameters__ = "-- Settings for the Moving Average indicator --"; // >>> MA <<<
#ifdef __input__ input #endif int MA_Period_Fast = 17; // Period Fast
#ifdef __input__ input #endif int MA_Period_Medium = 15; // Period Medium
#ifdef __input__ input #endif int MA_Period_Slow = 48; // Period Slow
#ifdef __input__ input #endif string MA_Periods = ""; // Periods to override
#ifdef __input__ input #endif double MA_Period_Ratio = 1.0; // Period ratio between timeframes (0.5-1.5)
#ifdef __input__ input #endif int MA_Shift = 0; // Shift
#ifdef __input__ input #endif int MA_Shift_Fast = 0; // Shift Fast (+1)
#ifdef __input__ input #endif int MA_Shift_Medium = 0; // Shift Medium (+1)
#ifdef __input__ input #endif int MA_Shift_Slow = 1; // Shift Slow (+1)
#ifdef __input__ input #endif int MA_Shift_Far = 4; // Shift Far (+2)
#ifdef __input__ input #endif string MA_Shifts = ""; // Shifts to override
#ifdef __input__ input #endif ENUM_MA_METHOD MA_Method = 1; // MA Method
#ifdef __input__ input #endif ENUM_APPLIED_PRICE MA_Applied_Price = 3; // Applied Price
#ifdef __input__ input #endif double MA_SignalLevel = 1.2; // Signal level
#ifdef __input__ input #endif int MA_SignalMethod = -98; // Signal method (-127-127)
#ifdef __input__ input #endif string MA_SignalMethods = ""; // Signal methods

class MA : public Strategy {
private:

public:

  // Calculates the Moving Average indicator.
  /*
  bool Update(ENUM_TIMEFRAMES tf = PERIOD_M1, string symbol = NULL) {
    double ratio = 1.0;
    int shift;
    int index = Timeframe::TfToIndex(tf);
    ratio = tf == 30 ? 1.0 : fmax(MA_Period_Ratio, NEAR_ZERO) / tf * 30;
    for (int i = 0; i < FINAL_ENUM_INDICATOR_INDEX; i++) {
      shift = i + MA_Shift + (i == FINAL_ENUM_INDICATOR_INDEX - 1 ? MA_Shift_Far : 0);
      ma_fast[index][i]   = iMA(symbol, tf, (int) (MA_Period_Fast * ratio),   MA_Shift_Fast,   MA_Method, MA_Applied_Price, shift);
      ma_medium[index][i] = iMA(symbol, tf, (int) (MA_Period_Medium * ratio), MA_Shift_Medium, MA_Method, MA_Applied_Price, shift);
      ma_slow[index][i]   = iMA(symbol, tf, (int) (MA_Period_Slow * ratio),   MA_Shift_Slow,   MA_Method, MA_Applied_Price, shift);
      if (tf == Period() && i < FINAL_ENUM_INDICATOR_INDEX - 1) {
        #include <EA31337-classes\Draw.mqh>
        Draw::TLine(StringFormat("%s%s%d", symbol, "MA Fast", i),   ma_fast[index][i],   ma_fast[index][i+1],    iTime(NULL, 0, shift), iTime(NULL, 0, shift+1), clrBlue);
        Draw::TLine(StringFormat("%s%s%d", symbol, "MA Medium", i), ma_medium[index][i], ma_medium[index][i+1],  iTime(NULL, 0, shift), iTime(NULL, 0, shift+1), clrYellow);
        Draw::TLine(StringFormat("%s%s%d", symbol, "MA Slow", i),   ma_slow[index][i],   ma_slow[index][i+1],    iTime(NULL, 0, shift), iTime(NULL, 0, shift+1), clrGray);
      }
    }
    #ifdef __debug__
    logger.Debug(StringFormat("MA Fast M%d: %s", tf, Arrays::ArrToString2D(ma_fast, ",", Digits)));
    logger.Debug(StringFormat("MA Medium M%d: %s", tf, Arrays::ArrToString2D(ma_medium, ",", Digits)));
    logger.Debug(StringFormat("MA Slow M%d: %s", tf, Arrays::ArrToString2D(ma_slow, ",", Digits)));
    // if (VerboseDebug && Check::IsVisualMode()) Draw::DrawMA(tf);
    #endif
    return (bool) ma_slow[index][CURR];
  }
  */

  /**
   * Check whether signal is on buy or sell.
   *
   * @param
   *   _cmd (int) - type of trade order command
   *   _method (int) - signal method to use by using bitwise AND operation
   *   _level (double) - signal level to consider the signal
   */
  bool Signal(ENUM_ORDER_TYPE _cmd, int _method = 0, double _level = 0.0) {
    bool result = False;
    /*
    // if (signal_method == EMPTY) signal_method = GetStrategySignalMethod(MA, tf, 0);
    // if (signal_level == EMPTY)  signal_level  = GetStrategySignalLevel(MA, tf, 0);
    double gap = signal_level * pip_size;

    switch (cmd) {
      case OP_BUY:
        result  = ma_fast[period][CURR]   > ma_medium[period][CURR] + gap;
        result &= ma_medium[period][CURR] > ma_slow[period][CURR];
        if ((signal_method &   1) != 0) result &= ma_fast[period][CURR] > ma_slow[period][CURR] + gap;
        if ((signal_method &   2) != 0) result &= ma_medium[period][CURR] > ma_slow[period][CURR];
        if ((signal_method &   4) != 0) result &= ma_slow[period][CURR] > ma_slow[period][PREV];
        if ((signal_method &   8) != 0) result &= ma_fast[period][CURR] > ma_fast[period][PREV];
        if ((signal_method &  16) != 0) result &= ma_fast[period][CURR] - ma_medium[period][CURR] > ma_medium[period][CURR] - ma_slow[period][CURR];
        if ((signal_method &  32) != 0) result &= (ma_medium[period][PREV] < ma_slow[period][PREV] || ma_medium[period][FAR] < ma_slow[period][FAR]);
        if ((signal_method &  64) != 0) result &= (ma_fast[period][PREV] < ma_medium[period][PREV] || ma_fast[period][FAR] < ma_medium[period][FAR]);
        break;
      case OP_SELL:
        result  = ma_fast[period][CURR]   < ma_medium[period][CURR] - gap;
        result &= ma_medium[period][CURR] < ma_slow[period][CURR];
        if ((signal_method &   1) != 0) result &= ma_fast[period][CURR] < ma_slow[period][CURR] - gap;
        if ((signal_method &   2) != 0) result &= ma_medium[period][CURR] < ma_slow[period][CURR];
        if ((signal_method &   4) != 0) result &= ma_slow[period][CURR] < ma_slow[period][PREV];
        if ((signal_method &   8) != 0) result &= ma_fast[period][CURR] < ma_fast[period][PREV];
        if ((signal_method &  16) != 0) result &= ma_medium[period][CURR] - ma_fast[period][CURR] > ma_slow[period][CURR] - ma_medium[period][CURR];
        if ((signal_method &  32) != 0) result &= (ma_medium[period][PREV] > ma_slow[period][PREV] || ma_medium[period][FAR] > ma_slow[period][FAR]);
        if ((signal_method &  64) != 0) result &= (ma_fast[period][PREV] > ma_medium[period][PREV] || ma_fast[period][FAR] > ma_medium[period][FAR]);
        break;
    }
    // result &= signal_method <= 0 || Convert::ValueToOp(curr_trend) == cmd;
    if (result) {
      logger.Add(V_DEBUG, StringFormat("%s:%d: Signal: %d/%d/%d/%g", __FUNCTION__, __LINE__, cmd, tf, signal_method, signal_level));
    }
    */
    return result;
  }
};

class MA_I : public Indicator {

protected:
  // Enums.
  enum ENUM_MA { MA_FAST = 0, MA_MEDIUM = 1, MA_SLOW = 2 };

public:

  /**
   * Get period value from settings.
   */
  int GetPeriod(ENUM_MA _ma_type) {
    switch (_ma_type) {
      default:
      case MA_FAST:   return MA_Period_Fast;
      case MA_MEDIUM: return MA_Period_Medium;
      case MA_SLOW:   return MA_Period_Slow;
    }
  }

  /**
   * Get shift value from settings.
   */
  int GetShift(ENUM_MA _ma_type) {
    switch (_ma_type) {
      default:
      case MA_FAST:   return MA_Shift_Fast;
      case MA_MEDIUM: return MA_Shift_Medium;
      case MA_SLOW:   return MA_Shift_Slow;
    }
  }

  /**
   * Get method value from settings.
   */
  ENUM_MA_METHOD GetMethod(ENUM_MA _ma_type) {
    switch (_ma_type) {
      default:
      case MA_FAST:   return MA_Method;
      case MA_MEDIUM: return MA_Method;
      case MA_SLOW:   return MA_Method;
    }
  }

  /**
   * Get applied price value from settings.
   */
  ENUM_APPLIED_PRICE GetAppliedPrice(ENUM_MA _ma_type) {
    switch (_ma_type) {
      default:
      case MA_FAST:   return MA_Applied_Price;
      case MA_MEDIUM: return MA_Applied_Price;
      case MA_SLOW:   return MA_Applied_Price;
    }
  }

  /**
   * Calculates the Moving Average indicator.
   */
  bool Update() {
    double _ma_value;
    for (ENUM_MA k = 0; k <= MA_SLOW; k++) {
      #ifdef __MQL4__
      _ma_value = iMA(i_symbol, i_tf, GetPeriod(k), GetShift(k), GetMethod(k), GetAppliedPrice(k), GetShift(k));
      #else // __MQL5__
      int _handle;
      double _ma_values[];
      _handle = iMA(i_symbol, i_tf, GetPeriod(k), GetShift(k), GetMethod(k), GetAppliedPrice(k));
      if (CopyBuffer(_handle, 0, 0, 1, _ma_values) < 0) {
        logger.Error("Error in copying data!", __FUNCTION__ . ":" . __LINE__ . ": ");
        return False;
      }
      _ma_value = _ma_values[0];
      #endif
      NewValue(_ma_value);
    }
    return True;
  }
};
