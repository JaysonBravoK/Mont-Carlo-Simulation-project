function generate_plots(stock_paths, market_params, mc_params, ...
    call_price, put_price, asian_call_price, asian_put_price, ...
    barrier_call_price, barrier_put_price, barrier_level, greeks)
%% ===================================================================
%% Generate Comprehensive Visualization Plots
%% ===================================================================
%
% This function generates multiple plots to visualize Monte Carlo simulation
% results and option pricing analysis
%
% Inputs:
%   stock_paths          - Matrix of simulated stock price paths
%   market_params        - Market parameters structure
%   mc_params           - Monte Carlo parameters structure
%   call_price          - European call option price
%   put_price           - European put option price
%   asian_call_price    - Asian call option price
%   asian_put_price     - Asian put option price
%   barrier_call_price  - Barrier call option price
%   barrier_put_price   - Barrier put option price
%   barrier_level       - Barrier level
%   greeks              - Greeks structure
%
%% ===================================================================

fprintf('Generating comprehensive visualization plots...\n');

% Create time vector for plotting
time_vec = linspace(0, market_params.T, size(stock_paths, 1));

%% ===================================================================
%% Figure 1: Monte Carlo Stock Price Paths
%% ===================================================================

figure('Position', [100, 100, 1200, 800]);

% Plot 1: Sample of stock price paths
subplot(2, 3, 1);
num_paths_to_plot = min(50, size(stock_paths, 2));
plot(time_vec, stock_paths(:, 1:num_paths_to_plot), 'b-', 'LineWidth', 0.5);
hold on;
plot(time_vec, mean(stock_paths, 2), 'r-', 'LineWidth', 3);
if barrier_level > 0
    plot([0, market_params.T], [barrier_level, barrier_level], 'k--', 'LineWidth', 2);
    legend('Sample Paths', 'Average Path', 'Barrier Level', 'Location', 'best');
else
    legend('Sample Paths', 'Average Path', 'Location', 'best');
end
xlabel('Time (Years)');
ylabel('Stock Price ($)');
title('Monte Carlo Stock Price Simulation');
grid on;

% Plot 2: Final stock price distribution
subplot(2, 3, 2);
final_prices = stock_paths(end, :);
histogram(final_prices, 50, 'Normalization', 'pdf', 'FaceColor', 'blue', 'EdgeColor', 'black');
hold on;
xline(market_params.K, 'r--', 'LineWidth', 2, 'Label', 'Strike Price');
xline(mean(final_prices), 'g--', 'LineWidth', 2, 'Label', 'Mean Final Price');
xlabel('Final Stock Price ($)');
ylabel('Probability Density');
title('Distribution of Final Stock Prices');
legend('Location', 'best');
grid on;

% Plot 3: Option price comparison
subplot(2, 3, 3);
option_types = {'European Call', 'European Put', 'Asian Call', 'Asian Put', ...
    'Barrier Call', 'Barrier Put'};
option_prices = [call_price, put_price, asian_call_price, asian_put_price, ...
    barrier_call_price, barrier_put_price];
bar(option_prices, 'FaceColor', [0.2, 0.6, 0.8]);
set(gca, 'XTickLabel', option_types);
xtickangle(45);
ylabel('Option Price ($)');
title('Comparison of Option Prices');
grid on;

% Plot 4: Greeks for call options
subplot(2, 3, 4);
greek_names = {'Delta', 'Gamma', 'Theta', 'Vega', 'Rho'};
call_greeks = [greeks.call_delta, greeks.call_gamma, greeks.call_theta, ...
    greeks.call_vega, greeks.call_rho];
bar(call_greeks, 'FaceColor', [0.8, 0.2, 0.2]);
set(gca, 'XTickLabel', greek_names);
ylabel('Greek Value');
title('Call Option Greeks');
grid on;

% Plot 5: Greeks for put options
subplot(2, 3, 5);
put_greeks = [greeks.put_delta, greeks.put_gamma, greeks.put_theta, ...
    greeks.put_vega, greeks.put_rho];
bar(put_greeks, 'FaceColor', [0.2, 0.8, 0.2]);
set(gca, 'XTickLabel', greek_names);
ylabel('Greek Value');
title('Put Option Greeks');
grid on;

% Plot 6: Payoff diagrams
subplot(2, 3, 6);
S_range = linspace(0.5 * market_params.S0, 1.5 * market_params.S0, 100);
call_payoffs = max(S_range - market_params.K, 0);
put_payoffs = max(market_params.K - S_range, 0);

