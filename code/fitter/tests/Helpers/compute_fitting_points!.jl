using Test;
using JSON;

# #########
# @info "Helpers.compute_fitting_points! -- atm_index in sub_fitter_expiration_info is NaN"

# sub_fitter_expiration_info = Dict(
#     "30JUN23" => Dict(
#         "atm_index" => NaN
#     )
# )
# options_orderbooks = Dict()
# expirations_map = Dict()
# Helpers.compute_fitting_points!(sub_fitter_expiration_info, options_orderbooks, expirations_map)

# target_object = Dict(
#     "30JUN23" => Dict(
#         "atm_index" => NaN
#     )
# )

# @test JSON.json(target_object) == JSON.json(sub_fitter_expiration_info)
# #########




# #########
# @info "Helpers.compute_fitting_points! -- (call bid iv +) (call ask iv +) (put bid iv +) (put ask iv +)"

# sub_fitter_expiration_info = Dict(
#     "30JUN23" => Dict(
#         "atm_index" => 1,
#         "ns_strike" => [1.5],
#         "fitting_strike" => [NaN],
#         "fitting_point" => [NaN],
#         "fitting_count" => NaN,
#         "min_normalized_strike" => [NaN],
#         "max_normalized_strike" => [NaN],
#     )
# )
# options_orderbooks = Dict(
#     "BTC-30JUN23-30000-P" => Dict(
#         "top_ask_iv" => 1.5,
#         "top_bid_iv" => 1.3,
#     ),
#     "BTC-30JUN23-30000-C" => Dict(
#         "top_ask_iv" => 1.6,
#         "top_bid_iv" => 1.4,
#     ),
# )
# expirations_map = Dict(
#     "30JUN23" => Dict(
#         "put_instruments" => ["BTC-30JUN23-30000-P"],
#         "call_instruments" => ["BTC-30JUN23-30000-C"],
#     )
# )
# Helpers.compute_fitting_points!(sub_fitter_expiration_info, options_orderbooks, expirations_map)

# target_object = Dict(
#     "30JUN23" => Dict(
#         "ns_strike" => [1.5],
#         "atm_index" => 1,
#         "fitting_strike" => [1.5],
#         "fitting_point" => [1.45],
#         "fitting_count" => 1,
#         "min_normalized_strike" => 1.5,
#         "max_normalized_strike" => 1.5
#     )
# )

# @test JSON.json(target_object) == JSON.json(sub_fitter_expiration_info)
# #########




# #########
# @info "Helpers.compute_fitting_points! -- (call bid iv +) (call ask iv +) (put bid iv -) (put ask iv +)"

# sub_fitter_expiration_info = Dict(
#     "30JUN23" => Dict(
#         "atm_index" => 1,
#         "ns_strike" => [1.5],
#         "fitting_strike" => [NaN],
#         "fitting_point" => [NaN],
#         "fitting_count" => NaN,
#         "min_normalized_strike" => [NaN],
#         "max_normalized_strike" => [NaN],
#     )
# )
# options_orderbooks = Dict(
#     "BTC-30JUN23-30000-P" => Dict(
#         "top_ask_iv" => 1.5,
#         "top_bid_iv" => NaN,
#     ),
#     "BTC-30JUN23-30000-C" => Dict(
#         "top_ask_iv" => 1.6,
#         "top_bid_iv" => 1.4,
#     ),
# )
# expirations_map = Dict(
#     "30JUN23" => Dict(
#         "put_instruments" => ["BTC-30JUN23-30000-P"],
#         "call_instruments" => ["BTC-30JUN23-30000-C"],
#     )
# )
# Helpers.compute_fitting_points!(sub_fitter_expiration_info, options_orderbooks, expirations_map)

# target_object = Dict(
#     "30JUN23" => Dict(
#         "ns_strike" => [1.5],
#         "atm_index" => 1,
#         "fitting_strike" => [1.5],
#         "fitting_point" => [1.45],
#         "fitting_count" => 1,
#         "min_normalized_strike" => 1.5,
#         "max_normalized_strike" => 1.5
#     )
# )

# @test JSON.json(target_object) == JSON.json(sub_fitter_expiration_info)
# #########




# #########
# @info "Helpers.compute_fitting_points! -- (call bid iv +) (call ask iv +) (put bid iv +) (put ask iv -)"

# sub_fitter_expiration_info = Dict(
#     "30JUN23" => Dict(
#         "atm_index" => 1,
#         "ns_strike" => [1.5],
#         "fitting_strike" => [NaN],
#         "fitting_point" => [NaN],
#         "fitting_count" => NaN,
#         "min_normalized_strike" => [NaN],
#         "max_normalized_strike" => [NaN],
#     )
# )
# options_orderbooks = Dict(
#     "BTC-30JUN23-30000-P" => Dict(
#         "top_ask_iv" => NaN,
#         "top_bid_iv" => 1.3,
#     ),
#     "BTC-30JUN23-30000-C" => Dict(
#         "top_ask_iv" => 1.6,
#         "top_bid_iv" => 1.4,
#     ),
# )
# expirations_map = Dict(
#     "30JUN23" => Dict(
#         "put_instruments" => ["BTC-30JUN23-30000-P"],
#         "call_instruments" => ["BTC-30JUN23-30000-C"],
#     )
# )
# Helpers.compute_fitting_points!(sub_fitter_expiration_info, options_orderbooks, expirations_map)

