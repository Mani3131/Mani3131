# Gold Trading Strategies

This repository contains advanced Pine Script strategies for trading Gold (XAUUSD).

## 🚀 THE SUPER INDICATOR: Gold Quantum Super Indicator V6

The **Gold Quantum Super Indicator** is the ultimate tool for XAUUSD, combining all strategies in this repository into a single, unified confluence engine.

### How it Works (Confluence Logic)
Instead of relying on a single indicator, the Super Indicator tracks four independent modules:
1. **Institutional Module (Aura):** VDM Z-Score and Session Liquidity Sweeps.
2. **Structural Module (SMC):** Order Blocks and Market Structure.
3. **Trend Module (AlphaTrend):** Advanced trailing trend tracking.
4. **Momentum Module (Ribbon & FVG):** EMA Ribbon alignment and Fair Value Gaps.

The indicator generates a **"QUANTUM BUY/SELL"** signal only when at least 2 out of 3 major confluence factors align, significantly reducing false signals.

### The Super Dashboard
The on-chart dashboard provides a real-time "Health Check" of the Gold market:
- **Aura VDM:** Momentum exhaustion status.
- **AlphaTrend & Ribbon:** Multi-layered trend alignment.
- **Confluence Score:** Real-time score (0-3) of signal strength.
- **Gold Bias:** Final recommendation (BUY/SELL/WAIT).

---

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
