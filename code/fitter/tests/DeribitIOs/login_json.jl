#########
@info "DeribitIOs.login_json -- output matches expectation"
CLIENT_ID = "CLIENT_ID"
CLIENT_SECRET = "CLIENT_SECRET"

@test DeribitIOs.login_json(CLIENT_ID, CLIENT_SECRET) == "{\"method\":\"public/auth\",\"params\":{\"client_secret\":\"$CLIENT_SECRET\",\"grant_type\":\"client_credentials\",\"client_id\":\"$CLIENT_ID\"},\"jsonrpc\":\"2.0\",\"id\":\"authentication\"}"
#########