# target_object = Dict(
#     "30JUN23" => Dict(
#         "ns_strike" => [1.5],
#         "atm_index" => 1,
#         "fitting_strike" => [1.5],
#         "fitting_point" => [1.5],
#         "fitting_count" => 1,
#         "min_normalized_strike" => 1.5,
#         "max_normalized_strike" => 1.5
#     )
# )

# @test JSON.json(target_object) == JSON.json(sub_fitter_expiration_info)
# #########




# #########
# @info "Helpers.compute_fitting_points! -- (call bid iv -) (call ask iv +) (put bid iv +) (put ask iv +)"

# sub_fitter_expiration_info = Dict(
#     "30JUN23" => Dict(
#         "atm_index" => 1,
#         "ns_strike" => [1.5],
#         "fitting_strike" => [NaN],
#         "fitting_point" => [NaN],
#         "fitting_count" => NaN,
#         "min_normalized_strike" => [NaN],
#         "max_normalized_strike" => [NaN],
#     )
# )
# options_orderbooks = Dict(
#     "BTC-30JUN23-30000-P" => Dict(
#         "top_ask_iv" => 1.5,
#         "top_bid_iv" => 1.3,
#     ),
#     "BTC-30JUN23-30000-C" => Dict(
#         "top_ask_iv" => 1.6,
#         "top_bid_iv" => NaN,
#     ),
# )
# expirations_map = Dict(
#     "30JUN23" => Dict(
#         "put_instruments" => ["BTC-30JUN23-30000-P"],
#         "call_instruments" => ["BTC-30JUN23-30000-C"],
#     )
# )
# Helpers.compute_fitting_points!(sub_fitter_expiration_info, options_orderbooks, expirations_map)

# target_object = Dict(
#     "30JUN23" => Dict(
#         "ns_strike" => [1.5],
#         "atm_index" => 1,
#         "fitting_strike" => [1.5],
#         "fitting_point" => [1.4],
#         "fitting_count" => 1,
#         "min_normalized_strike" => 1.5,
#         "max_normalized_strike" => 1.5
#     )
# )

# @test JSON.json(target_object) == JSON.json(sub_fitter_expiration_info)
# #########




# #########
# @info "Helpers.compute_fitting_points! -- (call bid iv +) (call ask iv -) (put bid iv +) (put ask iv +)"

# sub_fitter_expiration_info = Dict(
#     "30JUN23" => Dict(
#         "atm_index" => 1,
#         "ns_strike" => [1.5],
#         "fitting_strike" => [NaN],
#         "fitting_point" => [NaN],
#         "fitting_count" => NaN,
#         "min_normalized_strike" => [NaN],
#         "max_normalized_strike" => [NaN],
#     )
# )
# options_orderbooks = Dict(
#     "BTC-30JUN23-30000-P" => Dict(
#         "top_ask_iv" => 1.5,
#         "top_bid_iv" => 1.3,
#     ),
#     "BTC-30JUN23-30000-C" => Dict(
#         "top_ask_iv" => NaN,
#         "top_bid_iv" => 1.4,
#     ),
# )
# expirations_map = Dict(
#     "30JUN23" => Dict(
#         "put_instruments" => ["BTC-30JUN23-30000-P"],
#         "call_instruments" => ["BTC-30JUN23-30000-C"],
#     )
# )
# Helpers.compute_fitting_points!(sub_fitter_expiration_info, options_orderbooks, expirations_map)

# target_object = Dict(
#     "30JUN23" => Dict(
#         "ns_strike" => [1.5],
#         "atm_index" => 1,
#         "fitting_strike" => [1.5],
#         "fitting_point" => [1.45],
#         "fitting_count" => 1,
#         "min_normalized_strike" => 1.5,
#         "max_normalized_strike" => 1.5
#     )
# )

# @test JSON.json(target_object) == JSON.json(sub_fitter_expiration_info)
# #########




# #########
# @info "Helpers.compute_fitting_points! -- (call bid iv +) (call ask iv +) (put bid iv -) (put ask iv -)"

# sub_fitter_expiration_info = Dict(
#     "30JUN23" => Dict(
#         "atm_index" => 1,
#         "ns_strike" => [1.5],
#         "fitting_strike" => [NaN],
#         "fitting_point" => [NaN],
#         "fitting_count" => NaN,
#         "min_normalized_strike" => [NaN],
#         "max_normalized_strike" => [NaN],
#     )
# )
# options_orderbooks = Dict(
#     "BTC-30JUN23-30000-P" => Dict(
#         "top_ask_iv" => NaN,
#         "top_bid_iv" => NaN,
#     ),
#     "BTC-30JUN23-30000-C" => Dict(
#         "top_ask_iv" => 1.6,
#         "top_bid_iv" => 1.4,
#     ),
# )
# expirations_map = Dict(
#     "30JUN23" => Dict(
#         "put_instruments" => ["BTC-30JUN23-30000-P"],
#         "call_instruments" => ["BTC-30JUN23-30000-C"],
#     )
# )
# Helpers.compute_fitting_points!(sub_fitter_expiration_info, options_orderbooks, expirations_map)

