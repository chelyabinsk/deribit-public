import AVLTrees as avl;
using JSON;

#########
@info "DeribitIOs.parse_subscriptions! -- subscription - future - book.BTC-PERPETUAL - snapshot"

function _test()
    response = Dict(
        "method" => "subscription",
        "jsonrpc" => "2.0",
        "params" => Dict(
            "channel" => "book.BTC-PERPETUAL.raw",
            "data" => Dict(
                "instrument_name" => "BTC-PERPETUAL",
                "change_id" => 56636434448,
                "timestamp" => 1686675438851,
                "type" => "snapshot",
                "asks" => [
                    ["new", 25862.0, 131420.0],
                    ["new", 25862.5, 76830.0]
                ],
                "bids" => [
                    ["new", 25861.5, 1470.0],
                    ["new", 25861.0, 10000.0]
                ]
            )
        )
    )

    futures_orderbooks = Dict()
    FUTURES_ORDERBOOK_DEPTH = 5
    options_orderbooks = Dict()

    futures_orderbooks["BTC-PERPETUAL"] = Dict(
        "bids" => avl.AVLTree{Float64,Float64}(),
        "asks" => avl.AVLTree{Float64,Float64}()
    )

    target_futures_orderbooks = Dict(futures_orderbooks)

    DeribitIOs.parse_subscriptions!(response, futures_orderbooks, FUTURES_ORDERBOOK_DEPTH, options_orderbooks)

    insert!(target_futures_orderbooks["BTC-PERPETUAL"]["bids"], -25861.5, 1470.0)
    insert!(target_futures_orderbooks["BTC-PERPETUAL"]["bids"], -25861.0, 10000.0)
    
    insert!(target_futures_orderbooks["BTC-PERPETUAL"]["asks"], 25862.0, 131420.0)
    insert!(target_futures_orderbooks["BTC-PERPETUAL"]["asks"], 25862.5, 76830.0)

    return target_futures_orderbooks == futures_orderbooks

end

@test _test() == true
#########




#########
@info "DeribitIOs.parse_subscriptions! -- subscription - future - book.BTC-30JUN23-10000-C - snapshot"
function _test()
    response = Dict(
        "method" => "subscription",
        "jsonrpc" => "2.0",
        "params" => Dict(
            "channel" => "book.BTC-30JUN23-10000-C.raw",
            "data" => Dict(
                "instrument_name" => "BTC-30JUN23-10000-C",
                "change_id" => 56636434448,
                "timestamp" => 1686675438851,
                "type" => "snapshot",
                "asks" => [
                    ["new", 25862.0, 131420.0],
                    ["new", 25862.5, 76830.0]
                ],
                "bids" => [
                    ["new", 25861.5, 1470.0],
                    ["new", 25861.0, 10000.0]
                ]
            )
        )
    )

    futures_orderbooks = Dict()
    FUTURES_ORDERBOOK_DEPTH = 5
    options_orderbooks = Dict()

    options_orderbooks["BTC-30JUN23-10000-C"] = Dict(
        "bids" => avl.AVLTree{Float64,Float64}(),
        "asks" => avl.AVLTree{Float64,Float64}()
    )

    target_options_orderbooks = Dict(options_orderbooks)

    DeribitIOs.parse_subscriptions!(response, futures_orderbooks, FUTURES_ORDERBOOK_DEPTH, options_orderbooks)

    insert!(target_options_orderbooks["BTC-30JUN23-10000-C"]["bids"], -25861.5, 1470.0)
    insert!(target_options_orderbooks["BTC-30JUN23-10000-C"]["bids"], -25861.0, 10000.0)
    
    insert!(target_options_orderbooks["BTC-30JUN23-10000-C"]["asks"], 25862.0, 131420.0)
    insert!(target_options_orderbooks["BTC-30JUN23-10000-C"]["asks"], 25862.5, 76830.0)

    return target_options_orderbooks == options_orderbooks

end

@test _test() == true
#########




#########
@info "DeribitIOs.parse_subscriptions! -- subscription - future - book.BTC-PERPETUAL - change"
function _test()
    initial_response = Dict(
        "method" => "subscription",
        "jsonrpc" => "2.0",
        "params" => Dict(
            "channel" => "book.BTC-PERPETUAL.raw",
            "data" => Dict(
                "instrument_name" => "BTC-PERPETUAL",
                "change_id" => 56636434448,
                "timestamp" => 1686675438851,
                "type" => "snapshot",
                "asks" => [
                    ["new", 25862.0, 131420.0],
                    ["new", 25862.5, 76830.0]
                ],
                "bids" => [
                    ["new", 25861.5, 1470.0],
                    ["new", 25861.0, 10000.0]
                ]
            )
        )
    )

    futures_orderbooks = Dict()
    FUTURES_ORDERBOOK_DEPTH = 5
    options_orderbooks = Dict()

    futures_orderbooks["BTC-PERPETUAL"] = Dict(
        "bids" => avl.AVLTree{Float64,Float64}(),
        "asks" => avl.AVLTree{Float64,Float64}()
    )

    DeribitIOs.parse_subscriptions!(initial_response, futures_orderbooks, FUTURES_ORDERBOOK_DEPTH, options_orderbooks)


    ## Finish initialisation
    test_response = Dict(
        "method" => "subscription",
        "jsonrpc" => "2.0",
        "params" => Dict(
            "channel" => "book.BTC-PERPETUAL.raw",
            "data" => Dict(
                "instrument_name" => "BTC-PERPETUAL",
                "change_id" => 56636434448,
                "timestamp" => 1686675438851,
                "type" => "change",
                "asks" => [
                    ["new", 25869.0, 123.0],
                    ["change", 25862.5, 768.0],
                    ["delete", 25862.5, 0.0]
                ],
                "bids" => [
                    ["new", 25869.0, 123.0],
                    ["change", 25862.5, 768.0],
                    ["delete", 25862.5, 0.0]
                ]
            )
        )
    )

    target_futures_orderbooks = Dict(futures_orderbooks)

    DeribitIOs.parse_subscriptions!(test_response, futures_orderbooks, FUTURES_ORDERBOOK_DEPTH, options_orderbooks)

    delete!(target_futures_orderbooks["BTC-PERPETUAL"]["asks"], 25862.5)
    insert!(target_futures_orderbooks["BTC-PERPETUAL"]["asks"], 25862.5, 768.0)
    insert!(target_futures_orderbooks["BTC-PERPETUAL"]["asks"], 25869.0, 123.0)

    delete!(target_futures_orderbooks["BTC-PERPETUAL"]["asks"], -25862.5)
    insert!(target_futures_orderbooks["BTC-PERPETUAL"]["asks"], -25862.5, 768.0)
    insert!(target_futures_orderbooks["BTC-PERPETUAL"]["asks"], -25869.0, 123.0)

    return JSON.json(target_futures_orderbooks) == JSON.json(futures_orderbooks)
