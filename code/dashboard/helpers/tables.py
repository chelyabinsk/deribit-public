#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import json
import numpy as np
import pandas as pd
from scipy.interpolate import make_interp_spline

import math
from helpers.b76 import norm_pdf_simple
from scipy.stats import norm

from scipy.interpolate import UnivariateSpline
from sklearn.linear_model import LinearRegression
import time
from datetime import datetime as DateTime
from datetime import timedelta as TimeDelta


granularity = 500
sqrt2pi = 1/np.sqrt(2*np.pi)

def quoting_screen_table_data(redis_client, surface_fitter, expiration_str, request_count: int):
    surface_fitter = redis_client.get("__surface_fitter")
    expirations_map = redis_client.get("__expirations_map")
    
    surface_fitter = json.loads(surface_fitter)
    expirations_map = json.loads(expirations_map)

    underlying_future_name = expirations_map[expiration_str]["full_underlying_name"]
    underlying_price = surface_fitter["futures_orderbooks"][underlying_future_name]["computed_price"]

    # Find ATM strike
    atm_strike = 0
    min_distance = np.inf
    for strike in surface_fitter["sub_fitter_expiration_info"][expiration_str]["strike"]:
        if abs(strike - underlying_price) < min_distance:
            min_distance = abs(strike - atm_strike)
            atm_strike = strike

    # Find second ATM strike
    atm_strike_2 = 0
    min_distance = np.inf
    for strike in surface_fitter["sub_fitter_expiration_info"][expiration_str]["strike"]:
        if strike == atm_strike:
            continue
        if abs(strike - underlying_price) < min_distance:
            min_distance = abs(strike - atm_strike_2)
            atm_strike_2 = strike

    

    strike_colours = []
    strike_value = []

    call_bid = []

    call_bid_num = []
    call_bid_num_colour = []
    market_call_bid = []
    call_bid_colour = []

    call_fair = []
    
    call_ask_num = []
    call_ask_num_colour = []
    market_call_ask = []
    call_ask_colour = []

    call_ask = []

    put_bid = []

    put_bid_num = []
    put_bid_num_colour = []
    market_put_bid = []
    put_bid_colour = []
    
    put_fair = []
    
    put_ask_num = []
    put_ask_num_colour = []
    market_put_ask = []
    put_ask_colour = []

    put_ask = []

    fair_colour = []

    delta_call = []
    delta_put = []
    delta_colour = []

    normalised_strike = []
    normalised_strike_colour = []

    for i in range(len(surface_fitter["sub_fitter_expiration_info"][expiration_str]["strike"])):
        strike = surface_fitter["sub_fitter_expiration_info"][expiration_str]["strike"][i]
        strike_extra_char = ""
        if request_count % 2 == 0:
            strike_extra_char = " "

        call_instrument_str = expirations_map[expiration_str]["call_instruments"][i]
        put_instrument_str = expirations_map[expiration_str]["put_instruments"][i]

        __own_call_bid = surface_fitter["sub_fitter_expiration_info"][expiration_str]["own_call_bid"][i] 
        if __own_call_bid is None:
            __own_call_bid = "-"
        elif __own_call_bid <= 0:
            __own_call_bid = "-"
        call_bid.append(__own_call_bid)
        __own_call_ask = surface_fitter["sub_fitter_expiration_info"][expiration_str]["own_call_ask"][i] 
        if __own_call_ask is None:
            __own_call_ask = "-"
        elif __own_call_ask <= 0:
            __own_call_ask = "-"
        call_ask.append(__own_call_ask)

        __own_put_bid = surface_fitter["sub_fitter_expiration_info"][expiration_str]["own_put_bid"][i] 
        if __own_put_bid is None:
            __own_put_bid = "-"
        elif __own_put_bid <= 0:
            __own_put_bid = "-"
        put_bid.append(__own_put_bid)
        __own_put_ask = surface_fitter["sub_fitter_expiration_info"][expiration_str]["own_put_ask"][i]
        if __own_put_ask is None:
            __own_put_ask = "-"
        elif __own_put_ask <= 0:
            __own_put_ask = "-"
        put_ask.append(__own_put_ask)
        
        __market_call_bid = surface_fitter["options_orderbooks"][call_instrument_str]["top_bid_price"]
        if __market_call_bid is None:
            __market_call_bid = "-"
        market_call_bid.append(f'{__market_call_bid}{strike_extra_char}')
        __call_bid_num = surface_fitter["options_orderbooks"][call_instrument_str]["top_bid_size"]
        if __call_bid_num is None:
            __call_bid_num = "-"
        call_bid_num.append(f'{__call_bid_num}{strike_extra_char}')

        __market_put_bid = surface_fitter["options_orderbooks"][put_instrument_str]["top_bid_price"]
        if __market_put_bid is None:
            __market_put_bid = "-"
        market_put_bid.append(f'{__market_put_bid}{strike_extra_char}')
        __put_bid_num = surface_fitter["options_orderbooks"][put_instrument_str]["top_bid_size"]
        if __put_bid_num is None:
            __put_bid_num = "-"
        put_bid_num.append(f'{__put_bid_num}{strike_extra_char}')
        
        fair_fitting_point = surface_fitter["sub_fitter_expiration_info"][expiration_str]["fitting_point"][i]
        if fair_fitting_point is not None:
            fair_fitting_point = f"{100*fair_fitting_point:.2f}"
        call_fair_price = surface_fitter["sub_fitter_expiration_info"][expiration_str]["call_fair_price"][i]
        if call_fair_price is not None:
            call_fair_price = f"{call_fair_price:.4f}"
        call_fair.append(f'{call_fair_price} [{fair_fitting_point}%]')

        put_fair_price = surface_fitter["sub_fitter_expiration_info"][expiration_str]["put_fair_price"][i]
        if put_fair_price is not None:
            put_fair_price = f"{put_fair_price:.4f}"

        put_fair.append(f'{put_fair_price} [{fair_fitting_point}%]')

        __market_call_ask = surface_fitter["options_orderbooks"][call_instrument_str]["top_ask_price"]
        if __market_call_ask is None:
            __market_call_ask = "-"
        market_call_ask.append(f'{__market_call_ask}{strike_extra_char}')
        __call_ask_num = surface_fitter["options_orderbooks"][call_instrument_str]["top_ask_size"]
        if __call_ask_num is None:
            __call_ask_num = "-"
        call_ask_num.append(f'{__call_ask_num}{strike_extra_char}')

        __market_put_ask = surface_fitter["options_orderbooks"][put_instrument_str]["top_ask_price"]
        if __market_put_ask is None:
            __market_put_ask = "-"
        market_put_ask.append(f'{__market_put_ask}{strike_extra_char}')
        __put_ask_num = surface_fitter["options_orderbooks"][put_instrument_str]["top_ask_size"]
        if __put_ask_num is None:
            __put_ask_num = "-"
        put_ask_num.append(f'{__put_ask_num}{strike_extra_char}')

        __delta_call = surface_fitter["sub_fitter_expiration_info"][expiration_str]["delta_call"][i]
        if __delta_call is None:
            __delta_call = "-"
        else:
            __delta_call = f"{100*__delta_call:.2f}"
        delta_call.append(f'{__delta_call}{strike_extra_char}')

        __delta_put = surface_fitter["sub_fitter_expiration_info"][expiration_str]["delta_put"][i]
        if __delta_put is None:
            __delta_put = "-"
        else:
            __delta_put = f"{100*__delta_put:.2f}"
        delta_put.append(f'{__delta_put}{strike_extra_char}')


        strike_value.append(f'{surface_fitter["sub_fitter_expiration_info"][expiration_str]["strike"][i]}{strike_extra_char}')

        
        ## Compute colours
        colouring_rules = QuotingColouringRules()

        fair_colour.append(colouring_rules.fair_colour(i))
        strike_colours.append(colouring_rules.strike_colour(i, strike, atm_strike, atm_strike_2))
        call_bid_num_colour.append(colouring_rules.bid_num_colour(i, __call_bid_num, __own_call_bid, __market_call_bid ))
        call_bid_colour.append(colouring_rules.bid_colour(i, __call_bid_num, __own_call_bid, __market_call_bid ))
        call_ask_colour.append(colouring_rules.ask_colour(i, __call_ask_num, __own_call_ask, __market_call_ask ))
        call_ask_num_colour.append(colouring_rules.ask_num_colour(i, __call_ask_num, __own_call_ask, __market_call_ask ))

        put_bid_num_colour.append(colouring_rules.bid_num_colour(i, __put_bid_num, __own_put_bid, __market_put_bid ))
        put_bid_colour.append(colouring_rules.bid_colour(i, __put_bid_num, __own_put_bid, __market_put_bid ))
        put_ask_colour.append(colouring_rules.ask_colour(i, __put_ask_num, __own_put_ask, __market_put_ask ))
        put_ask_num_colour.append(colouring_rules.ask_num_colour(i, __put_ask_num, __own_put_ask, __market_put_ask ))

        __normalised_strike = surface_fitter["sub_fitter_expiration_info"][expiration_str]["ns_strike"][i]
        if __normalised_strike is None:
            __normalised_strike = "-"
        else:
            normalised_strike_colour.append(colouring_rules.ns_strike_colour(i, __normalised_strike))
            __normalised_strike = f"{__normalised_strike:.2f}"
        normalised_strike.append(f'{__normalised_strike}{strike_extra_char}')

        delta_colour.append(colouring_rules.delta_colour(i))
        
    
    return [
        {   "row_number" : c,
            "strike" : strike_value[c],
            "strike_colour" : strike_colours[c],
            "market_call_bid" : market_call_bid[c],
            "call_bid_num" : call_bid_num[c],
            "market_call_ask" : market_call_ask[c],
            "call_ask_num" : call_ask_num[c],
            "call_fair" : call_fair[c],
            "fair_colour" : fair_colour[c],
            "market_put_bid" : market_put_bid[c],
            "put_bid_num" : put_bid_num[c],
            "put_fair" : put_fair[c],
            "market_put_ask" : market_put_ask[c],
            "put_ask_num" : put_ask_num[c],
            "call_bid" : call_bid[c],
            "call_ask" : call_ask[c],
            "put_bid" : put_bid[c],
            "put_ask" : put_ask[c],
            "call_bid_num_colour" : call_bid_num_colour[c],
            "call_bid_colour" : call_bid_colour[c],
            "put_bid_num_colour": put_bid_num_colour[c],
            "put_bid_colour" : put_bid_colour[c],
            "call_ask_colour" : call_ask_colour[c],
            "put_ask_colour" : put_ask_colour[c],
            "call_ask_num_colour" : call_ask_num_colour[c],
            "put_ask_num_colour" : put_ask_num_colour[c],
            "call_delta" : delta_call[c],
            "put_delta" : delta_put[c],
            "call_normalised_strike" : normalised_strike[c],
            "put_normalised_strike" : normalised_strike[c],
            "delta_colour" : delta_colour[c],
            "normalised_strike_colour" : normalised_strike_colour[c]

        } for c,strike in enumerate(surface_fitter["sub_fitter_expiration_info"][expiration_str]["strike"])
    ]


