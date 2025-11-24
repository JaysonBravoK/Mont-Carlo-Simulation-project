%% ===================================================================
%% Monte Carlo Simulation for Derivative Pricing - Main Program
%% ===================================================================
%
% This is the main script for Monte Carlo simulation of derivative pricing
% Supports multiple derivative types including European options, Asian options,
% and barrier options with real market data analysis
%
% Author: Financial Engineering Portfolio

%
% Compatibility: MATLAB R2024a and later
% System: macOS/Windows
%
%% ===================================================================

clear; clc; close all;

% Add source directory to path
addpath(genpath('src'));

fprintf('=================================================================\n');
fprintf('Monte Carlo Simulation for Derivative Pricing System\n');
fprintf('=================================================================\n\n');

%% ===================================================================
%% Section 1: Market Data Download and Parameters Setup
%% ===================================================================

% First, download and generate market data
fprintf('Downloading market data...\n');
market_data = download_market_data();

% Set up market parameters using downloaded data
market_params = struct();
market_params.S0 = market_data.current_price;      % Current stock price from data
market_params.K = market_data.current_price;       % At-the-money strike price
market_params.T = 1;                               % Time to maturity (1 year)
market_params.r = market_data.risk_free_rate;      % Risk-free rate from data
market_params.sigma = market_data.realized_volatility;  % Realized volatility from data
market_params.q = market_data.dividend_yield;      % Dividend yield from data

% Monte Carlo simulation parameters
mc_params = struct();
mc_params.num_simulations = 100000;  % Number of Monte Carlo paths
mc_params.num_steps = 252;           % Number of time steps (daily)
mc_params.random_seed = 12345;       % Random seed for reproducibility

fprintf('Market Data Summary:\n');
fprintf('  Data Source: %s\n', market_data.data_source);
fprintf('  Last Updated: %s\n', char(market_data.last_updated));
fprintf('  52-Week Range: $%.2f - $%.2f\n', market_data.min_price_52w, market_data.max_price_52w);
fprintf('\n');

fprintf('Market Parameters (from real data):\n');
fprintf('  Current Stock Price (S0): $%.2f\n', market_params.S0);
fprintf('  Strike Price (K): $%.2f (ATM)\n', market_params.K);
fprintf('  Time to Maturity (T): %.1f year\n', market_params.T);
fprintf('  Risk-free Rate (r): %.2f%%\n', market_params.r * 100);
fprintf('  Realized Volatility (sigma): %.2f%%\n', market_params.sigma * 100);
fprintf('  Dividend Yield (q): %.2f%%\n', market_params.q * 100);
fprintf('\n');

fprintf('Monte Carlo Parameters:\n');
fprintf('  Number of Simulations: %d\n', mc_params.num_simulations);
fprintf('  Number of Time Steps: %d\n', mc_params.num_steps);
fprintf('  Random Seed: %d\n\n', mc_params.random_seed);

%% ===================================================================
%% Section 2: European Options Pricing
%% ===================================================================

fprintf('=================================================================\n');
fprintf('European Options Pricing\n');
fprintf('=================================================================\n');

% Price European call and put options
[call_price, put_price, call_std, put_std, stock_paths] = ...
    price_european_options(market_params, mc_params);

% Calculate Black-Scholes theoretical prices for comparison
bs_call = black_scholes_call(market_params.S0, market_params.K, ...
    market_params.T, market_params.r, market_params.sigma, market_params.q);
bs_put = black_scholes_put(market_params.S0, market_params.K, ...
    market_params.T, market_params.r, market_params.sigma, market_params.q);

fprintf('European Call Option:\n');
fprintf('  Monte Carlo Price: $%.4f (±%.4f)\n', call_price, call_std);
fprintf('  Black-Scholes Price: $%.4f\n', bs_call);
fprintf('  Absolute Error: $%.4f\n', abs(call_price - bs_call));
fprintf('  Relative Error: %.4f%%\n\n', abs(call_price - bs_call) / bs_call * 100);

fprintf('European Put Option:\n');
fprintf('  Monte Carlo Price: $%.4f (±%.4f)\n', put_price, put_std);
fprintf('  Black-Scholes Price: $%.4f\n', bs_put);
fprintf('  Absolute Error: $%.4f\n', abs(put_price - bs_put));
fprintf('  Relative Error: %.4f%%\n\n', abs(put_price - bs_put) / bs_put * 100);

%% ===================================================================
%% Section 3: Asian Options Pricing
%% ===================================================================

fprintf('=================================================================\n');
fprintf('Asian Options Pricing\n');
fprintf('=================================================================\n');

