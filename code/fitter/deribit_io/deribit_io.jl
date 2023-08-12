module DeribitIOs
using JSON, JSON3, HTTP, Dates
import AVLTrees as avl;
export authenticate, login_json, parse_subscriptions!

const authentication_hello_dict = Dict(
    :jsonrpc => "2.0",
    :id => "hello",
    :method => "public/hello",
    :params => Dict(
        :client_name => "Julia engine",
        :client_version => "v6.0",
        :extensions => ["subscriptions", "connection_close_on_session_drop"]
    )
);

const authentication_heartbeat_dict = Dict(
    :jsonrpc => "2.0",
    :id => "set_heartbeat",
    :method => "public/set_heartbeat",
    :params => Dict(
        :interval => 10
    )
);

const heartbeat_challenge_dict = Dict(
    :jsonrpc => "2.0",
    :id => "heartbeat_challenge",
    :method => "public/test",
    :params => Dict(
    )
);

const heartbeat_challenge_json = JSON.json(heartbeat_challenge_dict);


function update_instrument_maps!(currency, current_subscriptions, instrument_map, expirations_map, new_subscriptions, removed_subscriptions, MIN_FITTING_TTM, verbose::Bool = true)::Bool
    if verbose
        if verbose
            now_str = Dates.format(now(), "YYYY-mm-dd HH:MM:SS");
            @info "$now_str \t Gathering instrument details"
        end
    end
    all_instruments_url = "https://www.deribit.com/api/v2/public/get_instruments?currency=" * currency
    all_instruments_json = JSON3.read(String(HTTP.request("GET", all_instruments_url).body))

    all_strikes_tmp = Dict()
    current_time = time()

    for instrument in all_instruments_json["result"]
        if instrument["base_currency"] != currency
            continue
        end

        if (instrument["expiration_timestamp"]/1000 - current_time)/(24*60*60) < MIN_FITTING_TTM
            continue
        end

        tmp_subs_name_book = "book." * instrument["instrument_name"] * ".raw"

        if instrument["kind"] == "option"
            string_match = match(r"[0-9]{1,2}[A-Z]{3}[0-9]{2}", instrument["instrument_name"])

            if string_match === nothing

            else
                expiration_str = string_match.match
                expirations_map[expiration_str] = Dict(
                    "expiration_timestamp" => instrument["expiration_timestamp"],
                    "settlement_period" => instrument["settlement_period"],
                    "is_active" => instrument["is_active"],
                    "underlying_name" => "PERPETUAL",
                    "full_underlying_name" => "$currency-PERPETUAL",
                    "settlement_currency" => instrument["settlement_currency"],
                    "ttm_index" => NaN
                )

                instrument_map[instrument["instrument_name"]] = Dict(
                    "tick_size" => instrument["tick_size"],
                    "taker_commission" => instrument["taker_commission"],
                    "strike" => instrument["strike"],
                    "settlement_period" => instrument["settlement_period"],
                    "settlement_currency" => instrument["settlement_currency"],
                    "rfq" => instrument["rfq"],
                    "quote_currency" => instrument["quote_currency"],
                    "price_index" => instrument["price_index"],
                    "option_type" => instrument["option_type"],
                    "min_trade_amount" => instrument["min_trade_amount"],
                    "maker_commission" => instrument["maker_commission"],
                    "kind" => instrument["kind"],
                    "is_active" => instrument["is_active"],
                    "instrument_type" => instrument["instrument_type"],
                    "instrument_name" => instrument["instrument_name"],
                    "instrument_id" => instrument["instrument_id"],
                    "expiration_timestamp" => instrument["expiration_timestamp"],
                    "creation_timestamp" => instrument["creation_timestamp"],
                    "counter_currency" => instrument["counter_currency"],
                    "contract_size" => instrument["contract_size"],
                    "block_trade_tick_size" => instrument["block_trade_tick_size"],
                    "block_trade_min_trade_amount" => instrument["block_trade_min_trade_amount"],
                    "block_trade_commission" => instrument["block_trade_commission"],
                    "base_currency" => instrument["base_currency"],

                    "expiration_str" => expiration_str
                )

                if ! haskey(all_strikes_tmp, expiration_str)
                    all_strikes_tmp[expiration_str] = []
                end

                if !(instrument["strike"] in all_strikes_tmp[expiration_str])
                    push!(all_strikes_tmp[expiration_str], instrument["strike"])
                end

                if !(tmp_subs_name_book in current_subscriptions)
                    push!(new_subscriptions, tmp_subs_name_book)
                end

            end
        end
    end

    for instrument in all_instruments_json["result"]
        if instrument["base_currency"] != currency
            continue
        end

        if (instrument["expiration_timestamp"]/1000 - current_time)/(24*60*60) < MIN_FITTING_TTM
            continue
        end

        tmp_subs_name_book = "book." * instrument["instrument_name"] * ".raw"
        tmp_subs_name_trades = "trades." * instrument["instrument_name"] * ".raw"

        if instrument["kind"] == "future"
            instrument_map[instrument["instrument_name"]] = Dict(
                    "tick_size" => instrument["tick_size"],
                    "taker_commission" => instrument["taker_commission"],
                    "settlement_period" => instrument["settlement_period"],
                    "settlement_currency" => instrument["settlement_currency"],
                    "rfq" => instrument["rfq"],
                    "quote_currency" => instrument["quote_currency"],
                    "price_index" => instrument["price_index"],
                    "min_trade_amount" => instrument["min_trade_amount"],
                    "max_liquidation_commission" => instrument["max_liquidation_commission"],
                    "max_leverage" => instrument["max_leverage"],
                    "maker_commission" => instrument["maker_commission"],
                    "kind" => instrument["kind"],
                    "is_active" => instrument["is_active"],
                    "instrument_type" => instrument["instrument_type"],
                    "instrument_name" => instrument["instrument_name"],
                    "instrument_id" => instrument["instrument_id"],
                    "expiration_timestamp" => instrument["expiration_timestamp"],
                    "creation_timestamp" => instrument["creation_timestamp"],
                    "counter_currency" => instrument["counter_currency"],
                    "contract_size" => instrument["contract_size"],
                    "block_trade_tick_size" => instrument["block_trade_tick_size"],
                    "block_trade_min_trade_amount" => instrument["block_trade_min_trade_amount"],
                    "block_trade_commission" => instrument["block_trade_commission"],
                    "base_currency" => instrument["base_currency"]
                )

            string_match = match(r"[0-9]{1,2}[A-Z]{3}[0-9]{2}", instrument["instrument_name"])

            if string_match === nothing

            else
                expiration_str = string_match.match
                if haskey(expirations_map, expiration_str)
                    expirations_map[expiration_str]["underlying_name"] = expiration_str
                    expirations_map[expiration_str]["full_underlying_name"] = "$currency-$expiration_str"
                end
            end

            if ! (tmp_subs_name_book in current_subscriptions)
                if !(tmp_subs_name_book in new_subscriptions)
                    push!(new_subscriptions, tmp_subs_name_book)
                end
            end

            if ! (tmp_subs_name_trades in current_subscriptions)
                if !(tmp_subs_name_trades in new_subscriptions)
                    push!(new_subscriptions, tmp_subs_name_trades)
                end
            end
        end
    end

    for expiration_str in keys(all_strikes_tmp)
        sort!(all_strikes_tmp[expiration_str])
    end

    for instrument_name in keys(instrument_map)
        if instrument_map[instrument_name]["kind"] == "option"
            index = findfirst(element -> element == instrument_map[instrument_name]["strike"], 
                all_strikes_tmp[instrument_map[instrument_name]["expiration_str"]]
            )
            instrument_map[instrument_name]["position"] = index
        end
    end

    for subscription in current_subscriptions
        if ! (subscription in new_subscriptions)
            if !(subscription in removed_subscriptions)
                push!(removed_subscriptions, subscription)
            end
        end
    end

    # Add strikes information to each expiration
    for expiration_key in keys(expirations_map)
        expirations_map[expiration_key]["strike"] = all_strikes_tmp[expiration_key]
        expirations_map[expiration_key]["strikes_count"] = length(all_strikes_tmp[expiration_key])
        # Add instrument names
        expirations_map[expiration_key]["call_instruments"] = []
        expirations_map[expiration_key]["put_instruments"] = []
        for __strike in all_strikes_tmp[expiration_key]
            push!(expirations_map[expiration_key]["call_instruments"], "$currency-$expiration_key-$__strike-C")
            push!(expirations_map[expiration_key]["put_instruments"], "$currency-$expiration_key-$__strike-P")
        end
    end

    # Add TTM index
    expiration_timestamps_dict = Dict()
    expiration_timestamps = []
    for expiration_str in keys(expirations_map)
        expiration_timestamps_dict[expirations_map[expiration_str]["expiration_timestamp"]] = expiration_str
        push!(expiration_timestamps, expirations_map[expiration_str]["expiration_timestamp"])
    end

    sort!(expiration_timestamps)

    ttm_index = 0
    for expiration_timestamp in expiration_timestamps
        ttm_index += 1
        expirations_map[expiration_timestamps_dict[expiration_timestamp]]["ttm_index"] = ttm_index
    end

    # Add closest future to missing underlying
    for expiration_str in keys(expirations_map)
        __min_difference = Inf
        for ___expiration_timestamp in expiration_timestamps
            if haskey(instrument_map, "$currency-" * expiration_timestamps_dict[___expiration_timestamp])
                if abs(___expiration_timestamp - expirations_map[expiration_str]["expiration_timestamp"]) < __min_difference
                    __min_difference = abs(___expiration_timestamp - expirations_map[expiration_str]["expiration_timestamp"])

                    expirations_map[expiration_str]["underlying_name"] = expiration_timestamps_dict[___expiration_timestamp]
                    expirations_map[expiration_str]["full_underlying_name"] = "$currency-" * expiration_timestamps_dict[___expiration_timestamp]
                end
            end
        end
    end

    return true
