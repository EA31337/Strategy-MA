//+------------------------------------------------------------------+
//|                                                           MA.mqh |
//|                            Copyright 2016, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

#property strict
//---
#define ERR_ORDER_SELECT            ERR_USER_ERROR_FIRST + 102
#define ERR_INVALID_ORDER_TYPE      ERR_USER_ERROR_FIRST + 103
#define ERR_INVALID_SYMBOL_NAME     ERR_USER_ERROR_FIRST + 104
#define ERR_INVALID_EXPIRATION_TIME ERR_USER_ERROR_FIRST + 105
//---
#define TRADE_PAUSE_SHORT 500
#define TRADE_PAUSE_LONG  5000
//---
#define MA_AMOUNT 3
#define MA_VALUES 3
//---
#define FAST   0
#define MEDIUM 1
#define SLOW   2
//---
#define CUR    0
#define PREV   1
#define FAR    2
//---
#define OPEN_METHODS  8
#define OPEN_METHOD_1 1
#define OPEN_METHOD_2 2
#define OPEN_METHOD_3 4
#define OPEN_METHOD_4 8
#define OPEN_METHOD_5 16
#define OPEN_METHOD_6 32
#define OPEN_METHOD_7 64
#define OPEN_METHOD_8 128

//+------------------------------------------------------------------+
#ifdef __MQL4__
#define TFS 9
const ENUM_TIMEFRAMES tf[TFS]=
  {
   PERIOD_M1,PERIOD_M5,PERIOD_M15,
   PERIOD_M30,PERIOD_H1,PERIOD_H4,
   PERIOD_D1,PERIOD_W1,PERIOD_MN1
  };
#endif

//+------------------------------------------------------------------+
#ifdef __MQL5__

#include <Trade\Trade.mqh>

#define TFS 21
const ENUM_TIMEFRAMES tf[TFS]=
  {
   PERIOD_M1,PERIOD_M2,PERIOD_M3,PERIOD_M4,PERIOD_M5,PERIOD_M6,
   PERIOD_M10,PERIOD_M12,PERIOD_M15,PERIOD_M20,PERIOD_M30,PERIOD_H1,
   PERIOD_H2,PERIOD_H3,PERIOD_H4,PERIOD_H6,PERIOD_H8,PERIOD_H12,
   PERIOD_D1,PERIOD_W1,PERIOD_MN1
  };
#endif
//+------------------------------------------------------------------+
//|   ENUM_TRADE_DIRECTION                                           |
//+------------------------------------------------------------------+
enum ENUM_TRADE_DIRECTION
  {
   TRADE_BUY,
   TRADE_SELL
  };
//+------------------------------------------------------------------+
//|   TMovingAverage                                                 |
//+------------------------------------------------------------------+
struct TMovingParams
  {
   int               handles[TFS];
   string            symbol;
   int               period;
   int               shift;
   ENUM_MA_METHOD    method;
   ENUM_APPLIED_PRICE price;
  };
