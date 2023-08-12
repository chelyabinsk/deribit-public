module Helpers
using Dierckx
using Dates
# using Interpolations ## LinearInterpolation
# using GridInterpolations
# using ScatteredInterpolation
using BasicBSpline
using BasicBSplineFitting

include("iv_solver/iv_solver_householder.jl")
include("iv_solver/normal_dist.jl")

# Seconds and Milliseconds in a year
const MILLISECONDS = 365 * 24 * 60 * 60 * 1000
const SECONDS = 365 * 24 * 60 * 60

function chebyshev_reversed_range(range_min, range_max, points_count)
    tmp_values = zeros(points_count)
    output_values = zeros(points_count)
    for i in 1:points_count
        tmp_values[i] = cos((2*i-1)/(2*points_count) * pi)
    end

    if points_count % 2 == 0
        mid_point = Int64(points_count / 2)

        for i in 1:mid_point
            output_values[i] =  - ((1-tmp_values[mid_point - i + 1]) * (range_max - range_min) / 2 - (range_max + range_min) / 2)
            output_values[points_count-i+1] =  -(-(1-tmp_values[mid_point - i + 1]) * (range_max - range_min) / 2 - (range_max + range_min) / 2)
        end
    else
        if points_count == 1
            output_values[1] = (range_max + range_min) / 2
        else
            mid_point = Int64(ceil(points_count / 2))

            for i in 1:mid_point
                output_values[i] =  - ((1-tmp_values[mid_point - i + 1]) * (range_max - range_min) / 2 - (range_max + range_min) / 2)
                output_values[points_count-i+1] =  -(-(1-tmp_values[mid_point - i + 1]) * (range_max - range_min) / 2 - (range_max + range_min) / 2)
            end

            output_values[end] = (output_values[end] + output_values[end-1]) / 2
        end

    end

    output_values[1] = range_min
    output_values[end] = range_max

    return output_values
end



function initialize_surface_fitter_info!(surface_fitter_info, expirations_map, NS_FITTING_GRID_RESOLUTION, verbose::Bool=false)
    if verbose
        now_str = Dates.format(now(), "YYYY-mm-dd HH:MM:SS")
        @info "$now_str \t initialize_surface_fitter_info"
    end

    NUMBER_EXPIRATIONS = length(expirations_map)

    surface_fitter_info["ready_to_fit"] = false
    surface_fitter_info["ttm_axis"] = zeros(NUMBER_EXPIRATIONS)
    surface_fitter_info["ns_axis"] = NS_FITTING_GRID_RESOLUTION
    surface_fitter_info["fitting_grid"] = zeros(NUMBER_EXPIRATIONS, NS_FITTING_GRID_RESOLUTION)
    
    min_ttm = Inf
    max_ttm = -Inf
    for expiration_str in keys(expirations_map)
        tmp_ttm = expirations_map[expiration_str]["expiration_timestamp"]
        surface_fitter_info["ttm_axis"][expirations_map[expiration_str]["ttm_index"]] = tmp_ttm # / MILLISECONDS
        if tmp_ttm < min_ttm
            min_ttm = tmp_ttm
        end

        if tmp_ttm > max_ttm
            max_ttm = tmp_ttm
        end
    end

    for expiration_str in keys(expirations_map)
        surface_fitter_info["ttm_axis"][expirations_map[expiration_str]["ttm_index"]] = (expirations_map[expiration_str]["expiration_timestamp"] - min_ttm) / MILLISECONDS
    end

    surface_fitter_info["min_ttm"] = 0
    surface_fitter_info["max_ttm"] = (max_ttm - min_ttm)/MILLISECONDS
end


function compute_futures_prices!(futures_orderbooks, FUTURES_CALC_DEPTH, FUTURES_ORDERBOOK_DEPTH)
    for futures_name in keys(futures_orderbooks)
        bid_count = 1
        for i in futures_orderbooks[futures_name]["bids"]
            futures_orderbooks[futures_name]["bid_price"][bid_count] = -i[1]
            futures_orderbooks[futures_name]["bid_size"][bid_count] = i[2]

            bid_count = bid_count + 1
            if bid_count > min(FUTURES_ORDERBOOK_DEPTH, FUTURES_CALC_DEPTH)
                break
            end
        end

        ask_count = 1
        for i in futures_orderbooks[futures_name]["asks"]
            futures_orderbooks[futures_name]["ask_price"][ask_count] = i[1]
            futures_orderbooks[futures_name]["ask_size"][ask_count] = i[2]

            ask_count = ask_count + 1
            if ask_count > min(FUTURES_ORDERBOOK_DEPTH, FUTURES_CALC_DEPTH)
                break
            end
        end

        min_num_els_orderbook = min(bid_count, ask_count) - 1

        if min_num_els_orderbook == 0
            continue
        end

        bid_prices = futures_orderbooks[futures_name]["bid_price"][1:min_num_els_orderbook]
        bid_sizes = futures_orderbooks[futures_name]["bid_size"][1:min_num_els_orderbook]

        ask_prices = futures_orderbooks[futures_name]["ask_price"][1:min_num_els_orderbook]
        ask_sizes = futures_orderbooks[futures_name]["ask_size"][1:min_num_els_orderbook]

        last_trades_count = length(futures_orderbooks[futures_name]["last_traded_price"])

        if last_trades_count == 0
            top_fraction = sum((bid_prices .* ask_sizes) .+ (ask_prices .* bid_sizes))
            bottom_fraction = sum(ask_sizes .+ bid_sizes)
        else
            selected_trades_count = min(last_trades_count, FUTURES_CALC_DEPTH)
            top_fraction = sum((bid_prices .* ask_sizes) .+ (ask_prices .* bid_sizes)) + sum(futures_orderbooks[futures_name]["last_traded_price"][1:selected_trades_count] .* futures_orderbooks[futures_name]["last_traded_size"][1:selected_trades_count])
            bottom_fraction = sum(ask_sizes .+ bid_sizes) + sum(futures_orderbooks[futures_name]["last_traded_size"][1:selected_trades_count])
        end

        if bottom_fraction > 0
            futures_orderbooks[futures_name]["computed_price"] = top_fraction / bottom_fraction
        end

    end

end


