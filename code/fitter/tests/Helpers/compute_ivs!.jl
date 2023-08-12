using Test;
using JSON;

#########
@info "Helpers.compute_ivs! -- basic iv calculation validation"

current_time = 1687723381
expirations_map = Dict(
    "30JUN23" => Dict(
        "expiration_timestamp" => 1688112000000,
        "full_underlying_name" => "BTC-30JUN23",
        "strike" => [30000.0,],
        "put_instruments" => ["BTC-30JUN23-30000-P"],
        "call_instruments" => ["BTC-30JUN23-30000-C"]
    )
)
sub_fitter_expiration_info = Dict(
    "30JUN23" => Dict(
        "ttm" => NaN
    )
)
options_orderbooks = Dict(
    "BTC-30JUN23-30000-P" => Dict(
        "top_ask_price" => 0.0135,
        "top_bid_price" => 0.0125,
        "fitting_weighted_price" => 0.0127
    ),
    "BTC-30JUN23-30000-C" => Dict(
        "top_ask_price" => 0.0300,
        "top_bid_price" => 0.0280,
        "fitting_weighted_price" => 0.0291
    ),
)

futures_orderbooks = Dict(
    "BTC-30JUN23" => Dict(
        "computed_price" => 30400.0
    )
)

target_output = Dict(
    "BTC-30JUN23-30000-C" => Dict(
        "fitting_weighted_price" => 0.0291,
        "top_bid_price" => 0.028,
        "top_ask_price" => 0.03
    ),
    "BTC-30JUN23-30000-P" => Dict(
        "fitting_weighted_price" => 0.0127,
        "top_bid_price" => 0.0125,
        "top_ask_price" => 0.0135
    )
)

@test JSON.json(target_output) == JSON.json(options_orderbooks)
#########




#########
@info "Helpers.compute_ivs! -- swap Put and Call prices"

current_time = 1687723381
expirations_map = Dict(
    "30JUN23" => Dict(
        "expiration_timestamp" => 1688112000000,
        "full_underlying_name" => "BTC-30JUN23",
        "strike" => [30000.0,],
        "put_instruments" => ["BTC-30JUN23-30000-P"],
        "call_instruments" => ["BTC-30JUN23-30000-C"],
    )
)
sub_fitter_expiration_info = Dict(
    "30JUN23" => Dict(
        "ttm" => NaN
    )
)
options_orderbooks = Dict(
    "BTC-30JUN23-30000-P" => Dict(
        "top_ask_price" => 0.0135,
        "top_bid_price" => 0.0125,
        "fitting_weighted_price" => 0.0127
    ),
    "BTC-30JUN23-30000-C" => Dict(
        "top_ask_price" => 0.0300,
        "top_bid_price" => 0.0280,
        "fitting_weighted_price" => 0.0291
    ),
)
futures_orderbooks = Dict(
    "BTC-30JUN23" => Dict(
        "computed_price" => 30400.0
    )
)

Helpers.compute_ivs!(expirations_map, options_orderbooks, futures_orderbooks, sub_fitter_expiration_info, current_time)

target_output = Dict(
    "BTC-30JUN23-30000-C" => Dict(
        "fitting_weighted_price" => 0.0291,
        "top_bid_price" => 0.028,
        "top_ask_price" => 0.03,
        "top_bid_iv" => 0.47195558410404675,
        "top_ask_iv" => 0.5187751528454021,
        "fitting_weighted_iv" => 0.49773761545715883
    ),
    "BTC-30JUN23-30000-P" => Dict(
        "fitting_weighted_price" => 0.0127,
        "top_bid_price" => 0.0125,
        "top_ask_price" => 0.0135,
        "top_bid_iv" => 0.416739916792453,
        "top_ask_iv" => 0.44037596140136465,
        "fitting_weighted_iv" => 0.42147529979046505
    )
)

@test JSON.json(target_output) == JSON.json(options_orderbooks)
#########




#########
@info "Helpers.compute_ivs! -- wide prices - 1"

current_time = 1687723381
expirations_map = Dict(
    "30JUN23" => Dict(
        "expiration_timestamp" => 1688112000000,
        "full_underlying_name" => "BTC-30JUN23",
        "strike" => [30000.0,],
        "put_instruments" => ["BTC-30JUN23-30000-P"],
        "call_instruments" => ["BTC-30JUN23-30000-C"],
    )
)
sub_fitter_expiration_info = Dict(
    "30JUN23" => Dict(
        "ttm" => NaN
    )
)
options_orderbooks = Dict(
    "BTC-30JUN23-30000-P" => Dict(
        "top_ask_price" => 0.5000,
        "top_bid_price" => 0.0005,
        "fitting_weighted_price" => 0.0012
    ),
    "BTC-30JUN23-30000-C" => Dict(
        "top_ask_price" => 0.1000,
        "top_bid_price" => 0.0005,
        "fitting_weighted_price" => 0.005
    ),
)
futures_orderbooks = Dict(
    "BTC-30JUN23" => Dict(
        "computed_price" => 30400.0
    )
)