def vol_structure(redis_client):
    surface_fitter = json.loads(redis_client.get("__surface_fitter"))
    expirations_map = json.loads(redis_client.get("__expirations_map"))

    output = {
        "atm-vol-structure" : [0 for i in range(len(expirations_map))]
    }

    ttm = [0 for i in range(len(expirations_map))]
    ttm_iv = [0 for i in range(len(expirations_map))]

    for expiration_str in expirations_map:
        ttm_index = expirations_map[expiration_str]["ttm_index"] - 1
        atm_index = surface_fitter["sub_fitter_expiration_info"][expiration_str]["atm_index"] -1

        ttm[ttm_index] = surface_fitter["sub_fitter_expiration_info"][expiration_str]["ttm"]
        ttm_iv[ttm_index] = surface_fitter["sub_fitter_expiration_info"][expiration_str]["fair_iv"][atm_index]

        
    atm_curve = UnivariateSpline(ttm, ttm_iv, s=0)
    interp_x = np.linspace(min(ttm), max(ttm), 1000)
    interp_y = atm_curve(interp_x)

    output = {
        "atm-vol-structure" : [{"x": ttm, "y": ttm_iv[c]} for c, ttm in enumerate(ttm)],
        "atm-vol-structure-spline" : [{"x": ttm, "y": interp_y[c]} for c, ttm in enumerate(interp_x)]
    }

    return output

