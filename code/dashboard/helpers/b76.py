#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import numpy as np
import math

gamma2 =  -1/3 + 1/np.pi
gamma4 = 7/90 - 2/(3*np.pi) + 4/(3*np.pi*np.pi)
gamma6 = -1/70 + 4/(15*np.pi) - 4/(3*np.pi*np.pi) + 2/((np.pi**3))
gamma8 = 83/37800 - 76/(945*np.pi) + 34/(45*np.pi*np.pi) - 8/(3*(np.pi**3)) + 16/(5*(np.pi**4))
gamma10 = -73/249480 + 283/(14175*np.pi) - 178/(567*np.pi*np.pi) + 88/(45*(np.pi**3)) - 16/(3*(np.pi**4)) + 16/(3*(np.pi**5))

sqrt2pi = 1/np.sqrt(2*np.pi)

def norm_cdf_polya(x):
    """
    Approximate Normal CDF using Polya's method

    Parameters
    ----------
    x : float
        Real number.

    Returns
    -------
    Normal cdf function value for a given x.

    """
    x2 = x*x;
    # x3 = x2*x
    x4 = x2 * x2;
    x6 = x4 * x2;
    x8 = x4 * x4;
    x10 = x8 * x2;
    return 0.5 + 0.5 * np.sign(x) * np.sqrt(1- np.exp(-2/math.pi *x2 * (1+gamma2*x2
                                                                                  
                                                                                  + gamma4*x4
                                                                                  + gamma6*x6
                                                                                  + gamma8*x8
                                                                                  + gamma10 * x10
                                            )))


def norm_pdf_simple(x):
    return sqrt2pi * math.exp(-0.5 * x * x)

def compute_greeks(order_price: float, perpetual_price: float, underlying_price: float, t_years: float, strike: float, ivol: float, option_type: str) -> dict:
    """
    

    Parameters
    ----------
    order_price : float
        DESCRIPTION.
    perpetual_price : float
        DESCRIPTION.
    underlying_price : float
        DESCRIPTION.
    t_years : float
        DESCRIPTION.
    strike : float
        DESCRIPTION.
    sigma : float
        DESCRIPTION.
    option_type : str
        DESCRIPTION.

    Returns
    -------
    dict
        DESCRIPTION.

    """
    if t_years + ivol == 0:
        return {
                "r_adj" : 0.0,
                "delta" : 0.0,
                "vega" : 0.0
            }
    sigma = ivol
    log_forward_strike = math.log(underlying_price / strike)
    sigma_sqrt_time = sigma * math.sqrt(t_years)
    
    if sigma_sqrt_time == 0:
        return {
                "r_adj" : 0.0,
                "delta" : 0.0,
                "vega" : 0.0
            }
    d1 = (log_forward_strike + 0.5 * t_years * ((sigma)**2)) / (sigma_sqrt_time)
    d2 = d1 - sigma_sqrt_time
    
    if option_type == "call":
        cdf_d1_pstv = norm_cdf_polya(d1)
        cdf_d2_pstv = norm_cdf_polya(d2)
        
        # print(d1, d2)
        
        r_adj = (1/sigma_sqrt_time) * math.log((perpetual_price * cdf_d1_pstv - strike * cdf_d2_pstv)/(order_price*underlying_price))
        
        # print(order_price, perpetual_price, underlying_price, t_years, strike, sigma, option_type, d1, d2)
        delta = math.exp(-r_adj * t_years) * cdf_d1_pstv
        vega = delta * perpetual_price * math.sqrt(t_years)
    elif option_type == "put":   
        cdf_d1_pstv = norm_cdf_polya(d1)
        cdf_d1_ngtv = norm_cdf_polya(-d1)
        cdf_d2_ngtv = norm_cdf_polya(-d2)
        
        r_adj = (1/sigma_sqrt_time) * math.log((strike * cdf_d2_ngtv - perpetual_price * cdf_d1_ngtv)/(order_price*underlying_price))
        
        # print(order_price, perpetual_price, underlying_price, t_years, strike, sigma, option_type, d1, d2)
        delta = math.exp(-r_adj * t_years * 1.0) * (cdf_d1_pstv - 1)
        vega = math.exp(-r_adj * t_years * 1.0) * cdf_d1_pstv * perpetual_price * math.sqrt(t_years)
    
    return {
            "r_adj" : r_adj,
            "delta" : delta,
            "vega" : vega
        }
    

if __name__ == "__main__":
    a = compute_greeks(order_price = 0.0005, perpetual_price = 16500, underlying_price = 16500, t_years = 13/365, strike = 25000, ivol = 89.64, option_type = "call")
    # print(a["delta"] * 100)
    
    {'order_direction': 'sell',
     'instrument_name': 'BTC-30DEC22-14000-P',
     'instrument_expiration': '30DEC22',
     'instrument_type': 'option',
     'order_volume': 0.1,
     'order_price': 0.008,
     'order_fair': 0.008444668105782191,
     'order_id': '237966003',
     'order_iv': 78.44,
     'market_bid': 0.008,
     'market_ask': 0.0085,
     'model_bid': 0.008,
     'model_ask': 0.009,
     'order_delta': '',
     'order_vega': 0.0,
     'order_r_adj': -0.16249147362316096,
     'order_executor': 'market',
     'option_kind': 'put',
     'option_strike': 14000,
     'perpetual_price': 16957.53259960992,
     'underlying_price': 16624.41330891331,
     'option_years_left': 52.97714092088725,
     'option_iv': 78.44}