# target_object = Dict(
#     "30JUN23" => Dict(
#         "ns_strike" => [1.5],
#         "atm_index" => 1,
#         "fitting_strike" => [1.5],
#         "fitting_point" => [1.5],
#         "fitting_count" => 1,
#         "min_normalized_strike" => 1.5,
#         "max_normalized_strike" => 1.5
#     )
# )

# @test JSON.json(target_object) == JSON.json(sub_fitter_expiration_info)
# #########




# #########
# @info "Helpers.compute_fitting_points! -- (call bid iv +) (call ask iv -) (put bid iv +) (put ask iv -)"

# sub_fitter_expiration_info = Dict(
#     "30JUN23" => Dict(
#         "atm_index" => 1,
#         "ns_strike" => [1.5],
#         "fitting_strike" => [NaN],
#         "fitting_point" => [NaN],
#         "fitting_count" => NaN,
#         "min_normalized_strike" => [NaN],
#         "max_normalized_strike" => [NaN],
#     )
# )
# options_orderbooks = Dict(
#     "BTC-30JUN23-30000-P" => Dict(
#         "top_ask_iv" => NaN,
#         "top_bid_iv" => 1.3,
#     ),
#     "BTC-30JUN23-30000-C" => Dict(
#         "top_ask_iv" => NaN,
#         "top_bid_iv" => 1.4,
#     ),
# )
# expirations_map = Dict(
#     "30JUN23" => Dict(
#         "put_instruments" => ["BTC-30JUN23-30000-P"],
#         "call_instruments" => ["BTC-30JUN23-30000-C"],
#     )
# )
# Helpers.compute_fitting_points!(sub_fitter_expiration_info, options_orderbooks, expirations_map)

# target_object = Dict(
#     "30JUN23" => Dict(
#         "ns_strike" => [1.5],
#         "atm_index" => 1,
#         "fitting_strike" => [1.5],
#         "fitting_point" => [1.4],
#         "fitting_count" => 1,
#         "min_normalized_strike" => 1.5,
#         "max_normalized_strike" => 1.5
#     )
# )

# @test JSON.json(target_object) == JSON.json(sub_fitter_expiration_info)
# #########




# #########
# @info "Helpers.compute_fitting_points! -- (call bid iv -) (call ask iv +) (put bid iv +) (put ask iv -)"

# sub_fitter_expiration_info = Dict(
#     "30JUN23" => Dict(
#         "atm_index" => 1,
#         "ns_strike" => [1.5],
#         "fitting_strike" => [NaN],
#         "fitting_point" => [NaN],
#         "fitting_count" => NaN,
#         "min_normalized_strike" => [NaN],
#         "max_normalized_strike" => [NaN],
#     )
# )
# options_orderbooks = Dict(
#     "BTC-30JUN23-30000-P" => Dict(
#         "top_ask_iv" => NaN,
#         "top_bid_iv" => 1.3,
#     ),
#     "BTC-30JUN23-30000-C" => Dict(
#         "top_ask_iv" => 1.6,
#         "top_bid_iv" => NaN,
#     ),
# )
# expirations_map = Dict(
#     "30JUN23" => Dict(
#         "put_instruments" => ["BTC-30JUN23-30000-P"],
#         "call_instruments" => ["BTC-30JUN23-30000-C"],
#     )
# )
# Helpers.compute_fitting_points!(sub_fitter_expiration_info, options_orderbooks, expirations_map)

# target_object = Dict(
#     "30JUN23" => Dict(
#         "ns_strike" => [1.5],
#         "atm_index" => 1,
#         "fitting_strike" => [1.5],
#         "fitting_point" => [1.4500000000000002],
#         "fitting_count" => 1,
#         "min_normalized_strike" => 1.5,
#         "max_normalized_strike" => 1.5
#     )
# )

# @test JSON.json(target_object) == JSON.json(sub_fitter_expiration_info)
# #########




# #########
# @info "Helpers.compute_fitting_points! -- (call bid iv +) (call ask iv -) (put bid iv -) (put ask iv +)"

# sub_fitter_expiration_info = Dict(
#     "30JUN23" => Dict(
#         "atm_index" => 1,
#         "ns_strike" => [1.5],
#         "fitting_strike" => [NaN],
#         "fitting_point" => [NaN],
#         "fitting_count" => NaN,
#         "min_normalized_strike" => [NaN],
#         "max_normalized_strike" => [NaN],
#     )
# )
# options_orderbooks = Dict(
#     "BTC-30JUN23-30000-P" => Dict(
#         "top_ask_iv" => 1.5,
#         "top_bid_iv" => NaN,
#     ),
#     "BTC-30JUN23-30000-C" => Dict(
#         "top_ask_iv" => NaN,
#         "top_bid_iv" => 1.4,
#     ),
# )
# expirations_map = Dict(
#     "30JUN23" => Dict(
#         "put_instruments" => ["BTC-30JUN23-30000-P"],
#         "call_instruments" => ["BTC-30JUN23-30000-C"],
#     )
# )
# Helpers.compute_fitting_points!(sub_fitter_expiration_info, options_orderbooks, expirations_map)