def compute_future_term_structure(redis_client):
    fut_df = pd.DataFrame()
    model = LinearRegression()

    keys = redis_client.keys()
    fitter_status = redis_client.get("__surface_fitter")
    instrument_map = redis_client.get("__instrument_map")

    data = json.loads(fitter_status)
    instruments = json.loads(instrument_map)
    futures = data["futures_orderbooks"]

    maturities = futures.keys()
    times = [1, 5, 10]

    drop_cols = [
        "last_traded_size",
        "last_traded_price",
        "last_traded_timestamp",
    ]

    cols = [
        "bid_size_1", "bid_size_2", "bid_size_3",
        "ask_size_1", "ask_size_2", "ask_size_3",
        "bid_price_1", "bid_price_2", "bid_price_3",
        "ask_price_1", "ask_price_2", "ask_price_3",
    ]

    for maturity in maturities:
        futures[maturity] = {
            k: [v] if isinstance(v, float) else
            v for k, v in futures[maturity].items()
        }
        del futures[maturity]["computed_price"]


        # if not futures[maturity]["last_traded_timestamp"]:
        #     continue


        future = pd.DataFrame.from_dict(futures[maturity], orient="index").T

        # Price linear regression
        _past_trades = future[drop_cols]
        _past_trades = _past_trades.dropna()
        _past_trades["last_traded_time"] = pd.to_datetime(
            _past_trades["last_traded_timestamp"], unit="ms"
        )

        # last_traded_time = _past_trades["last_traded_time"].iloc[-1]

        # model.fit(
        #     X=_past_trades[["last_traded_timestamp"]],
        #     y=_past_trades["last_traded_price"]
        # )

        # # Price info
        _temp = future.drop(drop_cols, axis=1)
        # _temp["computed_price"] = _temp["computed_price"][0]
        _temp = _temp.dropna()

        _temp = _temp.melt().T
        _temp.drop(["variable"], axis=0, inplace=True)
        _temp = _temp.iloc[:, :len(cols)]
        _temp.columns = cols
        _temp = _temp.astype(float)

        _temp["instrument_name"] = maturity
        _temp.set_index(["instrument_name"], inplace=True)

        _info = pd.DataFrame(instruments[maturity], index=[0])
        _info.set_index(["instrument_name"], inplace=True)
        _info["ttm_timestamp"] = (
            _info["expiration_timestamp"] - time.time() * 1000
        )

        _info["ttm"] = _info["ttm_timestamp"] / (365*24*60*60*1000)
        _temp["ttm"] = _temp.index.map(_info["ttm"])

        # for i in range(len(times)):
        #     _new_time = DateTime.timestamp(
        #         last_traded_time + TimeDelta(seconds=times[i])) * 1000

        #     _new_time = pd.DataFrame(
        #         [_new_time],
        #         columns=_past_trades[["last_traded_timestamp"]].columns
        #     )

        #     forecast = model.predict(_new_time)

        #     if forecast < 0:
        #         forecast = np.nan

        #     _temp[f"forecast_{times[i]}s"] = np.round(forecast, 2)

        fut_df = pd.concat([fut_df, _temp])

    fut_df["ttm"] = np.where(
        fut_df.index == "BTC-PERPETUAL",
        0,
        fut_df["ttm"]
    )


    # Simple MidPoint
    fut_df["midpoint"] = (fut_df["bid_price_1"] + fut_df["ask_price_1"]) / 2
    fut_df["midpoint"] = round(fut_df["midpoint"], 2)

    # Weighted MidPoint Calculations
    fut_df["total_size"] = 0
    fut_df["num_value"] = 0

    for i in range(1, 4):
        fut_df[f"wgt_midpoint_{i}"] = 0
        fut_df[f"layer_{i}_size"] = (
            fut_df[f"bid_size_{i}"] + fut_df[f"ask_size_{i}"]
        )

        fut_df[f"lwgt_midpoint_{i}"] = (
            fut_df[f"bid_size_{i}"] * fut_df[f"ask_price_{i}"]
            + fut_df[f"ask_size_{i}"] * fut_df[f"bid_price_{i}"]
        )

        fut_df["total_size"] += fut_df[f"layer_{i}_size"]
        fut_df["num_value"] += fut_df[f"lwgt_midpoint_{i}"]

        fut_df[f"wgt_midpoint_{i}"] = fut_df["num_value"] / fut_df["total_size"]
        fut_df[f"wgt_midpoint_{i}"] = round(fut_df[f"wgt_midpoint_{i}"], 2)


    # Fit the spline on the 1 layer weighted midpoint
    fut_df = fut_df.sort_values("ttm")
    forward_curve = UnivariateSpline(
        fut_df["ttm"], fut_df["wgt_midpoint_1"], s=0
    )

    interp_x = np.linspace(fut_df["ttm"].min(), fut_df["ttm"].max(), 1000)
    interp_y = forward_curve(interp_x)

    output = {
        "weighted_point_1" : [{"x" : i, "y" : fut_df["wgt_midpoint_1"][c]} for c,i in enumerate(fut_df["ttm"]) ],
        "spline" : [{"x" : i, "y" : interp_y[c]} for c,i in enumerate(interp_x) ],
    }

    return output