plot(S_range, call_payoffs, 'b-', 'LineWidth', 2, 'DisplayName', 'Call Payoff');
hold on;
plot(S_range, put_payoffs, 'r-', 'LineWidth', 2, 'DisplayName', 'Put Payoff');
xline(market_params.S0, 'k--', 'LineWidth', 1, 'DisplayName', 'Current Price');
xline(market_params.K, 'g--', 'LineWidth', 1, 'DisplayName', 'Strike Price');
xlabel('Stock Price at Expiration ($)');
ylabel('Payoff ($)');
title('Option Payoff Diagrams');
legend('Location', 'best');
grid on;

% Adjust layout and save
sgtitle(sprintf('Monte Carlo Derivative Pricing Analysis (%d simulations)', ...
    mc_params.num_simulations), 'FontSize', 14, 'FontWeight', 'bold');

% Save the figure
print(gcf, 'results/monte_carlo_analysis.png', '-dpng', '-r300');

%% ===================================================================
%% Figure 2: Convergence Analysis
%% ===================================================================

figure('Position', [200, 200, 1000, 600]);

% Analyze convergence by calculating cumulative means
num_sims_test = min(10000, size(stock_paths, 2));
final_prices_subset = stock_paths(end, 1:num_sims_test);
call_payoffs_subset = max(final_prices_subset - market_params.K, 0) * exp(-market_params.r * market_params.T);
put_payoffs_subset = max(market_params.K - final_prices_subset, 0) * exp(-market_params.r * market_params.T);

% Calculate cumulative means
cum_call_prices = cumsum(call_payoffs_subset) ./ (1:num_sims_test);
cum_put_prices = cumsum(put_payoffs_subset) ./ (1:num_sims_test);

% Plot convergence
subplot(1, 2, 1);
semilogx(1:num_sims_test, cum_call_prices, 'b-', 'LineWidth', 2);
hold on;
semilogx(1:num_sims_test, cum_put_prices, 'r-', 'LineWidth', 2);
xlabel('Number of Simulations');
ylabel('Option Price ($)');
title('Monte Carlo Convergence Analysis');
legend('Call Option', 'Put Option', 'Location', 'best');
grid on;

% Plot standard error reduction
subplot(1, 2, 2);
std_errors_call = zeros(1, num_sims_test);
std_errors_put = zeros(1, num_sims_test);

for i = 100:num_sims_test
    std_errors_call(i) = std(call_payoffs_subset(1:i)) / sqrt(i);
    std_errors_put(i) = std(put_payoffs_subset(1:i)) / sqrt(i);
end

loglog(100:num_sims_test, std_errors_call(100:end), 'b-', 'LineWidth', 2);
hold on;
loglog(100:num_sims_test, std_errors_put(100:end), 'r-', 'LineWidth', 2);
loglog(100:num_sims_test, 1./sqrt(100:num_sims_test), 'k--', 'LineWidth', 1);
xlabel('Number of Simulations');
ylabel('Standard Error');
title('Standard Error Reduction');
legend('Call Option', 'Put Option', '1/√N Theoretical', 'Location', 'best');
grid on;

% Save the convergence figure
print(gcf, 'results/convergence_analysis.png', '-dpng', '-r300');

%% ===================================================================
%% Generate Summary Statistics
%% ===================================================================

% Calculate additional statistics
stats = struct();
stats.mean_final_price = mean(final_prices);
stats.std_final_price = std(final_prices);
stats.min_final_price = min(final_prices);
stats.max_final_price = max(final_prices);
stats.paths_itm_call = sum(final_prices > market_params.K) / length(final_prices);
stats.paths_itm_put = sum(final_prices < market_params.K) / length(final_prices);

fprintf('\nSimulation Statistics Summary:\n');
fprintf('  Mean final stock price: $%.2f\n', stats.mean_final_price);
fprintf('  Std dev final stock price: $%.2f\n', stats.std_final_price);
fprintf('  Min final stock price: $%.2f\n', stats.min_final_price);
fprintf('  Max final stock price: $%.2f\n', stats.max_final_price);
fprintf('  Percentage of paths with call ITM: %.2f%%\n', stats.paths_itm_call * 100);
fprintf('  Percentage of paths with put ITM: %.2f%%\n', stats.paths_itm_put * 100);

fprintf('Visualization plots generated and saved to results/ directory.\n');

end 