# target_object = Dict(
#     "30JUN23" => Dict(
#         "ns_strike" => [1.5],
#         "atm_index" => 1,
#         "fitting_strike" => [1.5],
#         "fitting_point" => [1.45],
#         "fitting_count" => 1,
#         "min_normalized_strike" => 1.5,
#         "max_normalized_strike" => 1.5
#     )
# )

# @test JSON.json(target_object) == JSON.json(sub_fitter_expiration_info)
# #########




# #########
# @info "Helpers.compute_fitting_points! -- (call bid iv -) (call ask iv +) (put bid iv -) (put ask iv +)"

# sub_fitter_expiration_info = Dict(
#     "30JUN23" => Dict(
#         "atm_index" => 1,
#         "ns_strike" => [1.5],
#         "fitting_strike" => [NaN],
#         "fitting_point" => [NaN],
#         "fitting_count" => NaN,
#         "min_normalized_strike" => [NaN],
#         "max_normalized_strike" => [NaN],
#     )
# )
# options_orderbooks = Dict(
#     "BTC-30JUN23-30000-P" => Dict(
#         "top_ask_iv" => 1.5,
#         "top_bid_iv" => NaN,
#     ),
#     "BTC-30JUN23-30000-C" => Dict(
#         "top_ask_iv" => 1.6,
#         "top_bid_iv" => NaN,
#     ),
# )
# expirations_map = Dict(
#     "30JUN23" => Dict(
#         "put_instruments" => ["BTC-30JUN23-30000-P"],
#         "call_instruments" => ["BTC-30JUN23-30000-C"],
#     )
# )
# Helpers.compute_fitting_points!(sub_fitter_expiration_info, options_orderbooks, expirations_map)

# target_object = Dict(
#     "30JUN23" => Dict(
#         "ns_strike" => [1.5],
#         "atm_index" => 1,
#         "fitting_strike" => [1.5],
#         "fitting_point" => [1.5],
#         "fitting_count" => 1,
#         "min_normalized_strike" => 1.5,
#         "max_normalized_strike" => 1.5
#     )
# )

# @test JSON.json(target_object) == JSON.json(sub_fitter_expiration_info)
# #########




# #########
# @info "Helpers.compute_fitting_points! -- (call bid iv -) (call ask iv -) (put bid iv +) (put ask iv +)"

# sub_fitter_expiration_info = Dict(
#     "30JUN23" => Dict(
#         "atm_index" => 1,
#         "ns_strike" => [1.5],
#         "fitting_strike" => [NaN],
#         "fitting_point" => [NaN],
#         "fitting_count" => NaN,
#         "min_normalized_strike" => [NaN],
#         "max_normalized_strike" => [NaN],
#     )
# )
# options_orderbooks = Dict(
#     "BTC-30JUN23-30000-P" => Dict(
#         "top_ask_iv" => 1.5,
#         "top_bid_iv" => 1.3,
#     ),
#     "BTC-30JUN23-30000-C" => Dict(
#         "top_ask_iv" => NaN,
#         "top_bid_iv" => NaN,
#     ),
# )
# expirations_map = Dict(
#     "30JUN23" => Dict(
#         "put_instruments" => ["BTC-30JUN23-30000-P"],
#         "call_instruments" => ["BTC-30JUN23-30000-C"],
#     )
# )
# Helpers.compute_fitting_points!(sub_fitter_expiration_info, options_orderbooks, expirations_map)

# target_object = Dict(
#     "30JUN23" => Dict(
#         "ns_strike" => [1.5],
#         "atm_index" => 1,
#         "fitting_strike" => [1.5],
#         "fitting_point" => [1.4],
#         "fitting_count" => 1,
#         "min_normalized_strike" => 1.5,
#         "max_normalized_strike" => 1.5
#     )
# )

# @test JSON.json(target_object) == JSON.json(sub_fitter_expiration_info)
# #########




# #########
# @info "Helpers.compute_fitting_points! -- (call bid iv +) (call ask iv -) (put bid iv -) (put ask iv -)"

# sub_fitter_expiration_info = Dict(
#     "30JUN23" => Dict(
#         "atm_index" => 1,
#         "ns_strike" => [1.5],
#         "fitting_strike" => [NaN],
#         "fitting_point" => [NaN],
#         "fitting_count" => NaN,
#         "min_normalized_strike" => [NaN],
#         "max_normalized_strike" => [NaN],
#     )
# )
# options_orderbooks = Dict(
#     "BTC-30JUN23-30000-P" => Dict(
#         "top_ask_iv" => NaN,
#         "top_bid_iv" => NaN,
#     ),
#     "BTC-30JUN23-30000-C" => Dict(
#         "top_ask_iv" => NaN,
#         "top_bid_iv" => 1.4,
#     ),
# )
# expirations_map = Dict(
#     "30JUN23" => Dict(
#         "put_instruments" => ["BTC-30JUN23-30000-P"],
#         "call_instruments" => ["BTC-30JUN23-30000-C"],
#     )
# )
# Helpers.compute_fitting_points!(sub_fitter_expiration_info, options_orderbooks, expirations_map)

