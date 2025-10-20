#!/usr/bin/with-contenv bashio

echo "🚗 Starting EMHASS EV Extension..."

# Set configuration directory for EMHASS EV
CONFIG_PATH="/share/emhass-ev"
mkdir -p "${CONFIG_PATH}"

# Create config.json from Home Assistant options
CONFIG_FILE="${CONFIG_PATH}/config.json"

echo "Creating EV config at $CONFIG_FILE"

# Build base configuration
cat > "$CONFIG_FILE" << 'EOF'
{
  "retrieve_hass_conf": {
    "hass_url": "http://supervisor/core",
    "long_lived_token": "",
    "time_zone": "Europe/Brussels",
    "lat": 50.8505,
    "lon": 4.3488,
    "alt": 100
  },
  "optim_conf": {
    "set_use_battery": true,
    "delta_forecast": 1,
    "weather_forecast_method": "scrapper",
    "load_forecast_method": "naive",
    "load_cost_forecast_method": "hp_hc_periods",
    "optimization_time_step": 60,
    "historic_days_to_retrieve": 2,
    "method_ts_round": "first",
    "number_of_deferrable_loads": 0,
    "nominal_power_of_deferrable_loads": [],
    "operating_hours_of_each_deferrable_load": [],
    "treat_deferrable_load_as_semi_cont": [],
    "set_deferrable_load_single_constant": [],
    "number_of_ev_loads": 1,
    "ev_battery_capacity": [75000],
    "ev_charging_efficiency": [0.9],
    "ev_nominal_charging_power": [11000],
    "ev_minimum_charging_power": [1400],
    "ev_consumption_efficiency": [0.2]
  },
  "plant_conf": {
    "P_grid_max": 9000,
    "module_model": ["PVLib_test"],
    "inverter_model": ["PVLib_test"],
    "surface_tilt": [30],
    "surface_azimuth": [180],
    "modules_per_string": [10],
    "strings_per_inverter": [1],
    "battery_discharge_power_max": 1000,
    "battery_charge_power_max": 1000,
    "battery_nominal_energy_capacity": 5000,
    "battery_minimum_state_of_charge": 0.3,
    "battery_maximum_state_of_charge": 0.9,
    "battery_target_state_of_charge": 0.6,
    "battery_discharge_efficiency": 0.95,
    "battery_charge_efficiency": 0.95,
    "inverter_is_hybrid": false,
    "compute_curtailment": false
  }
}
EOF

# Update with Home Assistant add-on options
if [ -f "/data/options.json" ]; then
    echo "Reading configuration from Home Assistant options"
    
    # Standard config updates
    if bashio::config.exists 'time_zone'; then
        TIME_ZONE=$(bashio::config 'time_zone')
        jq --arg time_zone "$TIME_ZONE" '.retrieve_hass_conf.time_zone = $time_zone' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    fi
    
    if bashio::config.exists 'latitude'; then
        LAT=$(bashio::config 'latitude')
        jq --argjson lat "$LAT" '.retrieve_hass_conf.lat = $lat' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    fi
    
    if bashio::config.exists 'longitude'; then
        LON=$(bashio::config 'longitude')
        jq --argjson lon "$LON" '.retrieve_hass_conf.lon = $lon' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    fi
    
    # EV-specific parameters
    if bashio::config.exists 'number_of_ev_loads'; then
        EV_LOADS=$(bashio::config 'number_of_ev_loads')
        jq --argjson number_of_ev_loads "$EV_LOADS" '.optim_conf.number_of_ev_loads = $number_of_ev_loads' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    fi
    
    if bashio::config.exists 'ev_battery_capacity'; then
        EV_CAPACITY=$(bashio::config 'ev_battery_capacity')
        jq --argjson ev_battery_capacity "$EV_CAPACITY" '.optim_conf.ev_battery_capacity = $ev_battery_capacity' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    fi
    
    if bashio::config.exists 'ev_charging_efficiency'; then
        EV_EFF=$(bashio::config 'ev_charging_efficiency')
        jq --argjson ev_charging_efficiency "$EV_EFF" '.optim_conf.ev_charging_efficiency = $ev_charging_efficiency' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    fi
    
    if bashio::config.exists 'ev_nominal_charging_power'; then
        EV_POWER=$(bashio::config 'ev_nominal_charging_power')
        jq --argjson ev_nominal_charging_power "$EV_POWER" '.optim_conf.ev_nominal_charging_power = $ev_nominal_charging_power' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    fi
    
    if bashio::config.exists 'ev_minimum_charging_power'; then
        EV_MIN_POWER=$(bashio::config 'ev_minimum_charging_power')
        jq --argjson ev_minimum_charging_power "$EV_MIN_POWER" '.optim_conf.ev_minimum_charging_power = $ev_minimum_charging_power' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    fi
    
    if bashio::config.exists 'ev_consumption_efficiency'; then
        EV_CONSUMPTION=$(bashio::config 'ev_consumption_efficiency')
        jq --argjson ev_consumption_efficiency "$EV_CONSUMPTION" '.optim_conf.ev_consumption_efficiency = $ev_consumption_efficiency' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    fi