//+------------------------------------------------------------------+
//|   CMovingTrade                                                   |
//+------------------------------------------------------------------+
class CMovingTrade
  {
private:
   TMovingParams     m_params[MA_AMOUNT];
   double            m_val[MA_AMOUNT][TFS][MA_VALUES];
   int               m_last_error;

   //+------------------------------------------------------------------+
   //|   TimeframeToIndex                                               |
   //+------------------------------------------------------------------+
   int               TimeframeToIndex(ENUM_TIMEFRAMES _tf)
     {
      if(_tf==0 || _tf==PERIOD_CURRENT)
         _tf=(ENUM_TIMEFRAMES)_Period;
      int total=ArraySize(tf);
      for(int i=0;i<total;i++)
        {
         if(tf[i]==_tf)
            return(i);
        }
      return(0);
     }

   //+------------------------------------------------------------------+
   bool Update(const ENUM_TIMEFRAMES _tf=PERIOD_CURRENT)
     {
      int index=TimeframeToIndex(_tf);
#ifdef __MQL4__
      for(int i=0;i<MA_AMOUNT;i++)
         for(int k=0;k<MA_VALUES;k++)
           {
            m_val[i][index][k]=iMA(NULL,_tf,m_params[i].period,m_params[i].shift,m_params[i].method,m_params[i].price,k);
           }

      return(true);
#endif
      //---
#ifdef __MQL5__
      double MaArray[];
      for(int i=0;i<MA_AMOUNT;i++)
        {
         if(CopyBuffer(m_params[i].handles[index],0,0,MA_VALUES,MaArray)!=MA_VALUES)
            return(false);
         m_val[i][index][CUR]=MaArray[2];
         m_val[i][index][PREV]=MaArray[1];
         m_val[i][index][FAR]=MaArray[0];
        }
      return(true);
#endif
      return(false);
     }
public:
   //+------------------------------------------------------------------+
                     CMovingTrade()

     {
      m_last_error=0;
      for(int i=0;i<MA_AMOUNT;i++)
        {
         ArrayInitialize(m_params[i].handles,INVALID_HANDLE);
         m_params[i].period=1;
         m_params[i].shift=0;
         m_params[i].method=MODE_SMA;
         m_params[i].price=PRICE_CLOSE;
        }
     }
   //+------------------------------------------------------------------+
   bool  SetFast(const string _symbol,
                 const int _period,
                 const int _shift,
                 const ENUM_MA_METHOD _method,
                 const ENUM_APPLIED_PRICE _price)
     {
      m_params[FAST].symbol = _symbol;
      m_params[FAST].period = fmax(1,_period);
      m_params[FAST].shift  = fmax(0,_shift);
      m_params[FAST].method = _method;
      m_params[FAST].price  = _price;

#ifdef __MQL5__
      for(int i=0;i<TFS;i++)
        {
         m_params[FAST].handles[i]=iMA(m_params[FAST].symbol,
                                       tf[i],
                                       m_params[FAST].period,
                                       m_params[FAST].shift,
                                       m_params[FAST].method,
                                       m_params[FAST].price
                                       );
         if(m_params[FAST].handles[i]==INVALID_HANDLE)
            return(false);
        }
#endif

      return(true);

     }
   //+------------------------------------------------------------------+
   bool  SetMedium(const string _symbol,
                   const int _period,
                   const int _shift,
                   const ENUM_MA_METHOD _method,
                   const ENUM_APPLIED_PRICE _price)
     {
      m_params[MEDIUM].symbol=_symbol;
      m_params[MEDIUM].period   = fmax(1,_period);
      m_params[MEDIUM].shift    = fmax(0,_shift);
      m_params[MEDIUM].method   = _method;
      m_params[MEDIUM].price    = _price;
#ifdef __MQL5__
      for(int i=0;i<TFS;i++)
        {
         m_params[MEDIUM].handles[i]=iMA(m_params[MEDIUM].symbol,
                                         tf[i],
                                         m_params[MEDIUM].period,
                                         m_params[MEDIUM].shift,
                                         m_params[MEDIUM].method,
                                         m_params[MEDIUM].price
                                         );
         if(m_params[MEDIUM].handles[i]==INVALID_HANDLE)
            return(false);
        }
#endif
      return(true);
     }
   //+------------------------------------------------------------------+
   bool  SetSlow(const string _symbol,
                 const int _period,
                 const int _shift,
                 const ENUM_MA_METHOD _method,
                 const ENUM_APPLIED_PRICE _price)
     {
      m_params[SLOW].symbol=_symbol;
      m_params[SLOW].period  = fmax(1,_period);
      m_params[SLOW].shift   = fmax(0,_shift);
      m_params[SLOW].method  = _method;
      m_params[SLOW].price   = _price;

#ifdef __MQL5__
      for(int i=0;i<TFS;i++)
        {
         m_params[FAST].handles[i]=iMA(m_params[FAST].symbol,
                                       tf[i],
                                       m_params[FAST].period,
                                       m_params[FAST].shift,
                                       m_params[FAST].method,
                                       m_params[FAST].price
                                       );
         if(m_params[FAST].handles[i]==INVALID_HANDLE)
            return(false);
        }

#endif

      return(true);
     }

   //+------------------------------------------------------------------+
   bool Signal(const ENUM_TRADE_DIRECTION _cmd,const ENUM_TIMEFRAMES _tf=PERIOD_CURRENT,const int _signal_method=OPEN_METHOD_1)
     {
      int index=TimeframeToIndex(_tf);
      Update(_tf);
      //---
      int result[OPEN_METHODS];
      ArrayInitialize(result,-1);

      for(int i=0; i<OPEN_METHODS; i++)
        {
         //---
         if(_cmd==TRADE_BUY)
           {
            // @todo Convert into like: ma[FAST][period][CURR], ma[SLOW][period][CURR] and so on.
            if((_signal_method&OPEN_METHOD_1) == OPEN_METHOD_1) result[i] = m_val[FAST][index][CUR]   > m_val[MEDIUM][index][CUR];
            if((_signal_method&OPEN_METHOD_2) == OPEN_METHOD_2) result[i] = m_val[FAST][index][CUR]   > m_val[SLOW][index][CUR];
            if((_signal_method&OPEN_METHOD_3) == OPEN_METHOD_3) result[i] = m_val[MEDIUM][index][CUR] > m_val[SLOW][index][CUR];
            if((_signal_method&OPEN_METHOD_4) == OPEN_METHOD_4) result[i] = m_val[SLOW][index][CUR]   > m_val[SLOW][index][PREV];
            //---
            if((_signal_method&OPEN_METHOD_5) == OPEN_METHOD_5) result[i] = m_val[FAST][index][CUR]    > m_val[FAST][index][PREV];
            if((_signal_method&OPEN_METHOD_6) == OPEN_METHOD_6) result[i] = m_val[FAST][index][CUR]    - m_val[MEDIUM][index][CUR]   >  m_val[MEDIUM][index][CUR]  -  m_val[SLOW][index][CUR];
            if((_signal_method&OPEN_METHOD_7) == OPEN_METHOD_7) result[i] = (m_val[MEDIUM][index][PREV]< m_val[SLOW][index][PREV]     || m_val[MEDIUM][index][FAR]  <  m_val[SLOW][index][FAR]);
            if((_signal_method&OPEN_METHOD_8) == OPEN_METHOD_8) result[i] = (m_val[FAST][index][PREV]  < m_val[MEDIUM][index][PREV]   || m_val[FAST][index][FAR]    <  m_val[MEDIUM][index][FAR]);
           }
         //---
         if(_cmd==TRADE_SELL)
           {
            if((_signal_method&OPEN_METHOD_1) == OPEN_METHOD_1) result[i] = m_val[FAST][index][CUR]    < m_val[MEDIUM][index][CUR];
            if((_signal_method&OPEN_METHOD_2) == OPEN_METHOD_2) result[i] = m_val[FAST][index][CUR]    < m_val[SLOW][index][CUR];
            if((_signal_method&OPEN_METHOD_3) == OPEN_METHOD_3) result[i] = m_val[MEDIUM][index][CUR]  < m_val[SLOW][index][CUR];
            if((_signal_method&OPEN_METHOD_4) == OPEN_METHOD_4) result[i] = m_val[SLOW][index][CUR]    < m_val[SLOW][index][PREV];
            //---
            if((_signal_method&OPEN_METHOD_5) == OPEN_METHOD_5) result[i] = m_val[FAST][index][CUR]    < m_val[FAST][index][PREV];
            if((_signal_method&OPEN_METHOD_6) == OPEN_METHOD_6) result[i] = m_val[MEDIUM][index][CUR]  - m_val[FAST][index][CUR]     >  m_val[SLOW][index][CUR]   -  m_val[MEDIUM][index][CUR];
            if((_signal_method&OPEN_METHOD_7) == OPEN_METHOD_7) result[i] = (m_val[MEDIUM][index][PREV]> m_val[SLOW][index][PREV]    || m_val[MEDIUM][index][FAR]   >  m_val[SLOW][index][FAR]);
            if((_signal_method&OPEN_METHOD_8) == OPEN_METHOD_8) result[i] = (m_val[FAST][index][PREV]  > m_val[MEDIUM][index][PREV]  || m_val[FAST][index][FAR]     >  m_val[MEDIUM][index][FAR]);
           }
        }

      bool res_value=false;
      for(int i=0; i<OPEN_METHODS; i++)
        {
         //--- true
         if(result[i]==1)
            res_value=true;

         //--- false
         if(result[i]==0)
           {
            res_value=false;
            break;
           }
        }
      //--- done
      return(res_value);
     }
   //+------------------------------------------------------------------+
   //|                                                                  |
   //+------------------------------------------------------------------+
   bool Trade(string   _symbol,// symbol
              ENUM_TRADE_DIRECTION _type,// operation
              double   _volume,           // volume
              int      _stop_loss,        // stop loss, pips
              int      _take_profit,      // take profit, pips
              string   _comment=NULL,     // comment
              int      _magic=0,          // magic number
              )
     {
      //--- check symbol name
      double _point=SymbolInfoDouble(_symbol,SYMBOL_POINT);
      if(_point==0.0)
        {
         m_last_error=ERR_INVALID_SYMBOL_NAME;
         return(false);
        }

      //--- order type
      if(!(_type==TRADE_BUY || _type==TRADE_SELL))
        {
         m_last_error=ERR_INVALID_ORDER_TYPE;
         return(false);
        }

      //--- get digits
      int _digits=(int)SymbolInfoInteger(_symbol,SYMBOL_DIGITS);

      //--- get coef point
      int _coef_point=1;
      if(_digits==3 || _digits==5)
         _coef_point=10;
#ifdef __MQL4__



      int attempts=5;
      while(attempts>0)
        {
         ResetLastError();

         if(IsTradeContextBusy())
           {
            Sleep(TRADE_PAUSE_SHORT);
            attempts--;
            continue;
           }

         RefreshRates();

         //--- check the free margin
         if(AccountFreeMarginCheck(_symbol,_type,_volume)<=0 || _LastError==ERR_NOT_ENOUGH_MONEY)
           {
            m_last_error=ERR_NOT_ENOUGH_MONEY;
            return(false);
           }

         //--- цена открытия
         double price=0.0;
         if(_type==OP_BUY)
            price=NormalizeDouble(SymbolInfoDouble(_symbol,SYMBOL_ASK),_digits);
         if(_type==OP_SELL)
            price=NormalizeDouble(SymbolInfoDouble(_symbol,SYMBOL_BID),_digits);

         //--- проскальзывание
         int slippage=(int)SymbolInfoInteger(_symbol,SYMBOL_SPREAD);

         //---
         //Print("symbol=",_symbol," type=",_type," vol=",_volume," price=",price," slippage=",slippage," magic=",_magic);
         int ticket=OrderSend(_symbol,_type,_volume,price,slippage,0,0,_comment,_magic,0,clrNONE);
         if(ticket>0)
           {
            if(_stop_loss>0 || _take_profit>0)
              {

               if(OrderSelect(ticket,SELECT_BY_TICKET))
                 {

                  //---
                  double order_open_price=NormalizeDouble(OrderOpenPrice(),_digits);
                  double order_stop_loss=NormalizeDouble(OrderStopLoss(),_digits);
                  double order_take_profit=NormalizeDouble(OrderTakeProfit(),_digits);

                  double sl=0.0;
                  double tp=0.0;

                  //---
                  attempts=5;
                  while(attempts>0)
                    {
                     ResetLastError();
                     RefreshRates();
                     //---
                     double _bid = SymbolInfoDouble(_symbol, SYMBOL_BID);
                     double _ask = SymbolInfoDouble(_symbol, SYMBOL_ASK);

                     if(IsTradeContextBusy())
                       {
                        attempts--;
                        Sleep(TRADE_PAUSE_SHORT);
                        continue;
                       }

                     //---
                     int stop_level=(int)SymbolInfoInteger(_symbol,SYMBOL_TRADE_STOPS_LEVEL);
                     int spread=(int)SymbolInfoInteger(_symbol,SYMBOL_SPREAD);
                     stop_level=fmax(stop_level,spread);

                     //---
                     if(OrderType()==OP_BUY)
                       {
                        if(_stop_loss==-1.0) sl=order_stop_loss;
                        else if(_stop_loss==0.0) sl=0.0;
                        else sl=NormalizeDouble(fmin(order_open_price-_stop_loss*_coef_point*_point,_bid-stop_level*_point),_digits);

                        if(_take_profit==-1.0) tp=order_take_profit;
                        else if(_take_profit==0.0) tp=0.0;
                        else tp=NormalizeDouble(fmax(order_open_price+_take_profit*_coef_point*_point,_bid+stop_level*_point),_digits);
                       }

                     if(OrderType()==OP_SELL)
                       {
                        if(_stop_loss==-1.0) sl=order_stop_loss;
                        else if(_stop_loss==0.0) sl=0.0;
                        else sl=NormalizeDouble(fmax(order_open_price+_stop_loss*_coef_point*_point,_ask+stop_level*_point),_digits);

                        if(_take_profit==-1.0) tp=order_take_profit;
                        else if(_take_profit==0.0) tp=0.0;
                        else tp=NormalizeDouble(fmin(order_open_price-_take_profit*_coef_point*_point,_ask-stop_level*_point),_digits);
                       }

                     if(sl==order_stop_loss && tp==order_take_profit)
                        return(true);

                     //---
                     ResetLastError();
                     if(OrderModify(ticket,order_open_price,sl,tp,0,clrNONE))
                       {
                        return(true);
                       }
                     else
                       {
                        //ENUM_ERROR_LEVEL level=PrintError(_LastError);
                        //if(level==LEVEL_ERROR)
                          {
                           Sleep(TRADE_PAUSE_LONG);
                           return(false);
                          }
                       }

                     //---
                     Sleep(TRADE_PAUSE_SHORT);
                     attempts--;
                    }// end while

                 }

               Sleep(TRADE_PAUSE_SHORT);
               return(true); //position opened
              }
            else
              {
               //ENUM_ERROR_LEVEL level=PrintError(_LastError);
               //if(level==LEVEL_ERROR)
                 {
                  Sleep(TRADE_PAUSE_LONG);
                  break;
                 }
              }// end else

            Sleep(TRADE_PAUSE_SHORT);
            attempts--;
           }
        }
#endif

#ifdef __MQL5__

      CTrade trade;
      ENUM_ORDER_TYPE order_type=-1;
      double price=0.0;
      double sl=0.0;
      double tp=0.0;
      double _ask=SymbolInfoDouble(_symbol,SYMBOL_ASK);
      double _bid=SymbolInfoDouble(_symbol,SYMBOL_BID);
      int stop_level=(int)SymbolInfoInteger(_symbol,SYMBOL_TRADE_STOPS_LEVEL);
      if(_type==TRADE_BUY)
        {
         order_type=ORDER_TYPE_BUY;
         price=_ask;

         if(_stop_loss>0)
            sl=NormalizeDouble(fmin(price-_stop_loss*_coef_point*_point,_bid-stop_level*_point),_digits);

         if(_take_profit>0)
            tp=NormalizeDouble(fmax(price+_take_profit*_coef_point*_point,_bid+stop_level*_point),_digits);

        }
      if(_type==TRADE_SELL)
        {
         order_type=ORDER_TYPE_SELL;
         price=_bid;

         if(_stop_loss>0)
            sl=NormalizeDouble(fmax(price+_stop_loss*_coef_point*_point,_ask+stop_level*_point),_digits);

         if(_take_profit>0)
            tp=NormalizeDouble(fmin(price-_take_profit*_coef_point*_point,_ask-stop_level*_point),_digits);
        }

      return(trade.PositionOpen(_symbol,order_type,_volume,price,sl,tp));
#endif

      return(true);
     }

   //+------------------------------------------------------------------+
   int GetLastError(){return(m_last_error);}
  };
//+------------------------------------------------------------------+