end

function login_json(CLIENT_ID::String, CLIENT_SECRET::String)
    return JSON.json(Dict(
        :method => "public/auth",
        :params => Dict(
            :grant_type => "client_credentials",
            :client_id => CLIENT_ID,
            :client_secret => CLIENT_SECRET,
        ),
        :jsonrpc => "2.0",
        :id => "authentication"
    )
    )
end

function update_futures_orderbook_keys!(expirations_map, instrument_map, futures_orderbooks, CURRENCY, FUTURES_CALC_DEPTH::Int64, verbose::Bool = false)
    if verbose
        now_str = Dates.format(now(), "YYYY-mm-dd HH:MM:SS");
        @info "$now_str \t update_futures_orderbook_keys"
    end

    futures_orderbooks[CURRENCY * "-PERPETUAL"] = Dict(
        "bids" => avl.AVLTree{Float64,Float64}(),
        "asks" => avl.AVLTree{Float64,Float64}(),
        "last_traded_price" => [],
        "last_traded_size" => [],
        "last_traded_timestamp" => [],
        "bid_price" => zeros(FUTURES_CALC_DEPTH),
        "ask_price" => zeros(FUTURES_CALC_DEPTH),
        "bid_size" => zeros(FUTURES_CALC_DEPTH),
        "ask_size" => zeros(FUTURES_CALC_DEPTH),

        "computed_price" => NaN
    )

    for expiration_key in keys(expirations_map)
        if haskey(instrument_map, "$CURRENCY-$expiration_key")
            if instrument_map["$CURRENCY-$expiration_key"]["kind"] == "future"
                futures_orderbooks[CURRENCY * "-" * expiration_key] = Dict(
                    "bids" => avl.AVLTree{Float64,Float64}(),
                    "asks" => avl.AVLTree{Float64,Float64}(),
                    "last_traded_price" => [],
                    "last_traded_size" => [],
                    "last_traded_timestamp" => [],
                    "bid_price" => zeros(FUTURES_CALC_DEPTH),
                    "ask_price" => zeros(FUTURES_CALC_DEPTH),
                    "bid_size" => zeros(FUTURES_CALC_DEPTH),
                    "ask_size" => zeros(FUTURES_CALC_DEPTH),

                    "computed_price" => NaN
                )
            end
        end
    end
