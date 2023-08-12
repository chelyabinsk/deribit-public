module OrderMethods
using JSON, HTTP

include("parameters.jl")  ## Parameters
include("deribit_io/deribit_io.jl")  ## DeribitIOs

verbose = false

function main()
    HTTP.WebSockets.open(Parameters.ORDER_URI; verbose, suppress_close_error=false) do ws
        DeribitIOs.authenticate(ws, Parameters.ORDER_CLIENT_ID, Parameters.ORDER_CLIENT_SECRET, true)

        for msg in ws
            response_json = JSON.parse(msg)
            
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
        end
    end
end

end