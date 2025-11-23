function sensitivity_analysis(market_params, mc_params)
%% ===================================================================
%% Sensitivity Analysis for Option Pricing Parameters
%% ===================================================================
%
% This function performs comprehensive sensitivity analysis by varying
% key market parameters and observing their impact on option prices
%
% Inputs:
%   market_params - Structure containing market parameters
%   mc_params     - Structure containing Monte Carlo parameters
%
%% ===================================================================

fprintf('Performing sensitivity analysis...\n');

% Reduce number of simulations for sensitivity analysis to speed up computation
mc_params_fast = mc_params;
mc_params_fast.num_simulations = 50000;

%% ===================================================================
%% Sensitivity to Stock Price (Delta Profile)
%% ===================================================================

% Define range of stock prices around current price
S_range = linspace(0.7 * market_params.S0, 1.3 * market_params.S0, 15);
call_prices_S = zeros(size(S_range));
put_prices_S = zeros(size(S_range));

fprintf('Analyzing sensitivity to stock price...\n');
for i = 1:length(S_range)
    temp_params = market_params;
    temp_params.S0 = S_range(i);
    [call_prices_S(i), put_prices_S(i), ~, ~, ~] = ...
        price_european_options(temp_params, mc_params_fast);
end

%% ===================================================================
%% Sensitivity to Volatility (Vega Profile)
%% ===================================================================

% Define range of volatilities
sigma_range = linspace(0.1, 0.4, 10);
call_prices_sigma = zeros(size(sigma_range));
put_prices_sigma = zeros(size(sigma_range));

fprintf('Analyzing sensitivity to volatility...\n');
for i = 1:length(sigma_range)
    temp_params = market_params;
    temp_params.sigma = sigma_range(i);
    [call_prices_sigma(i), put_prices_sigma(i), ~, ~, ~] = ...
        price_european_options(temp_params, mc_params_fast);
end

%% ===================================================================
%% Sensitivity to Time to Maturity (Theta Profile)
%% ===================================================================

% Define range of times to maturity
T_range = linspace(0.1, 2.0, 10);
call_prices_T = zeros(size(T_range));
put_prices_T = zeros(size(T_range));

fprintf('Analyzing sensitivity to time to maturity...\n');
for i = 1:length(T_range)
    temp_params = market_params;
    temp_params.T = T_range(i);
    [call_prices_T(i), put_prices_T(i), ~, ~, ~] = ...
        price_european_options(temp_params, mc_params_fast);
end

%% ===================================================================
%% Sensitivity to Interest Rate (Rho Profile)
%% ===================================================================

% Define range of interest rates
r_range = linspace(0.01, 0.10, 10);
call_prices_r = zeros(size(r_range));
put_prices_r = zeros(size(r_range));

fprintf('Analyzing sensitivity to interest rate...\n');
for i = 1:length(r_range)
    temp_params = market_params;
    temp_params.r = r_range(i);
    [call_prices_r(i), put_prices_r(i), ~, ~, ~] = ...
        price_european_options(temp_params, mc_params_fast);
end

%% ===================================================================
%% Generate Sensitivity Analysis Plots
%% ===================================================================

figure('Position', [300, 300, 1200, 800]);

% Plot 1: Sensitivity to Stock Price
subplot(2, 2, 1);
plot(S_range, call_prices_S, 'b-', 'LineWidth', 2, 'DisplayName', 'Call Option');
hold on;
plot(S_range, put_prices_S, 'r-', 'LineWidth', 2, 'DisplayName', 'Put Option');
xline(market_params.S0, 'k--', 'LineWidth', 1, 'DisplayName', 'Current Price');
xlabel('Stock Price ($)');
ylabel('Option Price ($)');
title('Sensitivity to Stock Price');
legend('Location', 'best');
grid on;

% Plot 2: Sensitivity to Volatility
subplot(2, 2, 2);
plot(sigma_range * 100, call_prices_sigma, 'b-', 'LineWidth', 2, 'DisplayName', 'Call Option');
hold on;
plot(sigma_range * 100, put_prices_sigma, 'r-', 'LineWidth', 2, 'DisplayName', 'Put Option');
xline(market_params.sigma * 100, 'k--', 'LineWidth', 1, 'DisplayName', 'Current Volatility');
xlabel('Volatility (%)');
ylabel('Option Price ($)');
title('Sensitivity to Volatility');
legend('Location', 'best');
grid on;

