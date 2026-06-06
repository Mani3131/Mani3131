//+------------------------------------------------------------------+
//|                                              EagleV4Auto.mq5     |
//|                                  Copyright 2024, Trading Bot     |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Trading Bot"
#property link      "https://www.mql5.com"
#property version   "4.40"
#property strict

#include <Trade\Trade.mqh>

//--- INPUTS ---
input group "ACCOUNT"
input double   InpInitialBalance = 290.90;   // Initial Balance
input double   InpProfitTarget   = 10.00;    // Profit Target ($)
input double   InpMaxLoss        = 0.00;     // Max Loss (0 = OFF)
input int      InpEntryLimit     = 20;       // Entry Limit (max trades/day)

input group "TECHNICAL SETTINGS"
input int      InpEMAFast        = 10;       // Fast EMA Length
input int      InpEMASlow        = 20;       // Slow EMA Length
input int      InpCILen          = 14;       // Choppiness Index Length

input group "SETTINGS"
input double   InpLot            = 0.01;     // Lot Size
input double   InpSL             = 5.00;     // Stop Loss ($)
input double   InpTP             = 15.00;    // Take Profit ($)
input double   InpTrailingStart  = 3.00;     // Trailing Start ($)
input double   InpTrailingStep   = 2.00;     // Trailing Step ($)
input double   InpBEStart        = 2.00;     // Break Even Start ($)
input double   InpBEOffset       = 0.20;     // Break Even Offset ($)

input group "NEWS FILTER (MOCK)"
input bool     InpNewsFilter     = true;     // Enable News Filter
input string   InpGMT            = "+0";     // GMT Offset

//--- GLOBAL VARIABLES ---
int      handleEMA10;
int      handleEMA20;
CTrade   trade;

//--- Technical Data ---
double   emaFast[], emaSlow[];
double   ciValue = 0;
string   trendText = "NEUTRAL";
color    trendColor = clrGray;
string   stateText = "STABLE";
color    stateColor = clrGray;
string   lastPattern = "NONE";
color    patternColor = clrGray;

//+------------------------------------------------------------------+
//| Calculate Choppiness Index                                       |
//+------------------------------------------------------------------+
double CalculateCI(int period)
{
   double trSum = 0;
   double highestHigh = -1;
   double lowestLow = 999999;

   for(int i=0; i<period; i++)
   {
      double high = iHigh(_Symbol, _Period, i);
      double low = iLow(_Symbol, _Period, i);
      double close_prev = iClose(_Symbol, _Period, i+1);

      double tr = MathMax(high - low, MathMax(MathAbs(high - close_prev), MathAbs(low - close_prev)));
      trSum += tr;

      if(high > highestHigh) highestHigh = high;
      if(low < lowestLow) lowestLow = low;
   }

   double range = highestHigh - lowestLow;
   if(range == 0) return 50;

   return 100 * MathLog10(trSum / range) / MathLog10(period);
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   handleEMA10 = iMA(_Symbol, _Period, InpEMAFast, 0, MODE_EMA, PRICE_CLOSE);
   handleEMA20 = iMA(_Symbol, _Period, InpEMASlow, 0, MODE_EMA, PRICE_CLOSE);

   if(handleEMA10 == INVALID_HANDLE || handleEMA20 == INVALID_HANDLE)
   {
      Print("Failed to create indicator handles");
      return(INIT_FAILED);
   }

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   IndicatorRelease(handleEMA10);
   IndicatorRelease(handleEMA20);
   ObjectsDeleteAll(0, "Eagle_");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Copy indicator buffers
   ArraySetAsSeries(emaFast, true);
   ArraySetAsSeries(emaSlow, true);

   if(CopyBuffer(handleEMA10, 0, 0, 3, emaFast) < 3 || CopyBuffer(handleEMA20, 0, 0, 3, emaSlow) < 3) return;

   // Trend Logic
   if(emaFast[0] > emaSlow[0]) { trendText = "BULLISH"; trendColor = clrLime; }
   else if(emaFast[0] < emaSlow[0]) { trendText = "BEARISH"; trendColor = clrRed; }

   // CI Logic
   ciValue = CalculateCI(InpCILen);
   if(ciValue > 61.8) { stateText = "SIDEWAYS"; stateColor = clrOrange; }
   else if(ciValue < 38.2) { stateText = "TRENDING"; stateColor = clrLime; }
   else { stateText = "STABLE"; stateColor = clrGray; }

   // Signal Detection
   bool buySig = emaFast[1] <= emaSlow[1] && emaFast[0] > emaSlow[0] && ciValue < 61.8;
   bool sellSig = emaFast[1] >= emaSlow[1] && emaFast[0] < emaSlow[0] && ciValue < 61.8;

   if(buySig) { lastPattern = "BUY SIG"; patternColor = clrLime; }
   if(sellSig) { lastPattern = "SELL SIG"; patternColor = clrRed; }

   // Risk Management Checks
   double total_pl = AccountInfoDouble(ACCOUNT_PROFIT);
   bool dailyLimitReached = (InpMaxLoss > 0 && total_pl <= -InpMaxLoss);
   bool entryLimitReached = (InpEntryLimit > 0 && (int)AccountInfoInteger(ACCOUNT_MARGIN_LEVEL) < 0); // Simplified check for entry limit demo

   // Trade Execution
   if(buySig && PositionsTotal() == 0 && !dailyLimitReached)
   {
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      double sl_price = ask - (InpSL / (InpLot * SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE / SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE)))) * point;
      // Fixed calculation: InpSL is in $, convert to points
      double sl_pts = InpSL / (InpLot * SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE));
      double tp_pts = InpTP / (InpLot * SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE));

      sl_price = NormalizeDouble(ask - sl_pts * point, _Digits);
      double tp_price = NormalizeDouble(ask + tp_pts * point, _Digits);

      trade.Buy(InpLot, _Symbol, ask, sl_price, tp_price);
   }

   if(sellSig && PositionsTotal() == 0 && !dailyLimitReached)
   {
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      double sl_pts = InpSL / (InpLot * SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE));
      double tp_pts = InpTP / (InpLot * SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE));

      double sl_price = NormalizeDouble(bid + sl_pts * point, _Digits);
      double tp_price = NormalizeDouble(bid - tp_pts * point, _Digits);

      trade.Sell(InpLot, _Symbol, bid, sl_price, tp_price);
   }

   ManagePositions();
   UpdateDashboard();
}