end

function update_options_orderbook_keys!(instrument_map, options_orderbooks, verbose::Bool = false)
    if verbose
        now_str = Dates.format(now(), "YYYY-mm-dd HH:MM:SS");
        @info "$now_str \t update_options_orderbook_keys"
    end

    for instrument_key in keys(instrument_map)
        if instrument_map[instrument_key]["kind"] == "option"
            if ! haskey(options_orderbooks, instrument_key)
                options_orderbooks[instrument_key] = Dict(
                    "bids" => avl.AVLTree{Float64,Float64}(),
                    "asks" => avl.AVLTree{Float64,Float64}(),
                    "top_bid_price" => NaN,
                    "top_ask_price" => NaN,
                    "top_bid_size" => NaN,
                    "top_ask_size" => NaN,
                    "top_bid_iv" => NaN,
                    "top_ask_iv" => NaN,
                    "fitting_bid_price" => NaN,
                    "fitting_ask_price" => NaN,
                    "fitting_weighted_price" => NaN,
                    "fitting_weighted_iv" => NaN
                )
            end
        end
    end
end

function update_sub_fitter_expirations!(sub_fitter_expiration_info, expirations_map, verbose::Bool = false)
    if verbose
        now_str = Dates.format(now(), "YYYY-mm-dd HH:MM:SS");
        @info "$now_str \t update_sub_fitter_expirations"
    end

    for expiration_str in keys(expirations_map)
        strikes_count = length(expirations_map[expiration_str]["strike"])
        sub_fitter_expiration_info[expiration_str] = Dict(
            "strike" => expirations_map[expiration_str]["strike"],
            "ns_strike" => zeros(strikes_count) * NaN,
            "delta_strike" => zeros(strikes_count) * NaN,
            "fitting_strike" => zeros(strikes_count) * NaN,
            "fitting_point" => zeros(strikes_count) * NaN,
            "fitting_count" => NaN,
            "atm_index" => NaN,
            "ttm_index" => NaN,
            "min_normalized_strike" => NaN,
            "max_normalized_strike" => NaN,
            "fair_iv" => zeros(strikes_count) * NaN,
            "ttm" => NaN,

            "market_bid_iv" => zeros(strikes_count) * NaN,
            "market_ask_iv" => zeros(strikes_count) * NaN,

            "put_fair_price" => zeros(strikes_count) * NaN,
            "call_fair_price" => zeros(strikes_count) * NaN,
            "own_call_bid" => zeros(strikes_count) * NaN,
            "own_call_ask" => zeros(strikes_count) * NaN,
            "own_put_bid" => zeros(strikes_count) * NaN,
            "own_put_ask" => zeros(strikes_count) * NaN,

            "delta_call" => zeros(strikes_count) * NaN,
            "delta_put" => zeros(strikes_count) * NaN,
            "gamma" => zeros(strikes_count) * NaN,
            "vega" => zeros(strikes_count) * NaN,
            "theta" => zeros(strikes_count) * NaN,
            "vanna" => zeros(strikes_count) * NaN,
            "volga" => zeros(strikes_count) * NaN,
            "total_delta_call" => zeros(strikes_count) * NaN,
            "total_delta_put" => zeros(strikes_count) * NaN,
            "strike_count" => NaN
        )
    end
