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
#include "I_MA.mqh"
#include <EA31337-classes\Strategy.mqh>

// User inputs.
#ifdef __input__ input #endif string MA_Override = ""; // Params to override

/**
 * Strategy class.
 */
class S_MA : public Strategy {
private:

public:

  /**
   * Class constructor.
   */
  S_MA(
    string _name,
    ENUM_TIMEFRAMES _tf,
    uint _magic_no
  ) :
    Strategy(_name, _tf, _magic_no)
  {
  }

  /**
   * Initialize strategy.
   */
  bool Init() {
    bool initiated = true;
    data = new I_MA();
    initiated &= data.Update();
    initiated &= data.GetValue(MA_FAST) > 0;
    return initiated;
  }

  /**
   * Check whether signal is on buy or sell.
   *
   * @param
   *   _cmd (int) - type of trade order command
   *   _method (int) - signal method to use by using bitwise AND operation
   *   _level (double) - signal level to consider the signal
   */
  bool Signal(ENUM_ORDER_TYPE _cmd, int _method = 0, double _level = 0.0) {
    bool _signal = false;
    _level *= market.GetPipSize();
    #define _MA(type, index) data.GetValue(type, index)

    switch (_cmd) {
      case ORDER_TYPE_BUY:
        _signal  = _MA(MA_FAST, CURR) > _MA(MA_MEDIUM, CURR) + _level;
        _signal &= _MA(MA_MEDIUM, CURR) > _MA(MA_SLOW, CURR) + _level;
        if ((_method & OPEN_METHOD1) != 0) _signal &= _MA(MA_FAST, CURR) > _MA(MA_SLOW, CURR) + _level;
        if ((_method & OPEN_METHOD2) != 0) _signal &= _MA(MA_MEDIUM, CURR) > _MA(MA_SLOW, CURR);
        if ((_method & OPEN_METHOD3) != 0) _signal &= _MA(MA_SLOW, CURR) > _MA(MA_SLOW, PREV);
        if ((_method & OPEN_METHOD4) != 0) _signal &= _MA(MA_FAST, CURR) > _MA(MA_FAST, PREV);
        if ((_method & OPEN_METHOD5) != 0) _signal &= _MA(MA_FAST, CURR) - _MA(MA_MEDIUM, CURR) > _MA(MA_MEDIUM, CURR) - _MA(MA_SLOW, CURR);
        if ((_method & OPEN_METHOD6) != 0) _signal &= (_MA(MA_MEDIUM, PREV) < _MA(MA_SLOW, PREV) || _MA(MA_MEDIUM, FAR) < _MA(MA_SLOW, FAR));
        if ((_method & OPEN_METHOD7) != 0) _signal &= (_MA(MA_FAST, PREV) < _MA(MA_MEDIUM, PREV) || _MA(MA_FAST, FAR) < _MA(MA_MEDIUM, FAR));
        break;
      case ORDER_TYPE_SELL:
        _signal  = _MA(MA_FAST, CURR)   < _MA(MA_MEDIUM, CURR) - _level;
        _signal &= _MA(MA_MEDIUM, CURR) < _MA(MA_SLOW, CURR) - _level;
        if ((_method & OPEN_METHOD1) != 0) _signal &= _MA(MA_FAST, CURR) < _MA(MA_SLOW, CURR) - _level;
        if ((_method & OPEN_METHOD2) != 0) _signal &= _MA(MA_MEDIUM, CURR) < _MA(MA_SLOW, CURR);
        if ((_method & OPEN_METHOD3) != 0) _signal &= _MA(MA_SLOW, CURR) < _MA(MA_SLOW, PREV);
        if ((_method & OPEN_METHOD4) != 0) _signal &= _MA(MA_FAST, CURR) < _MA(MA_FAST, PREV);
        if ((_method & OPEN_METHOD5) != 0) _signal &= _MA(MA_MEDIUM, CURR) - _MA(MA_FAST, CURR) > _MA(MA_SLOW, CURR) - _MA(MA_MEDIUM, CURR);
        if ((_method & OPEN_METHOD6) != 0) _signal &= (_MA(MA_MEDIUM, PREV) > _MA(MA_SLOW, PREV) || _MA(MA_MEDIUM, FAR) > _MA(MA_SLOW, FAR));
        if ((_method & OPEN_METHOD7) != 0) _signal &= (_MA(MA_FAST, PREV) > _MA(MA_MEDIUM, PREV) || _MA(MA_FAST, FAR) > _MA(MA_MEDIUM, FAR));
        break;
    }
    // _signal &= _method <= 0 || Convert::ValueToOp(curr_trend) == cmd;
    return _signal;
  }

  bool Draw() {
    #include <EA31337-classes\Draw.mqh>
    /* @todo
    Draw::TLine(StringFormat("%s%s%d", market.GetChartSymbol(), "MA Fast", i),   ma_fast[index][i],   ma_fast[index][i+1],    iTime(NULL, 0, shift), iTime(NULL, 0, shift+1), clrBlue);
    Draw::TLine(StringFormat("%s%s%d", market.GetChartSymbol(), "MA Medium", i), ma_medium[index][i], ma_medium[index][i+1],  iTime(NULL, 0, shift), iTime(NULL, 0, shift+1), clrYellow);
    Draw::TLine(StringFormat("%s%s%d", market.GetChartSymbol(), "MA Slow", i),   ma_slow[index][i],   ma_slow[index][i+1],    iTime(NULL, 0, shift), iTime(NULL, 0, shift+1), clrGray);
    */
    return true;
  }
};