# target_object = Dict(
#     "30JUN23" => Dict(
#         "ns_strike" => [1.5],
#         "atm_index" => 1,
#         "fitting_strike" => [1.5],
#         "fitting_point" => [1.4],
#         "fitting_count" => 1,
#         "min_normalized_strike" => 1.5,
#         "max_normalized_strike" => 1.5
#     )
# )

# @test JSON.json(target_object) == JSON.json(sub_fitter_expiration_info)
# #########




# #########
# @info "Helpers.compute_fitting_points! -- (call bid iv -) (call ask iv +) (put bid iv -) (put ask iv -)"

# sub_fitter_expiration_info = Dict(
#     "30JUN23" => Dict(
#         "atm_index" => 1,
#         "ns_strike" => [1.5],
#         "fitting_strike" => [NaN],
#         "fitting_point" => [NaN],
#         "fitting_count" => NaN,
#         "min_normalized_strike" => [NaN],
#         "max_normalized_strike" => [NaN],
#     )
# )
# options_orderbooks = Dict(
#     "BTC-30JUN23-30000-P" => Dict(
#         "top_ask_iv" => NaN,
#         "top_bid_iv" => NaN,
#     ),
#     "BTC-30JUN23-30000-C" => Dict(
#         "top_ask_iv" => 1.6,
#         "top_bid_iv" => NaN,
#     ),
# )
# expirations_map = Dict(
#     "30JUN23" => Dict(
#         "put_instruments" => ["BTC-30JUN23-30000-P"],
#         "call_instruments" => ["BTC-30JUN23-30000-C"],
#     )
# )
# Helpers.compute_fitting_points!(sub_fitter_expiration_info, options_orderbooks, expirations_map)

# target_object = Dict(
#     "30JUN23" => Dict(
#         "ns_strike" => [1.5],
#         "atm_index" => 1,
#         "fitting_strike" => [1.5],
#         "fitting_point" => [1.6],
#         "fitting_count" => 1,
#         "min_normalized_strike" => 1.5,
#         "max_normalized_strike" => 1.5
#     )
# )

# @test JSON.json(target_object) == JSON.json(sub_fitter_expiration_info)
# #########




# #########
# @info "Helpers.compute_fitting_points! -- (call bid iv -) (call ask iv -) (put bid iv -) (put ask iv +)"

# sub_fitter_expiration_info = Dict(
#     "30JUN23" => Dict(
#         "atm_index" => 1,
#         "ns_strike" => [1.5],
#         "fitting_strike" => [NaN],
#         "fitting_point" => [NaN],
#         "fitting_count" => NaN,
#         "min_normalized_strike" => [NaN],
#         "max_normalized_strike" => [NaN],
#     )
# )
# options_orderbooks = Dict(
#     "BTC-30JUN23-30000-P" => Dict(
#         "top_ask_iv" => 1.5,
#         "top_bid_iv" => NaN,
#     ),
#     "BTC-30JUN23-30000-C" => Dict(
#         "top_ask_iv" => NaN,
#         "top_bid_iv" => NaN,
#     ),
# )
# expirations_map = Dict(
#     "30JUN23" => Dict(
#         "put_instruments" => ["BTC-30JUN23-30000-P"],
#         "call_instruments" => ["BTC-30JUN23-30000-C"],
#     )
# )
# Helpers.compute_fitting_points!(sub_fitter_expiration_info, options_orderbooks, expirations_map)

# target_object = Dict(
#     "30JUN23" => Dict(
#         "ns_strike" => [1.5],
#         "atm_index" => 1,
#         "fitting_strike" => [1.5],
#         "fitting_point" => [1.5],
#         "fitting_count" => 1,
#         "min_normalized_strike" => 1.5,
#         "max_normalized_strike" => 1.5
#     )
# )

# @test JSON.json(target_object) == JSON.json(sub_fitter_expiration_info)
# #########




# #########
# @info "Helpers.compute_fitting_points! -- (call bid iv -) (call ask iv -) (put bid iv +) (put ask iv -)"

# sub_fitter_expiration_info = Dict(
#     "30JUN23" => Dict(
#         "atm_index" => 1,
#         "ns_strike" => [1.5],
#         "fitting_strike" => [NaN],
#         "fitting_point" => [NaN],
#         "fitting_count" => NaN,
#         "min_normalized_strike" => [NaN],
#         "max_normalized_strike" => [NaN],
#     )
# )
# options_orderbooks = Dict(
#     "BTC-30JUN23-30000-P" => Dict(
#         "top_ask_iv" => NaN,
#         "top_bid_iv" => 1.3,
#     ),
#     "BTC-30JUN23-30000-C" => Dict(
#         "top_ask_iv" => NaN,
#         "top_bid_iv" => NaN,
#     ),
# )
# expirations_map = Dict(
#     "30JUN23" => Dict(
#         "put_instruments" => ["BTC-30JUN23-30000-P"],
#         "call_instruments" => ["BTC-30JUN23-30000-C"],
#     )
# )
# Helpers.compute_fitting_points!(sub_fitter_expiration_info, options_orderbooks, expirations_map)

