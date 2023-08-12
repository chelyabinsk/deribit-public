#########
@info "NormalDistributionMethods.norm_pdf_simple -- pdf(0.5)"
@test NormalDistributionMethods.norm_pdf_simple(0.5) == 0.3520653267642995
#########




#########
@info "NormalDistributionMethods.norm_pdf_simple -- pdf(-0.5)"
@test NormalDistributionMethods.norm_pdf_simple(-0.5) == 0.3520653267642995
#########




#########
@info "NormalDistributionMethods.norm_pdf_simple -- pdf(0.0)"
@test NormalDistributionMethods.norm_pdf_simple(0.0) == 0.3989422804014327
#########