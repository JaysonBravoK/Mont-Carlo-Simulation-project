function [asian_call_price, asian_put_price, asian_call_std, asian_put_std] = ...
    price_asian_options(market_params, mc_params)
%% ===================================================================
%% Asian Options Pricing using Monte Carlo Simulation
%% ===================================================================
%
% This function prices Asian (average price) call and put options using
% Monte Carlo simulation. Asian options have payoffs that depend on the
% average price of the underlying asset over the life of the option.
%
% Inputs:
%   market_params - Structure containing market parameters
%   mc_params     - Structure containing Monte Carlo parameters
%
% Outputs:
%   asian_call_price - Monte Carlo estimated Asian call option price
%   asian_put_price  - Monte Carlo estimated Asian put option price
%   asian_call_std   - Standard error of Asian call option price estimate
%   asian_put_std    - Standard error of Asian put option price estimate
%
% Asian Option Payoffs:
%   Call: max(Average_Price - Strike, 0)
%   Put:  max(Strike - Average_Price, 0)
%
%% ===================================================================

% Extract market parameters
S0 = market_params.S0;          % Initial stock price
K = market_params.K;            % Strike price
T = market_params.T;            % Time to maturity
r = market_params.r;            % Risk-free rate
sigma = market_params.sigma;    % Volatility
q = market_params.q;            % Dividend yield

% Extract Monte Carlo parameters
num_sims = mc_params.num_simulations;   % Number of simulations
num_steps = mc_params.num_steps;        % Number of time steps
seed = mc_params.random_seed;           % Random seed

% Set random seed for reproducibility
rng(seed + 100);  % Different seed from European options

% Time increment
dt = T / num_steps;

% Pre-allocate matrices for efficiency
stock_paths = zeros(num_steps + 1, num_sims);
stock_paths(1, :) = S0;  % Initial stock price for all paths

% Generate random numbers for all paths at once (vectorized approach)
% Using antithetic variates for variance reduction
half_sims = floor(num_sims / 2);
randn_matrix = randn(num_steps, half_sims);

% Create antithetic pairs
if num_sims == 2 * half_sims
    % Even number of simulations
    full_randn_matrix = [randn_matrix, -randn_matrix];
else
    % Odd number of simulations
    full_randn_matrix = [randn_matrix, -randn_matrix, randn(num_steps, 1)];
end

% Calculate drift and diffusion terms
drift = (r - q - 0.5 * sigma^2) * dt;
diffusion = sigma * sqrt(dt);

% Simulate stock price paths using geometric Brownian motion
for i = 1:num_steps
    % Calculate log returns for all paths simultaneously
    log_returns = drift + diffusion * full_randn_matrix(i, :);
    
    % Update stock prices (vectorized)
    stock_paths(i+1, :) = stock_paths(i, :) .* exp(log_returns);
end

% Calculate arithmetic average of stock prices for each path
% For Asian options, we typically use the average price over the entire life
% of the option, including the initial price
average_prices = mean(stock_paths, 1);  % Average along time dimension

% Calculate Asian option payoffs at maturity
% Asian call payoff: max(Average_Price - Strike, 0)
asian_call_payoffs = max(average_prices - K, 0);

% Asian put payoff: max(Strike - Average_Price, 0)
asian_put_payoffs = max(K - average_prices, 0);

% Discount payoffs to present value
discount_factor = exp(-r * T);
discounted_asian_call_payoffs = asian_call_payoffs * discount_factor;
discounted_asian_put_payoffs = asian_put_payoffs * discount_factor;

% Calculate Asian option prices (mean of discounted payoffs)
asian_call_price = mean(discounted_asian_call_payoffs);
asian_put_price = mean(discounted_asian_put_payoffs);

% Calculate standard errors for confidence intervals
% Standard error = standard deviation / sqrt(number of samples)
asian_call_std = std(discounted_asian_call_payoffs) / sqrt(num_sims);
asian_put_std = std(discounted_asian_put_payoffs) / sqrt(num_sims);

% Display progress information
fprintf('Asian Options Monte Carlo Simulation:\n');
fprintf('  Generated %d stock price paths with %d time steps each\n', ...
    num_sims, num_steps);
fprintf('  Used arithmetic average pricing method\n');
fprintf('  Average price range: $%.2f - $%.2f\n', ...
    min(average_prices), max(average_prices));
fprintf('  Mean of average prices: $%.2f\n', mean(average_prices));
fprintf('  Asian options are typically cheaper than European options\n');
fprintf('  due to averaging effect reducing volatility\n');

end 