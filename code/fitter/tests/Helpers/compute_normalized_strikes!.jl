using Test;
using JSON;

#########
@info "Helpers.compute_normalized_strikes! -- normalized strikes empty case"

sub_fitter_expiration_info = Dict(
    "30JUN23" => Dict(
        "strike" => [30000.0],
        "fitting_count" => NaN,
        "ttm_index" => NaN,
        "atm_index" => NaN,
        "fair_iv" => NaN,
    )
)
futures_orderbooks = Dict(
    "BTC-30JUN23" => Dict(
        "computed_price" => 30500.0
    )
)
options_orderbooks = Dict(
    "BTC-30JUN23-30000-C" => Dict(
        "top_ask_iv" => NaN,
        "top_bid_iv" => NaN,
    ),
    "BTC-30JUN23-30000-P" => Dict(
        "top_ask_iv" => NaN,
        "top_bid_iv" => NaN,
    )
)
expirations_map = Dict(
    "30JUN23" => Dict(
        "expiration_timestamp" => 1688112000000,
        "full_underlying_name" => "BTC-30JUN23",
        "call_instruments" => ["BTC-30JUN23-30000-C"],
        "put_instruments" => ["BTC-30JUN23-30000-P"],
    )
)
current_time = 1687723381

Helpers.compute_normalized_strikes!(sub_fitter_expiration_info, futures_orderbooks, options_orderbooks, expirations_map, current_time)

target_object = Dict(
    "30JUN23" => Dict(
        "ttm_index" => NaN,
        "fair_iv" => [NaN],
        "strike_count" => NaN,
        "ns_strike" => [NaN],
        "atm_index" => NaN,
        "fitting_strike" => [NaN],
        "strike" => [30000.0],
        "fitting_point" => [NaN],
        "fitting_count" => NaN
    )
)

@test JSON.json(sub_fitter_expiration_info) == JSON.json(target_object)
#########




#########
@info "Helpers.compute_normalized_strikes! -- normalized strikes empty forward price"

sub_fitter_expiration_info = Dict(
    "30JUN23" => Dict(
        "strike" => [30000.0],
        "fitting_count" => NaN,
        "ttm_index" => NaN,
        "atm_index" => NaN,
        "fair_iv" => NaN,
    )
)
futures_orderbooks = Dict(
    "BTC-30JUN23" => Dict(
        "computed_price" => NaN
    )
)
options_orderbooks = Dict(
    "BTC-30JUN23-30000-C" => Dict(
        "top_ask_iv" => NaN,
        "top_bid_iv" => NaN,
    ),
    "BTC-30JUN23-30000-P" => Dict(
        "top_ask_iv" => NaN,
        "top_bid_iv" => NaN,
    )
)
expirations_map = Dict(
    "30JUN23" => Dict(
        "expiration_timestamp" => 1688112000000,
        "full_underlying_name" => "BTC-30JUN23",
        "call_instruments" => ["BTC-30JUN23-30000-C"],
        "put_instruments" => ["BTC-30JUN23-30000-P"],
    )
)
current_time = 1687723381

Helpers.compute_normalized_strikes!(sub_fitter_expiration_info, futures_orderbooks, options_orderbooks, expirations_map, current_time)

target_object = Dict(
    "30JUN23" => Dict(
        "ttm_index" => NaN,
        "fair_iv" => NaN,
        "atm_index" => NaN,
        "strike" => [30000.0],
        "fitting_count" => NaN
    )
)

@test JSON.json(sub_fitter_expiration_info) == JSON.json(target_object)
#########




#########
@info "Helpers.compute_normalized_strikes! -- valid ATM strike index"

