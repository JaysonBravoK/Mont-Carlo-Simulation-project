function put_price = black_scholes_put(S0, K, T, r, sigma, q)
%% ===================================================================
%% Black-Scholes Formula for European Put Options
%% ===================================================================
%
% This function calculates the theoretical price of a European put option
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
%   put_price - Theoretical put option price
%
% The Black-Scholes formula for a put option with dividend yield:
% P = K*exp(-r*T)*N(-d2) - S0*exp(-q*T)*N(-d1)
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
    put_price = max(K - S0, 0);
    return;
end

if sigma <= 0
    % No volatility case
    if K * exp(-r * T) > S0 * exp(-q * T)
        put_price = K * exp(-r * T) - S0 * exp(-q * T);
    else
        put_price = 0;
    end
    return;
end

% Calculate d1 and d2 parameters
% d1 represents the standardized distance between current stock price and strike
d1 = (log(S0 / K) + (r - q + 0.5 * sigma^2) * T) / (sigma * sqrt(T));

% d2 represents d1 adjusted for volatility term
d2 = d1 - sigma * sqrt(T);

% Calculate cumulative standard normal distribution values
% N(-d1) - probability that the put option will be in-the-money at expiration
% N(-d2) - probability used for discounting the strike price
N_minus_d1 = normcdf(-d1);
N_minus_d2 = normcdf(-d2);

% Apply Black-Scholes formula for put option
% First term: Present value of strike price payment if option is exercised
% Second term: Present value of expected stock price given up if option is exercised
put_price = K * exp(-r * T) * N_minus_d2 - S0 * exp(-q * T) * N_minus_d1;

end 