Helpers.compute_ivs!(expirations_map, options_orderbooks, futures_orderbooks, sub_fitter_expiration_info, current_time)

target_output = Dict(
    "BTC-30JUN23-30000-C" => Dict(
        "fitting_weighted_price" => 0.005,
        "top_bid_price" => 0.0005,
        "top_ask_price" => 0.1,
        "top_bid_iv" => NaN,
        "top_ask_iv" => 2.12504435991599,
        "fitting_weighted_iv" => NaN
    ), 
    "BTC-30JUN23-30000-P" => Dict(
        "fitting_weighted_price" => 0.0012,
        "top_bid_price" => 0.0005,
        "top_ask_price" => 0.5,
        "top_bid_iv" => 0.09381838569340384,
        "top_ask_iv" => 12.43450340845998,
        "fitting_weighted_iv" => 0.1231452884457126
    )
)

@test JSON.json(target_output) == JSON.json(options_orderbooks)
#########




#########
@info "Helpers.compute_ivs! -- wide prices - 2"

current_time = 1687723381
expirations_map = Dict(
    "30JUN23" => Dict(
        "expiration_timestamp" => 1688112000000,
        "full_underlying_name" => "BTC-30JUN23",
        "strike" => [50000.0,],
        "put_instruments" => ["BTC-30JUN23-50000-P"],
        "call_instruments" => ["BTC-30JUN23-50000-C"],
    )
)
sub_fitter_expiration_info = Dict(
    "30JUN23" => Dict(
        "ttm" => NaN
    )
)
options_orderbooks = Dict(
    "BTC-30JUN23-50000-P" => Dict(
        "top_ask_price" => 0.5000,
        "top_bid_price" => 0.0005,
        "fitting_weighted_price" => 0.05
    ),
    "BTC-30JUN23-50000-C" => Dict(
        "top_ask_price" => 0.1000,
        "top_bid_price" => 0.0005,
        "fitting_weighted_price" => 0.0012
    ),
)
futures_orderbooks = Dict(
    "BTC-30JUN23" => Dict(
        "computed_price" => 30400.0
    )
)

Helpers.compute_ivs!(expirations_map, options_orderbooks, futures_orderbooks, sub_fitter_expiration_info, current_time)

target_output = Dict(
    "BTC-30JUN23-50000-P" => Dict(
        "fitting_weighted_price" => 0.05,
        "top_bid_price" => 0.0005,
        "top_ask_price" => 0.5,
        "top_bid_iv" => NaN,
        "top_ask_iv" => NaN,
        "fitting_weighted_iv" => NaN
    ),
    "BTC-30JUN23-50000-C" => Dict(
        "fitting_weighted_price" => 0.0012,
        "top_bid_price" => 0.0005,
        "top_ask_price" => 0.1,
        "top_bid_iv" => 1.7890998834759313,
        "top_ask_iv" => 5.774717392806997,
        "fitting_weighted_iv" => 1.9932498754153216
    )
)

@test JSON.json(target_output) == JSON.json(options_orderbooks)
#########




#########
@info "Helpers.compute_ivs! -- wide prices - 3"

current_time = 1687723381
expirations_map = Dict(
    "30JUN23" => Dict(
        "expiration_timestamp" => 1688112000000,
        "full_underlying_name" => "BTC-30JUN23",
        "strike" => [100000.0,],
        "put_instruments" => ["BTC-30JUN23-100000-P"],
        "call_instruments" => ["BTC-30JUN23-100000-C"],
    )
)
sub_fitter_expiration_info = Dict(
    "30JUN23" => Dict(
        "ttm" => NaN
    )
)
options_orderbooks = Dict(
    "BTC-30JUN23-100000-P" => Dict(
        "top_ask_price" => 0.5000,
        "top_bid_price" => 0.0005,
        "fitting_weighted_price" => 0.05
    ),
    "BTC-30JUN23-100000-C" => Dict(
        "top_ask_price" => 0.1000,
        "top_bid_price" => 0.0005,
        "fitting_weighted_price" => 0.0015
    ),
)
futures_orderbooks = Dict(
    "BTC-30JUN23" => Dict(
        "computed_price" => 30400.0
    )
)