def zeta_profile_plot(sub_fitter_expiration_info, forward, underlying_future_name):
    forward = np.array(forward)
    tte = sub_fitter_expiration_info["ttm"]
    sqrt_tte = math.sqrt(sub_fitter_expiration_info["ttm"])
    active_strikes = np.array(sub_fitter_expiration_info["strike"])
    normalised_strike = np.array(sub_fitter_expiration_info["ns_strike"])
    spline_ivs = np.array(sub_fitter_expiration_info["fair_iv"])
    atm_iv = sub_fitter_expiration_info["fair_iv"][sub_fitter_expiration_info["atm_index"]-1]

    __df = pd.DataFrame(
        {
            "active_strikes" : active_strikes,
            "normalised_strike" : normalised_strike,
            "spline_ivs" : spline_ivs,
        }
    )
    __df = __df.dropna(axis=0)

    active_strikes = np.array(__df["active_strikes"])
    spline_ivs = np.array(__df["spline_ivs"])
    normalised_strike = np.array(__df["normalised_strike"])

    
    d1 = np.array((np.log(forward/active_strikes)+0.5*tte*(spline_ivs**2))/(spline_ivs*sqrt_tte)).astype(float)

    d1_pdf = sqrt2pi * np.exp(-0.5 * d1 * d1)
    vega = forward * d1_pdf * sqrt_tte
    
    zeta = vega * (spline_ivs - spline_ivs[sub_fitter_expiration_info["atm_index"]-1])

    # # zeta = zeta[::-1]
    
    # print(list(normalised_strike))
    smooth_fit = make_interp_spline(normalised_strike, zeta)
    
    smooth_points = np.linspace(
        min(normalised_strike),
        max(normalised_strike),
        granularity
    )
    smooth_zeta = smooth_fit(smooth_points)

    output = {
        "zeta_profile" : [{"x":strike,"y":smooth_zeta[c]} for c, strike in enumerate(smooth_points)],
        "forward" : [{"x" : 0, "y":0}, {"x" : 0, "y" : 1}],
        "underlying_name" : underlying_future_name
    }
    
    return output

