using Test;

include("parameters.jl")

@testset verbose = true "Fitter" begin
    @testset "Fitter.Helpers" begin
        include("misc/general.jl")

        printstyled(color=:blue, "\nHelpers.initialize_surface_fitter_info!\n")
        @testset verbose = true "Helpers.initialize_surface_fitter_info!" begin
            include("tests/Helpers/initialize_surface_fitter_info!.jl")
        end

        printstyled(color=:blue, "\nHelpers.compute_futures_prices!\n")
        @testset verbose = true "Helpers.compute_futures_prices!" begin
            include("tests/Helpers/compute_futures_prices!.jl")
        end

        printstyled(color=:blue, "\nHelpers.compute_option_top_orderbook!\n")
        @testset verbose = true "Helpers.compute_option_top_orderbook!" begin
            include("tests/Helpers/compute_option_top_orderbook!.jl")
        end

        printstyled(color=:blue, "\nHelpers.compute_ivs!\n")
        @testset verbose = true "Helpers.compute_ivs!" begin
            include("tests/Helpers/compute_ivs!.jl")
        end

        printstyled(color=:blue, "\nHelpers.compute_normalized_strikes!\n")
        @testset verbose = true "Helpers.compute_normalized_strikes!" begin
            include("tests/Helpers/compute_normalized_strikes!.jl")
        end

        printstyled(color=:blue, "\nHelpers.compute_fitting_points!\n")
        @testset verbose = true "Helpers.compute_fitting_points!" begin
            include("tests/Helpers/compute_fitting_points!.jl")
        end

        printstyled(color=:red, "\nHelpers.update_surface_fitter_info!\n")
        @testset verbose = true "\nHelpers.update_surface_fitter_info!" begin
            include("tests/Helpers/update_surface_fitter_info!.jl") 
        end

        printstyled(color=:blue, "\nHelpers.compute_prices!\n")
        @testset verbose = true "\nHelpers.compute_prices!" begin
            include("tests/Helpers/compute_prices!.jl") 
        end

        printstyled(color=:blue, "\nHelpers.compute_greeks!\n")
        @testset verbose = true "\nHelpers.compute_greeks!" begin
            include("tests/Helpers/compute_greeks!.jl") 
        end
    end

    @testset "Fitter.NormalDistributionMethods" begin
        include("misc/iv_solver/normal_dist.jl")

        printstyled(color=:blue, "\nNormalDistributionMethods.norm_cdf_polya\n")
        @testset verbose = true "NormalDistributionMethods.norm_cdf_polya" begin
            include("tests/NormalDistributionMethods/norm_cdf_polya.jl") 
        end

        printstyled(color=:blue, "\nNormalDistributionMethods.norm_pdf_simple\n")
        @testset verbose = true "NormalDistributionMethods.norm_pdf_simple" begin
            include("tests/NormalDistributionMethods/norm_pdf_simple.jl") 
        end
    end

    @testset "Fitter.DeribitIOs" begin
        include("deribit_io/deribit_io.jl")
        
        printstyled(color=:blue, "\nDeribitIOs.update_instrument_maps!\n")
        @testset verbose = true "DeribitIOs.update_instrument_maps!" begin
            include("tests/DeribitIOs/update_instrument_maps!.jl") 
        end

        printstyled(color=:blue, "\nDeribitIOs.login_json\n")
        @testset verbose = true "DeribitIOs.login_json" begin
            include("tests/DeribitIOs/login_json.jl") 
        end

        printstyled(color=:blue, "\nDeribitIOs.update_futures_orderbook_keys!\n")
        @testset verbose = true "DeribitIOs.update_futures_orderbook_keys!" begin
            include("tests/DeribitIOs/update_futures_orderbook_keys!.jl") 
        end

        printstyled(color=:blue, "\nDeribitIOs.authenticate\n")
        @testset verbose = true "DeribitIOs.authenticate" begin
            include("tests/DeribitIOs/authenticate.jl") 
        end

        printstyled(color=:blue, "\nDeribitIOs.heartbeat_response\n")
        @testset verbose = true "DeribitIOs.heartbeat_response" begin
            include("tests/DeribitIOs/heartbeat_response.jl") 
        end

        printstyled(color=:blue, "\nDeribitIOs.subscribe_to_streams\n")
        @testset verbose = true "DeribitIOs.subscribe_to_streams" begin
            include("tests/DeribitIOs/subscribe_to_streams.jl") 
        end

        printstyled(color=:blue, "\nDeribitIOs.parse_subscriptions!\n")
        @testset verbose = true "DeribitIOs.parse_subscriptions!" begin
            include("tests/DeribitIOs/parse_subscriptions!.jl") 
        end

        printstyled(color=:blue, "\nDeribitIOs.update_options_orderbook_keys!\n")
        @testset verbose = true "DeribitIOs.update_options_orderbook_keys!" begin
            include("tests/DeribitIOs/update_options_orderbook_keys!.jl") 
        end
    end

    @testset "Fitter.RedisIOs" begin
        include("misc/RedisIOs.jl")

        printstyled(color=:blue, "\nRedisIO.test_connection\n")
        @testset verbose = true "RedisIOs.test_connection" begin
            include("tests/RedisIOs/test_connection.jl") 
        end
    end
end