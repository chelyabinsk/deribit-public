import AVLTrees as avl;
using Test;

#########
@info "Helpers.compute_futures_prices! -- empty input"
FUTURES_ORDERBOOK_DEPTH = 5
FUTURES_CALC_DEPTH = 3
FUTURES_CALC_DEPTH = 3
CURRENCY = "BTC"
futures_orderbooks = Dict()
futures_orderbooks[CURRENCY*"-PERPETUAL"] = Dict(
    "bids" => avl.AVLTree{Float64,Float64}(),
    "asks" => avl.AVLTree{Float64,Float64}(),
    "last_traded_price" => [],
    "last_traded_size" => [],
    "bid_price" => zeros(FUTURES_CALC_DEPTH),
    "ask_price" => zeros(FUTURES_CALC_DEPTH),
    "bid_size" => zeros(FUTURES_CALC_DEPTH),
    "ask_size" => zeros(FUTURES_CALC_DEPTH), "computed_price" => -Inf
)

# Execute
Helpers.compute_futures_prices!(futures_orderbooks, FUTURES_CALC_DEPTH, FUTURES_ORDERBOOK_DEPTH)
@test futures_orderbooks[CURRENCY*"-PERPETUAL"]["computed_price"] == -Inf
#########




#########
@info "Helpers.compute_futures_prices! -- single key price, 1 layer deep"
FUTURES_ORDERBOOK_DEPTH = 5
FUTURES_CALC_DEPTH = 3
CURRENCY = "BTC"
futures_orderbooks = Dict()
futures_orderbooks[CURRENCY*"-PERPETUAL"] = Dict(
    "bids" => avl.AVLTree{Float64,Float64}(),
    "asks" => avl.AVLTree{Float64,Float64}(),
    "last_traded_price" => [],
    "last_traded_size" => [],
    "bid_price" => zeros(FUTURES_CALC_DEPTH),
    "ask_price" => zeros(FUTURES_CALC_DEPTH),
    "bid_size" => zeros(FUTURES_CALC_DEPTH),
    "ask_size" => zeros(FUTURES_CALC_DEPTH), "computed_price" => -Inf
)

# Insert a bid
insert!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["bids"], -25000, 100)
# Insert an ask
insert!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["asks"], 25000.5, 100)

# Execute
Helpers.compute_futures_prices!(futures_orderbooks, FUTURES_CALC_DEPTH, FUTURES_ORDERBOOK_DEPTH)
@test futures_orderbooks[CURRENCY*"-PERPETUAL"]["computed_price"] == 25000.25
#########




#########
@info "Helpers.compute_futures_prices! -- single key price, 3 layer deep staggered"
FUTURES_ORDERBOOK_DEPTH = 5
FUTURES_CALC_DEPTH = 3
CURRENCY = "BTC"
futures_orderbooks = Dict()
futures_orderbooks[CURRENCY*"-PERPETUAL"] = Dict(
    "bids" => avl.AVLTree{Float64,Float64}(),
    "asks" => avl.AVLTree{Float64,Float64}(),
    "last_traded_price" => [],
    "last_traded_size" => [],
    "bid_price" => zeros(FUTURES_CALC_DEPTH),
    "ask_price" => zeros(FUTURES_CALC_DEPTH),
    "bid_size" => zeros(FUTURES_CALC_DEPTH),
    "ask_size" => zeros(FUTURES_CALC_DEPTH), "computed_price" => -Inf
)

# Insert some bids
insert!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["bids"], -25000, 100)
insert!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["bids"], -24999.5, 10)
insert!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["bids"], -24999, 40)

# Insert an ask
insert!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["asks"], 25000.5, 100)

# Execute
Helpers.compute_futures_prices!(futures_orderbooks, FUTURES_CALC_DEPTH, FUTURES_ORDERBOOK_DEPTH)
@test futures_orderbooks[CURRENCY*"-PERPETUAL"]["computed_price"] == 25000.25

#########




#########
@info "Helpers.compute_futures_prices! -- single key price, 3 layer deep staggered with historic trades"
FUTURES_ORDERBOOK_DEPTH = 5
FUTURES_CALC_DEPTH = 3
CURRENCY = "BTC"
futures_orderbooks = Dict()
futures_orderbooks[CURRENCY*"-PERPETUAL"] = Dict(
    "bids" => avl.AVLTree{Float64,Float64}(),
    "asks" => avl.AVLTree{Float64,Float64}(),
    "last_traded_price" => [],
    "last_traded_size" => [],
    "bid_price" => zeros(FUTURES_CALC_DEPTH),
    "ask_price" => zeros(FUTURES_CALC_DEPTH),
    "bid_size" => zeros(FUTURES_CALC_DEPTH),
    "ask_size" => zeros(FUTURES_CALC_DEPTH), "computed_price" => -Inf
)

# Insert some bids
insert!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["bids"], -25000, 100)
insert!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["bids"], -24999.5, 10)
insert!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["bids"], -24999, 40)

