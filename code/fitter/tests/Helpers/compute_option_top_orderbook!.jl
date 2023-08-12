import AVLTrees as avl;
using Test;

#########
@info "Helpers.compute_option_top_orderbook! -- empty input"
options_orderbooks = Dict()
INSTRUMENT_NAME = "BTC-30JUN23-10000-C"
options_orderbooks[INSTRUMENT_NAME] = Dict(
    "bids" => avl.AVLTree{Float64,Float64}(),
    "asks" => avl.AVLTree{Float64,Float64}(),
    "top_bid_price" => 0.0,
    "top_ask_price" => 0.0,
    "top_bid_size" => 0.0,
    "top_ask_size" => 0.0,
    "top_bid_iv" => 0.0,
    "top_ask_iv" => 0.0
)

# Execute
Helpers.compute_option_top_orderbook!(options_orderbooks)
@test ((options_orderbooks[INSTRUMENT_NAME]["top_bid_price"] == 0) & (options_orderbooks[INSTRUMENT_NAME]["top_bid_size"] == 0) & (options_orderbooks[INSTRUMENT_NAME]["top_ask_price"] == 0) & (options_orderbooks[INSTRUMENT_NAME]["top_ask_size"] == 0)) == true
#########




#########
@info "Helpers.compute_option_top_orderbook! -- single key price, 1 layer deep"
INSTRUMENT_NAME = "BTC-30JUN23-10000-C"
options_orderbooks[INSTRUMENT_NAME] = Dict(
    "bids" => avl.AVLTree{Float64,Float64}(),
    "asks" => avl.AVLTree{Float64,Float64}(),
    "top_bid_price" => 0.0,
    "top_ask_price" => 0.0,
    "top_bid_size" => 0.0,
    "top_ask_size" => 0.0,
    "top_bid_iv" => 0.0,
    "top_ask_iv" => 0.0
)

# Insert a bid
insert!(options_orderbooks[INSTRUMENT_NAME]["bids"], -25000, 100)
# Insert an ask
insert!(options_orderbooks[INSTRUMENT_NAME]["asks"], 25000.5, 101)

# Execute
Helpers.compute_option_top_orderbook!(options_orderbooks)
@test ((options_orderbooks[INSTRUMENT_NAME]["top_bid_price"] == 25000) & (options_orderbooks[INSTRUMENT_NAME]["top_bid_size"] == 100) & (options_orderbooks[INSTRUMENT_NAME]["top_ask_price"] == 25000.5) & (options_orderbooks[INSTRUMENT_NAME]["top_ask_size"] == 101)) == true
#########