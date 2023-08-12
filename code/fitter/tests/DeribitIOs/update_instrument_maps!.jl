using HTTP, Dates, JSON3

#########
@info "DeribitIOs.update_instrument_maps! -- initialised test connection BTC"

CURRENCY = "BTC"
current_subscriptions = ["expired_instrument_1", "expired_instrument_2"]
instrument_map = Dict()
expirations_map = Dict()
new_subscriptions = []
removed_subscriptions = []
MIN_FITTING_TTM = 1

@test DeribitIOs.update_instrument_maps!(CURRENCY, current_subscriptions, instrument_map, expirations_map, new_subscriptions, removed_subscriptions, MIN_FITTING_TTM, true) == true
#########




#########
@info "DeribitIOs.update_instrument_maps! -- initialised check PERPETUAL presence"
@test haskey(instrument_map, CURRENCY * "-PERPETUAL") == true
#########




#########
@info "DeribitIOs.update_instrument_maps! -- initialised check current_subscriptions did not change"
@test current_subscriptions == ["expired_instrument_1", "expired_instrument_2"]
#########




#########
@info "DeribitIOs.update_instrument_maps! -- initialised check removed_subscriptions is updated"
@test removed_subscriptions == ["expired_instrument_1", "expired_instrument_2"]
#########




#########
@info "DeribitIOs.update_instrument_maps! -- initialised check new_subscriptions is not empty"
@test length(new_subscriptions) > 0
#########




#########
@info "DeribitIOs.update_instrument_maps! -- initialised check expirations_map is not empty"
@test length(expirations_map) > 0
#########




#########
@info "DeribitIOs.update_instrument_maps! -- initialised check that only valid currency is selected"
function _test()
    all_valid_currencies = true
    for instrument_name in keys(instrument_map)
        if instrument_map[instrument_name]["base_currency"] != CURRENCY
            all_valid_currencies = false
        end
    end
    return all_valid_currencies
end
@test _test() == true
#########




#########
@info "DeribitIOs.update_instrument_maps! -- initialised check that options and futures are present"
function _test()
    options_count = 0
    futures_count = 0
    for instrument_name in keys(instrument_map)
        if instrument_map[instrument_name]["kind"] == "option"
            options_count += 1
        end
        if instrument_map[instrument_name]["kind"] == "future"
            futures_count += 1
        end
    end

    return (options_count > 0) & (futures_count > 0)
end
@test _test() == true
#########




#########
@info "DeribitIOs.update_instrument_maps! -- check that no duplicates in new_subscriptions"
@test length(new_subscriptions) == length(unique(new_subscriptions))
#########




#########
@info "DeribitIOs.update_instrument_maps! -- check that expirations_map has more than 0 strikes for each expiration"
function _test()
    success = true
    for expiration_str in keys(expirations_map)
        if length(expirations_map[expiration_str]["strike"]) == 0
            success = false
            break
        end
    end

    return success
end
@test _test() == true
#########




#########
@info "DeribitIOs.update_instrument_maps! -- check that expirations_map strikes and strikes_count align"
function _test()
    success = true
    for expiration_str in keys(expirations_map)
        if length(expirations_map[expiration_str]["strike"]) != expirations_map[expiration_str]["strikes_count"]
            success = false
            break
        end
    end

    return success
end
@test _test() == true
#########




#########
@info "DeribitIOs.update_instrument_maps! -- check that expirations_map instruments is of length of strikes (call and put)"
function _test()
    success = true
    for expiration_str in keys(expirations_map)
        if length(expirations_map[expiration_str]["strike"]) != length(expirations_map[expiration_str]["call_instruments"])
            success = false
            break
        end

        if length(expirations_map[expiration_str]["strike"]) != length(expirations_map[expiration_str]["put_instruments"])
            success = false
            break
        end
    end

    return success
end
@test _test() == true
#########




#########
@info "DeribitIOs.update_instrument_maps! -- check that expirations_map call_instruments and put_instruments have no duplicates"
function _test()
    success = true
    for expiration_str in keys(expirations_map)
        if length(expirations_map[expiration_str]["call_instruments"]) != length(unique(expirations_map[expiration_str]["call_instruments"]))
            success = false
            break
        end
        if length(expirations_map[expiration_str]["put_instruments"]) != length(unique(expirations_map[expiration_str]["put_instruments"]))
            success = false
            break
        end
    end

    return success
end
@test _test() == true
#########




#########
@info "DeribitIOs.update_instrument_maps! -- check that no expiration_timestamps are closer than MIN_FITTING_TTM"
function _test()
    current_time = time()
    success = true
    for expiration_str in keys(expirations_map)
        if expirations_map[expiration_str]["expiration_timestamp"] / 1000 - current_time < MIN_FITTING_TTM
            success = false
            break
        end
    end
    return success
end
@test _test() == true
#########




#########
@info "DeribitIOs.update_instrument_maps! -- [TODO] check TTM index"

#########