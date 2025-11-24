function [barrier_call_price, barrier_put_price, barrier_call_std, barrier_put_std] = ...
    price_barrier_options(market_params, mc_params, barrier_level)
%% ===================================================================
%% Barrier Options Pricing using Monte Carlo Simulation
%% ===================================================================
%
% This function prices Down-and-Out barrier call and put options using
% Monte Carlo simulation. Barrier options have payoffs that depend on
% whether the underlying asset price crosses a specified barrier level
% during the life of the option.
%
% Inputs:
%   market_params - Structure containing market parameters
%   mc_params     - Structure containing Monte Carlo parameters
%   barrier_level - Barrier price level (Down-and-Out type)
%
% Outputs:
%   barrier_call_price - Monte Carlo estimated barrier call option price
%   barrier_put_price  - Monte Carlo estimated barrier put option price
%   barrier_call_std   - Standard error of barrier call option price estimate
%   barrier_put_std    - Standard error of barrier put option price estimate
%
% Down-and-Out Option Payoffs:
%   If min(Stock_Path) <= Barrier: Payoff = 0 (knocked out)
%   Otherwise:
%     Call: max(Final_Price - Strike, 0)
%     Put:  max(Strike - Final_Price, 0)
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

% Validate barrier level
if barrier_level >= S0
    warning('Barrier level should be below initial stock price for Down-and-Out options');
end

% Set random seed for reproducibility
rng(seed + 200);  % Different seed from other option types

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

% Find minimum stock price for each path to check barrier condition
min_prices = min(stock_paths, [], 1);  % Minimum along time dimension

% Create barrier indicator: 1 if barrier NOT crossed, 0 if crossed (knocked out)
barrier_indicator = min_prices > barrier_level;

% Extract final stock prices at maturity
final_prices = stock_paths(end, :);

% Calculate standard option payoffs at maturity
call_payoffs = max(final_prices - K, 0);  % Call payoff: max(S_T - K, 0)
put_payoffs = max(K - final_prices, 0);   % Put payoff: max(K - S_T, 0)

% Apply barrier condition: payoff is zero if barrier was crossed
barrier_call_payoffs = call_payoffs .* barrier_indicator;
barrier_put_payoffs = put_payoffs .* barrier_indicator;

% Discount payoffs to present value
discount_factor = exp(-r * T);
discounted_barrier_call_payoffs = barrier_call_payoffs * discount_factor;
discounted_barrier_put_payoffs = barrier_put_payoffs * discount_factor;

% Calculate barrier option prices (mean of discounted payoffs)
barrier_call_price = mean(discounted_barrier_call_payoffs);
barrier_put_price = mean(discounted_barrier_put_payoffs);

% Calculate standard errors for confidence intervals
% Standard error = standard deviation / sqrt(number of samples)
barrier_call_std = std(discounted_barrier_call_payoffs) / sqrt(num_sims);
barrier_put_std = std(discounted_barrier_put_payoffs) / sqrt(num_sims);

% Calculate and display barrier statistics
knocked_out_paths = sum(~barrier_indicator);
survival_rate = sum(barrier_indicator) / num_sims * 100;

% Display progress information
fprintf('Barrier Options Monte Carlo Simulation:\n');
fprintf('  Generated %d stock price paths with %d time steps each\n', ...
    num_sims, num_steps);
fprintf('  Barrier level: $%.2f (Down-and-Out)\n', barrier_level);
fprintf('  Paths knocked out: %d (%.2f%%)\n', ...
    knocked_out_paths, 100 - survival_rate);
fprintf('  Paths surviving: %d (%.2f%%)\n', ...
    sum(barrier_indicator), survival_rate);
fprintf('  Minimum stock price observed: $%.2f\n', min(min_prices));
fprintf('  Barrier options are typically cheaper than standard options\n');
fprintf('  due to knock-out probability\n');

end 