% Price Asian (average price) options
[asian_call_price, asian_put_price, asian_call_std, asian_put_std] = ...
    price_asian_options(market_params, mc_params);

fprintf('Asian Call Option (Arithmetic Average):\n');
fprintf('  Monte Carlo Price: $%.4f (±%.4f)\n', asian_call_price, asian_call_std);
fprintf('\n');

fprintf('Asian Put Option (Arithmetic Average):\n');
fprintf('  Monte Carlo Price: $%.4f (±%.4f)\n', asian_put_price, asian_put_std);
fprintf('\n');

%% ===================================================================
%% Section 4: Barrier Options Pricing
%% ===================================================================

fprintf('=================================================================\n');
fprintf('Barrier Options Pricing\n');
fprintf('=================================================================\n');

% Set barrier level
barrier_level = 90;  % Barrier at $90

% Price barrier options
[barrier_call_price, barrier_put_price, barrier_call_std, barrier_put_std] = ...
    price_barrier_options(market_params, mc_params, barrier_level);

fprintf('Down-and-Out Call Option (Barrier = $%.2f):\n', barrier_level);
fprintf('  Monte Carlo Price: $%.4f (±%.4f)\n', barrier_call_price, barrier_call_std);
fprintf('\n');

fprintf('Down-and-Out Put Option (Barrier = $%.2f):\n', barrier_level);
fprintf('  Monte Carlo Price: $%.4f (±%.4f)\n', barrier_put_price, barrier_put_std);
fprintf('\n');

%% ===================================================================
%% Section 5: Greeks Calculation
%% ===================================================================

fprintf('=================================================================\n');
fprintf('Greeks Calculation (Finite Difference Method)\n');
fprintf('=================================================================\n');

% Calculate Greeks using finite difference method
greeks = calculate_greeks(market_params, mc_params);

fprintf('European Call Option Greeks:\n');
fprintf('  Delta: %.4f\n', greeks.call_delta);
fprintf('  Gamma: %.4f\n', greeks.call_gamma);
fprintf('  Theta: %.4f\n', greeks.call_theta);
fprintf('  Vega: %.4f\n', greeks.call_vega);
fprintf('  Rho: %.4f\n\n', greeks.call_rho);

fprintf('European Put Option Greeks:\n');
fprintf('  Delta: %.4f\n', greeks.put_delta);
fprintf('  Gamma: %.4f\n', greeks.put_gamma);
fprintf('  Theta: %.4f\n', greeks.put_theta);
fprintf('  Vega: %.4f\n', greeks.put_vega);
fprintf('  Rho: %.4f\n\n', greeks.put_rho);

%% ===================================================================
%% Section 6: Results Visualization
%% ===================================================================

fprintf('=================================================================\n');
fprintf('Generating Visualization Results\n');
fprintf('=================================================================\n');

% Generate comprehensive plots
generate_plots(stock_paths, market_params, mc_params, ...
    call_price, put_price, asian_call_price, asian_put_price, ...
    barrier_call_price, barrier_put_price, barrier_level, greeks);

%% ===================================================================
%% Section 7: Sensitivity Analysis
%% ===================================================================

fprintf('=================================================================\n');
fprintf('Sensitivity Analysis\n');
fprintf('=================================================================\n');

% Perform sensitivity analysis
sensitivity_analysis(market_params, mc_params);

%% ===================================================================
%% Section 8: Generate Results Summary
%% ===================================================================

fprintf('=================================================================\n');
fprintf('Generating Results Summary\n');
fprintf('=================================================================\n');

% Save results to file
results = struct();
results.market_params = market_params;
results.mc_params = mc_params;
results.european_call = struct('mc_price', call_price, 'bs_price', bs_call, 'std_error', call_std);
results.european_put = struct('mc_price', put_price, 'bs_price', bs_put, 'std_error', put_std);
results.asian_call = struct('mc_price', asian_call_price, 'std_error', asian_call_std);
results.asian_put = struct('mc_price', asian_put_price, 'std_error', asian_put_std);
results.barrier_call = struct('mc_price', barrier_call_price, 'std_error', barrier_call_std);
results.barrier_put = struct('mc_price', barrier_put_price, 'std_error', barrier_put_std);
results.greeks = greeks;

% Save results to MAT file
save('results/monte_carlo_results.mat', 'results');

% Generate Excel report
generate_excel_report(results);

fprintf('\nMonte Carlo simulation completed successfully!\n');
fprintf('Results saved to results/ directory\n');
fprintf('=================================================================\n'); 