sub_fitter_expiration_info = Dict(
    "30JUN23" => Dict(
        "strike" => [30000.0, 31000.0, 32000.0],
        "ns_strike" => zeros(3) * NaN,
        "fitting_count" => NaN,
        "ttm_index" => NaN,
        "atm_index" => NaN,
        "fair_iv" => NaN,
    )
)
futures_orderbooks = Dict(
    "BTC-30JUN23" => Dict(
        "computed_price" => 30590.0
    )
)
options_orderbooks = Dict(
    "BTC-30JUN23-30000-C" => Dict(
        "top_ask_iv" => 0.51,
        "top_bid_iv" => 0.41,
    ),
    "BTC-30JUN23-30000-P" => Dict(
        "top_ask_iv" => 0.61,
        "top_bid_iv" => 0.31,
    ),
    "BTC-30JUN23-31000-C" => Dict(
        "top_ask_iv" => 0.52,
        "top_bid_iv" => 0.42,
    ),
    "BTC-30JUN23-31000-P" => Dict(
        "top_ask_iv" => 0.62,
        "top_bid_iv" => 0.32,
    ),
    "BTC-30JUN23-32000-C" => Dict(
        "top_ask_iv" => 0.53,
        "top_bid_iv" => 0.43,
    ),
    "BTC-30JUN23-32000-P" => Dict(
        "top_ask_iv" => 0.63,
        "top_bid_iv" => 0.33,
    )
)
expirations_map = Dict(
    "30JUN23" => Dict(
        "expiration_timestamp" => 1688112000000,
        "full_underlying_name" => "BTC-30JUN23",
        "call_instruments" => ["BTC-30JUN23-30000-C", "BTC-30JUN23-31000-C", "BTC-30JUN23-32000-C"],
        "put_instruments" => ["BTC-30JUN23-30000-P", "BTC-30JUN23-31000-P", "BTC-30JUN23-32000-P"],
        "ttm_index" => 1,
    )
)
current_time = 1687723381

Helpers.compute_normalized_strikes!(sub_fitter_expiration_info, futures_orderbooks, options_orderbooks, expirations_map, current_time)

target_object = Dict(
    "30JUN23" => Dict(
        "ttm_index" => 1,
        "fair_iv" => NaN,
        "strike_count" => 1,
        "ns_strike" => [-0.37328300070592296, 0.25518403143366114, 0.8636963223286622],
        "atm_index" => 2,
        "strike" => [30000.0, 31000.0, 32000.0],
        "fitting_count" => NaN
    )
)

@test JSON.json(sub_fitter_expiration_info) == JSON.json(target_object)
#########




#########
@info "Helpers.compute_normalized_strikes! -- empty strikes"

sub_fitter_expiration_info = Dict(
    "30JUN23" => Dict(
        "strike" => [],
        "ns_strike" => zeros(3) * NaN,
        "fitting_count" => NaN,
        "ttm_index" => NaN,
        "atm_index" => NaN,
        "fair_iv" => NaN,
    )
)
futures_orderbooks = Dict(
    "BTC-30JUN23" => Dict(
        "computed_price" => 30590.0
    )
)
options_orderbooks = Dict(
    "BTC-30JUN23-30000-C" => Dict(
        "top_ask_iv" => 0.51,
        "top_bid_iv" => 0.41,
    ),
    "BTC-30JUN23-30000-P" => Dict(
        "top_ask_iv" => 0.61,
        "top_bid_iv" => 0.31,
    ),
    "BTC-30JUN23-31000-C" => Dict(
        "top_ask_iv" => 0.52,
        "top_bid_iv" => 0.42,
    ),
    "BTC-30JUN23-31000-P" => Dict(
        "top_ask_iv" => 0.62,
        "top_bid_iv" => 0.32,
    ),
    "BTC-30JUN23-32000-C" => Dict(
        "top_ask_iv" => 0.53,
        "top_bid_iv" => 0.43,
    ),
    "BTC-30JUN23-32000-P" => Dict(
        "top_ask_iv" => 0.63,
        "top_bid_iv" => 0.33,
    )
)
expirations_map = Dict(
    "30JUN23" => Dict(
        "expiration_timestamp" => 1688112000000,
        "full_underlying_name" => "BTC-30JUN23",
        "call_instruments" => ["BTC-30JUN23-30000-C", "BTC-30JUN23-31000-C", "BTC-30JUN23-32000-C"],
        "put_instruments" => ["BTC-30JUN23-30000-P", "BTC-30JUN23-31000-P", "BTC-30JUN23-32000-P"],
        "ttm_index" => 1,
    )
)
current_time = 1687723381

Helpers.compute_normalized_strikes!(sub_fitter_expiration_info, futures_orderbooks, options_orderbooks, expirations_map, current_time)

target_object = Dict(
    "30JUN23" => Dict(
        "ttm_index" => NaN,
        "fair_iv" => NaN,
        "ns_strike" => [NaN, NaN, NaN],
        "atm_index" => NaN,
        "strike" => Any[],
        "fitting_count" => NaN
    )
)

@test JSON.json(sub_fitter_expiration_info) == JSON.json(target_object)
#########




#########
@info "Helpers.compute_normalized_strikes! -- (call bid +) (call bid +) (put bid +) (put bid +)"

