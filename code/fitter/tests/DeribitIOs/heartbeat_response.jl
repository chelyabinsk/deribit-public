using JSON, HTTP

#########
@info "DeribitIOs.heartbeat_response -- test Deribit's heartbeat challenge"
function _test()
    verbose = true

    heartbeat_count = 0
    success = false

    HTTP.WebSockets.open(Parameters.URI; verbose, suppress_close_error=true) do ws
        DeribitIOs.authenticate(ws, Parameters.CLIENT_ID, Parameters.CLIENT_SECRET, true)
        
        for msg in ws
            response_json = JSON.parse(msg)

            if haskey(response_json, "params")
                if haskey(response_json["params"], "type")
                    if response_json["params"]["type"] == "heartbeat"
                        # println(response_json)
                    elseif response_json["params"]["type"] == "test_request"
                        # Respond to heartbeat challenge
                        DeribitIOs.heartbeat_response(ws, true)
                        heartbeat_count += 1
                    end
                end
            end

            if haskey(response_json, "id")
                if response_json["id"] == "heartbeat_challenge"
                    if (heartbeat_count > 0) & (haskey(response_json, "result") )
                        if haskey(response_json["result"], "version")
                            success = true
                            break
                        end
                    end
                end
            end
        end
    end

    return success
end

@test _test() == true
#########




#########