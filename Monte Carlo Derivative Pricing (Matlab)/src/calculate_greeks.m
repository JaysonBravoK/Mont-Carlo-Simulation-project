function greeks = calculate_greeks(market_params, mc_params)
%% ===================================================================
%% Greeks Calculation using Finite Difference Method
%% ===================================================================
%
% This function calculates the Greeks (option sensitivities) for European
% options using finite difference method with Monte Carlo simulation.
%
% Inputs:
%   market_params - Structure containing market parameters
%   mc_params     - Structure containing Monte Carlo parameters
%
% Output:
%   greeks - Structure containing calculated Greeks
%
%% ===================================================================

% Define small increments for finite difference calculations
delta_S = 0.01;      % 1% change in stock price
delta_T = 1/365;     % 1 day change in time
delta_sigma = 0.01;  % 1% change in volatility
delta_r = 0.0001;    % 1 basis point change in interest rate

fprintf('Calculating Greeks using finite difference method...\n');

% Get base option prices with current parameters
[base_call_price, base_put_price, ~, ~, ~] = ...
    price_european_options(market_params, mc_params);

% Calculate Delta (sensitivity to stock price)
params_S_up = market_params;
params_S_down = market_params;
params_S_up.S0 = market_params.S0 * (1 + delta_S);
params_S_down.S0 = market_params.S0 * (1 - delta_S);

[call_price_S_up, put_price_S_up, ~, ~, ~] = ...
    price_european_options(params_S_up, mc_params);
[call_price_S_down, put_price_S_down, ~, ~, ~] = ...
    price_european_options(params_S_down, mc_params);

call_delta = (call_price_S_up - call_price_S_down) / ...
    (2 * market_params.S0 * delta_S);
put_delta = (put_price_S_up - put_price_S_down) / ...
    (2 * market_params.S0 * delta_S);

% Calculate Gamma (second derivative with respect to stock price)
call_gamma = (call_price_S_up - 2*base_call_price + call_price_S_down) / ...
    (market_params.S0 * delta_S)^2;
put_gamma = (put_price_S_up - 2*base_put_price + put_price_S_down) / ...
    (market_params.S0 * delta_S)^2;

% Calculate Theta (time decay)
params_T_down = market_params;
params_T_down.T = max(market_params.T - delta_T, 0.001);

[call_price_T_down, put_price_T_down, ~, ~, ~] = ...
    price_european_options(params_T_down, mc_params);

call_theta = -(base_call_price - call_price_T_down) / delta_T;
put_theta = -(base_put_price - put_price_T_down) / delta_T;

% Calculate Vega (sensitivity to volatility)
params_sigma_up = market_params;
params_sigma_down = market_params;
params_sigma_up.sigma = market_params.sigma + delta_sigma;
params_sigma_down.sigma = max(market_params.sigma - delta_sigma, 0.001);

[call_price_sigma_up, put_price_sigma_up, ~, ~, ~] = ...
    price_european_options(params_sigma_up, mc_params);
[call_price_sigma_down, put_price_sigma_down, ~, ~, ~] = ...
    price_european_options(params_sigma_down, mc_params);

call_vega = (call_price_sigma_up - call_price_sigma_down) / (2 * delta_sigma);
put_vega = (put_price_sigma_up - put_price_sigma_down) / (2 * delta_sigma);

% Calculate Rho (sensitivity to interest rate)
params_r_up = market_params;
params_r_down = market_params;
params_r_up.r = market_params.r + delta_r;
params_r_down.r = max(market_params.r - delta_r, 0);

[call_price_r_up, put_price_r_up, ~, ~, ~] = ...
    price_european_options(params_r_up, mc_params);
[call_price_r_down, put_price_r_down, ~, ~, ~] = ...
    price_european_options(params_r_down, mc_params);

call_rho = (call_price_r_up - call_price_r_down) / (2 * delta_r);
put_rho = (put_price_r_up - put_price_r_down) / (2 * delta_r);

% Package all results
greeks = struct();
greeks.call_delta = call_delta;
greeks.call_gamma = call_gamma;
greeks.call_theta = call_theta;
greeks.call_vega = call_vega;
greeks.call_rho = call_rho;
greeks.put_delta = put_delta;
greeks.put_gamma = put_gamma;
greeks.put_theta = put_theta;
greeks.put_vega = put_vega;
greeks.put_rho = put_rho;

fprintf('Greeks calculation completed.\n');

end 