sub_fitter_expiration_info = Dict(
    "30JUN23" => Dict(
        "strike" => [30000],
        "ns_strike" => zeros(1) * NaN,
        "fitting_count" => NaN,
        "ttm_index" => NaN,
        "atm_index" => NaN,
        "fair_iv" => NaN,
    )
)
futures_orderbooks = Dict(
    "BTC-30JUN23" => Dict(
        "computed_price" => 30590.0
    )
)
options_orderbooks = Dict(
    "BTC-30JUN23-30000-C" => Dict(
        "top_ask_iv" => 0.51,
        "top_bid_iv" => 0.41,
    ),
    "BTC-30JUN23-30000-P" => Dict(
        "top_ask_iv" => 0.62,
        "top_bid_iv" => 0.31,
    )
)
expirations_map = Dict(
    "30JUN23" => Dict(
        "expiration_timestamp" => 1688112000000,
        "full_underlying_name" => "BTC-30JUN23",
        "call_instruments" => ["BTC-30JUN23-30000-C"],
        "put_instruments" => ["BTC-30JUN23-30000-P"],
        "ttm_index" => 1,
    )
)
current_time = 1687723381

Helpers.compute_normalized_strikes!(sub_fitter_expiration_info, futures_orderbooks, options_orderbooks, expirations_map, current_time)

target_object = Dict(
    "30JUN23" => Dict(
        "ttm_index" => 1,
        "fair_iv" => NaN,
        "strike_count" => 1,
        "ns_strike" => [-0.38139784854735603],
        "atm_index" => 1,
        "strike" => [30000],
        "fitting_count" => NaN
    )
)

@test JSON.json(sub_fitter_expiration_info) == JSON.json(target_object)
#########




#########
@info "Helpers.compute_normalized_strikes! -- (call bid -) (call bid +) (put bid +) (put bid +)"

sub_fitter_expiration_info = Dict(
    "30JUN23" => Dict(
        "strike" => [30000],
        "ns_strike" => zeros(1) * NaN,
        "fitting_count" => NaN,
        "ttm_index" => NaN,
        "atm_index" => NaN,
        "fair_iv" => NaN,
    )
)
futures_orderbooks = Dict(
    "BTC-30JUN23" => Dict(
        "computed_price" => 30590.0
    )
)
options_orderbooks = Dict(
    "BTC-30JUN23-30000-C" => Dict(
        "top_ask_iv" => 0.51,
        "top_bid_iv" => NaN,
    ),
    "BTC-30JUN23-30000-P" => Dict(
        "top_ask_iv" => 0.62,
        "top_bid_iv" => 0.31,
    )
)
expirations_map = Dict(
    "30JUN23" => Dict(
        "expiration_timestamp" => 1688112000000,
        "full_underlying_name" => "BTC-30JUN23",
        "call_instruments" => ["BTC-30JUN23-30000-C"],
        "put_instruments" => ["BTC-30JUN23-30000-P"],
        "ttm_index" => 1,
    )
)
current_time = 1687723381

Helpers.compute_normalized_strikes!(sub_fitter_expiration_info, futures_orderbooks, options_orderbooks, expirations_map, current_time)

target_object = Dict(
    "30JUN23" => Dict(
        "ttm_index" => 1,
        "fair_iv" => NaN,
        "ns_strike" => [-0.38139784854735603],
        "atm_index" => 1,
        "strike" => [30000],
        "fitting_count" => NaN
    )
)

target_object = Dict(
    "30JUN23" => Dict(
        "ttm_index" => 1,
        "fair_iv" => NaN,
        "strike_count" => 1,
        "ns_strike" => [-0.37729679641243824],
        "atm_index" => 1,
        "strike" => [30000],
        "fitting_count" => NaN
    )
)

@test JSON.json(sub_fitter_expiration_info) == JSON.json(target_object)
#########




#########
@info "Helpers.compute_normalized_strikes! -- (call bid +) (call bid -) (put bid +) (put bid +)"