end

@test _test() == true
#########




#########
@info "DeribitIOs.parse_subscriptions! -- subscription - future - book.BTC-30JUN23 - snapshot"

function _test()
    response = Dict(
        "method" => "subscription",
        "jsonrpc" => "2.0",
        "params" => Dict(
            "channel" => "book.BTC-30JUN23.raw",
            "data" => Dict(
                "instrument_name" => "BTC-30JUN23",
                "change_id" => 56636434448,
                "timestamp" => 1686675438851,
                "type" => "snapshot",
                "asks" => [
                    ["new", 25862.0, 131420.0],
                    ["new", 25862.5, 76830.0]
                ],
                "bids" => [
                    ["new", 25861.5, 1470.0],
                    ["new", 25861.0, 10000.0]
                ]
            )
        )
    )

    futures_orderbooks = Dict()
    FUTURES_ORDERBOOK_DEPTH = 5
    options_orderbooks = Dict()

    futures_orderbooks["BTC-30JUN23"] = Dict(
        "bids" => avl.AVLTree{Float64,Float64}(),
        "asks" => avl.AVLTree{Float64,Float64}()
    )

    target_futures_orderbooks = Dict(futures_orderbooks)

    DeribitIOs.parse_subscriptions!(response, futures_orderbooks, FUTURES_ORDERBOOK_DEPTH, options_orderbooks)

    insert!(target_futures_orderbooks["BTC-30JUN23"]["bids"], -25861.5, 1470.0)
    insert!(target_futures_orderbooks["BTC-30JUN23"]["bids"], -25861.0, 10000.0)
    
    insert!(target_futures_orderbooks["BTC-30JUN23"]["asks"], 25862.0, 131420.0)
    insert!(target_futures_orderbooks["BTC-30JUN23"]["asks"], 25862.5, 76830.0)

    return JSON.json(target_futures_orderbooks) == JSON.json(futures_orderbooks)

end

@test _test() == true
#########




#########
@info "DeribitIOs.parse_subscriptions! -- subscription - future - book.BTC-30JUN23 - change"
function _test()
    initial_response = Dict(
        "method" => "subscription",
        "jsonrpc" => "2.0",
        "params" => Dict(
            "channel" => "book.BTC-30JUN23.raw",
            "data" => Dict(
                "instrument_name" => "BTC-30JUN23",
                "change_id" => 56636434448,
                "timestamp" => 1686675438851,
                "type" => "snapshot",
                "asks" => [
                    ["new", 25862.0, 131420.0],
                    ["new", 25862.5, 76830.0]
                ],
                "bids" => [
                    ["new", 25861.5, 1470.0],
                    ["new", 25861.0, 10000.0]
                ]
            )
        )
    )

    futures_orderbooks = Dict()
    FUTURES_ORDERBOOK_DEPTH = 5
    options_orderbooks = Dict()

    futures_orderbooks["BTC-30JUN23"] = Dict(
        "bids" => avl.AVLTree{Float64,Float64}(),
        "asks" => avl.AVLTree{Float64,Float64}()
    )

    DeribitIOs.parse_subscriptions!(initial_response, futures_orderbooks, FUTURES_ORDERBOOK_DEPTH, options_orderbooks)


    ## Finish initialisation
    test_response = Dict(
        "method" => "subscription",
        "jsonrpc" => "2.0",
        "params" => Dict(
            "channel" => "book.BTC-30JUN23.raw",
            "data" => Dict(
                "instrument_name" => "BTC-30JUN23",
                "change_id" => 56636434448,
                "timestamp" => 1686675438851,
                "type" => "change",
                "asks" => [
                    ["new", 25869.0, 123.0],
                    ["change", 25862.5, 768.0],
                    ["delete", 25862.5, 0.0]
                ],
                "bids" => [
                    ["new", 25869.0, 123.0],
                    ["change", 25862.5, 768.0],
                    ["delete", 25862.5, 0.0]
                ]
            )
        )
    )

    target_futures_orderbooks = Dict(futures_orderbooks)

    DeribitIOs.parse_subscriptions!(test_response, futures_orderbooks, FUTURES_ORDERBOOK_DEPTH, options_orderbooks)

    delete!(target_futures_orderbooks["BTC-30JUN23"]["asks"], 25862.5)
    insert!(target_futures_orderbooks["BTC-30JUN23"]["asks"], 25862.5, 768.0)
    insert!(target_futures_orderbooks["BTC-30JUN23"]["asks"], 25869.0, 123.0)

    delete!(target_futures_orderbooks["BTC-30JUN23"]["bids"], -25862.5)
    insert!(target_futures_orderbooks["BTC-30JUN23"]["bids"], -25862.5, 768.0)
    insert!(target_futures_orderbooks["BTC-30JUN23"]["bids"], -25869.0, 123.0)

    return target_futures_orderbooks == futures_orderbooks
