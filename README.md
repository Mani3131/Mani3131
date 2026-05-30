# Gold Trading Strategies

This repository contains advanced Pine Script strategies for trading Gold (XAUUSD).

## Featured Strategy: Aura of Midas: Quantum Institutional Flow [V6]

The **Aura of Midas** is a comprehensive, institutional-grade trading strategy specifically optimized for XAUUSD. It combines several advanced concepts to identify high-probability reversal and continuation points.

### Key Features

- **Volatility-Decoupled Momentum (VDM):** Uses Z-score normalization to identify momentum exhaustion and extreme price deviations.
- **Session Liquidity Capture (SLC):** Automatically tracks liquidity pools from the London and New York session opens to detect "stop hunts" or liquidity sweeps.
- **Golden Ratio Displacement (GRD):** Uses ATR-based bands with Fibonacci multipliers (1.618) to identify overextended price levels.
- **HTF Trend Filter:** Multi-timeframe trend alignment ensures trades are taken in the direction of the higher-timeframe market structure.
- **Advanced Risk Management:** Includes ATR-based stop-loss and take-profit levels, breakeven logic, and trailing stops.
- **Real-time Dashboard:** A comprehensive on-chart dashboard providing instant feedback on VDM levels, trend status, and wick rejection quality.

### How to Use

1. Copy the code from `aura_of_midas_gold_v6.pine`.
2. Open TradingView and go to the **Pine Editor**.
3. Paste the code and click **Add to Chart**.
4. Adjust the settings in the **Inputs** tab to match your trading style.

---

## Other Strategies

- **Smart Money Concepts (SMC) V6:** A professional-grade indicator focusing on institutional order flow, Order Blocks (OB), and Market Structure (BOS/CHoCH). It is highly effective for Gold due to the asset's tendency to respect institutional liquidity levels.
- **Gold AI AlphaTrend:** A trend-following strategy using the AlphaTrend indicator with MFI/RSI filters.
- **Apex Scalper V6:** A scalping-focused indicator featuring EMA ribbons and Fair Value Gap (FVG) detection.