fi

# Set environment variables
export EMHASS_PORT=5003
export EMHASS_DATA_PATH="${CONFIG_PATH}"

echo "Starting EMHASS EV on port 5003"
echo "Config path: ${CONFIG_PATH}"

# Activate virtual environment and start EMHASS EV
source /app/.venv/bin/activate
cd /app || exit

# Start EMHASS web application
exec python -m emhass.web_server --host 0.0.0.0 --port 5003

# Find the EMHASS installation
EMHASS_PATH=$(find /usr -name "emhass" -type d -path "*/site-packages/*" | head -1)
echo "📦 EMHASS found at: ${EMHASS_PATH}"

# Change to the directory containing EMHASS
cd "$(dirname "${EMHASS_PATH}")"
echo "📍 Working directory: $(pwd)"

# Test Python import
echo "🧪 Testing EMHASS import..."
python3 -c "import emhass; print('✅ EMHASS import successful')" || echo "❌ EMHASS import failed"

# Force EMHASS to use our isolated configuration by bind mounting
echo "🚀 Starting EMHASS EV web server with config: ${EMHASS_CONFIG_PATH}"

# Create a temporary isolated /share for this container
TEMP_SHARE="/tmp/emhass-ev-share"
mkdir -p "${TEMP_SHARE}"

# Copy our config to the temp share location
cp "${EMHASS_CONFIG_PATH}" "${TEMP_SHARE}/config.json"
echo "📋 Copied config to isolated share: ${TEMP_SHARE}/config.json"

# Set environment variables to point EMHASS to our isolated paths
export EMHASS_ROOT="${CONFIG_PATH}"
export EMHASS_CONF_DIR="${CONFIG_PATH}"
export EMHASS_DATA_DIR="${CONFIG_PATH}"
export SHARE_PATH="${TEMP_SHARE}"

# Create a python wrapper to start EMHASS with proper path
cat > /tmp/emhass_ev_start.py << 'PYTHON_EOF'
import sys
import os
import shutil

# Set up path isolation
isolated_share = "/tmp/emhass-ev-share"
config_path = os.environ.get("EMHASS_CONFIG_PATH")

# Monkey patch the config loading
def patch_config_paths():
    import emhass
    
    # Try to find and patch common config loading patterns
    original_open = open
    
    def patched_open(file, *args, **kwargs):
        if isinstance(file, str):
            # Redirect /share/config.json to our isolated config
            if file == "/share/config.json" or file.endswith("/share/config.json"):
                print(f"🔄 Redirecting config file access from {file} to {config_path}")
                return original_open(config_path, *args, **kwargs)
            # Redirect other /share/ paths to our isolated share
            elif file.startswith("/share/"):
                new_path = file.replace("/share/", isolated_share + "/")
                print(f"🔄 Redirecting share access from {file} to {new_path}")
                os.makedirs(os.path.dirname(new_path), exist_ok=True)
                return original_open(new_path, *args, **kwargs)
        
        return original_open(file, *args, **kwargs)
    
    # Apply the patch
    import builtins
    builtins.open = patched_open

# Apply patches before importing EMHASS modules
patch_config_paths()

# Now start EMHASS web server
from emhass import web_server
sys.argv = ['emhass.web_server', '--host', '0.0.0.0', '--port', os.environ.get('EMHASS_PORT', '5003')]
web_server.main()
PYTHON_EOF

echo "📍 Working directory: $(pwd)"
echo "� Isolated config: ${EMHASS_CONFIG_PATH}"
echo "🔄 Using path redirection wrapper"

# Start EMHASS with path redirection
cd "${CONFIG_PATH}"
exec python3 /tmp/emhass_ev_start.py