def compute_implied_probabilities_plot(sub_fitter_expiration_info, expiration_str, underlying_price) -> dict:
    granularity = 500
    
    df = pd.DataFrame()
    __df = pd.DataFrame(
        {
            "strike" : sub_fitter_expiration_info["strike"],
            "ns_strike" : sub_fitter_expiration_info["ns_strike"],
            "call_fair_price" : sub_fitter_expiration_info["call_fair_price"]
        }
    )
    __df = __df.dropna(how='any',axis=0) 


    # Create smooth spline
    interp_price = make_interp_spline(
        __df["strike"],
        __df["call_fair_price"]
    )

    df["strike"] = np.linspace(
        min(sub_fitter_expiration_info["strike"]),
        max(sub_fitter_expiration_info["strike"]),
        granularity
    )

    df["forward"] = underlying_price
    df["fair_price"] = interp_price(df["strike"]) * df["forward"]

    # Own pricing
    df["Dfair_price"] = df["fair_price"].diff()
    df["Dstrike"] = df["strike"].diff()

    df["Dfair_price_Dstrike"] = df["Dfair_price"] / df["Dstrike"]

    df["D2fair_price_Dstrike2"] = df["Dfair_price_Dstrike"].diff() / df["Dstrike"]

    df["cdf_fair_price"] = np.cumsum(
        df["D2fair_price_Dstrike2"] * df["Dstrike"][2]
    )
        
    strikes = list(df["strike"])
    strikes_cdf_fair_price = list(df["cdf_fair_price"].fillna(0))
    strikes_D2fair_price_Dstrike2 = list(df["D2fair_price_Dstrike2"].fillna(0))




    df = pd.DataFrame()
    # Create smooth spline
    interp_price = make_interp_spline(
        __df["ns_strike"],
        __df["call_fair_price"]
    )

    df["ns_strike"] = np.linspace(
        min(sub_fitter_expiration_info["ns_strike"]),
        max(sub_fitter_expiration_info["ns_strike"]),
        granularity
    )

    df["forward"] = underlying_price
    df["fair_price"] = interp_price(df["ns_strike"]) * df["forward"]

    # Own pricing
    df["Dfair_price"] = df["fair_price"].diff()
    df["Dstrike"] = df["ns_strike"].diff()

    df["Dfair_price_Dstrike"] = df["Dfair_price"] / df["Dstrike"]

    df["D2fair_price_Dstrike2"] = df["Dfair_price_Dstrike"].diff() / df["Dstrike"]

    df["cdf_fair_price"] = np.cumsum(
        df["D2fair_price_Dstrike2"] * df["Dstrike"][2]
    )
        
    ns_strike = list(df["ns_strike"])
    ns_strikes_cdf_fair_price = list(df["cdf_fair_price"].fillna(0))
    ns_strikes_D2fair_price_Dstrike2 = list(df["D2fair_price_Dstrike2"].fillna(0))

    
    output = {
        "strikes_cdf" : [
            {"x":strike,"y":strikes_cdf_fair_price[c]} for c, strike in enumerate(strikes)
        ],
        "strikes_pdf" : [
            {"x":strike,"y":strikes_D2fair_price_Dstrike2[c]} for c, strike in enumerate(strikes)
        ],
        "strikes_forward" : [
            {"x":underlying_price,"y":0}, {"x":underlying_price,"y":1}
        ],




        "ns_strikes_cdf" : [
            {"x":strike,"y":ns_strikes_cdf_fair_price[c]} for c, strike in enumerate(ns_strike)
        ],
        "ns_strikes_pdf" : [
            {"x":strike,"y":ns_strikes_D2fair_price_Dstrike2[c]} for c, strike in enumerate(ns_strike)
        ],        
        "ns_strikes_forward" : [
            {"x":0,"y":0}, {"x":0,"y":1}
        ],

        "underlying_name" : expiration_str,
    }

    return output

