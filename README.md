# 🚗⚡ EMHASS EV Charging Optimizer

**Electric Vehicle Charging Optimization Add-on for Home Assistant**

This is a **separate, enhanced** version of EMHASS specifically designed for **Electric Vehicle charging optimization**. It works **alongside** the original EMHASS add-on without any conflicts.

## 🎯 Key Features

### ✅ EV-Specific Capabilities
- **Availability Windows**: Define when your EV can charge using 0/1 arrays
- **Minimum SOC Requirements**: Set minimum battery levels for specific times  
- **Distance-Based Input**: Easy km-based consumption forecasting
- **Multi-EV Support**: Optimize multiple electric vehicles simultaneously
- **Smart Charging**: Integration with dynamic electricity pricing

### ✅ Complete Independence  
- **Separate Installation**: Runs alongside original EMHASS
- **Isolated Data**: Uses `/share/emhass-ev` directory
- **Different Port**: Port 5003 (vs 5002 for original EMHASS)
- **Custom Core**: Enhanced EMHASS with EV optimization features

## 🏠 Installation in Home Assistant

### Method 1: Add Custom Repository
```
Settings → Add-ons → Add-on Store → ⋮ → Repositories
Add: https://github.com/tomvanacker85/emhass-ev-addon
```

### Method 2: Manual Installation
1. Download the `emhass-ev/` folder
2. Copy to `/addons/local/emhass-ev/` in Home Assistant
3. Restart Home Assistant
4. Install from Local Add-ons

## ⚙️ Configuration

### Basic EV Setup
```yaml
number_of_ev_loads: 1
ev_battery_capacity: 
  - 75000                    # 75 kWh battery
ev_charging_efficiency:
  - 0.9                      # 90% charging efficiency  
ev_nominal_charging_power:
  - 11000                    # 11kW charger (3-phase 16A)
ev_consumption_efficiency:
  - 0.2                      # 0.2 kWh per km
```

### Multi-EV Configuration
```yaml
number_of_ev_loads: 2
ev_battery_capacity:
  - 75000                    # EV 1: Tesla Model 3 (75 kWh)
  - 50000                    # EV 2: Nissan Leaf (50 kWh)  
ev_nominal_charging_power:
  - 11000                    # EV 1: 11kW home charger
  - 7400                     # EV 2: 7.4kW portable charger
```

## 🚀 Usage Examples

### API Call with EV Parameters
```python
import requests

# Optimization with EV constraints
data = {
    "ev_soc_current": [50000],           # Current: 50kWh (67%)
    "ev_soc_target": [75000],            # Target: 75kWh (100%)
    "ev_availability": [1,1,1,0,0,0,1,1], # Available hours
    "ev_distance_forecast": [0,0,25,50,0] # Daily driving: 75km
}

response = requests.post(
    "http://homeassistant:5003/action/dayahead-optim",
    json=data
)
```

### Home Assistant Automation
```yaml
automation:
  - alias: "EV Charging Optimization"
    trigger:
      - platform: time
        at: "23:00:00"
    action:
      - service: rest_command.emhass_ev_optimization
        data:
          ev_soc_current: "{{ states('sensor.ev_battery_level') | float * 750 }}"
          ev_distance_forecast: "{{ states('input_number.tomorrow_distance') }}"
```

## 📊 Comparison with Original EMHASS

| **Feature** | **Original EMHASS** | **EMHASS EV Optimizer** |
|-------------|-------------------|------------------------|
| **Repository** | `davidusb-geek/emhass-add-on` | `tomvanacker85/emhass-ev-addon` |
| **Add-on Name** | "EMHASS" | "EMHASS EV Charging Optimizer" |
| **Port** | 5002 | 5003 |
| **Data Directory** | `/share/emhass` | `/share/emhass-ev` |
| **EV Features** | ❌ Basic deferrable loads | ✅ Full EV optimization |
| **Availability Windows** | ❌ No | ✅ 0/1 arrays |
| **SOC Management** | ❌ No | ✅ Current/target SOC |
| **Distance Input** | ❌ No | ✅ km-based forecasting |
| **Multi-EV** | ❌ No | ✅ Multiple vehicles |

## 🔧 Architecture

### Enhanced EMHASS Core
This add-on uses a **custom EMHASS fork** with EV extensions:
- **Source**: `tomvanacker85/emhass:feature/ev-charging-extension` 
- **Enhancements**: EV optimization algorithms, parameter validation, API extensions
- **Compatibility**: Fully compatible with EMHASS API structure

### Data Isolation
```
Home Assistant Data Structure:
├── /share/emhass/          # Original EMHASS data
├── /share/emhass-ev/       # EV Optimizer data  
│   ├── config_emhass.yaml  # EV-specific config
│   ├── secrets_emhass.yaml # EV credentials
│   ├── data/              # EV optimization results
│   └── logs/              # EV logs
```

## 🔄 Parallel Operation

Both add-ons can run simultaneously:

1. **Install original EMHASS** from `davidusb-geek/emhass-add-on`
2. **Install EV optimizer** from `tomvanacker85/emhass-ev-addon` 
3. **Configure separately** - no conflicts
4. **Use both** for different optimization scenarios

### Access Points
- **Original EMHASS**: `http://homeassistant:5002`
- **EV Optimizer**: `http://homeassistant:5003`

## 🎉 Benefits

### For EV Owners
- **Intelligent Charging**: Charge when electricity is cheapest
- **Availability Aware**: Respects your schedule and availability
- **SOC Guarantees**: Ensures minimum charge when needed
- **Easy Planning**: Simple km-based trip planning

### For Advanced Users  
- **Multi-EV Optimization**: Handle multiple vehicles optimally
- **API Integration**: Full programmatic control
- **Data Analytics**: Detailed charging and cost analysis
- **Home Automation**: Deep Home Assistant integration

## 📚 Documentation

- **Installation**: See this README
- **API Reference**: Compatible with EMHASS API + EV extensions
- **Configuration**: Home Assistant add-on UI
- **Troubleshooting**: Check `/share/emhass-ev/logs/`

## 🤝 Contributing

This is a **community-driven** enhancement of the excellent EMHASS project:
- **Original EMHASS**: https://github.com/davidusb-geek/emhass
- **EV Extensions**: https://github.com/tomvanacker85/emhass
- **This Add-on**: https://github.com/tomvanacker85/emhass-ev-addon

## 📄 License

Same as original EMHASS: MIT License

---

**🚗 Ready to optimize your EV charging? Install now and start saving!** ⚡