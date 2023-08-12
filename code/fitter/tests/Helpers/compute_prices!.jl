using Test;
using JSON;

include("../../misc/general.jl")

#########
@info "Helpers.compute_prices! -- fair_iv is NaN"

sub_fitter_expiration_info = Dict(
    "30JUN23" => Dict(
        "ttm" => 0.02739726027397260274,
        "fair_iv" => [NaN],
        "ns_strike" => 1.5
    )
)

futures_orderbooks = Dict(
    "BTC-30JUN23" => Dict(
        "computed_price" => 30000.0
    )
)

options_orderbooks = Dict(
    "BTC-30JUN23-30000-C" => Dict(
        "top_bid_price" => 0.01,
        "top_ask_price" => 0.015,
    ),
    "BTC-30JUN23-30000-P" => Dict(
        "top_bid_price" => 0.012,
        "top_ask_price" => 0.017,
    ),
)
expirations_map = Dict(
    "30JUN23" => Dict(
        "full_underlying_name" => "BTC-30JUN23",
        "strike" => [30000.],
        "call_instruments" => ["BTC-30JUN23-30000-C"],
        "put_instruments" => ["BTC-30JUN23-30000-P"],
    )
)

instrument_map = Dict(
    "BTC-30JUN23-30000-C" => Dict(
        "tick_size" => 0.0005
    ),
    "BTC-30JUN23-30000-P" => Dict(
        "tick_size" => 0.0005
    )
)
DIMINING_N_STRIKE_THREASHOLD = NaN
PRICING_MAX_MULTIPLIER = NaN

Helpers.compute_prices!(sub_fitter_expiration_info, futures_orderbooks, options_orderbooks, expirations_map, instrument_map, DIMINING_N_STRIKE_THREASHOLD, PRICING_MAX_MULTIPLIER)

target_object = Dict(
    "30JUN23" => Dict(
        "ttm" => 0.0273972602739726,
        "fair_iv" => [NaN],
        "ns_strike" => 1.5
    )
)

@test JSON.json(target_object) == JSON.json(sub_fitter_expiration_info)
#########




#########
@info "Helpers.compute_prices! -- diming: false top_bid_price: not NaN top_ask_price: not NaN"

sub_fitter_expiration_info = Dict(
    "30JUN23" => Dict(
        "ttm" => 0.02739726027397260274,
        "fair_iv" => [0.9],
        "ns_strike" => [1.5],
        "put_fair_price" => [NaN],
        "call_fair_price" => [NaN],
        "own_call_ask" => [NaN],
        "own_call_bid" => [NaN],
        "own_put_ask" => [NaN],
        "own_put_bid" => [NaN],
    )
)

futures_orderbooks = Dict(
    "BTC-30JUN23" => Dict(
        "computed_price" => 31000.0
    )
)

options_orderbooks = Dict(
    "BTC-30JUN23-30000-C" => Dict(
        "top_ask_price" => 0.9,
        "top_bid_price" => 0.7,
    ),
    "BTC-30JUN23-30000-P" => Dict(
        "top_ask_price" => 0.5,
        "top_bid_price" => 0.2,
    ),
)

expirations_map = Dict(
    "30JUN23" => Dict(
        "full_underlying_name" => "BTC-30JUN23",
        "strike" => [30000],
        "call_instruments" => ["BTC-30JUN23-30000-C"],
        "put_instruments" => ["BTC-30JUN23-30000-P"],
    )
)

instrument_map = Dict(
    "BTC-30JUN23-30000-C" => Dict(
        "tick_size" => 0.0005
    ),
    "BTC-30JUN23-30000-P" => Dict(
        "tick_size" => 0.0005
    )
)

DIMINING_N_STRIKE_THREASHOLD = NaN
PRICING_MAX_MULTIPLIER = NaN

Helpers.compute_prices!(sub_fitter_expiration_info, futures_orderbooks, options_orderbooks, expirations_map, instrument_map, DIMINING_N_STRIKE_THREASHOLD, PRICING_MAX_MULTIPLIER)

target_object = Dict(
    "30JUN23" => Dict(
        "own_put_bid" => [0.043],
        "ttm" => 0.0273972602739726,
        "fair_iv" => [0.9],
        "own_call_bid" => [0.0755],
        "own_put_ask" => [0.044],
        "ns_strike" => [1.5],
        "put_fair_price" => [0.043695143950423905],
        "own_call_ask" => [0.0765],
        "call_fair_price" => [0.07595320846655287]
    )
)

@test JSON.json(target_object) == JSON.json(sub_fitter_expiration_info)
#########




#########
@info "Helpers.compute_prices! -- diming: false top_bid_price: NaN top_ask_price: NaN"

sub_fitter_expiration_info = Dict(
    "30JUN23" => Dict(
        "ttm" => 0.02739726027397260274,
        "fair_iv" => [0.9],
        "ns_strike" => [1.5],
        "put_fair_price" => [NaN],
        "call_fair_price" => [NaN],
        "own_call_ask" => [NaN],
        "own_call_bid" => [NaN],
        "own_put_ask" => [NaN],
        "own_put_bid" => [NaN],
    )
)

futures_orderbooks = Dict(
    "BTC-30JUN23" => Dict(
        "computed_price" => 31000.0
    )
)

options_orderbooks = Dict(
    "BTC-30JUN23-30000-C" => Dict(
        "top_ask_price" => NaN,
        "top_bid_price" => NaN,
    ),
    "BTC-30JUN23-30000-P" => Dict(
        "top_ask_price" => NaN,
        "top_bid_price" => NaN,
    ),
)

expirations_map = Dict(
    "30JUN23" => Dict(
        "full_underlying_name" => "BTC-30JUN23",
        "strike" => [30000],
        "call_instruments" => ["BTC-30JUN23-30000-C"],
        "put_instruments" => ["BTC-30JUN23-30000-P"],
    )
)

instrument_map = Dict(
    "BTC-30JUN23-30000-C" => Dict(
        "tick_size" => 0.0005
    ),
    "BTC-30JUN23-30000-P" => Dict(
        "tick_size" => 0.0005
    )
)

DIMINING_N_STRIKE_THREASHOLD = NaN
PRICING_MAX_MULTIPLIER = 15

Helpers.compute_prices!(sub_fitter_expiration_info, futures_orderbooks, options_orderbooks, expirations_map, instrument_map, DIMINING_N_STRIKE_THREASHOLD, PRICING_MAX_MULTIPLIER)

target_object = Dict(
    "30JUN23" => Dict(
        "own_put_bid" => [0.036],
        "ttm" => 0.0273972602739726,
        "fair_iv" => [0.9],
        "own_call_bid" => [0.0685],
        "own_put_ask" => [0.051],
        "ns_strike" => [1.5],
        "put_fair_price" => [0.043695143950423905],
        "own_call_ask" => [0.0835],
        "call_fair_price" => [0.07595320846655287]
    )
)

@test JSON.json(target_object) == JSON.json(sub_fitter_expiration_info)
#########