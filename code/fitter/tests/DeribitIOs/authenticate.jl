using JSON, HTTP

#########
@info "DeribitIOs.authenticate -- test Deribit's authentication methods"
function _test()
    verbose = true
    authenticated = false
    said_hello = false
    set_heartbeat = false

    HTTP.WebSockets.open(Parameters.URI; verbose, suppress_close_error=true) do ws
        DeribitIOs.authenticate(ws, Parameters.CLIENT_ID, Parameters.CLIENT_SECRET, true)
        
        for msg in ws
            response_json = JSON.parse(msg)

            if haskey(response_json, "id")
                if response_json["id"] == "authentication"
                    if haskey(response_json, "result")
                        if haskey(response_json["result"], "expires_in")
                            authenticated = true
                        end
                    end
                end

                if response_json["id"] == "hello"
                    if haskey(response_json, "result")
                        if haskey(response_json["result"], "version")
                            said_hello = true
                        end
                    end
                end

                if response_json["id"] == "set_heartbeat"
                    if haskey(response_json, "result")
                        if response_json["result"] == "ok"
                            set_heartbeat = true
                        end
                    end
                end
            end

            if ( authenticated & said_hello & set_heartbeat)
                break
            end
        end
    end

    return ( authenticated & said_hello & set_heartbeat)
end

@test _test() == true
#########




#########