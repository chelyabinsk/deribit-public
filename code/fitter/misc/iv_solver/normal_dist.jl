module NormalDistributionMethods

const gamma2 = -1 / 3 + 1 / pi
const gamma4 = 7 / 90 - 2 / (3 * pi) + 4 / (3 * pi * pi)
const gamma6 = -1 / 70 + 4 / (15 * pi) - 4 / (3 * pi * pi) + 2 / ((pi^3))
const gamma8 = 83 / 37800 - 76 / (945 * pi) + 34 / (45 * pi * pi) - 8 / (3 * (pi^3)) + 16 / (5 * (pi^4))
const gamma10 = -73 / 249480 + 283 / (14175 * pi) - 178 / (567 * pi * pi) + 88 / (45 * (pi^3)) - 16 / (3 * (pi^4)) + 16 / (3 * (pi^5))

const sqrt2pi = 1 / sqrt(2 * pi)


# Coefficients in rational approximations
const a = [-39.69683028665376, 220.9460984245205, -275.9285104469687,
        138.3577518672690, -30.66479806614716, 2.506628277459239]

const b = [-54.47609879822406, 161.5858368580409, -155.6989798598866,
        66.80131188771972, -13.28068155288572, 1.0]

const c = [-7.784894002430293e-03, -0.3223964580411365, -2.400758277161838,
        -2.549732539343734, 4.374664141464968, 2.938163982698783]

const d = [7.784695709041462e-03, 0.3224671290700398, 2.445134137142996,
        3.754408661907416, 1.0]

# Define break-points
const plow = 0.02425
const phigh = 1 - plow


function norm_cdf_polya(x)
    # Polya's Approxmation of the CDF of a Normal Distribution

    x2 = x * x
    x4 = x2 * x2
    x6 = x4 * x2
    x8 = x4 * x4
    x10 = x8 * x2

    out = (
        0.5 + 0.5 * sign(x)
              * sqrt(1 - exp(-2 / pi * x2 * (1 + gamma2 * x2 + gamma4 * x4 + gamma6 * x6 + gamma8 * x8 + gamma10 * x10)))
    )

    return out

end


function norm_pdf_simple(x::Float64)
    # PDF of a Standard Normal Distribution (mean = 0, sd = 1)

    out = sqrt2pi * exp(-0.5 * x * x)

    return out
end

function norm_cdf_inverse_acklam(x::Float64)
    # Peter J. Acklam

    # Rational approximation for lower region
    if x < plow
       q = sqrt(-2*log(x))
       return (((((c[1]*q+c[2])*q+c[3])*q+c[4])*q+c[5])*q+c[6]) / ((((d[1]*q+d[2])*q+d[3])*q+d[4])*q+1)
    end

    # Rational approximation for upper region
    if phigh < x
       q = sqrt(-2*log(1-x))
       return -(((((c[1]*q+c[2])*q+c[3])*q+c[4])*q+c[5])*q+c[6]) / ((((d[1]*q+d[2])*q+d[3])*q+d[4])*q+1)
    end

    # Rational approximation for central region
    q = x - 0.5
    r = q*q
    return (((((a[1]*r+a[2])*r+a[3])*r+a[4])*r+a[5])*r+a[6])*q / (((((b[1]*r+b[2])*r+b[3])*r+b[4])*r+b[5])*r+1)
end

end