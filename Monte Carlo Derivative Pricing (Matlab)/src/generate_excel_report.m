function generate_excel_report(results)
%% ===================================================================
%% Generate Excel Report for Monte Carlo Results
%% ===================================================================
%
% This function generates a comprehensive Excel report containing all
% Monte Carlo simulation results and analysis
%
% Input:
%   results - Structure containing all simulation results
%
%% ===================================================================

fprintf('Generating Excel report...\n');

% Define the output filename
excel_filename = 'results/Monte_Carlo_Results_Report.xlsx';

try
    %% ===================================================================
    %% Sheet 1: Summary Results
    %% ===================================================================
    
    % Create summary data
    summary_headers = {'Option Type', 'Monte Carlo Price', 'Black-Scholes Price', ...
        'Absolute Error', 'Relative Error (%)', 'Standard Error'};
    
    % European Call
    if isfield(results.european_call, 'bs_price')
        abs_error_call = abs(results.european_call.mc_price - results.european_call.bs_price);
        rel_error_call = abs_error_call / results.european_call.bs_price * 100;
        bs_call_price = results.european_call.bs_price;
    else
        abs_error_call = NaN;
        rel_error_call = NaN;
        bs_call_price = NaN;
    end
    
    % European Put
    if isfield(results.european_put, 'bs_price')
        abs_error_put = abs(results.european_put.mc_price - results.european_put.bs_price);
        rel_error_put = abs_error_put / results.european_put.bs_price * 100;
        bs_put_price = results.european_put.bs_price;
    else
        abs_error_put = NaN;
        rel_error_put = NaN;
        bs_put_price = NaN;
    end
    
    summary_data = {
        'European Call', results.european_call.mc_price, bs_call_price, ...
        abs_error_call, rel_error_call, results.european_call.std_error;
        'European Put', results.european_put.mc_price, bs_put_price, ...
        abs_error_put, rel_error_put, results.european_put.std_error;
        'Asian Call', results.asian_call.mc_price, 'N/A', ...
        'N/A', 'N/A', results.asian_call.std_error;
        'Asian Put', results.asian_put.mc_price, 'N/A', ...
        'N/A', 'N/A', results.asian_put.std_error;
        'Barrier Call', results.barrier_call.mc_price, 'N/A', ...
        'N/A', 'N/A', results.barrier_call.std_error;
        'Barrier Put', results.barrier_put.mc_price, 'N/A', ...
        'N/A', 'N/A', results.barrier_put.std_error
    };
    
    % Write summary data to Excel
    writecell([summary_headers; summary_data], excel_filename, 'Sheet', 'Summary Results');
    
    %% ===================================================================
    %% Sheet 2: Market Parameters
    %% ===================================================================
    
    % Create market parameters data
    params_headers = {'Parameter', 'Value', 'Description'};
    params_data = {
        'Initial Stock Price (S0)', results.market_params.S0, 'Current price of underlying asset';
        'Strike Price (K)', results.market_params.K, 'Exercise price of options';
        'Time to Maturity (T)', results.market_params.T, 'Time until expiration (years)';
        'Risk-free Rate (r)', results.market_params.r, 'Annual risk-free interest rate';
        'Volatility (sigma)', results.market_params.sigma, 'Annual volatility of underlying';
        'Dividend Yield (q)', results.market_params.q, 'Annual dividend yield';
        'Number of Simulations', results.mc_params.num_simulations, 'Monte Carlo paths generated';
        'Number of Time Steps', results.mc_params.num_steps, 'Discretization steps per path';
        'Random Seed', results.mc_params.random_seed, 'Seed for reproducibility'
    };
    
    % Write parameters data to Excel
    writecell([params_headers; params_data], excel_filename, 'Sheet', 'Market Parameters');
    
    %% ===================================================================
    %% Sheet 3: Greeks Analysis
    %% ===================================================================
    
    % Create Greeks data
    greeks_headers = {'Greek', 'Call Option Value', 'Put Option Value', 'Description'};
    greeks_data = {
        'Delta', results.greeks.call_delta, results.greeks.put_delta, ...
        'Sensitivity to underlying price change';
        'Gamma', results.greeks.call_gamma, results.greeks.put_gamma, ...
        'Rate of change of Delta';
        'Theta', results.greeks.call_theta, results.greeks.put_theta, ...
        'Time decay (price change per day)';
        'Vega', results.greeks.call_vega, results.greeks.put_vega, ...
        'Sensitivity to volatility change';
        'Rho', results.greeks.call_rho, results.greeks.put_rho, ...
        'Sensitivity to interest rate change'
    };
    
    % Write Greeks data to Excel
    writecell([greeks_headers; greeks_data], excel_filename, 'Sheet', 'Greeks Analysis');
    
    %% ===================================================================
    %% Sheet 4: Computational Details
    %% ===================================================================
    
    % Create computational details
    comp_headers = {'Metric', 'Value', 'Notes'};
    comp_data = {
        'Variance Reduction Method', 'Antithetic Variates', 'Used to reduce standard errors';
        'Random Number Generator', 'MATLAB default (Mersenne Twister)', 'High-quality pseudorandom numbers';
        'Pricing Method', 'Risk-neutral Valuation', 'Discounted expected payoffs';
        'Stock Price Model', 'Geometric Brownian Motion', 'Lognormal distribution assumption';
        'Time Discretization', 'Euler Scheme', 'First-order approximation';
        'Convergence Rate', 'O(1/√N)', 'Standard Monte Carlo convergence';
        'Confidence Level', '95%', 'For error estimates';
        'Greeks Method', 'Finite Differences', 'Numerical approximation'
    };
    
    % Write computational details to Excel
    writecell([comp_headers; comp_data], excel_filename, 'Sheet', 'Computational Details');
    
    fprintf('Excel report successfully generated: %s\n', excel_filename);
    
catch ME
    % Handle errors gracefully
    fprintf('Warning: Could not generate Excel file. Error: %s\n', ME.message);
    fprintf('This may be due to missing Excel support or file permissions.\n');
    
    % Try to save as CSV instead
    try
        csv_filename = 'results/Monte_Carlo_Results_Summary.csv';
        
        % Create a simple CSV with summary results
        csv_data = [summary_headers; summary_data];
        writecell(csv_data, csv_filename);
        
        fprintf('Alternative CSV report generated: %s\n', csv_filename);
    catch
        fprintf('Warning: Could not generate CSV file either.\n');
    end
end

end 