function compute_option_top_orderbook!(options_orderbooks)
    MINIMUM_QUOTING_SIZE = 0.1;
    OUR_QUOTING_SIZE = 0.1;
    FITTING_STABILITY_SCALAR = 10;
    MINIMUM_FITTING_THRESHOLD = OUR_QUOTING_SIZE * FITTING_STABILITY_SCALAR;

    for instrument_str in keys(options_orderbooks)
        counter = 0;
        current_size = 0;
        tmp__fitting_bid_price = 0;
        for bid in options_orderbooks[instrument_str]["bids"]
            counter += 1;
            if counter == 1
                options_orderbooks[instrument_str]["top_bid_price"] = -bid[1]
                options_orderbooks[instrument_str]["top_bid_size"] = bid[2]
            end
            if bid[2] >= MINIMUM_FITTING_THRESHOLD
                options_orderbooks[instrument_str]["fitting_bid_price"] = -bid[1]
                current_size += bid[2]
                break
            else
                tmp__size_chosen = round(min(MINIMUM_FITTING_THRESHOLD - current_size, bid[2])/MINIMUM_QUOTING_SIZE) * MINIMUM_QUOTING_SIZE
                tmp__fitting_bid_price += -bid[1] * tmp__size_chosen;
                current_size += tmp__size_chosen
            end
            if current_size > MINIMUM_FITTING_THRESHOLD
                break
            end
        end
        if current_size >= MINIMUM_FITTING_THRESHOLD
            if tmp__fitting_bid_price > 0
                options_orderbooks[instrument_str]["fitting_bid_price"] = tmp__fitting_bid_price
            else
                # options_orderbooks[instrument_str]["fitting_bid_price"] = NaN
            end
        else
            options_orderbooks[instrument_str]["fitting_bid_price"] = NaN
        end



        counter = 0;
        current_size = 0;
        tmp__fitting_ask_price = 0;
        for ask in options_orderbooks[instrument_str]["asks"]
            counter += 1;
            if counter == 1
                options_orderbooks[instrument_str]["top_ask_price"] = ask[1]
                options_orderbooks[instrument_str]["top_ask_size"] = ask[2]
            end
            if ask[2] >= MINIMUM_FITTING_THRESHOLD
                options_orderbooks[instrument_str]["fitting_ask_price"] = ask[1]
                current_size += ask[2]
                break
            else
                tmp__size_chosen = round(min(MINIMUM_FITTING_THRESHOLD - current_size, ask[2])/MINIMUM_QUOTING_SIZE) * MINIMUM_QUOTING_SIZE
                tmp__fitting_ask_price += round((ask[1] * tmp__size_chosen)/MINIMUM_QUOTING_SIZE) * MINIMUM_QUOTING_SIZE;
                current_size += tmp__size_chosen
            end
            if current_size > MINIMUM_FITTING_THRESHOLD
                break
            end
        end
        if current_size >= MINIMUM_FITTING_THRESHOLD
            if tmp__fitting_ask_price > 0
                options_orderbooks[instrument_str]["fitting_ask_price"] = tmp__fitting_ask_price
            else
                # options_orderbooks[instrument_str]["fitting_ask_price"] = NaN
            end
        else
            options_orderbooks[instrument_str]["fitting_ask_price"] = NaN
        end

        if (!isnan(options_orderbooks[instrument_str]["fitting_ask_price"])) & (!isnan(options_orderbooks[instrument_str]["fitting_bid_price"]))
            options_orderbooks[instrument_str]["fitting_weighted_price"] = (options_orderbooks[instrument_str]["fitting_bid_price"] + options_orderbooks[instrument_str]["fitting_ask_price"]) / 2
        else
            options_orderbooks[instrument_str]["fitting_weighted_price"] = NaN
        end        
    end
end


