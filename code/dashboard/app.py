#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# gunicorn --workers 4 wsgi:app --log-level debug

from flask import Flask, render_template, url_for, send_from_directory
from flask_sock import Sock

import redis
import json
import time
from datetime import datetime
import os
import subprocess

from helpers.tables import compute_implied_probabilities_plot
from helpers.tables import zeta_profile_plot
from helpers.tables import compute_future_term_structure
from helpers.tables import vol_structure
from helpers.tables import quoting_screen_table_data

app = Flask(__name__)
app.config["SOCK_SERVER_OPTIONS"] = {"ping_interval": 10}
sock = Sock(app)

REDIS_PASSWORD = "REDIS_PASSWORD"
redis_client = redis.Redis(host="redislocal", port=6379, db=0, password = REDIS_PASSWORD)

print("initialising")

@app.route('/')
def hello():
    return render_template('index.html')

@app.route("/favicon.ico", methods = ["GET"])
def favicon():
    return app.send_static_file('image/favicon.ico')

@app.route('/system_status')
def system_status():
    return render_template('system_status.html')

@app.route('/cancel_fitter', methods = ['GET'])
def cancel_fitter_handler():
    redis_client.set("fitter_status", "stopping")
    os.system('pkill -f "julia /app/code/code/fitter/main.jl"')
    redis_client.delete("__surface_fitter")
    redis_client.set("fitter_status", "stopped")
    return ""

@app.route('/restart_fitter_handler', methods = ['GET'])
def restart_fitter_handler():
    # Check if process is running
    julia_process_pid = str(subprocess.run(['pgrep', '-f', "/app/code/code/fitter/main.jl"], stdout=subprocess.PIPE).stdout,encoding="utf8")

    redis_client.set("fitter_status", "restarting")

    if julia_process_pid == "":
        os.system("julia /app/code/code/fitter/main.jl &")

    redis_client.set("fitter_status", "restarted")
    return ""

@app.route('/fitter_status', methods = ["GET"])
def fitter_status_handler():
    # Check if process is running
    julia_process_pid = str(subprocess.run(['pgrep', '-f', "julia /app/code/code/fitter/main.jl"], stdout=subprocess.PIPE).stdout,encoding="utf8")

    if julia_process_pid == [] or julia_process_pid == "":
        return {
            "fitter_status" : "cancelled",
            "last_fitter_ping_str" : "",
            "last_server_ping_str" : "",
            "response_description_str" : ""
        }

    fitter_status_str = redis_client.get("fitter_status")
    surface_fitter = redis_client.get("__surface_fitter")

    if surface_fitter is None:
        return {
            "fitter_status" : "starting",
            "last_fitter_ping_str" : "",
            "last_server_ping_str" : "",
            "response_description_str" : ""
        }
    else:
        now_time = time.time()
        surface_fitter = json.loads(surface_fitter)
        time_diff = now_time - surface_fitter["last_update_timestamp"]

        last_fitter_ping_str = datetime.fromtimestamp(surface_fitter["last_update_timestamp"]).strftime("%Y-%m-%d %H:%M:%S")
        last_server_ping_str = datetime.fromtimestamp(now_time).strftime("%Y-%m-%d %H:%M:%S")
        response_description_str = f"Last Server Update: {last_server_ping_str} <br> Last Fitter Update: {last_fitter_ping_str}"

        if abs(time_diff) < 10:
            return {
                "fitter_status" : "running",
                "last_fitter_ping_str" : last_fitter_ping_str,
                "last_server_ping_str" : last_server_ping_str,
                "response_description_str" : response_description_str
            }
        else:
            return {
                "fitter_status" : "cancelled",
                "last_fitter_ping_str" : last_fitter_ping_str,
                "last_server_ping_str" : last_server_ping_str,
                "response_description_str" : response_description_str
                }
    return fitter_status_str

@app.route('/volatility', methods = ['GET'])
def fitter_plots():
    expirations_map = redis_client.get("__expirations_map")
    if expirations_map is None:
        expirations_list = []
    else:
        expirations_map = json.loads(expirations_map)
        expirations_list = ["" for i in range(len(expirations_map))]
        for c, expiration_str in enumerate(expirations_map):
            expirations_list[expirations_map[expiration_str]["ttm_index"] - 1] = expiration_str
    return render_template('fitter_plots.html', expirations_list = expirations_list)

@app.route('/perpetual', methods = ['GET'])
def perpetual_future():
    return render_template('perpetual_future.html')
    pass

@app.route('/quoting', methods = ['GET'])
def quoting_tables():
    expirations_map = redis_client.get("__expirations_map")
    if expirations_map is None:
        expirations_list = []
    else:
        expirations_map = json.loads(expirations_map)
        expirations_list = ["" for i in range(len(expirations_map))]
        for c, expiration_str in enumerate(expirations_map):
            expirations_list[expirations_map[expiration_str]["ttm_index"] - 1] = expiration_str
    return render_template('quotes_tables.html', expirations_list = expirations_list)