Helpers.compute_ivs!(expirations_map, options_orderbooks, futures_orderbooks, sub_fitter_expiration_info, current_time)

target_output = Dict(
    "BTC-30JUN23-100000-P" => Dict(
        "fitting_weighted_price" => 0.05,
        "top_bid_price" => 0.0005,
        "top_ask_price" => 0.5,
        "top_bid_iv" => NaN,
        "top_ask_iv" => NaN,
        "fitting_weighted_iv" => NaN
    ),
    "BTC-30JUN23-100000-C" => Dict(
        "fitting_weighted_price" => 0.0015,
        "top_bid_price" => 0.0005,
        "top_ask_price" => 0.1,
        "top_bid_iv" => 3.779583582480292,
        "top_ask_iv" => 9.139586933019606,
        "fitting_weighted_iv" => 4.232508899812415
    )
)

@test JSON.json(target_output) == JSON.json(options_orderbooks)
#########




#########
@info "Helpers.compute_ivs! -- wide prices - 4"

current_time = 1687723381
expirations_map = Dict(
    "30JUN23" => Dict(
        "expiration_timestamp" => 1688112000000,
        "full_underlying_name" => "BTC-30JUN23",
        "strike" => [100000.0,],
        "put_instruments" => ["BTC-30JUN23-100000-P"],
        "call_instruments" => ["BTC-30JUN23-100000-C"],
    )
)
sub_fitter_expiration_info = Dict(
    "30JUN23" => Dict(
        "ttm" => NaN
    )
)
options_orderbooks = Dict(
    "BTC-30JUN23-100000-P" => Dict(
        "top_ask_price" => 8.5000,
        "top_bid_price" => 0.0005,
        "fitting_weighted_price" => 6.05
    ),
    "BTC-30JUN23-100000-C" => Dict(
        "top_ask_price" => 8.1000,
        "top_bid_price" => 0.0005,
        "fitting_weighted_price" => 7.0012
    ),
)
futures_orderbooks = Dict(
    "BTC-30JUN23" => Dict(
        "computed_price" => 30400.0
    )
)

Helpers.compute_ivs!(expirations_map, options_orderbooks, futures_orderbooks, sub_fitter_expiration_info, current_time)

target_output = Dict(
    "BTC-30JUN23-100000-P" => Dict(
        "fitting_weighted_price" => 6.05,
        "top_bid_price" => 0.0005,
        "top_ask_price" => 8.5,
        "top_bid_iv" => NaN,
        "top_ask_iv" => NaN,
        "fitting_weighted_iv" => NaN
    ),
    "BTC-30JUN23-100000-C" => Dict(
        "fitting_weighted_price" => 7.0012,
        "top_bid_price" => 0.0005,
        "top_ask_price" => 8.1,
        "top_bid_iv" => 3.779583582480292,
        "top_ask_iv" => NaN,
        "fitting_weighted_iv" => NaN
    )
)

@test JSON.json(target_output) == JSON.json(options_orderbooks)
# #########




#########
@info "Helpers.compute_ivs! -- wide prices - 5"

current_time = 1687723381
expirations_map = Dict(
    "30JUN23" => Dict(
        "expiration_timestamp" => 1688112000000,
        "full_underlying_name" => "BTC-30JUN23",
        "strike" => [2000.0,],
        "put_instruments" => ["BTC-30JUN23-2000-P"],
        "call_instruments" => ["BTC-30JUN23-2000-C"],
    )
)
sub_fitter_expiration_info = Dict(
    "30JUN23" => Dict(
        "ttm" => NaN
    )
)
options_orderbooks = Dict(
    "BTC-30JUN23-2000-P" => Dict(
        "top_ask_price" => 8.5000,
        "top_bid_price" => 0.0005,
        "fitting_weighted_price" => 6.05
    ),
    "BTC-30JUN23-2000-C" => Dict(
        "top_ask_price" => 8.1000,
        "top_bid_price" => 0.0005,
        "fitting_weighted_price" => 7.005
    ),
)
futures_orderbooks = Dict(
    "BTC-30JUN23" => Dict(
        "computed_price" => 30400.0
    )
)

Helpers.compute_ivs!(expirations_map, options_orderbooks, futures_orderbooks, sub_fitter_expiration_info, current_time)