# target_object = Dict(
#     "30JUN23" => Dict(
#         "ns_strike" => [1.5],
#         "atm_index" => 1,
#         "fitting_strike" => [1.5],
#         "fitting_point" => [1.3],
#         "fitting_count" => 1,
#         "min_normalized_strike" => 1.5,
#         "max_normalized_strike" => 1.5
#     )
# )

# @test JSON.json(target_object) == JSON.json(sub_fitter_expiration_info)
# #########




# #########
# @info "Helpers.compute_fitting_points! -- (call bid iv -) (call ask iv -) (put bid iv -) (put ask iv -)"

# sub_fitter_expiration_info = Dict(
#     "30JUN23" => Dict(
#         "atm_index" => 1,
#         "ns_strike" => [1.5],
#         "fitting_strike" => [NaN],
#         "fitting_point" => [NaN],
#         "fitting_count" => NaN,
#         "min_normalized_strike" => [NaN],
#         "max_normalized_strike" => [NaN],
#     )
# )
# options_orderbooks = Dict(
#     "BTC-30JUN23-30000-P" => Dict(
#         "top_ask_iv" => NaN,
#         "top_bid_iv" => NaN,
#     ),
#     "BTC-30JUN23-30000-C" => Dict(
#         "top_ask_iv" => NaN,
#         "top_bid_iv" => NaN,
#     ),
# )
# expirations_map = Dict(
#     "30JUN23" => Dict(
#         "put_instruments" => ["BTC-30JUN23-30000-P"],
#         "call_instruments" => ["BTC-30JUN23-30000-C"],
#     )
# )
# Helpers.compute_fitting_points!(sub_fitter_expiration_info, options_orderbooks, expirations_map)

# target_object = Dict(
#     "30JUN23" => Dict(
#         "ns_strike" => [1.5],
#         "atm_index" => 1,
#         "fitting_strike" => [NaN],
#         "fitting_point" => [NaN],
#         "fitting_count" => 0,
#         "min_normalized_strike" => 1.5,
#         "max_normalized_strike" => 1.5
#     )
# )

# @test JSON.json(target_object) == JSON.json(sub_fitter_expiration_info)
# #########




#########
@info "Helpers.compute_fitting_points! -- (call bid +) (call ask +) (put bid +) (put ask +)"

sub_fitter_expiration_info = Dict(
    "30JUN23" => Dict(
        "atm_index" => 2,
        "ns_strike" => [1.5, 1.6, 1.8, 2.0],
        "strike" => [31000, 32000, 33000, 34000],
        "fitting_strike" => [NaN, NaN, NaN, NaN],
        "fitting_point" => [NaN, NaN, NaN, NaN],
        "market_bid_iv" => [NaN, NaN, NaN, NaN],
        "market_ask_iv" => [NaN, NaN, NaN, NaN],
        "fitting_count" => NaN,
        "min_normalized_strike" => [NaN],
        "max_normalized_strike" => [NaN],
        "strike_count" => 4
    )
)
options_orderbooks = Dict(
    "BTC-30JUN23-30000-P" => Dict(
        "top_ask_iv" => 0.6,
        "top_bid_iv" => 0.4,
    ),
    "BTC-30JUN23-30000-C" => Dict(
        "top_ask_iv" => 0.5,
        "top_bid_iv" => 0.3,
    ),
    "BTC-30JUN23-31000-P" => Dict(
        "top_ask_iv" => 0.7,
        "top_bid_iv" => 0.5,
    ),
    "BTC-30JUN23-31000-C" => Dict(
        "top_ask_iv" => 0.6,
        "top_bid_iv" => 0.4,
    ),
    "BTC-30JUN23-32000-P" => Dict(
        "top_ask_iv" => 0.8,
        "top_bid_iv" => 0.6,
    ),
    "BTC-30JUN23-32000-C" => Dict(
        "top_ask_iv" => 0.7,
        "top_bid_iv" => 0.5,
    ),
    "BTC-30JUN23-33000-P" => Dict(
        "top_ask_iv" => 0.9,
        "top_bid_iv" => 0.7,
    ),
    "BTC-30JUN23-33000-C" => Dict(
        "top_ask_iv" => 0.8,
        "top_bid_iv" => 0.6,
    ),
)

expirations_map = Dict(
    "30JUN23" => Dict(
        "put_instruments" => ["BTC-30JUN23-30000-P", "BTC-30JUN23-31000-P", "BTC-30JUN23-32000-P", "BTC-30JUN23-33000-P"],
        "call_instruments" => ["BTC-30JUN23-30000-C", "BTC-30JUN23-31000-C", "BTC-30JUN23-32000-C", "BTC-30JUN23-33000-C"],
        "full_underlying_name" => "BTC-30JUN23",
        "expiration_timestamp" => 1688112000000,
    )
)
futures_orderbooks = Dict(
    "BTC-30JUN23" => Dict(
        "computed_price" => 30123.5
    )
)

current_time = 1687248000
FITTING_POINT_WINGS_DELTA_OFFSET = 0.1

Helpers.compute_fitting_points!(sub_fitter_expiration_info, options_orderbooks, expirations_map, futures_orderbooks, current_time, FITTING_POINT_WINGS_DELTA_OFFSET)