function compute_ivs!(expirations_map, options_orderbooks, futures_orderbooks, sub_fitter_expiration_info, current_time)
    for expiration_str in keys(expirations_map)
        ttm = (expirations_map[expiration_str]["expiration_timestamp"] / 1000 - current_time) / SECONDS
        underlying_price = futures_orderbooks[expirations_map[expiration_str]["full_underlying_name"]]["computed_price"]
        sub_fitter_expiration_info[expiration_str]["ttm"] = ttm

        for index_position in 1:length(expirations_map[expiration_str]["strike"])
            strike = expirations_map[expiration_str]["strike"][index_position]

            # Puts
            instrument_str = expirations_map[expiration_str]["put_instruments"][index_position]

            # Put bid
            if isnan(options_orderbooks[instrument_str]["top_bid_price"])
                options_orderbooks[instrument_str]["top_bid_iv"] = NaN
            else
                c, ex = normalizePrice(false, options_orderbooks[instrument_str]["top_bid_price"] * underlying_price, underlying_price, strike * 1.0, 1.0)

                if ex === -Inf
                    options_orderbooks[instrument_str]["top_bid_iv"] = NaN
                elseif c === NaN
                    options_orderbooks[instrument_str]["top_bid_iv"] = NaN
                else
                    if c >= 1 / ex || c <= 0
                        options_orderbooks[instrument_str]["top_bid_iv"] = NaN
                    else
                        options_orderbooks[instrument_str]["top_bid_iv"] = impliedVolatilitySRHalley(c, ex, ttm, 0e-14, 64, Householder())
                    end
                end
            end

            # Put ask
            if isnan(options_orderbooks[instrument_str]["top_ask_price"])
                options_orderbooks[instrument_str]["top_ask_iv"] = NaN
            else
                c, ex = normalizePrice(false, options_orderbooks[instrument_str]["top_ask_price"] * underlying_price, underlying_price, strike * 1.0, 1.0)

                if ex === -Inf
                    options_orderbooks[instrument_str]["top_ask_iv"] = NaN
                elseif c === NaN
                    options_orderbooks[instrument_str]["top_ask_iv"] = NaN
                else
                    if c >= 1 / ex || c <= 0
                        options_orderbooks[instrument_str]["top_ask_iv"] = NaN
                    else
                        options_orderbooks[instrument_str]["top_ask_iv"] = impliedVolatilitySRHalley(c, ex, ttm, 0e-14, 64, Householder())
                    end
                end
            end

            # Put weighted fitting point
            if isnan(options_orderbooks[instrument_str]["fitting_weighted_price"])
                options_orderbooks[instrument_str]["fitting_weighted_iv"] = NaN
            else
                c, ex = normalizePrice(false, options_orderbooks[instrument_str]["fitting_weighted_price"] * underlying_price, underlying_price, strike * 1.0, 1.0)

                if ex === -Inf
                    options_orderbooks[instrument_str]["fitting_weighted_iv"] = NaN
                elseif c === NaN
                    options_orderbooks[instrument_str]["fitting_weighted_iv"] = NaN
                else
                    if c >= 1 / ex || c <= 0
                        options_orderbooks[instrument_str]["fitting_weighted_iv"] = NaN
                    else
                        options_orderbooks[instrument_str]["fitting_weighted_iv"] = impliedVolatilitySRHalley(c, ex, ttm, 0e-14, 64, Householder())
                    end
                end
            end


            # Calls
            instrument_str = expirations_map[expiration_str]["call_instruments"][index_position]

            # Call bid
            if isnan(options_orderbooks[instrument_str]["top_bid_price"])
                options_orderbooks[instrument_str]["top_bid_iv"] = NaN
            else
                c, ex = normalizePrice(true, options_orderbooks[instrument_str]["top_bid_price"] * underlying_price, underlying_price, strike * 1.0, 1.0)

                if ex === -Inf
                    options_orderbooks[instrument_str]["top_bid_iv"] = NaN
                elseif c === NaN
                    options_orderbooks[instrument_str]["top_bid_iv"] = NaN
                else
                    if c >= 1 / ex || c <= 0
                        options_orderbooks[instrument_str]["top_bid_iv"] = NaN
                    else
                        options_orderbooks[instrument_str]["top_bid_iv"] = impliedVolatilitySRHalley(c, ex, ttm, 0e-14, 64, Householder())
                    end
                end
            end

            # Call ask
            if isnan(options_orderbooks[instrument_str]["top_ask_price"])
                options_orderbooks[instrument_str]["top_ask_iv"] = NaN
            else
                c, ex = normalizePrice(true, options_orderbooks[instrument_str]["top_ask_price"] * underlying_price, underlying_price, strike * 1.0, 1.0)

                if ex === -Inf
                    options_orderbooks[instrument_str]["top_ask_iv"] = NaN
                elseif c === NaN
                    options_orderbooks[instrument_str]["top_ask_iv"] = NaN
                else
                    if c >= 1 / ex || c <= 0
                        options_orderbooks[instrument_str]["top_ask_iv"] = NaN
                    else
                        options_orderbooks[instrument_str]["top_ask_iv"] = impliedVolatilitySRHalley(c, ex, ttm, 0e-14, 64, Householder())
                    end
                end
            end

            # Call weighted fitting point
            if isnan(options_orderbooks[instrument_str]["fitting_weighted_price"])
                options_orderbooks[instrument_str]["fitting_weighted_iv"] = NaN
            else
                c, ex = normalizePrice(true, options_orderbooks[instrument_str]["fitting_weighted_price"] * underlying_price, underlying_price, strike * 1.0, 1.0)

                if ex === -Inf
                    options_orderbooks[instrument_str]["fitting_weighted_iv"] = NaN
                elseif c === NaN
                    options_orderbooks[instrument_str]["fitting_weighted_iv"] = NaN
                else
                    if c >= 1 / ex || c <= 0
                        options_orderbooks[instrument_str]["fitting_weighted_iv"] = NaN
                    else
                        options_orderbooks[instrument_str]["fitting_weighted_iv"] = impliedVolatilitySRHalley(c, ex, ttm, 0e-14, 64, Householder())
                    end
                end
            end
        end
    end
end


function compute_normalized_strikes!(sub_fitter_expiration_info, futures_orderbooks, options_orderbooks, expirations_map, current_time)
    for expiration_str in keys(sub_fitter_expiration_info)
        # Compute ATM strike
        forward_price = futures_orderbooks[expirations_map[expiration_str]["full_underlying_name"]]["computed_price"]
        ttm = (expirations_map[expiration_str]["expiration_timestamp"] / 1000 - current_time) / SECONDS

        if forward_price === NaN
            continue
        end

        atm_index = NaN
        min_difference = Inf
        tmp_index = 0

        for strike in sub_fitter_expiration_info[expiration_str]["strike"]
            tmp_index += 1
            if abs(strike - forward_price) < min_difference
                min_difference = abs(strike - forward_price)
                atm_index = tmp_index
            end
        end

        if tmp_index == 0
            continue
        end

        # Compute ATM IV
        atm_call_instrument_str = expirations_map[expiration_str]["call_instruments"][atm_index]
        atm_put_instrument_str = expirations_map[expiration_str]["put_instruments"][atm_index]

        # Try call side first
        call_bid_iv = options_orderbooks[atm_call_instrument_str]["top_bid_iv"]
        call_ask_iv = options_orderbooks[atm_call_instrument_str]["top_ask_iv"]

        atm_iv = NaN

        if ((!isnan(call_bid_iv)) & (!isnan(call_ask_iv)))
            atm_iv = (call_bid_iv + call_ask_iv) / 2
        else
            put_bid_iv = options_orderbooks[atm_put_instrument_str]["top_bid_iv"]
            put_ask_iv = options_orderbooks[atm_put_instrument_str]["top_ask_iv"]

            if ((!isnan(put_bid_iv)) & (!isnan(put_ask_iv)))
                atm_iv = (put_bid_iv + put_ask_iv) / 2
            end
        end

        if atm_iv === NaN
            strikes_count = length(sub_fitter_expiration_info[expiration_str]["strike"])
            sub_fitter_expiration_info[expiration_str]["ns_strike"] = zeros(strikes_count) * NaN
            sub_fitter_expiration_info[expiration_str]["fitting_strike"] = zeros(strikes_count) * NaN
            sub_fitter_expiration_info[expiration_str]["fitting_point"] = zeros(strikes_count) * NaN
            sub_fitter_expiration_info[expiration_str]["fitting_count"] = NaN
            sub_fitter_expiration_info[expiration_str]["ttm_index"] = NaN
            sub_fitter_expiration_info[expiration_str]["atm_index"] = NaN
            sub_fitter_expiration_info[expiration_str]["fair_iv"] = zeros(strikes_count) * NaN
            sub_fitter_expiration_info[expiration_str]["strike_count"] = NaN
            continue
        end

        # Compute normalized strikes, -ve value for small strikes
        tmp_index = 0
        for strike in sub_fitter_expiration_info[expiration_str]["strike"]
            tmp_index += 1
            sub_fitter_expiration_info[expiration_str]["ns_strike"][tmp_index] = log(strike / forward_price) / (atm_iv * sqrt(ttm))
        end

        sub_fitter_expiration_info[expiration_str]["atm_index"] = atm_index
        sub_fitter_expiration_info[expiration_str]["ttm_index"] = expirations_map[expiration_str]["ttm_index"]
        sub_fitter_expiration_info[expiration_str]["strike_count"] = length(expirations_map[expiration_str]["ttm_index"])
    end
