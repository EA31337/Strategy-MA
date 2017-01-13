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
 * Implements the Moving Average indicator.
 *
 * @docs
 * - https://docs.mql4.com/indicators/ima
 * - https://www.mql5.com/en/docs/indicators/ima
 */

// Includes.
#include <EA31337-classes\Indicator.mqh>

// User inputs.
#ifdef __input__ input #endif string __MA_Parameters__ = "-- Settings for the Moving Average indicator --"; // >>> MA <<<
#ifdef __input__ input #endif int MA_Period_Fast = 17; // Period Fast
#ifdef __input__ input #endif int MA_Period_Medium = 15; // Period Medium
#ifdef __input__ input #endif int MA_Period_Slow = 48; // Period Slow
#ifdef __input__ input #endif double MA_Period_Ratio = 1.0; // Period ratio between timeframes (0.5-1.5)
#ifdef __input__ input #endif int MA_Shift = 0; // Shift
#ifdef __input__ input #endif int MA_Shift_Fast = 0; // Shift Fast (+1)
#ifdef __input__ input #endif int MA_Shift_Medium = 0; // Shift Medium (+1)
#ifdef __input__ input #endif int MA_Shift_Slow = 1; // Shift Slow (+1)
#ifdef __input__ input #endif int MA_Shift_Far = 4; // Shift Far (+2)
#ifdef __input__ input #endif ENUM_MA_METHOD MA_Method = 1; // MA Method
#ifdef __input__ input #endif ENUM_APPLIED_PRICE MA_Applied_Price = 3; // Applied Price

/**
 * Indicator class.
 */
class I_MA : public Indicator {

protected:
  // Enums.
  enum ENUM_MA { MA_FAST = 0, MA_MEDIUM = 1, MA_SLOW = 2 };

public:

  /**
   * Class constructor.
   */
  void I_MA(IndicatorParams &_params, Timeframe *_tf = NULL) : Indicator(_params, _tf) {
  }

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
      _ma_value = iMA(market.GetSymbol(), tf.GetTf(), GetPeriod(k), GetShift(k), GetMethod(k), GetAppliedPrice(k), GetShift(k));
      #else // __MQL5__
      int _handle;
      double _ma_values[];
      _handle = iMA(market.GetSymbol(), tf.GetTf(), GetPeriod(k), GetShift(k), GetMethod(k), GetAppliedPrice(k));
      if (CopyBuffer(_handle, 0, 0, 1, _ma_values) < 0) {
        logger.Error("Error in copying data!", __FUNCTION__ + ": ");
        return false;
      }
      _ma_value = _ma_values[0];
      #endif
      NewValue(_ma_value);
    }
    return true;
  }
};
