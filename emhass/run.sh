#!/usr/bin/with-contenv bashio
# ==============================================================================
# Start EMHASS-EV
# ==============================================================================

bashio::log.info "Starting EMHASS-EV..."

# Export configuration from add-on options
export DATA_PATH="/data/"
export CONFIG_PATH="/share/emhass-ev/config.json"
export OPTIONS_PATH="/data/options.json"

# Start EMHASS web server
cd /app
python3 -m emhass.web_server