end


function compute_fitting_points!(sub_fitter_expiration_info, options_orderbooks, expirations_map, futures_orderbooks, current_time, FITTING_POINT_WINGS_DELTA_OFFSET)
    for expiration_str in keys(sub_fitter_expiration_info)
        forward_price = futures_orderbooks[expirations_map[expiration_str]["full_underlying_name"]]["computed_price"]
        ttm = (expirations_map[expiration_str]["expiration_timestamp"] / 1000 - current_time) / SECONDS
        atm_index = sub_fitter_expiration_info[expiration_str]["atm_index"]

        if atm_index === NaN
            continue
        end

        strikes_count = sub_fitter_expiration_info[expiration_str]["strike_count"]
        tmp_strike_index = 0
        fitting_count = 0
        lhs_two_sided = false
        rhs_two_sided = false
        
        filling_start_index = NaN
        filling_end_index = NaN
        filling_last_index = NaN
        filling_inner_status = "outer"

        for normalized_strike in sub_fitter_expiration_info[expiration_str]["ns_strike"]
            tmp_strike_index += 1

            put_instrument_str = expirations_map[expiration_str]["put_instruments"][tmp_strike_index]
            call_instrument_str = expirations_map[expiration_str]["call_instruments"][tmp_strike_index]

            call_bid_iv = options_orderbooks[call_instrument_str]["top_bid_iv"]
            call_ask_iv = options_orderbooks[call_instrument_str]["top_ask_iv"]
            put_bid_iv = options_orderbooks[put_instrument_str]["top_bid_iv"]
            put_ask_iv = options_orderbooks[put_instrument_str]["top_ask_iv"]

            if (!isnan(call_bid_iv)) & (!isnan(put_bid_iv))
                bid_iv = max(call_bid_iv, put_bid_iv)
            elseif (!isnan(call_bid_iv))
                bid_iv = call_bid_iv
            elseif (!isnan(put_bid_iv))
                bid_iv = put_bid_iv
            else
                bid_iv = NaN
            end

            if (!isnan(call_ask_iv)) & (!isnan(put_ask_iv))
                ask_iv = min(call_ask_iv, put_ask_iv)
            elseif (!isnan(call_ask_iv))
                ask_iv = call_ask_iv
            elseif (!isnan(put_ask_iv))
                ask_iv = put_ask_iv
            else
                ask_iv = NaN
            end
            
            ##TODO: This is a bit of a hack. Investigate this. 
            if (!isnan(ask_iv) & (!isnan(bid_iv)))
                if ask_iv < bid_iv
                    if tmp_strike_index < atm_index
                        ask_iv = put_ask_iv
                        bid_iv = put_bid_iv
                    else
                        ask_iv = call_ask_iv
                        bid_iv = call_bid_iv
                    end
                end
            end

            sub_fitter_expiration_info[expiration_str]["market_bid_iv"][tmp_strike_index] = bid_iv
            sub_fitter_expiration_info[expiration_str]["market_ask_iv"][tmp_strike_index] = ask_iv

            if (!isnan(bid_iv)) & (!isnan(ask_iv))
                fitting_count += 1

                if tmp_strike_index == 1
                    lhs_two_sided = true
                end

                if tmp_strike_index == strikes_count
                    rhs_two_sided = true
                end

                sub_fitter_expiration_info[expiration_str]["fitting_point"][fitting_count] = (bid_iv + ask_iv) / 2

                if filling_inner_status == "inside"
                    if lhs_two_sided
                        for index_position in filling_start_index:(tmp_strike_index - 2)
                            sub_fitter_expiration_info[expiration_str]["fitting_point"][index_position + 1] = (sub_fitter_expiration_info[expiration_str]["fitting_point"][index_position] + sub_fitter_expiration_info[expiration_str]["fitting_point"][tmp_strike_index]) / 2
                        end
                    else
                        for index_position in 1:(tmp_strike_index - 1)
                            if ! isnan(sub_fitter_expiration_info[expiration_str]["market_bid_iv"][index_position])
                                iv = sub_fitter_expiration_info[expiration_str]["market_bid_iv"][index_position]

                                d1 = (log(forward_price / sub_fitter_expiration_info[expiration_str]["strike"][index_position]) + 0.5 * ttm * iv^2) / (iv * sqrt(ttm))
                                delta = -NormalDistributionMethods.norm_cdf_polya(-d1)

                                quadratic_a = ttm /2
                                
                                if 0 <= abs(delta) * (1 + FITTING_POINT_WINGS_DELTA_OFFSET) <= 1
                                    quadratic_b = sqrt(ttm) * NormalDistributionMethods.norm_cdf_inverse_acklam(abs(delta) * (1 + FITTING_POINT_WINGS_DELTA_OFFSET))
                                    quadratic_c = log(forward_price / sub_fitter_expiration_info[expiration_str]["strike"][index_position])

                                    b24ac = (quadratic_b ^ 2) - (4 * quadratic_a * quadratic_c)
                                    if b24ac >= 0
                                        iv_plus = (-quadratic_b + sqrt(b24ac)) / (2*quadratic_a)
                                        iv_minus = (-quadratic_b - sqrt(b24ac)) / (2*quadratic_a)

                                        if (iv_plus > 0) & (iv_minus > 0)
                                            if isnan(sub_fitter_expiration_info[expiration_str]["fitting_point"][index_position])
                                                sub_fitter_expiration_info[expiration_str]["fitting_point"][index_position] = 0
                                            end
                                            sub_fitter_expiration_info[expiration_str]["fitting_point"][index_position] = min(iv_plus, iv_minus, sub_fitter_expiration_info[expiration_str]["fitting_point"][index_position])
                                        elseif iv_plus > 0
                                            sub_fitter_expiration_info[expiration_str]["fitting_point"][index_position] = iv_plus
                                        elseif iv_minus > 0
                                            sub_fitter_expiration_info[expiration_str]["fitting_point"][index_position] = iv_minus
                                        end
                                    end
                                end
                            elseif ! isnan(sub_fitter_expiration_info[expiration_str]["market_ask_iv"][index_position])
                                iv = sub_fitter_expiration_info[expiration_str]["market_ask_iv"][index_position]

                                d1 = (log(forward_price / sub_fitter_expiration_info[expiration_str]["strike"][index_position]) + 0.5 * ttm * iv^2) / (iv * sqrt(ttm))
                                delta = -NormalDistributionMethods.norm_cdf_polya(-d1)

                                quadratic_a = ttm /2

                                if 0 <= abs(delta) * (1 - FITTING_POINT_WINGS_DELTA_OFFSET) <= 1
                                    quadratic_b = sqrt(ttm) * NormalDistributionMethods.norm_cdf_inverse_acklam(abs(delta) * (1 - FITTING_POINT_WINGS_DELTA_OFFSET))
                                    quadratic_c = log(forward_price / sub_fitter_expiration_info[expiration_str]["strike"][index_position])

                                    b24ac = (quadratic_b ^ 2) - (4 * quadratic_a * quadratic_c)
                                    if b24ac >= 0
                                        iv_plus = (-quadratic_b + sqrt(b24ac)) / (2*quadratic_a)
                                        iv_minus = (-quadratic_b - sqrt(b24ac)) / (2*quadratic_a)

                                        if (iv_plus > 0) & (iv_minus > 0)
                                            if isnan(sub_fitter_expiration_info[expiration_str]["fitting_point"][index_position])
                                                sub_fitter_expiration_info[expiration_str]["fitting_point"][index_position] = 0
                                            end
                                            sub_fitter_expiration_info[expiration_str]["fitting_point"][index_position] = min(iv_plus, iv_minus, sub_fitter_expiration_info[expiration_str]["fitting_point"][index_position])
                                        elseif iv_plus > 0
                                            sub_fitter_expiration_info[expiration_str]["fitting_point"][index_position] = iv_plus
                                        elseif iv_minus > 0
                                            sub_fitter_expiration_info[expiration_str]["fitting_point"][index_position] = iv_minus
                                        end
                                    end
                                end
                            end

                        end
                    end

                    filling_inner_status = "outer"
                    filling_end_index = NaN
                end


                filling_start_index = tmp_strike_index
                filling_last_index = tmp_strike_index

                sub_fitter_expiration_info[expiration_str]["fitting_strike"][fitting_count] = normalized_strike
                
            elseif !isnan(bid_iv)
                fitting_count += 1

                filling_end_index = tmp_strike_index
                
                sub_fitter_expiration_info[expiration_str]["fitting_strike"][fitting_count] = normalized_strike
                sub_fitter_expiration_info[expiration_str]["fitting_point"][fitting_count] = bid_iv
                filling_inner_status = "inside"
            elseif !isnan(ask_iv)
                fitting_count += 1
                
                filling_end_index = tmp_strike_index
                
                sub_fitter_expiration_info[expiration_str]["fitting_strike"][fitting_count] = normalized_strike
                sub_fitter_expiration_info[expiration_str]["fitting_point"][fitting_count] = ask_iv
                filling_inner_status = "inside"
            end
        end

        if !rhs_two_sided
            if filling_last_index < fitting_count
                for index_position in (filling_last_index+1):fitting_count
                    if ! isnan(sub_fitter_expiration_info[expiration_str]["market_bid_iv"][index_position])
                        iv = sub_fitter_expiration_info[expiration_str]["market_bid_iv"][index_position]

                        d1 = (log(forward_price / sub_fitter_expiration_info[expiration_str]["strike"][index_position]) + 0.5 * ttm * iv^2) / (iv * sqrt(ttm))
                        delta = NormalDistributionMethods.norm_cdf_polya(d1)

                        quadratic_a = ttm /2

                        if 0 <= abs(delta) * (1 + FITTING_POINT_WINGS_DELTA_OFFSET) <= 1
                            quadratic_b = -sqrt(ttm) * NormalDistributionMethods.norm_cdf_inverse_acklam(delta * (1 + FITTING_POINT_WINGS_DELTA_OFFSET))
                            quadratic_c = log(forward_price / sub_fitter_expiration_info[expiration_str]["strike"][index_position])

                            b24ac = (quadratic_b ^ 2) - (4 * quadratic_a * quadratic_c)

                            if b24ac >= 0
                                iv_plus = (-quadratic_b + sqrt(b24ac)) / (2*quadratic_a)
                                iv_minus = (-quadratic_b - sqrt(b24ac)) / (2*quadratic_a)

                                if (iv_plus > 0) & (iv_minus > 0)
                                    if isnan(sub_fitter_expiration_info[expiration_str]["fitting_point"][index_position])
                                        sub_fitter_expiration_info[expiration_str]["fitting_point"][index_position] = 0
                                    end
                                    sub_fitter_expiration_info[expiration_str]["fitting_point"][index_position] = min(iv_plus, iv_minus, sub_fitter_expiration_info[expiration_str]["fitting_point"][index_position])
                                elseif iv_plus > 0
                                    sub_fitter_expiration_info[expiration_str]["fitting_point"][index_position] = min(iv_plus, sub_fitter_expiration_info[expiration_str]["fitting_point"][index_position])
                                elseif iv_minus > 0
                                    sub_fitter_expiration_info[expiration_str]["fitting_point"][index_position] = iv_minus
                                end
                            end
                        end
                    elseif ! isnan(sub_fitter_expiration_info[expiration_str]["market_ask_iv"][index_position])
                        iv = sub_fitter_expiration_info[expiration_str]["market_ask_iv"][index_position]

                        d1 = (log(forward_price / sub_fitter_expiration_info[expiration_str]["strike"][index_position]) + 0.5 * ttm * iv^2) / (iv * sqrt(ttm))
                        delta = NormalDistributionMethods.norm_cdf_polya(d1)

                        quadratic_a = ttm /2


                        if 0 <= abs(delta) * (1 - FITTING_POINT_WINGS_DELTA_OFFSET) <= 1
                            quadratic_b = -sqrt(ttm) * NormalDistributionMethods.norm_cdf_inverse_acklam(delta * (1 - FITTING_POINT_WINGS_DELTA_OFFSET))
                            quadratic_c = log(forward_price / sub_fitter_expiration_info[expiration_str]["strike"][index_position])

                            b24ac = (quadratic_b ^ 2) - (4 * quadratic_a * quadratic_c)

                            if b24ac >= 0
                                iv_plus = (-quadratic_b + sqrt(b24ac)) / (2*quadratic_a)
                                iv_minus = (-quadratic_b - sqrt(b24ac)) / (2*quadratic_a)

                                if (iv_plus > 0) & (iv_minus > 0)
                                    if isnan(sub_fitter_expiration_info[expiration_str]["fitting_point"][index_position])
                                        sub_fitter_expiration_info[expiration_str]["fitting_point"][index_position] = 0
                                    end
                                    sub_fitter_expiration_info[expiration_str]["fitting_point"][index_position] = min(iv_plus, iv_minus, sub_fitter_expiration_info[expiration_str]["fitting_point"][index_position])
                                elseif iv_plus > 0
                                    sub_fitter_expiration_info[expiration_str]["fitting_point"][index_position] = min(iv_plus, sub_fitter_expiration_info[expiration_str]["fitting_point"][index_position])
                                elseif iv_minus > 0
                                    sub_fitter_expiration_info[expiration_str]["fitting_point"][index_position] = iv_minus
                                end
                            end
                        end
                    end

                end
            end
        end

        sub_fitter_expiration_info[expiration_str]["fitting_count"] = fitting_count
        sub_fitter_expiration_info[expiration_str]["min_normalized_strike"] = sub_fitter_expiration_info[expiration_str]["ns_strike"][1]
        sub_fitter_expiration_info[expiration_str]["max_normalized_strike"] = sub_fitter_expiration_info[expiration_str]["ns_strike"][end]
    end