target_object = Dict(
    "30JUN23" => Dict(
        "fitting_point" => [0.45, 0.55, 0.6499999999999999, 0.75],
        "atm_index" => 2,
        "fitting_strike" => [1.5, 1.6, 1.8, 2.0],
        "strike" => [31000, 32000, 33000, 34000],
        "min_normalized_strike" => 1.5,
        "max_normalized_strike" => 2.0,
        "strike_count" => 4,
        "ns_strike" => [1.5, 1.6, 1.8, 2.0],
        "market_ask_iv" => [0.5, 0.6, 0.7, 0.8],
        "market_bid_iv" => [0.4, 0.5, 0.6, 0.7],
        "fitting_count" => 4
    )
)

@test JSON.json(target_object) == JSON.json(sub_fitter_expiration_info)
#########




#########
@info "Helpers.compute_fitting_points! -- gaps with edges present"

sub_fitter_expiration_info = Dict(
    "30JUN23" => Dict(
        "atm_index" => 2,
        "ns_strike" => [1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9],
        "strike" => [31000, 32000, 33000, 34000, 35000, 36000, 37000, 38000, 39000],
        "fitting_strike" => [NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN],
        "fitting_point" => [NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN],
        "market_bid_iv" => [NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN],
        "market_ask_iv" => [NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN],
        "fitting_count" => NaN,
        "min_normalized_strike" => [NaN],
        "max_normalized_strike" => [NaN],
        "strike_count" => 9
    )
)
options_orderbooks = Dict(
    "BTC-30JUN23-31000-P" => Dict(
        "top_ask_iv" => 0.6,
        "top_bid_iv" => 0.4,
    ),
    "BTC-30JUN23-31000-C" => Dict(
        "top_ask_iv" => NaN,
        "top_bid_iv" => NaN,
    ),

    "BTC-30JUN23-32000-P" => Dict(
        "top_ask_iv" => 0.7,
        "top_bid_iv" => NaN,
    ),
    "BTC-30JUN23-32000-C" => Dict(
        "top_ask_iv" => NaN,
        "top_bid_iv" => NaN,
    ),

    "BTC-30JUN23-33000-P" => Dict(
        "top_ask_iv" => 0.8,
        "top_bid_iv" => NaN,
    ),
    "BTC-30JUN23-33000-C" => Dict(
        "top_ask_iv" => NaN,
        "top_bid_iv" => NaN,
    ),

    "BTC-30JUN23-34000-P" => Dict(
        "top_ask_iv" => 0.9,
        "top_bid_iv" => 0.7,
    ),
    "BTC-30JUN23-34000-C" => Dict(
        "top_ask_iv" => NaN,
        "top_bid_iv" => NaN,
    ),

    "BTC-30JUN23-35000-P" => Dict(
        "top_ask_iv" => 1.0,
        "top_bid_iv" => 0.8,
    ),
    "BTC-30JUN23-35000-C" => Dict(
        "top_ask_iv" => NaN,
        "top_bid_iv" => NaN,
    ),

    "BTC-30JUN23-36000-P" => Dict(
        "top_ask_iv" => 1.1,
        "top_bid_iv" => NaN,
    ),
    "BTC-30JUN23-36000-C" => Dict(
        "top_ask_iv" => NaN,
        "top_bid_iv" => NaN,
    ),

    "BTC-30JUN23-37000-P" => Dict(
        "top_ask_iv" => 1.2,
        "top_bid_iv" => 1.0,
    ),
    "BTC-30JUN23-37000-C" => Dict(
        "top_ask_iv" => NaN,
        "top_bid_iv" => NaN,
    ),

    "BTC-30JUN23-38000-P" => Dict(
        "top_ask_iv" => 1.3,
        "top_bid_iv" => NaN,
    ),
    "BTC-30JUN23-38000-C" => Dict(
        "top_ask_iv" => NaN,
        "top_bid_iv" => NaN,
    ),

    "BTC-30JUN23-39000-P" => Dict(
        "top_ask_iv" => 1.4,
        "top_bid_iv" => 1.2,
    ),
    "BTC-30JUN23-39000-C" => Dict(
        "top_ask_iv" => NaN,
        "top_bid_iv" => NaN,
    ),
)

expirations_map = Dict(
    "30JUN23" => Dict(
        "put_instruments" => ["BTC-30JUN23-31000-P", "BTC-30JUN23-32000-P", "BTC-30JUN23-33000-P", "BTC-30JUN23-34000-P", "BTC-30JUN23-35000-P", "BTC-30JUN23-36000-P", "BTC-30JUN23-37000-P", "BTC-30JUN23-38000-P", "BTC-30JUN23-39000-P"],
        "call_instruments" => ["BTC-30JUN23-31000-C", "BTC-30JUN23-32000-C", "BTC-30JUN23-33000-C", "BTC-30JUN23-34000-C", "BTC-30JUN23-35000-C", "BTC-30JUN23-36000-C", "BTC-30JUN23-37000-C", "BTC-30JUN23-38000-C", "BTC-30JUN23-39000-C"],
        "full_underlying_name" => "BTC-30JUN23",
        "expiration_timestamp" => 1688112000000,
    )
)
futures_orderbooks = Dict(
    "BTC-30JUN23" => Dict(
        "computed_price" => 30123.5
    )
)