sub_fitter_expiration_info = Dict(
    "30JUN23" => Dict(
        "strike" => [30000],
        "ns_strike" => zeros(1) * NaN,
        "fitting_count" => NaN,
        "ttm_index" => NaN,
        "atm_index" => NaN,
        "fair_iv" => NaN,
    )
)
futures_orderbooks = Dict(
    "BTC-30JUN23" => Dict(
        "computed_price" => 30590.0
    )
)
options_orderbooks = Dict(
    "BTC-30JUN23-30000-C" => Dict(
        "top_ask_iv" => NaN,
        "top_bid_iv" => 0.41,
    ),
    "BTC-30JUN23-30000-P" => Dict(
        "top_ask_iv" => 0.62,
        "top_bid_iv" => 0.31,
    )
)
expirations_map = Dict(
    "30JUN23" => Dict(
        "expiration_timestamp" => 1688112000000,
        "full_underlying_name" => "BTC-30JUN23",
        "call_instruments" => ["BTC-30JUN23-30000-C"],
        "put_instruments" => ["BTC-30JUN23-30000-P"],
        "ttm_index" => 1,
    )
)
current_time = 1687723381

Helpers.compute_normalized_strikes!(sub_fitter_expiration_info, futures_orderbooks, options_orderbooks, expirations_map, current_time)

target_object = Dict(
    "30JUN23" => Dict(
        "ttm_index" => 1,
        "fair_iv" => NaN,
        "strike_count" => 1,
        "ns_strike" => [-0.37729679641243824],
        "atm_index" => 1,
        "strike" => [30000],
        "fitting_count" => NaN
    )
)

@test JSON.json(sub_fitter_expiration_info) == JSON.json(target_object)
#########




#########
@info "Helpers.compute_normalized_strikes! -- (call bid -) (call bid -) (put bid +) (put bid +)"

sub_fitter_expiration_info = Dict(
    "30JUN23" => Dict(
        "strike" => [30000],
        "ns_strike" => zeros(1) * NaN,
        "fitting_count" => NaN,
        "ttm_index" => NaN,
        "atm_index" => NaN,
        "fair_iv" => NaN,
    )
)
futures_orderbooks = Dict(
    "BTC-30JUN23" => Dict(
        "computed_price" => 30590.0
    )
)
options_orderbooks = Dict(
    "BTC-30JUN23-30000-C" => Dict(
        "top_ask_iv" => NaN,
        "top_bid_iv" => NaN,
    ),
    "BTC-30JUN23-30000-P" => Dict(
        "top_ask_iv" => 0.62,
        "top_bid_iv" => 0.31,
    )
)
expirations_map = Dict(
    "30JUN23" => Dict(
        "expiration_timestamp" => 1688112000000,
        "full_underlying_name" => "BTC-30JUN23",
        "call_instruments" => ["BTC-30JUN23-30000-C"],
        "put_instruments" => ["BTC-30JUN23-30000-P"],
        "ttm_index" => 1,
    )
)
current_time = 1687723381

Helpers.compute_normalized_strikes!(sub_fitter_expiration_info, futures_orderbooks, options_orderbooks, expirations_map, current_time)

target_object = Dict(
    "30JUN23" => Dict(
        "ttm_index" => 1,
        "fair_iv" => NaN,
        "strike_count" => 1,
        "ns_strike" => [-0.37729679641243824],
        "atm_index" => 1,
        "strike" => [30000],
        "fitting_count" => NaN
    )
)

@test JSON.json(sub_fitter_expiration_info) == JSON.json(target_object)
#########




#########
@info "Helpers.compute_normalized_strikes! -- (call bid -) (call bid -) (put bid -) (put bid +)"

sub_fitter_expiration_info = Dict(
    "30JUN23" => Dict(
        "strike" => [30000],
        "ns_strike" => zeros(1) * NaN,
        "fitting_count" => NaN,
        "ttm_index" => NaN,
        "atm_index" => NaN,
        "fair_iv" => NaN,
    )
)
futures_orderbooks = Dict(
    "BTC-30JUN23" => Dict(
        "computed_price" => 30590.0
    )
)
options_orderbooks = Dict(
    "BTC-30JUN23-30000-C" => Dict(
        "top_ask_iv" => NaN,
        "top_bid_iv" => NaN,
    ),
    "BTC-30JUN23-30000-P" => Dict(
        "top_ask_iv" => 0.61,
        "top_bid_iv" => NaN,
    )
)
expirations_map = Dict(
    "30JUN23" => Dict(
        "expiration_timestamp" => 1688112000000,
        "full_underlying_name" => "BTC-30JUN23",
        "call_instruments" => ["BTC-30JUN23-30000-C"],
        "put_instruments" => ["BTC-30JUN23-30000-P"],
        "ttm_index" => 1,
    )
)
current_time = 1687723381