# Insert an ask
insert!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["asks"], 25000.5, 100)

# Insert some trades
push!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["last_traded_price"], 25002)
push!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["last_traded_price"], 25001)
push!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["last_traded_size"], 30)
push!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["last_traded_size"], 10)


# Execute
Helpers.compute_futures_prices!(futures_orderbooks, FUTURES_CALC_DEPTH, FUTURES_ORDERBOOK_DEPTH)
@test futures_orderbooks[CURRENCY*"-PERPETUAL"]["computed_price"] == 25000.5
#########




#########
@info "Helpers.compute_futures_prices! -- single key price, 6 layers deep with historic trades"
FUTURES_ORDERBOOK_DEPTH = 5
FUTURES_CALC_DEPTH = 3
CURRENCY = "BTC"
futures_orderbooks = Dict()
futures_orderbooks[CURRENCY*"-PERPETUAL"] = Dict(
    "bids" => avl.AVLTree{Float64,Float64}(),
    "asks" => avl.AVLTree{Float64,Float64}(),
    "last_traded_price" => [],
    "last_traded_size" => [],
    "bid_price" => zeros(FUTURES_CALC_DEPTH),
    "ask_price" => zeros(FUTURES_CALC_DEPTH),
    "bid_size" => zeros(FUTURES_CALC_DEPTH),
    "ask_size" => zeros(FUTURES_CALC_DEPTH), "computed_price" => NaN
)

# Insert some bids
insert!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["bids"], -24003, 100)
insert!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["bids"], -24002, 100)
insert!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["bids"], -24001, 100)
insert!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["bids"], -24000, 100)
insert!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["bids"], -24999.5, 10)
insert!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["bids"], -24999, 40)

# Insert an ask
insert!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["asks"], 25000.5, 100)
insert!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["asks"], 25001.0, 100)
insert!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["asks"], 25002.0, 100)
insert!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["asks"], 25003.0, 100)
insert!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["asks"], 25004.0, 100)
insert!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["asks"], 25005.0, 100)

# Insert some trades
push!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["last_traded_price"], 25002)
push!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["last_traded_price"], 25001)
push!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["last_traded_size"], 30)
push!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["last_traded_size"], 10)


# Execute
Helpers.compute_futures_prices!(futures_orderbooks, FUTURES_CALC_DEPTH, FUTURES_ORDERBOOK_DEPTH)
@test futures_orderbooks[CURRENCY*"-PERPETUAL"]["computed_price"] == 24796.867346938776
#########




#########
@info "Helpers.compute_futures_prices! -- only use at most FUTURES_CALC_DEPTH number of past trades"

FUTURES_ORDERBOOK_DEPTH = 5
FUTURES_CALC_DEPTH = 3
CURRENCY = "BTC"
futures_orderbooks = Dict()
futures_orderbooks[CURRENCY*"-PERPETUAL"] = Dict(
    "bids" => avl.AVLTree{Float64,Float64}(),
    "asks" => avl.AVLTree{Float64,Float64}(),
    "last_traded_price" => [],
    "last_traded_size" => [],
    "bid_price" => zeros(FUTURES_CALC_DEPTH),
    "ask_price" => zeros(FUTURES_CALC_DEPTH),
    "bid_size" => zeros(FUTURES_CALC_DEPTH),
    "ask_size" => zeros(FUTURES_CALC_DEPTH), "computed_price" => NaN
)

# Insert some bids
insert!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["bids"], -24003, 100)
insert!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["bids"], -24002, 200)
insert!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["bids"], -24001, 300)
insert!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["bids"], -24000, 400)
insert!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["bids"], -24999.5, 500)
insert!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["bids"], -24999, 600)

# Insert an ask
insert!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["asks"], 25000.5, 700)
insert!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["asks"], 25001.0, 800)
insert!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["asks"], 25002.0, 900)
insert!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["asks"], 25003.0, 1000)
insert!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["asks"], 25004.0, 1100)
insert!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["asks"], 25005.0, 1200)

# Insert some trades
push!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["last_traded_price"], 25007)
push!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["last_traded_size"], 30)
push!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["last_traded_price"], 25006)
push!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["last_traded_size"], 30)
push!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["last_traded_price"], 25005)
push!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["last_traded_size"], 30)
push!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["last_traded_price"], 25004)
push!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["last_traded_size"], 30)
push!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["last_traded_price"], 25003)
push!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["last_traded_size"], 30)
push!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["last_traded_price"], 25002)
push!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["last_traded_size"], 30)
push!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["last_traded_price"], 25001)
push!(futures_orderbooks[CURRENCY*"-PERPETUAL"]["last_traded_size"], 30)

# Execute
Helpers.compute_futures_prices!(futures_orderbooks, FUTURES_CALC_DEPTH, FUTURES_ORDERBOOK_DEPTH)
@test futures_orderbooks[CURRENCY*"-PERPETUAL"]["computed_price"] == 24756.948509485093
#########