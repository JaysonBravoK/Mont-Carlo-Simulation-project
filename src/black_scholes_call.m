function call_price = black_scholes_call(S0, K, T, r, sigma, q)
%% ===================================================================
%% Black-Scholes Formula for European Call Options
%% ===================================================================
%
% This function calculates the theoretical price of a European call option
% using the Black-Scholes formula with dividend yield
%
% Inputs:
%   S0    - Current stock price
%   K     - Strike price
%   T     - Time to maturity (in years)
%   r     - Risk-free interest rate (annual)
%   sigma - Volatility of the underlying asset (annual)
%   q     - Dividend yield (annual)
%
% Output:
%   call_price - Theoretical call option price
%
% The Black-Scholes formula for a call option with dividend yield:
% C = S0*exp(-q*T)*N(d1) - K*exp(-r*T)*N(d2)
%
% where:
% d1 = [ln(S0/K) + (r - q + 0.5*sigma^2)*T] / (sigma*sqrt(T))
% d2 = d1 - sigma*sqrt(T)
% N(x) = cumulative standard normal distribution function
%
%% ===================================================================

% Handle edge cases
if T <= 0
    % Option has expired, only intrinsic value remains
    call_price = max(S0 - K, 0);
    return;
end

if sigma <= 0
    % No volatility case
    if S0 * exp(-q * T) > K * exp(-r * T)
        call_price = S0 * exp(-q * T) - K * exp(-r * T);
    else
        call_price = 0;
    end
    return;
end

% Calculate d1 and d2 parameters
% d1 represents the standardized distance between current stock price and strike
d1 = (log(S0 / K) + (r - q + 0.5 * sigma^2) * T) / (sigma * sqrt(T));

% d2 represents d1 adjusted for volatility term
d2 = d1 - sigma * sqrt(T);

% Calculate cumulative standard normal distribution values
% N(d1) - probability that the option will be in-the-money at expiration
% N(d2) - probability used for discounting the strike price
N_d1 = normcdf(d1);
N_d2 = normcdf(d2);

% Apply Black-Scholes formula
% First term: Present value of expected stock price if option is exercised
% Second term: Present value of strike price payment if option is exercised
call_price = S0 * exp(-q * T) * N_d1 - K * exp(-r * T) * N_d2;

end 