end

function authenticate(ws, CLIENT_ID::String, CLIENT_SECRET::String, verbose::Bool = false)
    if verbose
        now_str = Dates.format(now(), "YYYY-mm-dd HH:MM:SS");
        @info "$now_str \t heartbeat"
    end
    HTTP.send(ws, login_json(CLIENT_ID, CLIENT_SECRET))
    HTTP.send(ws, JSON.json(authentication_hello_dict))
    HTTP.send(ws, JSON.json(authentication_heartbeat_dict))
end

function heartbeat_response(ws, verbose::Bool = false)
    if verbose
        now_str = Dates.format(now(), "YYYY-mm-dd HH:MM:SS");
        @info "$now_str \t heartbeat"
    end
    HTTP.send(ws, heartbeat_challenge_json)
end

function subscribe_to_streams(ws, instrument_map, verbose::Bool = false)
    if verbose
        now_str = Dates.format(now(), "YYYY-mm-dd HH:MM:SS");
        @info "$now_str \t Subscribing to streams"
    end
    HTTP.send(ws, JSON.json(Dict(
        :method => "public/subscribe",
        :params => Dict(
            :channels => instrument_map
        ),
        :jsonrpc => "2.0",
        :id => "streaming_subcription"
    ))
    )
end

function parse_subscriptions!(response, futures_orderbooks, MAX_TRACKED_FUTURE_TRADES, options_orderbooks)
    # Main function to parse subscription based events from Deribit
    # There are two types of events.. Subscription and Subscriptions
    # The latter returns multiple events in a same response
    if haskey(response, "method")
        if response["method"] == "subscription"
            if haskey(response, "params")
                if haskey(response["params"], "channel")
                    channel = response["params"]["channel"]

                    if occursin(r"book\.[A-Z]{3}-[0-9]{1,2}[A-Z]{3}[0-9]{2}-[0-9]{1,5}-[CP]\.", response["params"]["channel"])
                        instrument_name = response["params"]["data"]["instrument_name"]

                        if response["params"]["data"]["type"] == "snapshot"
                            if haskey(response["params"]["data"], "bids")
                                for bids in response["params"]["data"]["bids"]
                                    if bids[1] == "new"
                                        insert!(options_orderbooks[instrument_name]["bids"], -bids[2] * 1.0, bids[3] * 1.0)
                                    end
                                end
                            end
                            if haskey(response["params"]["data"], "asks")
                                for asks in response["params"]["data"]["asks"]
                                    if asks[1] == "new"
                                        insert!(options_orderbooks[instrument_name]["asks"], asks[2] * 1.0, asks[3] * 1.0)
                                    end
                                end
                            end
                        else
                            if haskey(response["params"]["data"], "bids")
                                for bids in response["params"]["data"]["bids"]
                                    if bids[1] == "new"
                                        insert!(options_orderbooks[instrument_name]["bids"], -bids[2], bids[3])
                                    elseif bids[1] == "edit"
                                        insert!(options_orderbooks[instrument_name]["bids"], -bids[2], bids[3])
                                    elseif bids[1] == "delete"
                                        if bids[2] * -1.0 in options_orderbooks[instrument_name]["bids"]
                                            delete!(options_orderbooks[instrument_name]["bids"], -1.0 * bids[2])
                                        end
                                    end
                                end
                            end
                            if haskey(response["params"]["data"], "asks")
                                for asks in response["params"]["data"]["asks"]
                                    if asks[1] == "new"
                                        insert!(options_orderbooks[instrument_name]["asks"], asks[2] * 1.0, asks[3] * 1.0)
                                    elseif asks[1] == "edit"
                                        insert!(options_orderbooks[instrument_name]["asks"], asks[2] * 1.0, asks[3] * 1.0)
                                    elseif asks[1] == "delete"
                                        if asks[2] * 1.0 in options_orderbooks[instrument_name]["asks"]
                                            delete!(options_orderbooks[instrument_name]["asks"], asks[2] * 1.0)
                                        end
                                    end
                                end
                            end
                        end
                    elseif occursin(r"book\.[A-Z]{3}-PERPETUAL", response["params"]["channel"])
                        instrument_name = response["params"]["data"]["instrument_name"]

                        if response["params"]["data"]["type"] == "snapshot"
                            if haskey(response["params"]["data"], "bids")
                                for bids in response["params"]["data"]["bids"]
                                    if bids[1] == "new"
                                        insert!(futures_orderbooks[instrument_name]["bids"], -bids[2] * 1.0, bids[3] * 1.0)
                                    end
                                end
                            end
                            if haskey(response["params"]["data"], "asks")
                                for asks in response["params"]["data"]["asks"]
                                    if asks[1] == "new"
                                        insert!(futures_orderbooks[instrument_name]["asks"], asks[2] * 1.0, asks[3] * 1.0)
                                    end
                                end
                            end
                        else
                            if haskey(response["params"]["data"], "bids")
                                for bids in response["params"]["data"]["bids"]
                                    if bids[1] == "new"
                                        insert!(futures_orderbooks[instrument_name]["bids"], -bids[2], bids[3])
                                    elseif bids[1] == "edit"
                                        insert!(futures_orderbooks[instrument_name]["bids"], -bids[2], bids[3])
                                    elseif bids[1] == "delete"
                                        if bids[2] * -1.0 in futures_orderbooks[instrument_name]["bids"]
                                            delete!(futures_orderbooks[instrument_name]["bids"], -1.0 * bids[2])
                                        end
                                    end
                                end
                            end
                            if haskey(response["params"]["data"], "asks")
                                for asks in response["params"]["data"]["asks"]
                                    if asks[1] == "new"
                                        insert!(futures_orderbooks[instrument_name]["asks"], asks[2] * 1.0, asks[3] * 1.0)
                                    elseif asks[1] == "edit"
                                        insert!(futures_orderbooks[instrument_name]["asks"], asks[2] * 1.0, asks[3] * 1.0)
                                    elseif asks[1] == "delete"
                                        if asks[2] * 1.0 in futures_orderbooks[instrument_name]["asks"]
                                            delete!(futures_orderbooks[instrument_name]["asks"], asks[2] * 1.0)
                                        end
                                    end
                                end
                            end
                        end
                    elseif occursin(r"book\.[A-Z]{3}-[0-9]{1,2}[A-Z]{3}[0-9]{2}\.", response["params"]["channel"])
                        instrument_name = response["params"]["data"]["instrument_name"]

                        # Underlying future orderbook
                        if response["params"]["data"]["type"] == "snapshot"
                            if haskey(response["params"]["data"], "bids")
                                for bids in response["params"]["data"]["bids"]
                                    if bids[1] == "new"
                                        insert!(futures_orderbooks[instrument_name]["bids"], -bids[2] * 1.0, bids[3] * 1.0)
                                    end
                                end
                            end
                            if haskey(response["params"]["data"], "asks")
                                for asks in response["params"]["data"]["asks"]
                                    if asks[1] == "new"
                                        insert!(futures_orderbooks[instrument_name]["asks"], asks[2] * 1.0, asks[3] * 1.0)
                                    end
                                end
                            end
                        else
                            if haskey(response["params"]["data"], "bids")
                                for bids in response["params"]["data"]["bids"]
                                    if bids[1] == "new"
                                        insert!(futures_orderbooks[instrument_name]["bids"], -bids[2] * 1.0, bids[3] * 1.0)
                                    elseif bids[1] == "edit"
                                        insert!(futures_orderbooks[instrument_name]["bids"], -bids[2] * 1.0, bids[3] * 1.0)
                                    elseif bids[1] == "delete"
                                        if bids[2] * -1.0 in futures_orderbooks[instrument_name]["bids"]
                                            delete!(futures_orderbooks[instrument_name]["bids"], -bids[2] * 1.0)
                                        end
                                    end
                                end
                            end
                            if haskey(response["params"]["data"], "asks")
                                for asks in response["params"]["data"]["asks"]
                                    if asks[1] == "new"
                                        insert!(futures_orderbooks[instrument_name]["asks"], asks[2] * 1.0, asks[3] * 1.0)
                                    elseif asks[1] == "edit"
                                        insert!(futures_orderbooks[instrument_name]["asks"], asks[2] * 1.0, asks[3] * 1.0)
                                    elseif asks[1] == "delete"
                                        if asks[2] * 1.0 in futures_orderbooks[instrument_name]["asks"]
                                            delete!(futures_orderbooks[instrument_name]["asks"], asks[2] * 1.0)
                                        end
                                    end
                                end
                            end
                        end
                    elseif occursin(r"trades\.[A-Z]{3}-PERPETUAL", response["params"]["channel"])
                        tmp_events = response["params"]["data"]
                        count = 1       

                        for trade_element in response["params"]["data"]
                            if count > MAX_TRACKED_FUTURE_TRADES
                                break
                            end

                            instrument_name = trade_element["instrument_name"]

                            if length(futures_orderbooks[instrument_name]["last_traded_price"]) < MAX_TRACKED_FUTURE_TRADES
                                push!(futures_orderbooks[instrument_name]["last_traded_price"], trade_element["price"])
                                push!(futures_orderbooks[instrument_name]["last_traded_size"], trade_element["amount"])
                                push!(futures_orderbooks[instrument_name]["last_traded_timestamp"], trade_element["timestamp"])
                            else
                                futures_orderbooks[instrument_name]["last_traded_price"][1:MAX_TRACKED_FUTURE_TRADES-1] = futures_orderbooks[instrument_name]["last_traded_price"][2:end]
                                futures_orderbooks[instrument_name]["last_traded_price"][MAX_TRACKED_FUTURE_TRADES] = trade_element["price"]

                                futures_orderbooks[instrument_name]["last_traded_size"][1:MAX_TRACKED_FUTURE_TRADES-1] = futures_orderbooks[instrument_name]["last_traded_size"][2:end]
                                futures_orderbooks[instrument_name]["last_traded_size"][MAX_TRACKED_FUTURE_TRADES] = trade_element["amount"]

                                futures_orderbooks[instrument_name]["last_traded_timestamp"][1:MAX_TRACKED_FUTURE_TRADES-1] = futures_orderbooks[instrument_name]["last_traded_timestamp"][2:end]
                                futures_orderbooks[instrument_name]["last_traded_timestamp"][MAX_TRACKED_FUTURE_TRADES] = trade_element["timestamp"]
                            end
                        end
                    elseif occursin(r"trades\.[A-Z]{3}-[0-9]{1,2}[A-Z]{3}[0-9]{2}", response["params"]["channel"])
                        tmp_events = response["params"]["data"]
                        count = 1       

                        for trade_element in response["params"]["data"]
                            if count > MAX_TRACKED_FUTURE_TRADES
                                break
                            end

                            instrument_name = trade_element["instrument_name"]

                            if length(futures_orderbooks[instrument_name]["last_traded_price"]) < MAX_TRACKED_FUTURE_TRADES
                                push!(futures_orderbooks[instrument_name]["last_traded_price"], trade_element["price"])
                                push!(futures_orderbooks[instrument_name]["last_traded_size"], trade_element["amount"])
                                push!(futures_orderbooks[instrument_name]["last_traded_timestamp"], trade_element["timestamp"])
                                
                            else
                                futures_orderbooks[instrument_name]["last_traded_price"][1:MAX_TRACKED_FUTURE_TRADES-1] = futures_orderbooks[instrument_name]["last_traded_price"][2:end]
                                futures_orderbooks[instrument_name]["last_traded_price"][MAX_TRACKED_FUTURE_TRADES] = trade_element["price"]

                                futures_orderbooks[instrument_name]["last_traded_size"][1:MAX_TRACKED_FUTURE_TRADES-1] = futures_orderbooks[instrument_name]["last_traded_size"][2:end]
                                futures_orderbooks[instrument_name]["last_traded_size"][MAX_TRACKED_FUTURE_TRADES] = trade_element["amount"]

                                futures_orderbooks[instrument_name]["last_traded_timestamp"][1:MAX_TRACKED_FUTURE_TRADES-1] = futures_orderbooks[instrument_name]["last_traded_timestamp"][2:end]
                                futures_orderbooks[instrument_name]["last_traded_timestamp"][MAX_TRACKED_FUTURE_TRADES] = trade_element["timestamp"]
                            end
                        end

                        for trade_element in response["params"]["data"]
                            instrument_name = trade_element["instrument_name"]

                            if length(futures_orderbooks[instrument_name]["last_traded_price"]) < MAX_TRACKED_FUTURE_TRADES
                                push!(futures_orderbooks[instrument_name]["last_traded_price"], trade_element["price"])
                                push!(futures_orderbooks[instrument_name]["last_traded_size"], trade_element["amount"])
                                push!(futures_orderbooks[instrument_name]["last_traded_timestamp"], trade_element["timestamp"])
                            else
                                futures_orderbooks[instrument_name]["last_traded_price"][1:MAX_TRACKED_FUTURE_TRADES-1] = futures_orderbooks[instrument_name]["last_traded_price"][2:end]
                                futures_orderbooks[instrument_name]["last_traded_price"][MAX_TRACKED_FUTURE_TRADES] = trade_element["price"]

                                futures_orderbooks[instrument_name]["last_traded_size"][1:MAX_TRACKED_FUTURE_TRADES-1] = futures_orderbooks[instrument_name]["last_traded_size"][2:end]
                                futures_orderbooks[instrument_name]["last_traded_size"][MAX_TRACKED_FUTURE_TRADES] = trade_element["amount"]

                                futures_orderbooks[instrument_name]["last_traded_timestamp"][1:MAX_TRACKED_FUTURE_TRADES-1] = futures_orderbooks[instrument_name]["last_traded_timestamp"][2:end]
                                futures_orderbooks[instrument_name]["last_traded_timestamp"][MAX_TRACKED_FUTURE_TRADES] = trade_element["timestamp"]
                            end
                        end
                    end
                end
            end
        elseif response["method"] == "subscriptions"
            if haskey(response, "params")
                if haskey(response["params"], "events")
                    for event in response["params"]["events"]
                        if occursin(r"book\.[A-Z]{3}-[0-9]{1,2}[A-Z]{3}[0-9]{2}-[0-9]{1,5}-[CP]\.", event[1])
                            instrument_name = event[2]["instrument_name"]
                            if event[2]["type"] == "change"
                                if haskey(event[2], "bids")
                                    for bids in event[2]["bids"]
                                        if bids[1] == "new"
                                            insert!(options_orderbooks[instrument_name]["bids"], -bids[2] * 1.0, bids[3] * 1.0)
                                        elseif bids[1] == "edit"
                                            insert!(options_orderbooks[instrument_name]["bids"], -bids[2] * 1.0, bids[3] * 1.0)
                                        elseif bids[1] == "delete"
                                            if bids[2] * -1.0 in options_orderbooks[instrument_name]["bids"]
                                                delete!(options_orderbooks[instrument_name]["bids"], -bids[2] * 1.0)
                                            end
                                        end
                                    end
                                end
                                if haskey(event[2], "asks")
                                    for asks in event[2]["asks"]
                                        if asks[1] == "new"
                                            insert!(options_orderbooks[instrument_name]["asks"], asks[2] * 1.0, asks[3] * 1.0)
                                        elseif asks[1] == "edit"
                                            insert!(options_orderbooks[instrument_name]["asks"], asks[2] * 1.0, asks[3] * 1.0)
                                        elseif asks[1] == "delete"
                                            if asks[2] * 1.0 in options_orderbooks[instrument_name]["asks"]
                                                delete!(options_orderbooks[instrument_name]["asks"], asks[2] * 1.0)
                                            end
                                        end
                                    end
                                end
                            end
                        elseif occursin(r"book\.[A-Z]{3}-PERPETUAL\.", event[1])
                            instrument_name = event[2]["instrument_name"]
                            if event[2]["type"] == "change"
                                if haskey(event[2], "bids")
                                    for bids in event[2]["bids"]
                                        if bids[1] == "new"
                                            insert!(futures_orderbooks[instrument_name]["bids"], -bids[2] * 1.0, bids[3] * 1.0)
                                        elseif bids[1] == "edit"
                                            insert!(futures_orderbooks[instrument_name]["bids"], -bids[2] * 1.0, bids[3] * 1.0)
                                        elseif bids[1] == "delete"
                                            if bids[2] * -1.0 in futures_orderbooks[instrument_name]["bids"]
                                                delete!(futures_orderbooks[instrument_name]["bids"], -bids[2] * 1.0)
                                            end
                                        end
                                    end
                                end
                                if haskey(event[2], "asks")
                                    for asks in event[2]["asks"]
                                        if asks[1] == "new"
                                            insert!(futures_orderbooks[instrument_name]["asks"], asks[2] * 1.0, asks[3] * 1.0)
                                        elseif asks[1] == "edit"
                                            insert!(futures_orderbooks[instrument_name]["asks"], asks[2] * 1.0, asks[3] * 1.0)
                                        elseif asks[1] == "delete"
                                            if asks[2] * 1.0 in futures_orderbooks[instrument_name]["asks"]
                                                delete!(futures_orderbooks[instrument_name]["asks"], asks[2] * 1.0)
                                            end
                                        end
                                    end
                                end
                            end
                        elseif occursin(r"book\.[A-Z]{3}-[0-9]{1,2}[A-Z]{3}[0-9]{2}\.", event[1])
                            instrument_name = event[2]["instrument_name"]
        
                            if event[2]["type"] == "change"
                                if haskey(event[2], "bids")
                                    for bids in event[2]["bids"]
                                        if bids[1] == "new"
                                            insert!(futures_orderbooks[instrument_name]["bids"], -bids[2] * 1.0, bids[3] * 1.0)
                                        elseif bids[1] == "edit"
                                            insert!(futures_orderbooks[instrument_name]["bids"], -bids[2] * 1.0, bids[3] * 1.0)
                                        elseif bids[1] == "delete"
                                            if bids[2] * -1.0 in futures_orderbooks[instrument_name]["bids"]
                                                delete!(futures_orderbooks[instrument_name]["bids"], -bids[2] * 1.0)
                                            end
                                        end
                                    end
                                end
                                if haskey(event[2], "asks")
                                    for asks in event[2]["asks"]
                                        if asks[1] == "new"
                                            insert!(futures_orderbooks[instrument_name]["asks"], asks[2] * 1.0, asks[3] * 1.0)
                                        elseif asks[1] == "edit"
                                            insert!(futures_orderbooks[instrument_name]["asks"], asks[2] * 1.0, asks[3] * 1.0)
                                        elseif asks[1] == "delete"
                                            if asks[2] * 1.0 in futures_orderbooks[instrument_name]["asks"]
                                                delete!(futures_orderbooks[instrument_name]["asks"], asks[2] * 1.0)
                                            end
                                        end
                                    end
                                end
                            end
                        elseif occursin(r"trades\.[A-Z]{3}-PERPETUAL", event[1])
                            tmp_events = reverse(event[2])
                            count = 1

                            for event in tmp_events
                                if count > MAX_TRACKED_FUTURE_TRADES
                                    break
                                end

                                instrument_name = event["instrument_name"]
        
                                if length(futures_orderbooks[instrument_name]["last_traded_price"]) < MAX_TRACKED_FUTURE_TRADES
                                    push!(futures_orderbooks[instrument_name]["last_traded_price"], event["price"])
                                    push!(futures_orderbooks[instrument_name]["last_traded_size"], event["amount"])
                                    push!(futures_orderbooks[instrument_name]["last_traded_timestamp"], event["timestamp"])
                                else
                                    futures_orderbooks[instrument_name]["last_traded_price"][1:MAX_TRACKED_FUTURE_TRADES-1] = futures_orderbooks[instrument_name]["last_traded_price"][2:end]
                                    futures_orderbooks[instrument_name]["last_traded_price"][MAX_TRACKED_FUTURE_TRADES] = event["price"]
        
                                    futures_orderbooks[instrument_name]["last_traded_size"][1:MAX_TRACKED_FUTURE_TRADES-1] = futures_orderbooks[instrument_name]["last_traded_size"][2:end]
                                    futures_orderbooks[instrument_name]["last_traded_size"][MAX_TRACKED_FUTURE_TRADES] = event["amount"]

                                    futures_orderbooks[instrument_name]["last_traded_timestamp"][1:MAX_TRACKED_FUTURE_TRADES-1] = futures_orderbooks[instrument_name]["last_traded_timestamp"][2:end]
                                    futures_orderbooks[instrument_name]["last_traded_timestamp"][MAX_TRACKED_FUTURE_TRADES] = event["timestamp"]
                                end
        
                                count = count + 1
                            end
                        elseif occursin(r"trades\.[A-Z]{3}-[0-9]{1,2}[A-Z]{3}[0-9]{2}", event[1])
                            tmp_events = reverse(event[2])
                            count = 1       
                            
                            for event in tmp_events
                                if count > MAX_TRACKED_FUTURE_TRADES
                                    break
                                end

                                instrument_name = event["instrument_name"]
        
                                if length(futures_orderbooks[instrument_name]["last_traded_price"]) < MAX_TRACKED_FUTURE_TRADES
                                    push!(futures_orderbooks[instrument_name]["last_traded_price"], event["price"])
                                    push!(futures_orderbooks[instrument_name]["last_traded_size"], event["amount"])
                                    push!(futures_orderbooks[instrument_name]["last_traded_timestamp"], event["timestamp"])
                                else
                                    futures_orderbooks[instrument_name]["last_traded_price"][1:MAX_TRACKED_FUTURE_TRADES-1] = futures_orderbooks[instrument_name]["last_traded_price"][2:end]
                                    futures_orderbooks[instrument_name]["last_traded_price"][MAX_TRACKED_FUTURE_TRADES] = event["price"]
        
                                    futures_orderbooks[instrument_name]["last_traded_size"][1:MAX_TRACKED_FUTURE_TRADES-1] = futures_orderbooks[instrument_name]["last_traded_size"][2:end]
                                    futures_orderbooks[instrument_name]["last_traded_size"][MAX_TRACKED_FUTURE_TRADES] = event["amount"]

                                    futures_orderbooks[instrument_name]["last_traded_timestamp"][1:MAX_TRACKED_FUTURE_TRADES-1] = futures_orderbooks[instrument_name]["last_traded_timestamp"][2:end]
                                    futures_orderbooks[instrument_name]["last_traded_timestamp"][MAX_TRACKED_FUTURE_TRADES] = event["timestamp"]
                                end
        
                                count = count + 1
                            end
                        end
                    end

                end
            end
        end
    end
end

end