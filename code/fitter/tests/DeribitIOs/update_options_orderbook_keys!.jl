import AVLTrees as avl;

FUTURES_ORDERBOOK_DEPTH = 5
current_subscriptions = []
instrument_map = Dict()
expirations_map = Dict()
new_subscriptions = []
removed_subscriptions = []

options_orderbooks = Dict()

DeribitIOs.update_instrument_maps!(Parameters.CURRENCY, current_subscriptions, instrument_map, expirations_map, new_subscriptions, removed_subscriptions, true)

#########
old_instrument_map = Dict(instrument_map)
DeribitIOs.update_options_orderbook_keys!(instrument_map, options_orderbooks, true)

@info "DeribitIOs.update_options_orderbook_keys! -- instrument_map does not change"
@test instrument_map == old_instrument_map
#########




#########
@info "DeribitIOs.update_options_orderbook_keys! -- check that each key is in expected format"
# println(options_orderbooks)
#########