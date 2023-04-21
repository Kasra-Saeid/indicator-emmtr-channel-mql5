#property copyright "Copyright 2023, KaiAlgo"
#property version   "1.00"
#property indicator_chart_window

#property indicator_buffers 2
#property indicator_plots 2

#property indicator_type1 DRAW_LINE
#property indicator_label1 "lower line"
#property indicator_color1 clrBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1

#property indicator_type2 DRAW_LINE
#property indicator_label2 "upper line"
#property indicator_color2 clrBlue
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1

int maxPeriod;

input ENUM_MA_METHOD emaMethod = MODE_EMA;   // Ma Method
input int emaPeriod = 18;              // Ema Period
input int atrPeriod = 18;              // Atr Period
input double multiplier = 2;           // Multiplier

double UpperBuffer[];
double LowerBuffer[];

double atrBuffer[];
double emaBuffer[];

int atrHandle;
int emaHandle;

int OnInit() {

   SetIndexBuffer(0, LowerBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, UpperBuffer, INDICATOR_DATA);
   
   atrHandle = iATR(_Symbol, _Period, atrPeriod);
   emaHandle = iMA(_Symbol, _Period, emaPeriod, 0, emaMethod, PRICE_CLOSE);
   
   maxPeriod = (int)MathMax(atrPeriod, emaPeriod);
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, maxPeriod);
   
   return(INIT_SUCCEEDED);
}



void OnDeinit(const int reason) {
   if(atrHandle != INVALID_HANDLE) IndicatorRelease(atrHandle);
   if(emaHandle != INVALID_HANDLE) IndicatorRelease(emaHandle);
}
  


int OnCalculate(const int rates_total, // rates_total is the number of total available candles
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]){
   
   if (IsStopped()) return 0;             // This line respects MetaTrader stop flag
   if (rates_total < maxPeriod) return 0; // To check if there is sufficient candles to calculate indicator
   
   if (BarsCalculated(emaHandle) < rates_total) return 0;
   
   int copyBars = 0;
   if (prev_calculated > rates_total || prev_calculated <= 0) {
      copyBars = rates_total;
   } else {
      copyBars = rates_total - prev_calculated;
   }
   
   if (IsStopped()) return 0;
   
   CopyBuffer(emaHandle, 0, 0, copyBars, emaBuffer);
   CopyBuffer(atrHandle, 0, 0, copyBars, atrBuffer);
   

   for(int i = copyBars - 1; i >= 0; i--) {
      LowerBuffer[ArraySize(LowerBuffer) - 1 - i] = emaBuffer[ArraySize(emaBuffer) - 1 - i] - (multiplier * atrBuffer[ArraySize(atrBuffer) - 1 - i]);
      UpperBuffer[ArraySize(UpperBuffer) - 1 - i] = emaBuffer[ArraySize(emaBuffer) - 1 - i] + (multiplier * atrBuffer[ArraySize(atrBuffer) - 1 - i]);
   }


   return(rates_total);
}