colours = {
    "strike" : {
            "odd_strike_0" : "#e0e0e0",
            "even_strike_0" : "#e4e4e4",
            "strike_atm_1" : "#ffff80",
            "strike_atm_2" : "#f7f7ab",            
        },
    "put_bid_num" : {
            "odd_volume_empty" : "#f9d5b0",
            "even_volume_empty" : "#ffc080",
            
            "odd_bid_empty" : "#ffffff",
            "even_bid_empty" : "#fcfcfc",
            
            "odd_bid_bbo" : "#64f8f8",
            "even_bid_bbo" : "#01ffff",
            
            "odd_bid_matching" : "#60d5d7",
            "even_bid_matching" : "#00c0c0",
        },
    "put_bid" : {
            "odd_volume_empty" : "#f9d5b0",
            "even_volume_empty" : "#ffc080",
            
            "odd_bid_empty" : "#ffffff",
            "even_bid_empty" : "#fcfcfc",
            
            "odd_bid_bbo" : "#64f8f8",
            "even_bid_bbo" : "#01ffff",
            
            "odd_bid_matching" : "#60d5d7",
            "even_bid_matching" : "#00c0c0",
        },
    "fair" : {
            "odd_fair" : "#f9fbb0",
            "even_fair" : "#ffff80",
        },
    "put_ask" : {
            "odd_volume_empty" : "#f9d5b0",
            "even_volume_empty" : "#ffc080",
            
            "odd_ask_empty" : "#ffffff",
            "even_ask_empty" : "#fcfcfc",
            
            "odd_ask_bbo" : "#f9aefd",
            "even_ask_bbo" : "#ff80ff",
            
            "odd_ask_matching" : "#d362d7",
            "even_ask_matching" : "#c000c0",
        },
    "put_ask_num" : {
            "odd_volume_empty" : "#f9d5b0",
            "even_volume_empty" : "#ffc080",
            
            "odd_ask_empty" : "#ffffff",
            "even_ask_empty" : "#fcfcfc",
            
            "odd_ask_bbo" : "#f9aefd",
            "even_ask_bbo" : "#ff80ff",
            
            "odd_ask_matching" : "#d362d7",
            "even_ask_matching" : "#c000c0",
        },
    "normalised_strike" : {
            "odd_level_0" : "#d7d2f8",
            "even_level_0" : "#c0c0ff",
            
            "odd_level_1" : "#fdf85f",
            "even_level_1" : "#ffff00",
            
            "odd_level_2" : "#64f85f",
            "even_level_2" : "#01ff00",
            
            "odd_level_3" : "#64f8f8",
            "even_level_3" : "#01ffff",
            
            "odd_level_4" : "#fe4de8",
            "even_level_4" : "#f60ad9",
            
            "odd_level_5" : "#ff932e",
            "even_level_5" : "#fa7c05",
        },
    "delta" : {
            "odd_delta" : "#f9fbb0",
            "even_delta" : "#ffff80",
        },
    "iv_diffs" : {
            "odd_negative_colour" : "#f6d4da",
            "even_negative_colour" : "#ffc6c3",
            "odd_positive_colour" : "#c8f7d6",
            "even_positive_colour" : "#befbbe",
        },
    "call_bid_num" : {
            "even_volume_empty" : "#ffc080",
            "odd_volume_empty" : "#f9d5b0",
            "even_bid_empty" : "#fcfcfc",
            "odd_bid_empty" : "#ffffff",
            "even_bid_bbo" : "#01ffff",
            "odd_bid_bbo" : "#64f8f8",
            "even_bid_matching" : "#00c0c0",
            "odd_bid_matching" : "#60d5d7",
        },
    "call_bid" : {
            "even_volume_empty" : "#ffc080",
            "odd_volume_empty" : "#f9d5b0",
            "even_bid_empty" : "#fcfcfc",
            "odd_bid_empty" : "#ffffff",
            "even_bid_bbo" : "#01ffff",
            "odd_bid_bbo" : "#64f8f8",
            "even_bid_matching" : "#00c0c0",
            "odd_bid_matching" : "#60d5d7",
        },
    "call_ask" : {
            "even_ask_empty" : "#fcfcfc",
            "odd_ask_empty" : "#ffffff",
            "even_ask_bbo" : "#ff80ff",
            "odd_ask_bbo" : "#f9aefd",
            "even_ask_matching" : "#c000c0",
            "odd_ask_matching" : "#d362d7",
        },
    "call_ask_num" : {
            "even_volume_empty" : "#ffc080",
            "odd_volume_empty" : "#f9d5b0",
            "even_ask_empty" : "#fcfcfc",
            "odd_ask_empty" : "#ffffff",
            "even_ask_bbo" : "#ff80ff",
            "odd_ask_bbo" : "#f9aefd",
            "even_ask_matching" : "#c000c0",
            "odd_ask_matching" : "#d362d7",
        }
}

