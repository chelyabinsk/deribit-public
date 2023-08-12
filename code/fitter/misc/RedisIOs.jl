module RedisIOs

using Redis;
using JSON;


function create_redis_connection(HOST, PORT, PASSWORD)
    local_redis_connection = Redis.RedisConnection(host = HOST, port = PORT, password = PASSWORD)
    local_redis_pipeline = Redis.open_pipeline(local_redis_connection);

    return [local_redis_connection, local_redis_pipeline]
end

function test_connection(HOST, PORT, PASSWORD)::Bool
    @info "trying Redis connection to $HOST:$PORT with a password"

    try
        conn = RedisConnection(host = HOST, port = PORT, password = PASSWORD)
    catch e
        @error e
        return false
    end
    conn = RedisConnection(host = HOST, port = PORT, password = PASSWORD)

    @info "trying to ping Redis server at $HOST:$PORT"

    try
        if ping(conn) == "PONG"
            @info "PING - PONG : Success!"
            return true
        else
            @info "PING - PONG : Fail!"
            return false
        end
    catch e
        @info "PING - PONG : Fail!"
        @error e
        return false
    end
end

function export_mapping_details(redis_connection, expirations_map, instrument_map)
    set(redis_connection, "__expirations_map", JSON.json(expirations_map))
    set(redis_connection, "__instrument_map", JSON.json(instrument_map))
end

function export_surface_fitter_info(redis_connection, futures_orderbooks, options_orderbooks, sub_fitter_expiration_info)
    output = Dict(
        "futures_orderbooks" => Dict(),
        "options_orderbooks" => Dict(),
        "sub_fitter_expiration_info" => Dict(),
        "last_update_timestamp" => round(Int64,time())
    )

    for future_expiration_str in keys(futures_orderbooks)
        output["futures_orderbooks"][future_expiration_str] = Dict(
            "last_traded_price" => futures_orderbooks[future_expiration_str]["last_traded_price"],
            "last_traded_size" => futures_orderbooks[future_expiration_str]["last_traded_size"],
            "last_traded_timestamp" => futures_orderbooks[future_expiration_str]["last_traded_timestamp"],
            "bid_price" => futures_orderbooks[future_expiration_str]["bid_price"],
            "ask_price" => futures_orderbooks[future_expiration_str]["ask_price"],
            "bid_size" => futures_orderbooks[future_expiration_str]["bid_size"],
            "ask_size" => futures_orderbooks[future_expiration_str]["ask_size"],
            "computed_price" => futures_orderbooks[future_expiration_str]["computed_price"],
        )
    end

    for option_instrument_str in keys(options_orderbooks)
        output["options_orderbooks"][option_instrument_str] = Dict(
            "top_bid_price" => options_orderbooks[option_instrument_str]["top_bid_price"],
            "top_ask_price" => options_orderbooks[option_instrument_str]["top_ask_price"],
            "top_bid_size" => options_orderbooks[option_instrument_str]["top_bid_size"],
            "top_ask_size" => options_orderbooks[option_instrument_str]["top_ask_size"],
            "top_bid_iv" => options_orderbooks[option_instrument_str]["top_bid_iv"],
            "top_ask_iv" => options_orderbooks[option_instrument_str]["top_ask_iv"],
            "fitting_bid_price" => options_orderbooks[option_instrument_str]["fitting_bid_price"],
            "fitting_ask_price" => options_orderbooks[option_instrument_str]["fitting_ask_price"],
            "fitting_weighted_price" => options_orderbooks[option_instrument_str]["fitting_weighted_price"],
            "fitting_weighted_iv" => options_orderbooks[option_instrument_str]["fitting_weighted_iv"],
        )
    end

    for sub_fitter_str in keys(sub_fitter_expiration_info)
        output["sub_fitter_expiration_info"][sub_fitter_str] = Dict(
            "strike" => sub_fitter_expiration_info[sub_fitter_str]["strike"],
            "ns_strike" => sub_fitter_expiration_info[sub_fitter_str]["ns_strike"],
            "fitting_strike" => sub_fitter_expiration_info[sub_fitter_str]["fitting_strike"],
            "fitting_point" => sub_fitter_expiration_info[sub_fitter_str]["fitting_point"],
            "fitting_count" => sub_fitter_expiration_info[sub_fitter_str]["fitting_count"],
            "atm_index" => sub_fitter_expiration_info[sub_fitter_str]["atm_index"],
            "fair_iv" => sub_fitter_expiration_info[sub_fitter_str]["fair_iv"],
            "ttm" => sub_fitter_expiration_info[sub_fitter_str]["ttm"],
            "call_fair_price" => sub_fitter_expiration_info[sub_fitter_str]["call_fair_price"],
            "put_fair_price" => sub_fitter_expiration_info[sub_fitter_str]["put_fair_price"],
            "own_call_bid" => sub_fitter_expiration_info[sub_fitter_str]["own_call_bid"],
            "own_call_ask" => sub_fitter_expiration_info[sub_fitter_str]["own_call_ask"],
            "own_put_bid" => sub_fitter_expiration_info[sub_fitter_str]["own_put_bid"],
            "own_put_ask" => sub_fitter_expiration_info[sub_fitter_str]["own_put_ask"],
            
            "market_bid_iv" => sub_fitter_expiration_info[sub_fitter_str]["market_bid_iv"],
            "market_ask_iv" => sub_fitter_expiration_info[sub_fitter_str]["market_ask_iv"],
            
            "delta_call" => sub_fitter_expiration_info[sub_fitter_str]["delta_call"],
            "delta_put" => sub_fitter_expiration_info[sub_fitter_str]["delta_put"],
            "gamma" => sub_fitter_expiration_info[sub_fitter_str]["gamma"],
            "vega" => sub_fitter_expiration_info[sub_fitter_str]["vega"],
            "theta" => sub_fitter_expiration_info[sub_fitter_str]["theta"],
            "vanna" => sub_fitter_expiration_info[sub_fitter_str]["vanna"],
            "volga" => sub_fitter_expiration_info[sub_fitter_str]["volga"],
            "total_delta_call" => sub_fitter_expiration_info[sub_fitter_str]["total_delta_call"],
            "total_delta_put" => sub_fitter_expiration_info[sub_fitter_str]["total_delta_put"],
        )
    end

    set(redis_connection, "__surface_fitter", JSON.json(output))
end

end