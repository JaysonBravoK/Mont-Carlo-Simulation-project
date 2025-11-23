function market_data = download_market_data()
%% ===================================================================
%% Download Market Data for Monte Carlo Analysis
%% ===================================================================
%
% This function creates sample market data for Monte Carlo simulation
% In a real implementation, this would connect to financial data APIs
% like Yahoo Finance, Bloomberg, or Quandl
%
% Output:
%   market_data - Structure containing historical price data and parameters
%
%% ===================================================================

fprintf('Generating sample market data...\n');

% Create synthetic historical data for demonstration
% In practice, replace this with actual API calls

% Time series parameters
num_days = 252;  % One year of trading days
initial_price = 100;
annual_volatility = 0.25;
annual_drift = 0.08;

% Generate dates
dates = datetime('today') - days(num_days-1:-1:0);

% Generate synthetic price path using geometric Brownian motion
rng(42);  % Fixed seed for reproducible data
dt = 1/252;  % Daily time step
dW = randn(num_days-1, 1) * sqrt(dt);
returns = (annual_drift - 0.5 * annual_volatility^2) * dt + annual_volatility * dW;

% Calculate price path
prices = zeros(num_days, 1);
prices(1) = initial_price;
for i = 2:num_days
    prices(i) = prices(i-1) * exp(returns(i-1));
end

% Calculate realized volatility from price data
log_returns = diff(log(prices));
realized_volatility = std(log_returns) * sqrt(252);

% Estimate drift from data
realized_drift = mean(log_returns) * 252 + 0.5 * realized_volatility^2;

% Create market data structure
market_data = struct();
market_data.dates = dates;
market_data.prices = prices;
market_data.returns = [NaN; log_returns];  % First return is NaN
market_data.current_price = prices(end);
market_data.realized_volatility = realized_volatility;
market_data.realized_drift = realized_drift;
market_data.data_source = 'Synthetic Data';
market_data.last_updated = datetime('now');

% Add some market indicators
market_data.min_price_52w = min(prices);
market_data.max_price_52w = max(prices);
market_data.price_range_52w = market_data.max_price_52w - market_data.min_price_52w;

% Calculate some technical indicators
% Simple moving averages
market_data.sma_20 = calculate_sma(prices, 20);
market_data.sma_50 = calculate_sma(prices, 50);

% Risk-free rate (simulated from current economic conditions)
market_data.risk_free_rate = 0.045;  % 4.5% annual

% Dividend yield estimate
market_data.dividend_yield = 0.02;  % 2% annual

% Save to data directory
data_filename = 'data/market_data.mat';
save(data_filename, 'market_data');

% Also save as CSV for external analysis
% Ensure all variables have the same length
dates_vec = market_data.dates(:);
prices_vec = market_data.prices(:);
returns_vec = market_data.returns(:);

% Check lengths and adjust if necessary
min_length = min([length(dates_vec), length(prices_vec), length(returns_vec)]);
dates_vec = dates_vec(1:min_length);
prices_vec = prices_vec(1:min_length);
returns_vec = returns_vec(1:min_length);

csv_data = table(dates_vec, prices_vec, returns_vec, ...
    'VariableNames', {'Date', 'Price', 'LogReturn'});
writetable(csv_data, 'data/historical_prices.csv');

fprintf('Market data generated and saved to data/ directory\n');
fprintf('  Current price: $%.2f\n', market_data.current_price);
fprintf('  Realized volatility: %.2f%%\n', market_data.realized_volatility * 100);
fprintf('  52-week range: $%.2f - $%.2f\n', ...
    market_data.min_price_52w, market_data.max_price_52w);
fprintf('  Risk-free rate: %.2f%%\n', market_data.risk_free_rate * 100);

%% ===================================================================
%% Generate Option Chain Data (Sample)
%% ===================================================================

% Create sample option chain data
strikes = (80:5:120)';  % Strike prices from 80 to 120
times_to_expiry = [30, 60, 90, 180, 365] / 365;  % Various maturities

option_chain = struct();
option_chain.strikes = strikes;
option_chain.maturities = times_to_expiry;
option_chain.current_underlying = market_data.current_price;

% Calculate theoretical Black-Scholes prices for the option chain
for i = 1:length(times_to_expiry)
    T = times_to_expiry(i);
    
    call_prices = zeros(size(strikes));
    put_prices = zeros(size(strikes));
    
    for j = 1:length(strikes)
        K = strikes(j);
        call_prices(j) = black_scholes_call(market_data.current_price, K, T, ...
            market_data.risk_free_rate, market_data.realized_volatility, ...
            market_data.dividend_yield);
        put_prices(j) = black_scholes_put(market_data.current_price, K, T, ...
            market_data.risk_free_rate, market_data.realized_volatility, ...
            market_data.dividend_yield);
    end
    
    option_chain.call_prices{i} = call_prices;
    option_chain.put_prices{i} = put_prices;
end

% Save option chain data
save('data/option_chain.mat', 'option_chain');

fprintf('Sample option chain data generated and saved\n');

end

%% ===================================================================
%% Helper Function: Simple Moving Average
%% ===================================================================

function sma = calculate_sma(prices, window)
%
% Calculate simple moving average
%
% Inputs:
%   prices - Vector of prices
%   window - Moving average window size
%
% Output:
%   sma - Simple moving average (NaN for insufficient data points)
%

n = length(prices);
sma = NaN(n, 1);

for i = window:n
    sma(i) = mean(prices(i-window+1:i));
end

end 