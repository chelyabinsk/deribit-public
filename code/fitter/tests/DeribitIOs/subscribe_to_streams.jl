using JSON, HTTP

current_subscriptions = []
instrument_map = Dict()
expirations_map = Dict()
new_subscriptions = []
removed_subscriptions = []

#########
@info "DeribitIOs.subscribe_to_streams -- test Deribit's public/subscribe method"
function _test()
    verbose = true
    DeribitIOs.update_instrument_maps!(Parameters.CURRENCY, current_subscriptions, instrument_map, expirations_map, new_subscriptions, removed_subscriptions, true)

    valid_number_of_subscriptions = false

    HTTP.WebSockets.open(Parameters.URI; verbose, suppress_close_error=true) do ws
        DeribitIOs.authenticate(ws, Parameters.CLIENT_ID, Parameters.CLIENT_SECRET, true)
        DeribitIOs.update_futures_orderbook_keys!(expirations_map, instrument_map, futures_orderbooks, Parameters.CURRENCY, Parameters.FUTURES_ORDERBOOK_DEPTH, true)
        DeribitIOs.subscribe_to_streams(ws, new_subscriptions, true)

        
        for msg in ws
            response_json = JSON.parse(msg)

            # Parse response message
            if haskey(response_json, "method")
                if response_json["method"] in ["subscription", "subscriptions"]
                    DeribitIOs.parse_subscriptions!(response_json, futures_orderbooks, Parameters.FUTURES_ORDERBOOK_DEPTH, options_orderbooks)
                elseif response_json["method"] == "heartbeat"
                    # println(response_json)
                end
            else
                # println(response_json)
            end

            if haskey(response_json, "id")
                if response_json["id"] == "streaming_subcription"
                    # println(response_json)
                    if ! haskey(response_json, "error")
                        # Check the length
                        valid_number_of_subscriptions = length(response_json["result"]) == length(new_subscriptions)
                        break
                    end
                end
            end
        end
    end

    return valid_number_of_subscriptions
end

@test _test() == true
#########




#########