end

function compute_delta_strikes!(sub_fitter_expiration_info, expirations_map, futures_orderbooks, NS_FITTING_GRID_RESOLUTION, current_time)
    ##TODO: Test this function
    for expiration_str in keys(sub_fitter_expiration_info)
        forward_price = futures_orderbooks[expirations_map[expiration_str]["full_underlying_name"]]["computed_price"]
        ttm = (expirations_map[expiration_str]["expiration_timestamp"] / 1000 - current_time) / SECONDS

        index_position = 0
        for strike in sub_fitter_expiration_info[expiration_str]["strike"]
            index_position += 1
            iv = sub_fitter_expiration_info[expiration_str]["fitting_point"][index_position]
            d1 = (log(forward_price / strike) + 0.5 * ttm * iv^2) / (iv * sqrt(ttm))
            sub_fitter_expiration_info[expiration_str]["delta_strike"][index_position] = NormalDistributionMethods.norm_cdf_polya(-d1)
        end
    end
end

function update_surface_fitter_info!(surface_fitter_info, sub_fitter_expiration_info, NS_FITTING_GRID_RESOLUTION, SPLINE_EXPONENT_TTM, SPLINE_EXPONENT_NSTRIKE, KNOT_COUNT_NSTRIKE)
    # Compute the NS linespace
    __ready_to_fit = true
    min_normalized_strike = Inf
    max_normalized_strike = -Inf
    for expiration_str in keys(sub_fitter_expiration_info)
        if !surface_fitter_info["ready_to_fit"]
            if isnan(sub_fitter_expiration_info[expiration_str]["min_normalized_strike"]) | isnan(sub_fitter_expiration_info[expiration_str]["max_normalized_strike"])
                __ready_to_fit = false
                break
            else
                if sub_fitter_expiration_info[expiration_str]["min_normalized_strike"] < min_normalized_strike
                    min_normalized_strike = sub_fitter_expiration_info[expiration_str]["min_normalized_strike"]
                end

                if sub_fitter_expiration_info[expiration_str]["max_normalized_strike"] > max_normalized_strike
                    max_normalized_strike = sub_fitter_expiration_info[expiration_str]["max_normalized_strike"]
                end
            end
        else
            if isnan(sub_fitter_expiration_info[expiration_str]["min_normalized_strike"]) | isnan(sub_fitter_expiration_info[expiration_str]["max_normalized_strike"])
                __ready_to_fit = false
                break
            else
                if sub_fitter_expiration_info[expiration_str]["min_normalized_strike"] < min_normalized_strike
                    min_normalized_strike = sub_fitter_expiration_info[expiration_str]["min_normalized_strike"]
                end

                if sub_fitter_expiration_info[expiration_str]["max_normalized_strike"] > max_normalized_strike
                    max_normalized_strike = sub_fitter_expiration_info[expiration_str]["max_normalized_strike"]
                end
            end
        end
    end

    if !__ready_to_fit
        surface_fitter_info["ready_to_fit"] = false
    else
        # Compute grid for fitting
        surface_fitter_info["ns_axis"] = LinRange(min_normalized_strike, max_normalized_strike, NS_FITTING_GRID_RESOLUTION)
        for expiration_str in keys(sub_fitter_expiration_info)
            __fitting_count = sub_fitter_expiration_info[expiration_str]["fitting_count"]
            __ttm_index = sub_fitter_expiration_info[expiration_str]["ttm_index"]
            if isnan(__fitting_count)
                continue
            end
            tck = Spline1D(sub_fitter_expiration_info[expiration_str]["fitting_strike"][1:__fitting_count], sub_fitter_expiration_info[expiration_str]["fitting_point"][1:__fitting_count], k=1, bc="extrapolate")
            surface_fitter_info["fitting_grid"][__ttm_index, :] = tck(surface_fitter_info["ns_axis"])
        end

        axis_range_nstrike = chebyshev_reversed_range(min_normalized_strike, max_normalized_strike, KNOT_COUNT_NSTRIKE)

        knots_ttm = KnotVector(surface_fitter_info["ttm_axis"])+SPLINE_EXPONENT_TTM*KnotVector([surface_fitter_info["min_ttm"],surface_fitter_info["max_ttm"]])
        knots_nstrike = KnotVector(axis_range_nstrike)+SPLINE_EXPONENT_NSTRIKE*KnotVector([min_normalized_strike,max_normalized_strike])

        spline_space_ttm = BSplineSpace{SPLINE_EXPONENT_TTM}(knots_ttm)
        spline_space_nstrike = BSplineSpace{SPLINE_EXPONENT_TTM}(knots_nstrike)

        # Fit surface fitter
        spline = Spline2D(surface_fitter_info["ttm_axis"], surface_fitter_info["ns_axis"], surface_fitter_info["fitting_grid"], kx=1, ky=1)

        a = fittingcontrolpoints(spline, (spline_space_ttm, spline_space_nstrike))
        M = BSplineManifold(a, (spline_space_ttm, spline_space_nstrike))

        for expiration_str in keys(sub_fitter_expiration_info)
            __ttm_index = sub_fitter_expiration_info[expiration_str]["ttm_index"]
            __strike_index = 0
            for normalized_strike in sub_fitter_expiration_info[expiration_str]["ns_strike"]
                __strike_index += 1
                sub_fitter_expiration_info[expiration_str]["fair_iv"][__strike_index] = M(surface_fitter_info["ttm_axis"][__ttm_index], normalized_strike)
            end
        end
    end