end

@test _test() == true
#########




#########
@info "DeribitIOs.parse_subscriptions! -- subscription - future - book.BTC-30JUN23-10000-C - change"
function _test()
    initial_response = Dict(
        "method" => "subscription",
        "jsonrpc" => "2.0",
        "params" => Dict(
            "channel" => "book.BTC-30JUN23-10000-C.raw",
            "data" => Dict(
                "instrument_name" => "BTC-30JUN23-10000-C",
                "change_id" => 56636434448,
                "timestamp" => 1686675438851,
                "type" => "snapshot",
                "asks" => [
                    ["new", 25862.0, 131420.0],
                    ["new", 25862.5, 76830.0]
                ],
                "bids" => [
                    ["new", 25861.5, 1470.0],
                    ["new", 25861.0, 10000.0]
                ]
            )
        )
    )

    futures_orderbooks = Dict()
    FUTURES_ORDERBOOK_DEPTH = 5
    options_orderbooks = Dict()

    options_orderbooks["BTC-30JUN23-10000-C"] = Dict(
        "bids" => avl.AVLTree{Float64,Float64}(),
        "asks" => avl.AVLTree{Float64,Float64}()
    )

    DeribitIOs.parse_subscriptions!(initial_response, futures_orderbooks, FUTURES_ORDERBOOK_DEPTH, options_orderbooks)


    ## Finish initialisation
    test_response = Dict(
        "method" => "subscription",
        "jsonrpc" => "2.0",
        "params" => Dict(
            "channel" => "book.BTC-30JUN23-10000-C.raw",
            "data" => Dict(
                "instrument_name" => "BTC-30JUN23-10000-C",
                "change_id" => 56636434448,
                "timestamp" => 1686675438851,
                "type" => "change",
                "asks" => [
                    ["new", 25869.0, 123.0],
                    ["change", 25862.5, 768.0],
                    ["delete", 25862.5, 0.0]
                ],
                "bids" => [
                    ["new", 25869.0, 123.0],
                    ["change", 25862.5, 768.0],
                    ["delete", 25862.5, 0.0]
                ]
            )
        )
    )

    target_options_orderbooks = Dict(options_orderbooks)

    DeribitIOs.parse_subscriptions!(test_response, futures_orderbooks, FUTURES_ORDERBOOK_DEPTH, options_orderbooks)

    delete!(target_options_orderbooks["BTC-30JUN23-10000-C"]["asks"], 25862.5)
    insert!(target_options_orderbooks["BTC-30JUN23-10000-C"]["asks"], 25862.5, 768.0)
    insert!(target_options_orderbooks["BTC-30JUN23-10000-C"]["asks"], 25869.0, 123.0)

    delete!(target_options_orderbooks["BTC-30JUN23-10000-C"]["bids"], -25862.5)
    insert!(target_options_orderbooks["BTC-30JUN23-10000-C"]["bids"], -25862.5, 768.0)
    insert!(target_options_orderbooks["BTC-30JUN23-10000-C"]["bids"], -25869.0, 123.0)

    return JSON.json(target_options_orderbooks) == JSON.json(options_orderbooks)
end

@test _test() == true
#########



#########
@info "DeribitIOs.parse_subscriptions! -- subscription - future - trades.BTC-PERPETUAL"
function _test()
    FUTURES_ORDERBOOK_DEPTH = 3

    options_orderbooks = Dict()
    futures_orderbooks = Dict()

    futures_orderbooks["BTC-PERPETUAL"] = Dict(
        "bids" => avl.AVLTree{Float64,Float64}(),
        "asks" => avl.AVLTree{Float64,Float64}(),
        "last_traded_price" => [9000, 9001, 9007],
        "last_traded_size" => [20, 40, 5],
        "last_traded_timestamp" => [20000, 40000, 5000],
        "bid_price" => zeros(FUTURES_ORDERBOOK_DEPTH) * NaN,
        "ask_price" => zeros(FUTURES_ORDERBOOK_DEPTH) * NaN,
        "bid_size" => zeros(FUTURES_ORDERBOOK_DEPTH) * NaN,
        "ask_size" => zeros(FUTURES_ORDERBOOK_DEPTH) * NaN,

        "computed_price" => -Inf
    )

    test_response = Dict(
        "method" => "subscription",
        "jsonrpc" => "2.0",
        "params" => Dict(
            "channel" => "trades.BTC-PERPETUAL.raw",
            "data" => [
                Dict(
                    "trade_seq" => 30289442,
                    "trade_id" => "48079269",
                    "timestamp" => 1590484512188,
                    "tick_direction" => 2,
                    "price" => 8950,
                    "mark_price" => 8948.9,
                    "instrument_name" => "BTC-PERPETUAL",
                    "index_price" => 8955.88,
                    "direction" => "sell",
                    "amount" => 10
                ),
                Dict(
                    "trade_seq" => 30289442,
                    "trade_id" => "48079269",
                    "timestamp" => 1590484512188,
                    "tick_direction" => 2,
                    "price" => 9000,
                    "mark_price" => 9000.9,
                    "instrument_name" => "BTC-PERPETUAL",
                    "index_price" => 9000.9,
                    "direction" => "sell",
                    "amount" => 20
                ),
                Dict(
                    "trade_seq" => 30289442,
                    "trade_id" => "48079269",
                    "timestamp" => 1590484512188,
                    "tick_direction" => 2,
                    "price" => 9001,
                    "mark_price" => 9001.9,
                    "instrument_name" => "BTC-PERPETUAL",
                    "index_price" => 9002.9,
                    "direction" => "sell",
                    "amount" => 40
                ),
                Dict(
                    "trade_seq" => 30289442,
                    "trade_id" => "48079269",
                    "timestamp" => 1590484512188,
                    "tick_direction" => 2,
                    "price" => 9007,
                    "mark_price" => 9007.9,
                    "instrument_name" => "BTC-PERPETUAL",
                    "index_price" => 9007.9,
                    "direction" => "buy",
                    "amount" => 5
                )
            ]
        )
    )

    target_futures_orderbooks = Dict(futures_orderbooks)
    DeribitIOs.parse_subscriptions!(test_response, futures_orderbooks, FUTURES_ORDERBOOK_DEPTH, options_orderbooks)

    @test JSON.json(target_futures_orderbooks) == JSON.json(futures_orderbooks)

    test_response = Dict(
        "method" => "subscription",
        "jsonrpc" => "2.0",
        "params" => Dict(
            "channel" => "trades.BTC-PERPETUAL.raw",
            "data" => [
                Dict(
                    "trade_seq" => 30289442,
                    "trade_id" => "48079269",
                    "timestamp" => 1590484512188,
                    "tick_direction" => 2,
                    "price" => 1000,
                    "mark_price" => 1000.9,
                    "instrument_name" => "BTC-PERPETUAL",
                    "index_price" => 1000.88,
                    "direction" => "buy",
                    "amount" => 80
                ),
                Dict(
                    "trade_seq" => 30289442,
                    "trade_id" => "48079269",
                    "timestamp" => 1590484512188,
                    "tick_direction" => 2,
                    "price" => 3000,
                    "mark_price" => 3000.9,
                    "instrument_name" => "BTC-PERPETUAL",
                    "index_price" => 3000.9,
                    "direction" => "sell",
                    "amount" => 10
                )
            ]
        )
    )

    DeribitIOs.parse_subscriptions!(test_response, futures_orderbooks, FUTURES_ORDERBOOK_DEPTH, options_orderbooks)

    target_futures_orderbooks["BTC-PERPETUAL"]["last_traded_price"] = [9007, 1000, 3000]
    target_futures_orderbooks["BTC-PERPETUAL"]["last_traded_size"] = [5, 80, 10]

    @test JSON.json(futures_orderbooks) == JSON.json(target_futures_orderbooks)
