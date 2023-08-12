#########
@info "NormalDistributionMethods.norm_cdf_polya -- cdf(0.5)"
@test NormalDistributionMethods.norm_cdf_polya(0.5) == 0.6914624612738499
#########




#########
@info "NormalDistributionMethods.norm_cdf_polya -- cdf(-0.5)"
@test NormalDistributionMethods.norm_cdf_polya(-0.5) == 0.3085375387261501
#########




#########
@info "NormalDistributionMethods.norm_cdf_polya -- cdf(0.0)"
@test NormalDistributionMethods.norm_cdf_polya(0.0) == 0.5
#########