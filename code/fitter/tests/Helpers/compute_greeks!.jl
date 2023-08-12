using Test;
using JSON;

include("../../misc/general.jl")

#########
@info "Helpers.compute_greeks! -- single strike check"

sub_fitter_expiration_info = Dict(
    "30JUN23" => Dict(
        "ttm" => 0.02739726027397260274,
        "fair_iv" => [0.85],
        "strike" => [30000],
        "delta_call" => [NaN],
        "delta_put" => [NaN],
        "gamma" => [NaN],
        "vega" => [NaN],
        "theta" => [NaN],
        "vanna" => [NaN],
        "volga" => [NaN],
        "total_delta_call" => [NaN],
        "total_delta_put" => [NaN],
        "call_fair_price" => [0.123],
        "put_fair_price" => [0.952],
    )
)

expirations_map = Dict(
    "30JUN23" => Dict(
        "full_underlying_name" => "BTC-30JUN23",
        "strike" => [30000]
    )
)

futures_orderbooks = Dict(
    "BTC-30JUN23" => Dict(
        "computed_price" => 30000.0
    )
)

Helpers.compute_greeks!(sub_fitter_expiration_info, expirations_map, futures_orderbooks)

target_object = Dict(
    "30JUN23" => Dict(
        "fair_iv" => [0.85],
        "put_fair_price" => [0.952],
        "call_fair_price" => [0.123],
        "theta" => [-30654.349275161014],
        "ttm" => 0.0273972602739726,
        "strike" => [30000],
        "volga" => [-11.504728570148625],
        "total_delta_put" => [-1.5540436082918119],
        "vega" => [1976.1063191078817],
        "delta_call" => [0.5280410639594643],
        "total_delta_call" => [0.27495639170818803],
        "vanna" => [0.0329351053184647],
        "delta_put" => [-0.47195893604053574],
        "gamma" => [9.42848113038401e-5]
    )
)

@test JSON.json(sub_fitter_expiration_info) == JSON.json(target_object)
#########




#########