@app.route("/implied_probabilities", methods = ["GET"])
def implied_probs():
    expirations_map = redis_client.get("__expirations_map")
    if expirations_map is None:
        expirations_list = []
    else:
        expirations_map = json.loads(expirations_map)
        expirations_list = ["" for i in range(len(expirations_map))]
        for c, expiration_str in enumerate(expirations_map):
            expirations_list[expirations_map[expiration_str]["ttm_index"] - 1] = expiration_str
    return render_template('implied_probabilities.html', expirations_list = expirations_list)

@app.route("/zeta_profile", methods = ["GET"])
def zeta_profile():
    expirations_map = redis_client.get("__expirations_map")
    if expirations_map is None:
        expirations_list = []
    else:
        expirations_map = json.loads(expirations_map)
        expirations_list = ["" for i in range(len(expirations_map))]
        for c, expiration_str in enumerate(expirations_map):
            expirations_list[expirations_map[expiration_str]["ttm_index"] - 1] = expiration_str
    return render_template('zeta_profile.html', expirations_list = expirations_list)

@app.route("/futures_term", methods = ["GET"])
def futures_term():
    return render_template('futures_term_structure.html')

@app.route("/atm_vol_structure", methods = ["GET"])
def atm_vol_structure():
    return render_template('atm_vol_structure.html')