end

_test()
#########




#########
@info "DeribitIOs.parse_subscriptions! -- subscription - future - trades.BTC-30JUN23"
function _test()
    FUTURES_ORDERBOOK_DEPTH = 3

    options_orderbooks = Dict()
    futures_orderbooks = Dict()

    futures_orderbooks["BTC-30JUN23"] = Dict(
        "bids" => avl.AVLTree{Float64,Float64}(),
        "asks" => avl.AVLTree{Float64,Float64}(),
        "last_traded_price" => [9000, 9001, 9007],
        "last_traded_size" => [20, 40, 5],
        "last_traded_timestamp" => [20000, 400000, 5000],
        "bid_price" => zeros(FUTURES_ORDERBOOK_DEPTH) * NaN,
        "ask_price" => zeros(FUTURES_ORDERBOOK_DEPTH) * NaN,
        "bid_size" => zeros(FUTURES_ORDERBOOK_DEPTH) * NaN,
        "ask_size" => zeros(FUTURES_ORDERBOOK_DEPTH) * NaN,

        "computed_price" => -Inf
    )

    test_response = Dict(
        "method" => "subscription",
        "jsonrpc" => "2.0",
        "params" => Dict(
            "channel" => "trades.BTC-30JUN23.raw",
            "data" => [
                Dict(
                    "trade_seq" => 30289442,
                    "trade_id" => "48079269",
                    "timestamp" => 1590484512188,
                    "tick_direction" => 2,
                    "price" => 8950,
                    "mark_price" => 8948.9,
                    "instrument_name" => "BTC-30JUN23",
                    "index_price" => 8955.88,
                    "direction" => "sell",
                    "amount" => 10
                ),
                Dict(
                    "trade_seq" => 30289442,
                    "trade_id" => "48079269",
                    "timestamp" => 1590484512188,
                    "tick_direction" => 2,
                    "price" => 9000,
                    "mark_price" => 9000.9,
                    "instrument_name" => "BTC-30JUN23",
                    "index_price" => 9000.9,
                    "direction" => "sell",
                    "amount" => 20
                ),
                Dict(
                    "trade_seq" => 30289442,
                    "trade_id" => "48079269",
                    "timestamp" => 1590484512188,
                    "tick_direction" => 2,
                    "price" => 9001,
                    "mark_price" => 9001.9,
                    "instrument_name" => "BTC-30JUN23",
                    "index_price" => 9002.9,
                    "direction" => "sell",
                    "amount" => 40
                ),
                Dict(
                    "trade_seq" => 30289442,
                    "trade_id" => "48079269",
                    "timestamp" => 1590484512188,
                    "tick_direction" => 2,
                    "price" => 9007,
                    "mark_price" => 9007.9,
                    "instrument_name" => "BTC-30JUN23",
                    "index_price" => 9007.9,
                    "direction" => "buy",
                    "amount" => 5
                )
            ]
        )
    )

    target_futures_orderbooks = Dict(futures_orderbooks)
    DeribitIOs.parse_subscriptions!(test_response, futures_orderbooks, FUTURES_ORDERBOOK_DEPTH, options_orderbooks)

    @test JSON.json(target_futures_orderbooks) == JSON.json(futures_orderbooks)

    test_response = Dict(
        "method" => "subscription",
        "jsonrpc" => "2.0",
        "params" => Dict(
            "channel" => "trades.BTC-30JUN23.raw",
            "data" => [
                Dict(
                    "trade_seq" => 30289442,
                    "trade_id" => "48079269",
                    "timestamp" => 1590484512188,
                    "tick_direction" => 2,
                    "price" => 1000,
                    "mark_price" => 1000.9,
                    "instrument_name" => "BTC-30JUN23",
                    "index_price" => 1000.88,
                    "direction" => "buy",
                    "amount" => 80
                ),
                Dict(
                    "trade_seq" => 30289442,
                    "trade_id" => "48079269",
                    "timestamp" => 1590484512188,
                    "tick_direction" => 2,
                    "price" => 3000,
                    "mark_price" => 3000.9,
                    "instrument_name" => "BTC-30JUN23",
                    "index_price" => 3000.9,
                    "direction" => "sell",
                    "amount" => 10
                )
            ]
        )
    )

    DeribitIOs.parse_subscriptions!(test_response, futures_orderbooks, FUTURES_ORDERBOOK_DEPTH, options_orderbooks)

    target_futures_orderbooks["BTC-30JUN23"]["last_traded_price"] = [9007, 1000, 3000]
    target_futures_orderbooks["BTC-30JUN23"]["last_traded_size"] = [5, 80, 10]

    @test JSON.json(futures_orderbooks) == JSON.json(target_futures_orderbooks)