Helpers.compute_normalized_strikes!(sub_fitter_expiration_info, futures_orderbooks, options_orderbooks, expirations_map, current_time)

target_object = Dict(
    "30JUN23" => Dict(
        "ttm_index" => NaN,
        "fair_iv" => [NaN],
        "strike_count" => NaN,
        "ns_strike" => [NaN],
        "atm_index" => NaN,
        "fitting_strike" => [NaN],
        "strike" => [30000],
        "fitting_point" => [NaN],
        "fitting_count" => NaN
    )
)

@test JSON.json(sub_fitter_expiration_info) == JSON.json(target_object)
# #########




#########
@info "Helpers.compute_normalized_strikes! -- (call bid -) (call bid -) (put bid +) (put bid -)"

sub_fitter_expiration_info = Dict(
    "30JUN23" => Dict(
        "strike" => [30000],
        "ns_strike" => zeros(1) * NaN,
        "fitting_count" => NaN,
        "ttm_index" => NaN,
        "atm_index" => NaN,
        "fair_iv" => NaN,
    )
)
futures_orderbooks = Dict(
    "BTC-30JUN23" => Dict(
        "computed_price" => 30590.0
    )
)
options_orderbooks = Dict(
    "BTC-30JUN23-30000-C" => Dict(
        "top_ask_iv" => NaN,
        "top_bid_iv" => NaN,
    ),
    "BTC-30JUN23-30000-P" => Dict(
        "top_ask_iv" => NaN,
        "top_bid_iv" => 0.31,
    )
)
expirations_map = Dict(
    "30JUN23" => Dict(
        "expiration_timestamp" => 1688112000000,
        "full_underlying_name" => "BTC-30JUN23",
        "call_instruments" => ["BTC-30JUN23-30000-C"],
        "put_instruments" => ["BTC-30JUN23-30000-P"],
        "ttm_index" => 1,
    )
)
current_time = 1687723381

Helpers.compute_normalized_strikes!(sub_fitter_expiration_info, futures_orderbooks, options_orderbooks, expirations_map, current_time)

target_object = Dict(
    "30JUN23" => Dict(
        "ttm_index" => NaN,
        "fair_iv" => [NaN],
        "strike_count" => NaN,
        "ns_strike" => [NaN],
        "atm_index" => NaN,
        "fitting_strike" => [NaN],
        "strike" => [30000],
        "fitting_point" => [NaN],
        "fitting_count" => NaN
    )
)

@test JSON.json(sub_fitter_expiration_info) == JSON.json(target_object)
#########




#########
@info "Helpers.compute_normalized_strikes! -- (call bid -) (call bid -) (put bid -) (put bid -)"

sub_fitter_expiration_info = Dict(
    "30JUN23" => Dict(
        "strike" => [30000],
        "ns_strike" => zeros(1) * NaN,
        "fitting_count" => NaN,
        "ttm_index" => NaN,
        "atm_index" => NaN,
        "fair_iv" => NaN,
    )
)
futures_orderbooks = Dict(
    "BTC-30JUN23" => Dict(
        "computed_price" => 30590.0
    )
)
options_orderbooks = Dict(
    "BTC-30JUN23-30000-C" => Dict(
        "top_ask_iv" => NaN,
        "top_bid_iv" => NaN,
    ),
    "BTC-30JUN23-30000-P" => Dict(
        "top_ask_iv" => NaN,
        "top_bid_iv" => NaN,
    )
)
expirations_map = Dict(
    "30JUN23" => Dict(
        "expiration_timestamp" => 1688112000000,
        "full_underlying_name" => "BTC-30JUN23",
        "call_instruments" => ["BTC-30JUN23-30000-C"],
        "put_instruments" => ["BTC-30JUN23-30000-P"],
        "ttm_index" => 1,
    )
)
current_time = 1687723381

Helpers.compute_normalized_strikes!(sub_fitter_expiration_info, futures_orderbooks, options_orderbooks, expirations_map, current_time)

target_object = Dict(
    "30JUN23" => Dict(
        "ttm_index" => NaN,
        "fair_iv" => [NaN],
        "strike_count" => NaN,
        "ns_strike" => [NaN],
        "atm_index" => NaN,
        "fitting_strike" => [NaN],
        "strike" => [30000],
        "fitting_point" => [NaN],
        "fitting_count" => NaN
    )
)

@test JSON.json(sub_fitter_expiration_info) == JSON.json(target_object)
#########