% Plot 3: Sensitivity to Time to Maturity
subplot(2, 2, 3);
plot(T_range, call_prices_T, 'b-', 'LineWidth', 2, 'DisplayName', 'Call Option');
hold on;
plot(T_range, put_prices_T, 'r-', 'LineWidth', 2, 'DisplayName', 'Put Option');
xline(market_params.T, 'k--', 'LineWidth', 1, 'DisplayName', 'Current Maturity');
xlabel('Time to Maturity (Years)');
ylabel('Option Price ($)');
title('Sensitivity to Time to Maturity');
legend('Location', 'best');
grid on;

% Plot 4: Sensitivity to Interest Rate
subplot(2, 2, 4);
plot(r_range * 100, call_prices_r, 'b-', 'LineWidth', 2, 'DisplayName', 'Call Option');
hold on;
plot(r_range * 100, put_prices_r, 'r-', 'LineWidth', 2, 'DisplayName', 'Put Option');
xline(market_params.r * 100, 'k--', 'LineWidth', 1, 'DisplayName', 'Current Rate');
xlabel('Interest Rate (%)');
ylabel('Option Price ($)');
title('Sensitivity to Interest Rate');
legend('Location', 'best');
grid on;

% Add main title
sgtitle('Sensitivity Analysis of European Options', 'FontSize', 14, 'FontWeight', 'bold');

% Save the sensitivity analysis figure
print(gcf, 'results/sensitivity_analysis.png', '-dpng', '-r300');

%% ===================================================================
%% Generate Sensitivity Summary Table
%% ===================================================================

% Calculate percentage changes for a 10% increase in each parameter
base_call_price = call_prices_S(S_range == market_params.S0);
base_put_price = put_prices_S(S_range == market_params.S0);

% Find closest values for percentage calculations
[~, idx_S] = min(abs(S_range - 1.1 * market_params.S0));
[~, idx_sigma] = min(abs(sigma_range - 1.1 * market_params.sigma));
[~, idx_T] = min(abs(T_range - 1.1 * market_params.T));
[~, idx_r] = min(abs(r_range - 1.1 * market_params.r));

% Calculate percentage changes
pct_change_S_call = (call_prices_S(idx_S) - base_call_price) / base_call_price * 100;
pct_change_S_put = (put_prices_S(idx_S) - base_put_price) / base_put_price * 100;

pct_change_sigma_call = (call_prices_sigma(idx_sigma) - base_call_price) / base_call_price * 100;
pct_change_sigma_put = (put_prices_sigma(idx_sigma) - base_put_price) / base_put_price * 100;

pct_change_T_call = (call_prices_T(idx_T) - base_call_price) / base_call_price * 100;
pct_change_T_put = (put_prices_T(idx_T) - base_put_price) / base_put_price * 100;

pct_change_r_call = (call_prices_r(idx_r) - base_call_price) / base_call_price * 100;
pct_change_r_put = (put_prices_r(idx_r) - base_put_price) / base_put_price * 100;

% Display sensitivity summary
fprintf('\nSensitivity Analysis Summary (10%% parameter increase):\n');
fprintf('=========================================================\n');
fprintf('Parameter Change    | Call Option Change | Put Option Change\n');
fprintf('--------------------|--------------------|------------------\n');
fprintf('Stock Price +10%%    | %+8.2f%%         | %+8.2f%%\n', pct_change_S_call, pct_change_S_put);
fprintf('Volatility +10%%     | %+8.2f%%         | %+8.2f%%\n', pct_change_sigma_call, pct_change_sigma_put);
fprintf('Time to Maturity +10%% | %+8.2f%%         | %+8.2f%%\n', pct_change_T_call, pct_change_T_put);
fprintf('Interest Rate +10%%  | %+8.2f%%         | %+8.2f%%\n', pct_change_r_call, pct_change_r_put);
fprintf('=========================================================\n');

fprintf('Sensitivity analysis completed and saved to results/ directory.\n');

end 