end

_test()
#########




#########
@info "DeribitIOs.parse_subscriptions! -- subscriptions - future - book.BTC-PERPETUAL - change"
function _test()
    initial_response = Dict(
        "method" => "subscription",
        "jsonrpc" => "2.0",
        "params" => Dict(
            "channel" => "book.BTC-PERPETUAL.raw",
            "data" => Dict(
                "instrument_name" => "BTC-PERPETUAL",
                "change_id" => 56636434448,
                "timestamp" => 1686675438851,
                "type" => "snapshot",
                "asks" => [
                    ["new", 25862.0, 131420.0],
                    ["new", 25862.5, 76830.0]
                ],
                "bids" => [
                    ["new", 25861.5, 1470.0],
                    ["new", 25861.0, 10000.0]
                ]
            )
        )
    )

    futures_orderbooks = Dict()
    FUTURES_ORDERBOOK_DEPTH = 5
    options_orderbooks = Dict()

    futures_orderbooks["BTC-PERPETUAL"] = Dict(
        "bids" => avl.AVLTree{Float64,Float64}(),
        "asks" => avl.AVLTree{Float64,Float64}(),
        "last_traded_price" => [],
        "last_traded_size" => [],
        "bid_price" => zeros(FUTURES_ORDERBOOK_DEPTH) * NaN,
        "ask_price" => zeros(FUTURES_ORDERBOOK_DEPTH) * NaN,
        "bid_size" => zeros(FUTURES_ORDERBOOK_DEPTH) * NaN,
        "ask_size" => zeros(FUTURES_ORDERBOOK_DEPTH) * NaN,

        "computed_price" => -Inf
    )

    DeribitIOs.parse_subscriptions!(initial_response, futures_orderbooks, FUTURES_ORDERBOOK_DEPTH, options_orderbooks)


    ## Finish initialisation
    test_response = Dict(
        "method" => "subscription",
        "jsonrpc" => "2.0",
        "params" => Dict(
            "channel" => "book.BTC-PERPETUAL.raw",
            "data" => Dict(
                "instrument_name" => "BTC-PERPETUAL",
                "change_id" => 56636434448,
                "timestamp" => 1686675438851,
                "type" => "change",
                "asks" => [
                    ["new", 25869.0, 123.0],
                    ["change", 25862.5, 768.0],
                    ["delete", 25862.5, 0.0]
                ],
                "bids" => [
                    ["new", 25869.0, 123.0],
                    ["change", 25862.5, 768.0],
                    ["delete", 25862.5, 0.0]
                ]
            )
        )
    )

    test_response = Dict(
        "method" => "subscriptions",
        "jsonrpc" => "2.0",
        "params" => Dict(
            "events" => [
                [
                    "book.BTC-PERPETUAL.raw",
                    Dict(
                        "instrument_name" => "BTC-PERPETUAL",
                        "change_id" => 56636434448,
                        "timestamp" => 1686675438851,
                        "type" => "change",
                        "asks" => [
                            ["new", 25869.0, 123.0],
                            ["change", 25862.5, 768.0],
                            ["delete", 25862.5, 0.0]
                        ],
                        "bids" => [
                            ["new", 25869.0, 123.0],
                            ["change", 25862.5, 768.0],
                            ["delete", 25862.5, 0.0]
                        ]
                    )
                ]
            ]
        )
    )

    target_futures_orderbooks = Dict(futures_orderbooks)

    DeribitIOs.parse_subscriptions!(test_response, futures_orderbooks, FUTURES_ORDERBOOK_DEPTH, options_orderbooks)

    delete!(target_futures_orderbooks["BTC-PERPETUAL"]["asks"], 25862.5)
    insert!(target_futures_orderbooks["BTC-PERPETUAL"]["asks"], 25862.5, 768.0)
    insert!(target_futures_orderbooks["BTC-PERPETUAL"]["asks"], 25869.0, 123.0)

    delete!(target_futures_orderbooks["BTC-PERPETUAL"]["asks"], -25862.5)
    insert!(target_futures_orderbooks["BTC-PERPETUAL"]["asks"], -25862.5, 768.0)
    insert!(target_futures_orderbooks["BTC-PERPETUAL"]["asks"], -25869.0, 123.0)

    return JSON.json(target_futures_orderbooks) == JSON.json(futures_orderbooks)
end

@test _test() == true
#########




