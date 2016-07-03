//+------------------------------------------------------------------+
//|                                                           MA.mqh |
//|                            Copyright 2016, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

#property strict
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
class CMovingTrade : public CBasicTrade
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
   bool Signal(const ENUM_TRADE_DIRECTION _cmd,const ENUM_TIMEFRAMES _tf=PERIOD_CURRENT,const int _open_method=OPEN_METHOD_1)
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
            if((_open_method&OPEN_METHOD_1) == OPEN_METHOD_1) result[i] = m_val[FAST][index][CUR]   > m_val[MEDIUM][index][CUR];
            if((_open_method&OPEN_METHOD_2) == OPEN_METHOD_2) result[i] = m_val[FAST][index][CUR]   > m_val[SLOW][index][CUR];
            if((_open_method&OPEN_METHOD_3) == OPEN_METHOD_3) result[i] = m_val[MEDIUM][index][CUR] > m_val[SLOW][index][CUR];
            if((_open_method&OPEN_METHOD_4) == OPEN_METHOD_4) result[i] = m_val[SLOW][index][CUR]   > m_val[SLOW][index][PREV];
            //---
            if((_open_method&OPEN_METHOD_5) == OPEN_METHOD_5) result[i] = m_val[FAST][index][CUR]    > m_val[FAST][index][PREV];
            if((_open_method&OPEN_METHOD_6) == OPEN_METHOD_6) result[i] = m_val[FAST][index][CUR]    - m_val[MEDIUM][index][CUR]   >  m_val[MEDIUM][index][CUR]  -  m_val[SLOW][index][CUR];
            if((_open_method&OPEN_METHOD_7) == OPEN_METHOD_7) result[i] = (m_val[MEDIUM][index][PREV]< m_val[SLOW][index][PREV]     || m_val[MEDIUM][index][FAR]  <  m_val[SLOW][index][FAR]);
            if((_open_method&OPEN_METHOD_8) == OPEN_METHOD_8) result[i] = (m_val[FAST][index][PREV]  < m_val[MEDIUM][index][PREV]   || m_val[FAST][index][FAR]    <  m_val[MEDIUM][index][FAR]);
           }
         //---
         if(_cmd==TRADE_SELL)
           {
            if((_open_method&OPEN_METHOD_1) == OPEN_METHOD_1) result[i] = m_val[FAST][index][CUR]    < m_val[MEDIUM][index][CUR];
            if((_open_method&OPEN_METHOD_2) == OPEN_METHOD_2) result[i] = m_val[FAST][index][CUR]    < m_val[SLOW][index][CUR];
            if((_open_method&OPEN_METHOD_3) == OPEN_METHOD_3) result[i] = m_val[MEDIUM][index][CUR]  < m_val[SLOW][index][CUR];
            if((_open_method&OPEN_METHOD_4) == OPEN_METHOD_4) result[i] = m_val[SLOW][index][CUR]    < m_val[SLOW][index][PREV];
            //---
            if((_open_method&OPEN_METHOD_5) == OPEN_METHOD_5) result[i] = m_val[FAST][index][CUR]    < m_val[FAST][index][PREV];
            if((_open_method&OPEN_METHOD_6) == OPEN_METHOD_6) result[i] = m_val[MEDIUM][index][CUR]  - m_val[FAST][index][CUR]     >  m_val[SLOW][index][CUR]   -  m_val[MEDIUM][index][CUR];
            if((_open_method&OPEN_METHOD_7) == OPEN_METHOD_7) result[i] = (m_val[MEDIUM][index][PREV]> m_val[SLOW][index][PREV]    || m_val[MEDIUM][index][FAR]   >  m_val[SLOW][index][FAR]);
            if((_open_method&OPEN_METHOD_8) == OPEN_METHOD_8) result[i] = (m_val[FAST][index][PREV]  > m_val[MEDIUM][index][PREV]  || m_val[FAST][index][FAR]     >  m_val[MEDIUM][index][FAR]);
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
  };
//+------------------------------------------------------------------+
