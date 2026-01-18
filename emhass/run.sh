#!/usr/bin/with-contenv bashio
# ==============================================================================
# Start EMHASS-EV
# ==============================================================================

bashio::log.info "Starting EMHASS-EV..."

# Create EMHASS-EV data directory if it doesn't exist
mkdir -p /share/emhass-ev

# Export configuration from add-on options
# Use /share/emhass-ev/ for all data to avoid conflicts with standard EMHASS
export DATA_PATH="/share/emhass-ev/"
export CONFIG_PATH="/share/emhass-ev/config.json"
export OPTIONS_PATH="/data/options.json"
export PORT="5001"

# Start EMHASS web server
cd /app
python3 -m emhass.web_server