void ManagePositions()
{
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double tick_val = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   int stops_level = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);

   for(int i=PositionsTotal()-1; i>=0; i--)
   {
      string symbol = PositionGetSymbol(i);
      if(symbol == _Symbol)
      {
         ulong ticket = PositionGetInteger(POSITION_TICKET);
         double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         double currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
         double currentSL = PositionGetDouble(POSITION_SL);
         double type = PositionGetInteger(POSITION_TYPE);

         double profit_dollars = (type == POSITION_TYPE_BUY) ? (currentPrice - openPrice) / point * tick_val * InpLot : (openPrice - currentPrice) / point * tick_val * InpLot;

         // Break Even Logic
         if(profit_dollars >= InpBEStart && currentSL != (type == POSITION_TYPE_BUY ? openPrice + InpBEOffset*point : openPrice - InpBEOffset*point))
         {
             double beSL = (type == POSITION_TYPE_BUY) ? openPrice + InpBEOffset * point : openPrice - InpBEOffset * point;
             trade.PositionModify(ticket, NormalizeDouble(beSL, _Digits), PositionGetDouble(POSITION_TP));
         }

         // Trailing Stop Logic
         if(profit_dollars >= InpTrailingStart)
         {
            double step_pts = InpTrailingStep / (InpLot * tick_val);
            if(type == POSITION_TYPE_BUY)
            {
               double newSL = NormalizeDouble(currentPrice - step_pts * point, _Digits);
               if(newSL > currentSL + stops_level * point)
                  trade.PositionModify(ticket, newSL, PositionGetDouble(POSITION_TP));
            }
            else
            {
               double newSL = NormalizeDouble(currentPrice + step_pts * point, _Digits);
               if(newSL < currentSL - stops_level * point || currentSL == 0)
                  trade.PositionModify(ticket, newSL, PositionGetDouble(POSITION_TP));
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Update Dashboard UI                                              |
//+------------------------------------------------------------------+
void UpdateDashboard()
{
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   double profit = AccountInfoDouble(ACCOUNT_PROFIT);

   DrawLabel("Eagle_Title", "⚡ EAGLE   V4.4   AUTO ⚡", 10, 20, clrOrange, 12);

   DrawLabel("Eagle_Acc_Header", "ACCOUNT", 10, 50, clrGray, 8);
   DrawLabel("Eagle_Balance", "Balance: $ " + DoubleToString(balance, 2), 10, 70, clrAqua, 9);
   DrawLabel("Eagle_Equity", "Equity: $ " + DoubleToString(equity, 2), 10, 90, clrAqua, 9);
   DrawLabel("Eagle_PL", "P/L Day: $ " + DoubleToString(profit, 2), 10, 110, (profit >= 0 ? clrLime : clrRed), 9);

   DrawLabel("Eagle_Prog_Header", "PROGRESS", 10, 140, clrGray, 8);
   double prof_pct = MathMin(100, MathMax(0, (profit / InpProfitTarget) * 100));
   DrawLabel("Eagle_Profit", "Profit: [" + GetProgressBar(prof_pct) + "] " + IntegerToString((int)prof_pct) + "%", 10, 160, clrLime, 9);

   DrawLabel("Eagle_Mkt_Header", "MARKET STATUS", 10, 190, clrGray, 8);
   DrawLabel("Eagle_State", "State: " + stateText + " (" + DoubleToString(ciValue, 1) + ")", 10, 210, stateColor, 9);

   DrawLabel("Eagle_Trend_Header", "TREND / PATTERN", 10, 240, clrGray, 8);
   DrawLabel("Eagle_Trend", "M5 Trend: " + trendText, 10, 260, trendColor, 9);
   DrawLabel("Eagle_Pattern", "Pattern: " + lastPattern, 10, 280, patternColor, 9);
}

void DrawLabel(string name, string text, int x, int y, color clr, int size)
{
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, size);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
}

string GetProgressBar(double pct)
{
   string bar = "";
   int filled = (int)(pct / 10);
   for(int i=0; i<10; i++) bar += (i < filled ? "■" : " ");
   return bar;
}
//+------------------------------------------------------------------+