#########
@info "DeribitIOs.parse_subscriptions! -- subscriptions - future - book.BTC-30JUN23 - change"
function _test()
    initial_response = Dict(
        "method" => "subscription",
        "jsonrpc" => "2.0",
        "params" => Dict(
            "channel" => "book.BTC-30JUN23.raw",
            "data" => Dict(
                "instrument_name" => "BTC-30JUN23",
                "change_id" => 56636434448,
                "timestamp" => 1686675438851,
                "type" => "snapshot",
                "asks" => [
                    ["new", 25862.0, 131420.0],
                    ["new", 25862.5, 76830.0]
                ],
                "bids" => [
                    ["new", 25861.5, 1470.0],
                    ["new", 25861.0, 10000.0]
                ]
            )
        )
    )

    futures_orderbooks = Dict()
    FUTURES_ORDERBOOK_DEPTH = 5
    options_orderbooks = Dict()

    futures_orderbooks["BTC-30JUN23"] = Dict(
        "bids" => avl.AVLTree{Float64,Float64}(),
        "asks" => avl.AVLTree{Float64,Float64}(),
        "last_traded_price" => [],
        "last_traded_size" => [],
        "bid_price" => zeros(FUTURES_ORDERBOOK_DEPTH) * NaN,
        "ask_price" => zeros(FUTURES_ORDERBOOK_DEPTH) * NaN,
        "bid_size" => zeros(FUTURES_ORDERBOOK_DEPTH) * NaN,
        "ask_size" => zeros(FUTURES_ORDERBOOK_DEPTH) * NaN,

        "computed_price" => -Inf
    )

    DeribitIOs.parse_subscriptions!(initial_response, futures_orderbooks, FUTURES_ORDERBOOK_DEPTH, options_orderbooks)


    ## Finish initialisation
    test_response = Dict(
        "method" => "subscription",
        "jsonrpc" => "2.0",
        "params" => Dict(
            "channel" => "book.BTC-30JUN23.raw",
            "data" => Dict(
                "instrument_name" => "BTC-30JUN23",
                "change_id" => 56636434448,
                "timestamp" => 1686675438851,
                "type" => "change",
                "asks" => [
                    ["new", 25869.0, 123.0],
                    ["change", 25862.5, 768.0],
                    ["delete", 25862.5, 0.0]
                ],
                "bids" => [
                    ["new", 25869.0, 123.0],
                    ["change", 25862.5, 768.0],
                    ["delete", 25862.5, 0.0]
                ]
            )
        )
    )

    test_response = Dict(
        "method" => "subscriptions",
        "jsonrpc" => "2.0",
        "params" => Dict(
            "events" => [
                [
                    "book.BTC-30JUN23.raw",
                    Dict(
                        "instrument_name" => "BTC-30JUN23",
                        "change_id" => 56636434448,
                        "timestamp" => 1686675438851,
                        "type" => "change",
                        "asks" => [
                            ["new", 25869.0, 123.0],
                            ["change", 25862.5, 768.0],
                            ["delete", 25862.5, 0.0]
                        ],
                        "bids" => [
                            ["new", 25869.0, 123.0],
                            ["change", 25862.5, 768.0],
                            ["delete", 25862.5, 0.0]
                        ]
                    )
                ]
            ]
        )
    )

    target_futures_orderbooks = Dict(futures_orderbooks)

    DeribitIOs.parse_subscriptions!(test_response, futures_orderbooks, FUTURES_ORDERBOOK_DEPTH, options_orderbooks)

    delete!(target_futures_orderbooks["BTC-30JUN23"]["asks"], 25862.5)
    insert!(target_futures_orderbooks["BTC-30JUN23"]["asks"], 25862.5, 768.0)
    insert!(target_futures_orderbooks["BTC-30JUN23"]["asks"], 25869.0, 123.0)

    delete!(target_futures_orderbooks["BTC-30JUN23"]["asks"], -25862.5)
    insert!(target_futures_orderbooks["BTC-30JUN23"]["asks"], -25862.5, 768.0)
    insert!(target_futures_orderbooks["BTC-30JUN23"]["asks"], -25869.0, 123.0)

    return JSON.json(target_futures_orderbooks) == JSON.json(futures_orderbooks)
end

@test _test() == true
#########




#########
@info "DeribitIOs.parse_subscriptions! -- subscriptions - future - book.BTC-30JUN23-10000-C - change"
function _test()
    initial_response = Dict(
        "method" => "subscription",
        "jsonrpc" => "2.0",
        "params" => Dict(
            "channel" => "book.BTC-30JUN23-10000-C.raw",
            "data" => Dict(
                "instrument_name" => "BTC-30JUN23-10000-C",
                "change_id" => 56636434448,
                "timestamp" => 1686675438851,
                "type" => "snapshot",
                "asks" => [
                    ["new", 25862.0, 131420.0],
                    ["new", 25862.5, 76830.0]
                ],
                "bids" => [
                    ["new", 25861.5, 1470.0],
                    ["new", 25861.0, 10000.0]
                ]
            )
        )
    )

    futures_orderbooks = Dict()
    FUTURES_ORDERBOOK_DEPTH = 5
    options_orderbooks = Dict()

    options_orderbooks["BTC-30JUN23-10000-C"] = Dict(
        "bids" => avl.AVLTree{Float64,Float64}(),
        "asks" => avl.AVLTree{Float64,Float64}()
    )

    DeribitIOs.parse_subscriptions!(initial_response, futures_orderbooks, FUTURES_ORDERBOOK_DEPTH, options_orderbooks)


    ## Finish initialisation
    test_response = Dict(
        "method" => "subscription",
        "jsonrpc" => "2.0",
        "params" => Dict(
            "channel" => "book.BTC-30JUN23-10000-C.raw",
            "data" => Dict(
                "instrument_name" => "BTC-30JUN23-10000-C",
                "change_id" => 56636434448,
                "timestamp" => 1686675438851,
                "type" => "change",
                "asks" => [
                    ["new", 25869.0, 123.0],
                    ["change", 25862.5, 768.0],
                    ["delete", 25862.5, 0.0]
                ],
                "bids" => [
                    ["new", 25869.0, 123.0],
                    ["change", 25862.5, 768.0],
                    ["delete", 25862.5, 0.0]
                ]
            )
        )
    )

    test_response = Dict(
        "method" => "subscriptions",
        "jsonrpc" => "2.0",
        "params" => Dict(
            "events" => [
                [
                    "book.BTC-30JUN23-10000-C.raw",
                    Dict(
                        "instrument_name" => "BTC-30JUN23-10000-C",
                        "change_id" => 56636434448,
                        "timestamp" => 1686675438851,
                        "type" => "change",
                        "asks" => [
                            ["new", 25869.0, 123.0],
                            ["change", 25862.5, 768.0],
                            ["delete", 25862.5, 0.0]
                        ],
                        "bids" => [
                            ["new", 25869.0, 123.0],
                            ["change", 25862.5, 768.0],
                            ["delete", 25862.5, 0.0]
                        ]
                    )
                ]
            ]
        )
    )

    target_options_orderbooks = Dict(options_orderbooks)

    DeribitIOs.parse_subscriptions!(test_response, futures_orderbooks, FUTURES_ORDERBOOK_DEPTH, options_orderbooks)

    delete!(target_options_orderbooks["BTC-30JUN23-10000-C"]["asks"], 25862.5)
    insert!(target_options_orderbooks["BTC-30JUN23-10000-C"]["asks"], 25862.5, 768.0)
    insert!(target_options_orderbooks["BTC-30JUN23-10000-C"]["asks"], 25869.0, 123.0)

    delete!(target_options_orderbooks["BTC-30JUN23-10000-C"]["asks"], -25862.5)
    insert!(target_options_orderbooks["BTC-30JUN23-10000-C"]["asks"], -25862.5, 768.0)
    insert!(target_options_orderbooks["BTC-30JUN23-10000-C"]["asks"], -25869.0, 123.0)

    return JSON.json(target_options_orderbooks) == JSON.json(options_orderbooks)
