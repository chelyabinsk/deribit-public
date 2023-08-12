using Test;
using JSON;

#########
@info "Helpers.initialize_surface_fitter_info! -- basic shape check"

surface_fitter_info = Dict()
NS_FITTING_GRID_RESOLUTION = 10
expirations_map = Dict(
    "30JUN23" => Dict(
        "expiration_timestamp" => 16877118318216,
        "ttm_index" => 1
    ),
    "30DEC23" => Dict(
        "expiration_timestamp" => 16877119318216,
        "ttm_index" => 2
    ),
)

Helpers.initialize_surface_fitter_info!(surface_fitter_info, expirations_map, NS_FITTING_GRID_RESOLUTION, true)

target_output = Dict(
    "fitting_grid" => [0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0],
    "max_ttm" => 3.1709791983764585e-5,
    "min_ttm" => 0,
    "ttm_axis" => [0.0, 3.1709791983764585e-5],
    "ns_axis" => 10,
    "ready_to_fit" => false
)

@test JSON.json(surface_fitter_info) == JSON.json(target_output)
#########