@sock.route('/ws_data_point')
def ws_data_point(sock):
    first_response = sock.receive(timeout=10)  # Timeout after 10 seconds

    try:
        data_input = json.loads(first_response)
    except:
        sock.send(json.dumps({"error": "bad-format"}))
        return

    # Add data validation

    while True:
        resp = sock.receive(timeout=10)
        try:
            resp = json.loads(resp)
        except:
            sock.send(json.dumps({"error": "bad-format"}))
            return

        # Validate data
        if resp["message-type"] == "give-me-da-data":
            if resp["message-source"] == "/fitters":
                expiration_str = resp["request-body"]["selection-str"]
                surface_fitter = redis_client.get("__surface_fitter")
                expirations_map = redis_client.get("__expirations_map")
                if surface_fitter is not None:
                    surface_fitter = json.loads(surface_fitter)
                    expirations_map = json.loads(expirations_map)
                    sub_fitter_expiration_info = surface_fitter["sub_fitter_expiration_info"][expiration_str]

                    underlying_future_name = expirations_map[expiration_str]["full_underlying_name"]
                    underlying_price = surface_fitter["futures_orderbooks"][underlying_future_name]["computed_price"]

                    perpetual_future_name = "BTC-PERPETUAL"
                    perpetual_price = surface_fitter["futures_orderbooks"][perpetual_future_name]["computed_price"]

                    fitting_point_fair_strike = [{"x" : strike, "y" : 100*sub_fitter_expiration_info["fitting_point"][c]} for c, strike in enumerate(sub_fitter_expiration_info["strike"]) if sub_fitter_expiration_info["fitting_point"][c] is not None]
                    market_bid_point_strike = [{"x" : strike, "y" : 100*sub_fitter_expiration_info["market_bid_iv"][c]} for c, strike in enumerate(sub_fitter_expiration_info["strike"]) if sub_fitter_expiration_info["market_bid_iv"][c] is not None]
                    market_ask_point_strike = [{"x" : strike, "y" : 100*sub_fitter_expiration_info["market_ask_iv"][c]} for c, strike in enumerate(sub_fitter_expiration_info["strike"]) if sub_fitter_expiration_info["market_ask_iv"][c] is not None]

                    perpetual_forward_strike = [{"x" : perpetual_price, "y" : 0}, {"x" : perpetual_price, "y" : 1}]
                    underlying_forward_strike = [{"x" : underlying_price, "y" : 0}, {"x" : underlying_price, "y" : 1}]

                    fitting_point_fair_ns_strike = [{"x" : strike, "y" : 100*sub_fitter_expiration_info["fitting_point"][c]} for c, strike in enumerate(sub_fitter_expiration_info["ns_strike"]) if sub_fitter_expiration_info["fitting_point"][c] is not None]
                    market_bid_point_ns_strike = [{"x" : strike, "y" : 100*sub_fitter_expiration_info["market_bid_iv"][c]} for c, strike in enumerate(sub_fitter_expiration_info["ns_strike"]) if sub_fitter_expiration_info["market_bid_iv"][c] is not None]
                    market_ask_point_ns_strike = [{"x" : strike, "y" : 100*sub_fitter_expiration_info["market_ask_iv"][c]} for c, strike in enumerate(sub_fitter_expiration_info["ns_strike"]) if sub_fitter_expiration_info["market_ask_iv"][c] is not None]

                    perpetual_forward_ns_strike = [{"x" : 0, "y" : 0}, {"x" : 0, "y" : 1}]
                    underlying_forward_ns_strike = [{"x" : 0, "y" : 0}, {"x" : 0, "y" : 1}]

                    response_data = {
                        "message-name" : "send-updates",
                        "data" : {
                            "market_bid_point_strike" : market_bid_point_strike,
                            "fitting_point_fair_strike" : fitting_point_fair_strike,
                            "market_ask_point_strike" : market_ask_point_strike,
                            "underlying_future_name" : underlying_future_name,
                            "underlying_price" : underlying_price,
                            "perpetual_future_name" : perpetual_future_name,
                            "perpetual_price" : perpetual_price,
                            "perpetual_forward_strike" : perpetual_forward_strike,
                            "underlying_forward_strike" : underlying_forward_strike,

                            "fitting_point_fair_ns_strike" : fitting_point_fair_ns_strike,
                            "market_bid_point_ns_strike" : market_bid_point_ns_strike,
                            "market_ask_point_ns_strike" : market_ask_point_ns_strike,
                            "perpetual_forward_ns_strike" : perpetual_forward_ns_strike,
                            "underlying_forward_ns_strike" : underlying_forward_ns_strike,
                        }
                    }
                    sock.send(
                        json.dumps(response_data)
                    )
            elif resp["message-source"] == "/quoting":
                selected_expirations = resp["request-body"]["selected-expirations"]
                surface_fitter = redis_client.get("__surface_fitter")

                import random
                if surface_fitter is not None:
                    surface_fitter = json.loads(surface_fitter)
                    
                    if resp["request-body"]["request-count"] == 0:
                        output = {}
                        for expiration_str in surface_fitter["sub_fitter_expiration_info"]:
                            output[expiration_str] = {
                                    "add" : [
                                    {"row_number" : c,
                                     "strike" : f"{strike} ",
                                     "strike_colour" : "#000000",
                                     } for c,strike in enumerate(surface_fitter["sub_fitter_expiration_info"][expiration_str]["strike"])
                                ]
                            }

                        response_data = {
                            "message-name" : "send-updates",
                            "data" : output,
                            "request-count" : 0
                        }

                        sock.send(
                            json.dumps(response_data)
                        )

                    elif resp["request-body"]["request-count"] > 0:
                        output = {}
                        for expiration_str in surface_fitter["sub_fitter_expiration_info"]:
                            output[expiration_str] = {
                                    "update" : quoting_screen_table_data(redis_client, surface_fitter, expiration_str, resp["request-body"]["request-count"])
                            }

                        response_data = {
                            "message-name" : "send-updates",
                            "data" : output,
                            "request-count" : 0
                        }

                        sock.send(
                            json.dumps(response_data)
                        )
            elif resp["message-source"] == "/implied-probabilities":
                expiration_str = resp["request-body"]["selection-str"]
                surface_fitter = redis_client.get("__surface_fitter")
                expirations_map = redis_client.get("__expirations_map")
                if surface_fitter is not None:
                    surface_fitter = json.loads(surface_fitter)
                    expirations_map = json.loads(expirations_map)
                    sub_fitter_expiration_info = surface_fitter["sub_fitter_expiration_info"][expiration_str]

                    underlying_future_name = expirations_map[expiration_str]["full_underlying_name"]
                    underlying_price = surface_fitter["futures_orderbooks"][underlying_future_name]["computed_price"]

                    sock.send(
                        json.dumps({
                            "message-name" : "send-updates",
                            "data" : compute_implied_probabilities_plot(sub_fitter_expiration_info, underlying_future_name, underlying_price),
                            "request-count" : resp["request-body"]["request-count"]
                        })
                    )
            elif resp["message-source"] == "/zeta-profile":
                expiration_str = resp["request-body"]["selection-str"]
                surface_fitter = redis_client.get("__surface_fitter")
                expirations_map = redis_client.get("__expirations_map")
                if surface_fitter is not None:
                    surface_fitter = json.loads(surface_fitter)
                    expirations_map = json.loads(expirations_map)
                    sub_fitter_expiration_info = surface_fitter["sub_fitter_expiration_info"][expiration_str]

                    underlying_future_name = expirations_map[expiration_str]["full_underlying_name"]
                    underlying_price = surface_fitter["futures_orderbooks"][underlying_future_name]["computed_price"]

                    sock.send(
                        json.dumps({
                            "message-name" : "send-updates",
                            "data" : zeta_profile_plot(sub_fitter_expiration_info,  underlying_price, underlying_future_name),
                            "request-count" : resp["request-body"]["request-count"]
                        })
                    )
            elif resp["message-source"] =="/future-term-structure":
                sock.send(
                    json.dumps({
                        "message-name" : "send-updates",
                        "data" : compute_future_term_structure(redis_client),
                        "request-count" : 0
                    })
                )
            elif resp["message-source"] == "/atm-vol-structure":
                sock.send(
                    json.dumps({
                        "message-name" : "send-updates",
                        "data" : vol_structure(redis_client),
                        "request-count" : 0
                    })
                )
            
        time.sleep(1)

        
if __name__ == "__main__":
    app.run()