end

@test _test() == true
#########




#########
@info "DeribitIOs.parse_subscriptions! -- subscriptions - future - trades.BTC-PERPETUAL"
function _test()
    FUTURES_ORDERBOOK_DEPTH = 3

    options_orderbooks = Dict()
    futures_orderbooks = Dict()

    futures_orderbooks["BTC-PERPETUAL"] = Dict(
        "bids" => avl.AVLTree{Float64,Float64}(),
        "asks" => avl.AVLTree{Float64,Float64}(),
        "last_traded_price" => [9000, 9001, 9007],
        "last_traded_size" => [20, 40, 5],
        "last_traded_timestamp" => [20000, 400000, 5000],
        "bid_price" => zeros(FUTURES_ORDERBOOK_DEPTH) * NaN,
        "ask_price" => zeros(FUTURES_ORDERBOOK_DEPTH) * NaN,
        "bid_size" => zeros(FUTURES_ORDERBOOK_DEPTH) * NaN,
        "ask_size" => zeros(FUTURES_ORDERBOOK_DEPTH) * NaN,

        "computed_price" => -Inf
    )

    test_response = Dict(
        "method" => "subscriptions",
        "jsonrpc" => "2.0",
        "params" => Dict(
            "events" => Dict(
                [
                    [
                        "trades.BTC-PERPETUAL.raw",
                        [
                            Dict(
                                "trade_seq" => 30289442,
                                "trade_id" => "48079269",
                                "timestamp" => 1590484512188,
                                "tick_direction" => 2,
                                "price" => 8950,
                                "mark_price" => 8948.9,
                                "instrument_name" => "BTC-PERPETUAL",
                                "index_price" => 8955.88,
                                "direction" => "sell",
                                "amount" => 10
                            ),
                            Dict(
                                "trade_seq" => 30289442,
                                "trade_id" => "48079269",
                                "timestamp" => 1590484512188,
                                "tick_direction" => 2,
                                "price" => 9000,
                                "mark_price" => 9000.9,
                                "instrument_name" => "BTC-PERPETUAL",
                                "index_price" => 9000.9,
                                "direction" => "sell",
                                "amount" => 20
                            ),
                            Dict(
                                "trade_seq" => 30289442,
                                "trade_id" => "48079269",
                                "timestamp" => 1590484512188,
                                "tick_direction" => 2,
                                "price" => 9001,
                                "mark_price" => 9001.9,
                                "instrument_name" => "BTC-PERPETUAL",
                                "index_price" => 9002.9,
                                "direction" => "sell",
                                "amount" => 40
                            ),
                            Dict(
                                "trade_seq" => 30289442,
                                "trade_id" => "48079269",
                                "timestamp" => 1590484512188,
                                "tick_direction" => 2,
                                "price" => 9007,
                                "mark_price" => 9007.9,
                                "instrument_name" => "BTC-PERPETUAL",
                                "index_price" => 9007.9,
                                "direction" => "buy",
                                "amount" => 5
                            )   
                        ]
                    ]
                ]
            )
        )
    )

    target_futures_orderbooks = Dict(futures_orderbooks)
    DeribitIOs.parse_subscriptions!(test_response, futures_orderbooks, FUTURES_ORDERBOOK_DEPTH, options_orderbooks)

    @test JSON.json(target_futures_orderbooks) == JSON.json(futures_orderbooks)

    test_response = Dict(
        "method" => "subscriptions",
        "jsonrpc" => "2.0",
        "params" => Dict(
            "events" => Dict(
                [
                    [
                        "trades.BTC-PERPETUAL.raw",
                        [
                            Dict(
                                "trade_seq" => 30289442,
                                "trade_id" => "48079269",
                                "timestamp" => 1590484512188,
                                "tick_direction" => 2,
                                "price" => 1000,
                                "mark_price" => 1000.9,
                                "instrument_name" => "BTC-PERPETUAL",
                                "index_price" => 1000.88,
                                "direction" => "buy",
                                "amount" => 80
                            ),
                            Dict(
                                "trade_seq" => 30289442,
                                "trade_id" => "48079269",
                                "timestamp" => 1590484512188,
                                "tick_direction" => 2,
                                "price" => 3000,
                                "mark_price" => 3000.9,
                                "instrument_name" => "BTC-PERPETUAL",
                                "index_price" => 3000.9,
                                "direction" => "sell",
                                "amount" => 10
                            )
                        ]
                    ]
                ]
            )
        )
    )

    DeribitIOs.parse_subscriptions!(test_response, futures_orderbooks, FUTURES_ORDERBOOK_DEPTH, options_orderbooks)

    target_futures_orderbooks["BTC-PERPETUAL"]["last_traded_price"] = [9007, 1000, 3000]
    target_futures_orderbooks["BTC-PERPETUAL"]["last_traded_size"] = [5, 80, 10]

    @test JSON.json(futures_orderbooks) == JSON.json(target_futures_orderbooks)
