function [call_price, put_price, call_std, put_std, stock_paths] = ...
    price_european_options(market_params, mc_params)
%% ===================================================================
%% European Options Pricing using Monte Carlo Simulation
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
rng(seed);

% Time increment
dt = T / num_steps;

% Pre-allocate matrices for efficiency
stock_paths = zeros(num_steps + 1, num_sims);
stock_paths(1, :) = S0;  % Initial stock price for all paths

% Generate random numbers for all paths
half_sims = floor(num_sims / 2);
randn_matrix = randn(num_steps, half_sims);

% Create antithetic pairs for variance reduction
if num_sims == 2 * half_sims
    full_randn_matrix = [randn_matrix, -randn_matrix];
else
    full_randn_matrix = [randn_matrix, -randn_matrix, randn(num_steps, 1)];
end

% Calculate drift and diffusion terms
drift = (r - q - 0.5 * sigma^2) * dt;
diffusion = sigma * sqrt(dt);

% Simulate stock price paths using geometric Brownian motion
for i = 1:num_steps
    log_returns = drift + diffusion * full_randn_matrix(i, :);
    stock_paths(i+1, :) = stock_paths(i, :) .* exp(log_returns);
end

% Extract final stock prices at maturity
final_prices = stock_paths(end, :);

% Calculate option payoffs at maturity
call_payoffs = max(final_prices - K, 0);
put_payoffs = max(K - final_prices, 0);

% Discount payoffs to present value
discount_factor = exp(-r * T);
discounted_call_payoffs = call_payoffs * discount_factor;
discounted_put_payoffs = put_payoffs * discount_factor;

% Calculate option prices
call_price = mean(discounted_call_payoffs);
put_price = mean(discounted_put_payoffs);

% Calculate standard errors
call_std = std(discounted_call_payoffs) / sqrt(num_sims);
put_std = std(discounted_put_payoffs) / sqrt(num_sims);

% Display progress information
fprintf('European Options Monte Carlo Simulation:\n');
fprintf('  Generated %d stock price paths with %d time steps each\n', ...
    num_sims, num_steps);
fprintf('  Final stock price range: $%.2f - $%.2f\n', ...
    min(final_prices), max(final_prices));

end