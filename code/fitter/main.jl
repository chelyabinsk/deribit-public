include("fitter_loop.jl")
include("order_loop.jl")

futures_orderbooks = Dict()
options_orderbooks = Dict()

instrument_map = Dict()
expirations_map = Dict()
new_subscriptions = []
removed_subscriptions = []
current_subscriptions = []  # Track current subscription to deribit instruments
sub_fitter_expiration_info = Dict() # Information about underlying line fitters
surface_fitter_info = Dict()  ## Dictionary with surface fitter info, such as ivs

FitterMethods.main(futures_orderbooks, options_orderbooks, instrument_map, expirations_map, new_subscriptions, removed_subscriptions, current_subscriptions, sub_fitter_expiration_info, surface_fitter_info)
# OrderMethods.main()