target_output = Dict(
    "BTC-30JUN23-2000-P" => Dict(
        "fitting_weighted_price" => 6.05,
        "top_bid_price" => 0.0005,
        "top_ask_price" => 8.5,
        "top_bid_iv" => 9.817767527031148,
        "top_ask_iv" => NaN,
        "fitting_weighted_iv" => NaN
    ),
    "BTC-30JUN23-2000-C" => Dict(
        "fitting_weighted_price" => 7.005,
        "top_bid_price" => 0.0005,
        "top_ask_price" => 8.1,
        "top_bid_iv" => NaN,
        "top_ask_iv" => NaN,
        "fitting_weighted_iv" => NaN
    )
)

@test JSON.json(target_output) == JSON.json(options_orderbooks)
#########




#########
@info "Helpers.compute_ivs! -- wide underlying - 1"

current_time = 1687723381
expirations_map = Dict(
    "30JUN23" => Dict(
        "expiration_timestamp" => 1688112000000,
        "full_underlying_name" => "BTC-30JUN23",
        "strike" => [2000.0,],
        "put_instruments" => ["BTC-30JUN23-2000-P"],
        "call_instruments" => ["BTC-30JUN23-2000-C"],
    )
)
sub_fitter_expiration_info = Dict(
    "30JUN23" => Dict(
        "ttm" => NaN
    )
)
options_orderbooks = Dict(
    "BTC-30JUN23-2000-P" => Dict(
        "top_ask_price" => 8.5000,
        "top_bid_price" => 0.0005,
        "fitting_weighted_price" => 7.005
    ),
    "BTC-30JUN23-2000-C" => Dict(
        "top_ask_price" => 8.1000,
        "top_bid_price" => 0.0005,
        "fitting_weighted_price" => 6.05
    ),
)
futures_orderbooks = Dict(
    "BTC-30JUN23" => Dict(
        "computed_price" => 80400.0
    )
)

Helpers.compute_ivs!(expirations_map, options_orderbooks, futures_orderbooks, sub_fitter_expiration_info, current_time)

target_output = Dict(
    "BTC-30JUN23-2000-P" => Dict(
        "fitting_weighted_price" => 7.005,
        "top_bid_price" => 0.0005,
        "top_ask_price" => 8.5,
        "top_bid_iv" => 13.802876810736828,
        "top_ask_iv" => NaN,
        "fitting_weighted_iv" => NaN
    ),
    "BTC-30JUN23-2000-C" => Dict(
        "fitting_weighted_price" => 6.05,
        "top_bid_price" => 0.0005,
        "top_ask_price" => 8.1,
        "top_bid_iv" => NaN,
        "top_ask_iv" => NaN,
        "fitting_weighted_iv" => NaN
    )
)

@test JSON.json(target_output) == JSON.json(options_orderbooks)
#########




#########
@info "Helpers.compute_ivs! -- wide underlying - 2"

current_time = 1687723381
expirations_map = Dict(
    "30JUN23" => Dict(
        "expiration_timestamp" => 1688112000000,
        "full_underlying_name" => "BTC-30JUN23",
        "strike" => [2000.0,],
        "put_instruments" => ["BTC-30JUN23-2000-P"],
        "call_instruments" => ["BTC-30JUN23-2000-C"],
    )
)
sub_fitter_expiration_info = Dict(
    "30JUN23" => Dict(
        "ttm" => NaN
    )
)
options_orderbooks = Dict(
    "BTC-30JUN23-2000-P" => Dict(
        "top_ask_price" => 8.5000,
        "top_bid_price" => 0.0005,
        "fitting_weighted_price" => 7.005
    ),
    "BTC-30JUN23-2000-C" => Dict(
        "top_ask_price" => 8.1000,
        "top_bid_price" => 0.0005,
        "fitting_weighted_price" => 6.005
    ),
)
futures_orderbooks = Dict(
    "BTC-30JUN23" => Dict(
        "computed_price" => 400.0
    )
)

Helpers.compute_ivs!(expirations_map, options_orderbooks, futures_orderbooks, sub_fitter_expiration_info, current_time)

target_output = Dict(
    "BTC-30JUN23-2000-P" => Dict(
        "fitting_weighted_price" => 7.005,
        "top_bid_price" => 0.0005,
        "top_ask_price" => 8.5,
        "top_bid_iv" => NaN,
        "top_ask_iv" => NaN,
        "fitting_weighted_iv" => NaN
    ),
    "BTC-30JUN23-2000-C" => Dict(
        "fitting_weighted_price" => 6.005,
        "top_bid_price" => 0.0005,
        "top_ask_price" => 8.1,
        "top_bid_iv" => 4.882799472014584,
        "top_ask_iv" => NaN,
        "fitting_weighted_iv" => NaN
    )
)

@test JSON.json(target_output) == JSON.json(options_orderbooks)
#########