current_time = 1687248000
FITTING_POINT_WINGS_DELTA_OFFSET = 0.1

Helpers.compute_fitting_points!(sub_fitter_expiration_info, options_orderbooks, expirations_map, futures_orderbooks, current_time, FITTING_POINT_WINGS_DELTA_OFFSET)

target_object = Dict(
    "30JUN23" => Dict(
        "fitting_point" => [0.5, 0.65, 0.7250000000000001, 0.8, 0.9, 1.0, 1.1, 1.2, 1.2999999999999998],
        "atm_index" => 2,
        "fitting_strike" => [1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9],
        "strike" => [31000, 32000, 33000, 34000, 35000, 36000, 37000, 38000, 39000],
        "min_normalized_strike" => 1.1,
        "max_normalized_strike" => 1.9,
        "strike_count" => 9,
        "ns_strike" => [1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9],
        "market_ask_iv" => [0.6, 0.7, 0.8, 0.9, 1.0, 1.1, 1.2, 1.3, 1.4],
        "market_bid_iv" => [0.4, NaN, NaN, 0.7, 0.8, NaN, 1.0, NaN, 1.2],
        "fitting_count" => 9
    )
)

@test JSON.json(target_object) == JSON.json(sub_fitter_expiration_info)
#########




#########
@info "Helpers.compute_fitting_points! -- left and right missing edges"

sub_fitter_expiration_info = Dict(
    "30JUN23" => Dict(
        "atm_index" => 2,
        "ns_strike" => [0.4, 0.5, 0.6, 0.7],
        "strike" => [31000, 32000, 33000, 34000],
        "fitting_strike" => [NaN, NaN, NaN, NaN],
        "fitting_point" => [NaN, NaN, NaN, NaN],
        "market_bid_iv" => [NaN, NaN, NaN, NaN],
        "market_ask_iv" => [NaN, NaN, NaN, NaN],
        "fitting_count" => NaN,
        "min_normalized_strike" => [NaN],
        "max_normalized_strike" => [NaN],
        "strike_count" => 4
    )
)
options_orderbooks = Dict(
    "BTC-30JUN23-31000-P" => Dict(
        "top_ask_iv" => 0.4,
        "top_bid_iv" => NaN,
    ),
    "BTC-30JUN23-31000-C" => Dict(
        "top_ask_iv" => NaN,
        "top_bid_iv" => NaN,
    ),

    "BTC-30JUN23-32000-P" => Dict(
        "top_ask_iv" => 0.5,
        "top_bid_iv" => NaN,
    ),
    "BTC-30JUN23-32000-C" => Dict(
        "top_ask_iv" => NaN,
        "top_bid_iv" => NaN,
    ),

    "BTC-30JUN23-33000-P" => Dict(
        "top_ask_iv" => 0.6,
        "top_bid_iv" => 0.4,
    ),
    "BTC-30JUN23-33000-C" => Dict(
        "top_ask_iv" => NaN,
        "top_bid_iv" => NaN,
    ),

    "BTC-30JUN23-34000-P" => Dict(
        "top_ask_iv" => 0.7,
        "top_bid_iv" => NaN,
    ),
    "BTC-30JUN23-34000-C" => Dict(
        "top_ask_iv" => NaN,
        "top_bid_iv" => NaN,
    ),

)

expirations_map = Dict(
    "30JUN23" => Dict(
        "put_instruments" => ["BTC-30JUN23-31000-P", "BTC-30JUN23-32000-P", "BTC-30JUN23-33000-P", "BTC-30JUN23-34000-P"],
        "call_instruments" => ["BTC-30JUN23-31000-C", "BTC-30JUN23-32000-C", "BTC-30JUN23-33000-C", "BTC-30JUN23-34000-C"],
        "full_underlying_name" => "BTC-30JUN23",
        "expiration_timestamp" => 1688112000000,
    )
)
futures_orderbooks = Dict(
    "BTC-30JUN23" => Dict(
        "computed_price" => 30123.5
    )
)

current_time = 1687248000
FITTING_POINT_WINGS_DELTA_OFFSET = 0.1

Helpers.compute_fitting_points!(sub_fitter_expiration_info, options_orderbooks, expirations_map, futures_orderbooks, current_time, FITTING_POINT_WINGS_DELTA_OFFSET)

target_object = Dict(
    "30JUN23" => Dict(
        "market_bid_iv" => [0.4, NaN, NaN, 0.7, 0.8, NaN, 1.0, NaN, 1.2],
        "strike_count" => 9,
        "ns_strike" => [1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9],
        "atm_index" => 2,
        "fitting_strike" => [1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9],
        "fitting_point" => [0.5, 0.65, 0.7250000000000001, 0.8, 0.9, 1.0, 1.1, 1.2, 1.2999999999999998],
        "market_ask_iv" => [0.6, 0.7, 0.8, 0.9, 1.0, 1.1, 1.2, 1.3, 1.4],
        "fitting_count" => 9,
        "min_normalized_strike" => 1.1,
        "max_normalized_strike" => 1.9
    )
)
#########