end

function copy_fair_iv_from_fitting_point!(sub_fitter_expiration_info)
    for expiration_str in keys(sub_fitter_expiration_info)
        __index_count = 0
        for fitting_point in sub_fitter_expiration_info[expiration_str]["fitting_point"]
            __index_count += 1
            sub_fitter_expiration_info[expiration_str]["fair_iv"][__index_count] = fitting_point
        end
    end
end


function compute_prices!(sub_fitter_expiration_info, futures_orderbooks, options_orderbooks, expirations_map, instrument_map, DIMINING_N_STRIKE_THREASHOLD, PRICING_MAX_MULTIPLIER)
    for expiration_str in keys(expirations_map)
        ttm = sub_fitter_expiration_info[expiration_str]["ttm"]
        underlying_price = futures_orderbooks[expirations_map[expiration_str]["full_underlying_name"]]["computed_price"]

        index_count = 0
        for strike in expirations_map[expiration_str]["strike"]
            index_count += 1

            call_instrument_str = expirations_map[expiration_str]["call_instruments"][index_count]
            put_instrument_str = expirations_map[expiration_str]["put_instruments"][index_count]

            market_call_bid_price = options_orderbooks[call_instrument_str]["top_bid_price"]
            market_call_ask_price = options_orderbooks[call_instrument_str]["top_ask_price"]
            market_put_bid_price = options_orderbooks[put_instrument_str]["top_bid_price"]
            market_put_ask_price = options_orderbooks[put_instrument_str]["top_ask_price"]

            CALL_OPTION_TICK_SIZE = instrument_map[call_instrument_str]["tick_size"]
            CALL_PRICING_SPREAD = CALL_OPTION_TICK_SIZE / 2

            PUT_OPTION_TICK_SIZE = instrument_map[put_instrument_str]["tick_size"]
            PUT_PRICING_SPREAD = PUT_OPTION_TICK_SIZE / 2

            normalized_strike = sub_fitter_expiration_info[expiration_str]["ns_strike"][index_count]
            iv = sub_fitter_expiration_info[expiration_str]["fair_iv"][index_count]
            if isnan(iv)
                continue
            end
            d1 = 1 / (iv * sqrt(ttm)) * (log(underlying_price / strike) + ttm * (iv^2) / 2)
            d2 = d1 - iv * sqrt(ttm)

            call_fair_price = (underlying_price * NormalDistributionMethods.norm_cdf_polya(d1) - strike * NormalDistributionMethods.norm_cdf_polya(d2)) / underlying_price
            put_fair_price = (strike * NormalDistributionMethods.norm_cdf_polya(-d2) - underlying_price * NormalDistributionMethods.norm_cdf_polya(-d1)) / underlying_price

            sub_fitter_expiration_info[expiration_str]["put_fair_price"][index_count] = put_fair_price
            sub_fitter_expiration_info[expiration_str]["call_fair_price"][index_count] = call_fair_price
            

            if abs(normalized_strike < DIMINING_N_STRIKE_THREASHOLD)
                diming = true
            else
                diming = false
            end

            # Call Bid
            _min_bid_prelim = round((call_fair_price - CALL_PRICING_SPREAD) * 10000) / 10000
            if floor(_min_bid_prelim / CALL_OPTION_TICK_SIZE) * CALL_OPTION_TICK_SIZE < 0
                min_bid = 0
                max_bid = 0
            else
                min_bid = floor(_min_bid_prelim / CALL_OPTION_TICK_SIZE) * CALL_OPTION_TICK_SIZE
                if min_bid - ((PRICING_MAX_MULTIPLIER - 1) * CALL_OPTION_TICK_SIZE) < 0
                    max_bid = 0
                else
                    max_bid = min_bid - ((PRICING_MAX_MULTIPLIER - 1) * CALL_OPTION_TICK_SIZE)
                end
            end

            if isnan(market_call_bid_price)
                own_call_bid = max_bid
            else
                if diming
                    value = market_call_bid_price + CALL_OPTION_TICK_SIZE
                else
                    value = market_call_bid_price
                end

                if max_bid <= value <= min_bid
                    own_call_bid = value
                elseif market_call_bid_price <= max_bid
                    own_call_bid = max_bid
                else
                    own_call_bid = min_bid
                end
            end

            own_call_bid = round(Int64, own_call_bid * 10000) / 10000

            sub_fitter_expiration_info[expiration_str]["own_call_bid"][index_count] = own_call_bid

            # Call Ask
            _min_ask_prelim = round((call_fair_price + CALL_PRICING_SPREAD) * 10000) / 10000
            if floor(_min_ask_prelim / CALL_OPTION_TICK_SIZE) * CALL_OPTION_TICK_SIZE < 0
                min_ask = 0
                max_ask = 0
            else
                min_ask = ceil(_min_ask_prelim / CALL_OPTION_TICK_SIZE) * CALL_OPTION_TICK_SIZE
                if min_ask + ((PRICING_MAX_MULTIPLIER - 1) * CALL_OPTION_TICK_SIZE) < 0
                    max_ask = 0
                else
                    max_ask = min_ask + ((PRICING_MAX_MULTIPLIER - 1) * CALL_OPTION_TICK_SIZE)
                end
            end

            if isnan(market_call_ask_price)
                own_call_ask = max_ask
            else
                if diming
                    value = market_call_ask_price - CALL_OPTION_TICK_SIZE
                else
                    value = market_call_ask_price
                end

                if min_ask <= value <= max_ask
                    own_call_ask = value
                elseif market_call_ask_price >= max_ask
                    own_call_ask = max_ask
                else
                    own_call_ask = min_ask
                end
            end

            own_call_ask = round(Int64, own_call_ask * 10000) / 10000
            sub_fitter_expiration_info[expiration_str]["own_call_ask"][index_count] = own_call_ask

            # Put Bid
            _min_bid_prelim = round((put_fair_price - PUT_PRICING_SPREAD) * 10000) / 10000
            if floor(_min_bid_prelim / PUT_OPTION_TICK_SIZE) * PUT_OPTION_TICK_SIZE < 0
                min_bid = 0
                max_bid = 0
            else
                min_bid = floor(_min_bid_prelim / PUT_OPTION_TICK_SIZE) * PUT_OPTION_TICK_SIZE
                if min_bid - ((PRICING_MAX_MULTIPLIER - 1) * PUT_OPTION_TICK_SIZE) < 0
                    max_bid = 0
                else
                    max_bid = min_bid - ((PRICING_MAX_MULTIPLIER - 1) * PUT_OPTION_TICK_SIZE)
                end
            end

            if isnan(market_put_bid_price)
                own_put_bid = max_bid
            else
                if diming
                    value = market_put_bid_price + PUT_OPTION_TICK_SIZE
                else
                    value = market_put_bid_price
                end

                if max_bid <= value <= min_bid
                    own_put_bid = value
                elseif market_put_bid_price <= max_bid
                    own_put_bid = max_bid
                else
                    own_put_bid = min_bid
                end
            end

            own_put_bid = round(Int64, own_put_bid * 10000) / 10000
            sub_fitter_expiration_info[expiration_str]["own_put_bid"][index_count] = own_put_bid

            # Put Ask
            _min_ask_prelim = round((put_fair_price + PUT_PRICING_SPREAD) * 10000) / 10000
            if floor(_min_ask_prelim / PUT_OPTION_TICK_SIZE) * PUT_OPTION_TICK_SIZE < 0
                min_ask = 0
                max_ask = 0
            else
                min_ask = ceil(_min_ask_prelim / PUT_OPTION_TICK_SIZE) * PUT_OPTION_TICK_SIZE
                if min_ask + ((PRICING_MAX_MULTIPLIER - 1) * PUT_OPTION_TICK_SIZE) < 0
                    max_ask = 0
                else
                    max_ask = min_ask + ((PRICING_MAX_MULTIPLIER - 1) * PUT_OPTION_TICK_SIZE)
                end
            end

            if isnan(market_put_ask_price)
                own_put_ask = max_ask
            else
                if diming
                    value = market_put_ask_price - PUT_OPTION_TICK_SIZE
                else
                    value = market_put_ask_price
                end

                if min_ask <= value <= max_ask
                    own_put_ask = value
                elseif market_put_ask_price >= max_ask
                    own_put_ask = max_ask
                else
                    own_put_ask = min_ask
                end
            end

            own_put_ask = round(Int64, own_put_ask * 10000) / 10000

            sub_fitter_expiration_info[expiration_str]["own_put_ask"][index_count] = own_put_ask

        end
    end
