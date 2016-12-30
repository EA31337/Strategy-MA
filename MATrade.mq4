//+------------------------------------------------------------------+
//|                                                      MATrade.mq4 |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property version   "1.00"
#property strict

#include <MA.mqh>

//+------------------------------------------------------------------+
//|   Input parameters                                               |
//+------------------------------------------------------------------+
input ENUM_TIMEFRAMES InpTimeframe=PERIOD_H1;//Timeframe
//---
input uint MA_Period_Fast=10;//Period Fast
input uint MA_Period_Medium=18;//Period Medium
input uint MA_Period_Slow=42;//Period Slow
//---
input uint MA_Shift_Fast=0;//Shift Fast
input uint MA_Shift_Medium=2;//Shift Medium
input uint MA_Shift_Slow=5;//Shift Slow
//---
input ENUM_MA_METHOD MA_Method=MODE_EMA;//Method
input ENUM_APPLIED_PRICE MA_Applied_Price=PRICE_CLOSE;//Applied Price
input ENUM_OPEN_METHOD MA_OpenMethod=OPEN_METHOD1;//Open Method

//---
input double InpVolume=0.01;     // Volume
input uint  InpStopLoss=10;      // Stop Loss, pips
input uint  InpTakeProfit=10;    // Take Profit, pips
input uint  InpMagicNumber=1;    // Magic Number

//--- global vars
CMovingTrade moving;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(!moving.SetFast(_Symbol,MA_Period_Fast,MA_Shift_Fast,MA_Method,MA_Applied_Price))return(INIT_FAILED);
   if(!moving.SetMedium(_Symbol,MA_Period_Medium,MA_Shift_Medium,MA_Method,MA_Applied_Price))return(INIT_FAILED);
   if(!moving.SetSlow(_Symbol,MA_Period_Slow,MA_Shift_Slow,MA_Method,MA_Applied_Price))return(INIT_FAILED);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {

   int pos_count;
//--- BUY
   if(PositonTotal(_Symbol,TRADE_BUY,InpMagicNumber,pos_count) && pos_count==0)
     {
      datetime last_time=0;
      if(!DealLastTime(_Symbol,TRADE_BUY,InpMagicNumber,last_time))return;

      if(last_time<Time(_Symbol,InpTimeframe,0))
        {
         bool signal_buy=moving.Signal(TRADE_BUY,(ENUM_TIMEFRAMES)InpTimeframe,OPEN_METHOD_1|OPEN_METHOD_2);
         if(signal_buy)
           {
            if(!moving.Trade(_Symbol,TRADE_BUY,InpVolume,InpStopLoss,InpTakeProfit,NULL,InpMagicNumber))
               Print("Error ",moving.GetLastError());
            return;
           }
        }
     }

//--- SELL
   if(PositonTotal(_Symbol,TRADE_SELL,InpMagicNumber,pos_count) && pos_count==0)
     {
      datetime last_time=0;
      if(!DealLastTime(_Symbol,TRADE_SELL,InpMagicNumber,last_time))return;

      if(last_time<Time(_Symbol,InpTimeframe,0))
        {
         bool signal_sell=moving.Signal(TRADE_SELL,(ENUM_TIMEFRAMES)InpTimeframe,MA_OpenMethod);
         if(signal_sell)
           {
            if(!moving.Trade(_Symbol,TRADE_SELL,InpVolume,InpStopLoss,InpTakeProfit,NULL,InpMagicNumber))
               Print("Error ",moving.GetLastError());
            return;
           }
        }
     }
//---
  }
//+------------------------------------------------------------------+
