module FitterMethods
using JSON, HTTP

include("parameters.jl")  ## Parameters
include("deribit_io/deribit_io.jl")  ## DeribitIOs
include("misc/general.jl") ## Helpers
include("misc/RedisIOs.jl") ## RedisIOs

redis_connections = RedisIOs.create_redis_connection(Parameters.LOCAL_REDIS_HOST, Parameters.LOCAL_REDIS_PORT, Parameters.LOCAL_REDIS_PASSWORD)

verbose = false

function main(futures_orderbooks, options_orderbooks, instrument_map, expirations_map, new_subscriptions, removed_subscriptions, current_subscriptions, sub_fitter_expiration_info, surface_fitter_info)
    DeribitIOs.update_instrument_maps!(Parameters.CURRENCY, current_subscriptions, instrument_map, expirations_map, new_subscriptions, removed_subscriptions, Parameters.MIN_FITTING_TTM, true)

    HTTP.WebSockets.open(Parameters.URI; verbose, suppress_close_error=false) do ws
        DeribitIOs.authenticate(ws, Parameters.CLIENT_ID, Parameters.CLIENT_SECRET, true)
        DeribitIOs.update_futures_orderbook_keys!(expirations_map, instrument_map, futures_orderbooks, Parameters.CURRENCY, Parameters.FUTURES_CALC_DEPTH, true)
        DeribitIOs.update_options_orderbook_keys!(instrument_map, options_orderbooks, true)
        Helpers.initialize_surface_fitter_info!(surface_fitter_info, expirations_map, Parameters.NS_FITTING_GRID_RESOLUTION, true)
        DeribitIOs.update_sub_fitter_expirations!(sub_fitter_expiration_info, expirations_map, true)
        DeribitIOs.subscribe_to_streams(ws, new_subscriptions, true)

        RedisIOs.export_mapping_details(redis_connections[2], expirations_map, instrument_map)

        last_redis_export_time = 0.0
        redis_export_interval = 1

        for msg in ws
            response_json = JSON.parse(msg)

            # Parse response message
            if haskey(response_json, "method")
                if response_json["method"] in ["subscription", "subscriptions"]
                    DeribitIOs.parse_subscriptions!(response_json, futures_orderbooks, Parameters.MAX_TRACKED_FUTURE_TRADES, options_orderbooks)
                elseif response_json["method"] == "heartbeat"
                    # println(response_json)
                end
            else
                # println(response_json)
            end

            if haskey(response_json, "params")
                if haskey(response_json["params"], "type")
                    if response_json["params"]["type"] == "heartbeat"
                        # println(response_json)
                    elseif response_json["params"]["type"] == "test_request"
                        # Respond to heartbeat challenge
                        DeribitIOs.heartbeat_response(ws, true)
                    end
                end
            end
            
            # t0 = time()
            current_time = time()
            Helpers.compute_futures_prices!(futures_orderbooks, Parameters.FUTURES_CALC_DEPTH, Parameters.FUTURES_ORDERBOOK_DEPTH)
            Helpers.compute_option_top_orderbook!(options_orderbooks)
            Helpers.compute_ivs!(expirations_map, options_orderbooks, futures_orderbooks, sub_fitter_expiration_info, current_time)
            Helpers.compute_normalized_strikes!(sub_fitter_expiration_info, futures_orderbooks, options_orderbooks, expirations_map, current_time)
            Helpers.compute_fitting_points!(sub_fitter_expiration_info, options_orderbooks, expirations_map, futures_orderbooks, current_time, Parameters.FITTING_POINT_WINGS_DELTA_OFFSET)
            # Helpers.compute_delta_strikes!(sub_fitter_expiration_info, expirations_map, futures_orderbooks, Parameters.NS_FITTING_GRID_RESOLUTION, current_time)
            # Helpers.update_surface_fitter_info!(surface_fitter_info, sub_fitter_expiration_info, Parameters.NS_FITTING_GRID_RESOLUTION, Parameters.SPLINE_EXPONENT_TTM, Parameters.SPLINE_EXPONENT_NSTRIKE, Parameters.KNOT_COUNT_NSTRIKE)
            Helpers.copy_fair_iv_from_fitting_point!(sub_fitter_expiration_info)
            Helpers.compute_prices!(sub_fitter_expiration_info, futures_orderbooks, options_orderbooks, expirations_map, instrument_map, Parameters.DIMINING_N_STRIKE_THREASHOLD, Parameters.PRICING_MAX_MULTIPLIER)
            Helpers.compute_greeks!(sub_fitter_expiration_info, expirations_map, futures_orderbooks)
            
            # t1 = time()
            # println(t1 - t0)

            # Remove own quotes (todo)

            if current_time - last_redis_export_time > redis_export_interval
                last_redis_export_time = current_time
                RedisIOs.export_surface_fitter_info(redis_connections[2], futures_orderbooks, options_orderbooks, sub_fitter_expiration_info)
            end
        end
    end
end

end