class QuotingColouringRules:
    def fair_colour(self, row_count: int) -> str:
        if row_count % 2 == 0:
            return colours["fair"]["even_fair"]
        else:
            return colours["fair"]["odd_fair"]
    
    def strike_colour(self, row_count: int, strike: int, atm_strike: int, atm_strike_2: int) -> str:
        if strike == atm_strike:
            return colours["strike"]["strike_atm_1"]
        elif strike == atm_strike_2:
            return colours["strike"]["strike_atm_2"]
        else:
            if row_count % 2 == 0:
                return colours["strike"]["even_strike_0"]
            else:
                return colours["strike"]["odd_strike_0"]
    
    def bid_num_colour(self, row_count: int, market_size: float, own_price: float, market_price: float) -> str:
        if market_size == "-" and own_price == "-":
            if row_count % 2 == 0:
                return colours["call_bid_num"]["even_volume_empty"]
            else:
                return colours["call_bid_num"]["odd_volume_empty"]
        if market_size == "-" or own_price == "-":
            if row_count % 2 == 0:
                return colours["call_bid_num"]["even_bid_empty"]
            else:
                return colours["call_bid_num"]["odd_bid_empty"]
        if own_price > market_price:
            if row_count % 2 == 0:
                return colours["call_bid_num"]["even_bid_bbo"]
            else:
                return colours["call_bid_num"]["odd_bid_bbo"]
        elif own_price < market_price:
            if row_count % 2 == 0:
                return colours["call_bid_num"]["even_bid_empty"]
            else:
                return colours["call_bid_num"]["odd_bid_empty"]
        else:
            if row_count % 2 == 0:
                return colours["call_bid_num"]["even_bid_matching"]
            else:
                return colours["call_bid_num"]["odd_bid_matching"]
            
    def bid_colour(self, row_count: int, market_size: float, own_price: float, market_price: float) -> str:
        if market_size == "-" and own_price != "-":
            if row_count % 2 == 0:
                return colours["put_bid"]["even_bid_bbo"]
            else:
                return colours["put_bid"]["odd_bid_bbo"]
        if market_size == "-":
            if row_count % 2 == 0:
                return colours["put_bid"]["even_bid_empty"]
            else:
                return colours["put_bid"]["odd_bid_empty"]
        if own_price == "-" or market_size == "-":
            if row_count % 2 == 0:
                return colours["put_bid"]["even_bid_empty"]
            else:
                return colours["put_bid"]["odd_bid_empty"]
        else:
            if own_price > market_price:
                if row_count % 2 == 0:
                    return colours["put_bid"]["even_bid_bbo"]
                else:
                    return colours["put_bid"]["odd_bid_bbo"]
            elif own_price < market_price:
                if row_count % 2 == 0:
                    return colours["put_bid"]["even_bid_empty"]
                else:
                    return colours["put_bid"]["odd_bid_empty"]
            else:
                if row_count % 2 == 0:
                    return colours["put_bid"]["even_bid_matching"]
                else:
                    return colours["put_bid"]["odd_bid_matching"]
    
    def ask_colour(self, row_count: int, market_size: float, own_price: float, market_price: float) -> str:
        if market_size == "-" and own_price != "-":
            if row_count % 2 == 0:
                return colours["put_ask"]["even_ask_bbo"]
            else:
                return colours["put_ask"]["odd_ask_bbo"]
        if market_price == "-" or own_price == "-":
            if row_count % 2 == 0:
                return colours["put_ask"]["even_ask_empty"]
            else:
                return colours["put_ask"]["odd_ask_empty"]
        if own_price == "-":
            if row_count % 2 == 0:
                return colours["put_ask"]["even_ask_empty"]
            else:
                return colours["put_ask"]["odd_ask_empty"]
        if own_price == "-":
            if row_count % 2 == 0:
                return colours["put_ask"]["even_ask_bbo"]
            else:
                return colours["put_ask"]["odd_ask_bbo"]
        else:
            if own_price < market_price:
                if row_count % 2 == 0:
                    return colours["put_ask"]["even_ask_bbo"]
                else:
                    return colours["put_ask"]["odd_ask_bbo"]
            elif own_price > market_price:
                if row_count % 2 == 0:
                    return colours["put_ask"]["even_ask_empty"]
                else:
                    return colours["put_ask"]["odd_ask_empty"]
            else:
                if row_count % 2 == 0:
                    return colours["put_ask"]["even_ask_matching"]
                else:
                    return colours["put_ask"]["odd_ask_matching"]
    
    def ask_num_colour(self, row_count: int, market_size: float, own_price: float, market_price: float) -> str:
        if own_price == "-" and  market_size == "-":
            if row_count % 2 == 0:
                return colours["put_ask_num"]["even_volume_empty"]
            else:
                return colours["put_ask_num"]["odd_volume_empty"]
        if own_price == "-":
            if row_count % 2 == 0:
                return colours["put_ask_num"]["even_volume_empty"]
            else:
                return colours["put_ask_num"]["odd_volume_empty"]
        if market_price == "-":
            if row_count % 2 == 0:
                return colours["put_ask_num"]["even_ask_bbo"]
            else:
                return colours["put_ask_num"]["odd_ask_bbo"]
        else:
            if own_price < market_price:
                if row_count % 2 == 0:
                    return colours["put_ask_num"]["even_ask_bbo"]
                else:
                    return colours["put_ask_num"]["odd_ask_bbo"]
            elif own_price > market_price:
                if row_count % 2 == 0:
                    return colours["put_ask_num"]["even_ask_empty"]
                else:
                    return colours["put_ask_num"]["odd_ask_empty"]
            else:
                if row_count % 2 == 0:
                    return colours["put_ask_num"]["even_ask_matching"]
                else:
                    return colours["put_ask_num"]["odd_ask_matching"]
    
    def delta_colour(self, row_count: int) -> str:
        if row_count % 2 == 0:
            return colours["delta"]["even_delta"]
        else:
            return colours["delta"]["odd_delta"]

    def ns_strike_colour(self, row_count: int, ns_strike: float) -> str:
        if abs(ns_strike) < 1:
            if row_count % 2 == 0:
                return colours["normalised_strike"]["even_level_0"]
            else:
                return colours["normalised_strike"]["odd_level_0"]
        elif abs(ns_strike) < 2:
            if row_count % 2 == 0:
                return colours["normalised_strike"]["even_level_1"]
            else:
                return colours["normalised_strike"]["odd_level_1"]
        elif abs(ns_strike) < 2.5:
            if row_count % 2 == 0:
                return colours["normalised_strike"]["even_level_2"]
            else:
                return colours["normalised_strike"]["odd_level_2"]
        elif abs(ns_strike) < 3:
            if row_count % 2 == 0:
                return colours["normalised_strike"]["even_level_3"]
            else:
                return colours["normalised_strike"]["odd_level_3"]
        else:
            if row_count % 2 == 0:
                return colours["normalised_strike"]["even_level_4"]
            else:
                return colours["normalised_strike"]["odd_level_4"]