end


function compute_greeks!(sub_fitter_expiration_info, expirations_map, futures_orderbooks)
    for expiration_str in keys(expirations_map)
        ttm = sub_fitter_expiration_info[expiration_str]["ttm"]
        underlying_price = futures_orderbooks[expirations_map[expiration_str]["full_underlying_name"]]["computed_price"]

        index_count = 0
        for strike in expirations_map[expiration_str]["strike"]
            index_count += 1

            iv = sub_fitter_expiration_info[expiration_str]["fair_iv"][index_count]
            if isnan(iv)
                continue
            end
            d1 = 1 / (iv * sqrt(ttm)) * (log(underlying_price / strike) + ttm * (iv^2) / 2)
            d2 = d1 - iv * sqrt(ttm)

            sub_fitter_expiration_info[expiration_str]["delta_call"][index_count] = NormalDistributionMethods.norm_cdf_polya(d1)
            sub_fitter_expiration_info[expiration_str]["delta_put"][index_count] = sub_fitter_expiration_info[expiration_str]["delta_call"][index_count] - 1

            sub_fitter_expiration_info[expiration_str]["gamma"][index_count] = NormalDistributionMethods.norm_pdf_simple(d1) / (underlying_price * iv * sqrt(ttm))
            sub_fitter_expiration_info[expiration_str]["vega"][index_count] = underlying_price * NormalDistributionMethods.norm_pdf_simple(d1) * sqrt(ttm)
            sub_fitter_expiration_info[expiration_str]["theta"][index_count] = -(underlying_price * NormalDistributionMethods.norm_pdf_simple(d1) * iv) / (2 * sqrt(ttm))

            sub_fitter_expiration_info[expiration_str]["vanna"][index_count] = (sub_fitter_expiration_info[expiration_str]["vega"][index_count] / underlying_price) * (1 - d1 / (iv * sqrt(ttm)))
            sub_fitter_expiration_info[expiration_str]["volga"][index_count] = (sub_fitter_expiration_info[expiration_str]["vega"][index_count] * d1 * d2) / iv

            sub_fitter_expiration_info[expiration_str]["total_delta_call"][index_count] = NormalDistributionMethods.norm_pdf_simple(d1) - sub_fitter_expiration_info[expiration_str]["call_fair_price"][index_count]
            sub_fitter_expiration_info[expiration_str]["total_delta_put"][index_count] = (NormalDistributionMethods.norm_pdf_simple(d1) - 1) - sub_fitter_expiration_info[expiration_str]["put_fair_price"][index_count]

        end
    end
end

end
