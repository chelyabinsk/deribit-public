#########
CURRENCY = "BTC"
FUTURES_ORDERBOOK_DEPTH = 5
current_subscriptions = []
instrument_map = Dict()
expirations_map = Dict()
new_subscriptions = []
removed_subscriptions = []

futures_orderbooks = Dict()

DeribitIOs.update_instrument_maps!(CURRENCY, current_subscriptions, instrument_map, expirations_map, new_subscriptions, removed_subscriptions, true)

old_expirations_map = Dict(expirations_map)
DeribitIOs.update_futures_orderbook_keys!(expirations_map, instrument_map, futures_orderbooks, CURRENCY, FUTURES_ORDERBOOK_DEPTH, true)

@info "DeribitIOs.update_futures_orderbook_keys! -- expirations_map does not change"
@test expirations_map == old_expirations_map
#########




#########
@info "DeribitIOs.update_futures_orderbook_keys! -- check that PERPETUAL exists"
@test haskey(futures_orderbooks, CURRENCY * "-PERPETUAL")
#########




#########
@info "DeribitIOs.update_futures_orderbook_keys! -- check that each key is in expected format"
function _test()
    bad_format = false
    for expiration_name in keys(futures_orderbooks)
        if futures_orderbooks[expiration_name] != Dict(
                "bids" => avl.AVLTree{Float64,Float64}(),
                "asks" => avl.AVLTree{Float64,Float64}(),
                "last_traded_price" => [],
                "last_traded_size" => [],
                "bid_price" => zeros(FUTURES_ORDERBOOK_DEPTH),
                "ask_price" => zeros(FUTURES_ORDERBOOK_DEPTH),
                "bid_size" => zeros(FUTURES_ORDERBOOK_DEPTH),
                "ask_size" => zeros(FUTURES_ORDERBOOK_DEPTH),

                "computed_price" => -Inf
            )
            bad_format = true
            break
        end
    end
    return bad_format
end
@test _test()
#########