end

_test()
#########




#########
@info "DeribitIOs.parse_subscriptions! -- subscriptions - future - trades.BTC-30JUN23"
function _test()
    FUTURES_ORDERBOOK_DEPTH = 3

    options_orderbooks = Dict()
    futures_orderbooks = Dict()

    futures_orderbooks["BTC-30JUN23"] = Dict(
        "bids" => avl.AVLTree{Float64,Float64}(),
        "asks" => avl.AVLTree{Float64,Float64}(),
        "last_traded_price" => [9000, 9001, 9007],
        "last_traded_size" => [20, 40, 5],
        "last_traded_timestamp" => [20000, 400000, 5000],
        "bid_price" => zeros(FUTURES_ORDERBOOK_DEPTH) * NaN,
        "ask_price" => zeros(FUTURES_ORDERBOOK_DEPTH) * NaN,
        "bid_size" => zeros(FUTURES_ORDERBOOK_DEPTH) * NaN,
        "ask_size" => zeros(FUTURES_ORDERBOOK_DEPTH) * NaN,

        "computed_price" => -Inf
    )

    test_response = Dict(
        "method" => "subscriptions",
        "jsonrpc" => "2.0",
        "params" => Dict(
            "events" => Dict(
                [
                    [
                        "trades.BTC-30JUN23.raw",
                        [
                            Dict(
                                "trade_seq" => 30289442,
                                "trade_id" => "48079269",
                                "timestamp" => 1590484512188,
                                "tick_direction" => 2,
                                "price" => 8950,
                                "mark_price" => 8948.9,
                                "instrument_name" => "BTC-30JUN23",
                                "index_price" => 8955.88,
                                "direction" => "sell",
                                "amount" => 10
                            ),
                            Dict(
                                "trade_seq" => 30289442,
                                "trade_id" => "48079269",
                                "timestamp" => 1590484512188,
                                "tick_direction" => 2,
                                "price" => 9000,
                                "mark_price" => 9000.9,
                                "instrument_name" => "BTC-30JUN23",
                                "index_price" => 9000.9,
                                "direction" => "sell",
                                "amount" => 20
                            ),
                            Dict(
                                "trade_seq" => 30289442,
                                "trade_id" => "48079269",
                                "timestamp" => 1590484512188,
                                "tick_direction" => 2,
                                "price" => 9001,
                                "mark_price" => 9001.9,
                                "instrument_name" => "BTC-30JUN23",
                                "index_price" => 9002.9,
                                "direction" => "sell",
                                "amount" => 40
                            ),
                            Dict(
                                "trade_seq" => 30289442,
                                "trade_id" => "48079269",
                                "timestamp" => 1590484512188,
                                "tick_direction" => 2,
                                "price" => 9007,
                                "mark_price" => 9007.9,
                                "instrument_name" => "BTC-30JUN23",
                                "index_price" => 9007.9,
                                "direction" => "buy",
                                "amount" => 5
                            )   
                        ]
                    ]
                ]
            )
        )
    )

    target_futures_orderbooks = Dict(futures_orderbooks)
    DeribitIOs.parse_subscriptions!(test_response, futures_orderbooks, FUTURES_ORDERBOOK_DEPTH, options_orderbooks)

    @test JSON.json(target_futures_orderbooks) == JSON.json(futures_orderbooks)

    test_response = Dict(
        "method" => "subscriptions",
        "jsonrpc" => "2.0",
        "params" => Dict(
            "events" => Dict(
                [
                    [
                        "trades.BTC-30JUN23.raw",
                        [
                            Dict(
                                "trade_seq" => 30289442,
                                "trade_id" => "48079269",
                                "timestamp" => 1590484512188,
                                "tick_direction" => 2,
                                "price" => 1000,
                                "mark_price" => 1000.9,
                                "instrument_name" => "BTC-30JUN23",
                                "index_price" => 1000.88,
                                "direction" => "buy",
                                "amount" => 80
                            ),
                            Dict(
                                "trade_seq" => 30289442,
                                "trade_id" => "48079269",
                                "timestamp" => 1590484512188,
                                "tick_direction" => 2,
                                "price" => 3000,
                                "mark_price" => 3000.9,
                                "instrument_name" => "BTC-30JUN23",
                                "index_price" => 3000.9,
                                "direction" => "sell",
                                "amount" => 10
                            )
                        ]
                    ]
                ]
            )
        )
    )

    DeribitIOs.parse_subscriptions!(test_response, futures_orderbooks, FUTURES_ORDERBOOK_DEPTH, options_orderbooks)

    target_futures_orderbooks["BTC-30JUN23"]["last_traded_price"] = [9007, 1000, 3000]
    target_futures_orderbooks["BTC-30JUN23"]["last_traded_size"] = [5, 80, 10]

    @test JSON.json(futures_orderbooks) == JSON.json(target_futures_orderbooks)
end

_test()
#########