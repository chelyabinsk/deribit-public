module Parameters
const URI = "wss://www.deribit.com/ws/api/v2";
const CLIENT_ID = "CLIENT_ID";
const CLIENT_SECRET = "CLIENT_SECRET";

const ORDER_URI = "wss://test.deribit.com/ws/api/v2";
const ORDER_CLIENT_ID = "CLIENT_ID";
const ORDER_CLIENT_SECRET = "CLIENT_SECRET";

const LOCAL_REDIS_HOST = "redislocal"; ## Part of the local docker network
const LOCAL_REDIS_PORT = 6379; ## Part of the local docker network, forwarded to 63001
const LOCAL_REDIS_PASSWORD = "REDIS_PASSWORD";

const CURRENCY = "BTC"

const MIN_FITTING_TTM = 1; ## Days to the TTM cutoff

const FUTURES_ORDERBOOK_DEPTH = 5; ## Depth used for tracking
const MAX_TRACKED_FUTURE_TRADES = 10;  ## Count of tracked trades
const FUTURES_CALC_DEPTH = 3;  ## Depth used for computing the price

## Filtering
const FITTING_POINT_WINGS_DELTA_OFFSET = 0.5;
const FITTING_STABILITY_SCALAR = 10;

## Quoting
const OUR_QUOTING_SIZE = 0.1;
const MINIMUM_FITTING_THRESHOLD = OUR_QUOTING_SIZE * FITTING_STABILITY_SCALAR;
const MINIMUM_QUOTING_SIZE = 0.1;

## Surface fitter
const NS_FITTING_GRID_RESOLUTION = 500; # Resolution of the fitting grid on NStrike. TTM does not need interpolation
const SPLINE_EXPONENT_TTM = 2; # Spline order used on TTM axis
const SPLINE_EXPONENT_NSTRIKE = 2; # Spline order used on NStrike axis
const KNOT_COUNT_NSTRIKE = 50; # Number of knots used on NStrike axis

## Pricing
const DIMINING_N_STRIKE_THREASHOLD = 1.5; ## Normalised strike within which we allow diming
const PRICING_MAX_MULTIPLIER = 15.0; ## # Maximum number of ticks for the bid-fair and fair-ask spreads

end
