<!-- markdown file presented on the documentation tab -->

# EMHASS Add-on

<div>
 <a style="text-decoration:none" href="https://emhass.readthedocs.io/en/latest/">
      <img src="https://raw.githubusercontent.com/davidusb-geek/emhass/master/docs/images/Documentation_button.svg" alt="EMHASS Documentation">
  </a>
   <a style="text-decoration:none" href="https://community.home-assistant.io/t/emhass-an-energy-management-for-home-assistant/338126">
      <img src="https://raw.githubusercontent.com/davidusb-geek/emhass/master/docs/images/Community_button.svg" alt="Community">
  </a>
  <a style="text-decoration:none" href="https://github.com/davidusb-geek/emhass/issues">
      <img src="https://raw.githubusercontent.com/davidusb-geek/emhass/master/docs/images/Issues_button.svg" alt="Issues">
  </a>
  <a style="text-decoration:none" href="https://github.com/davidusb-geek/emhass-add-on">
     <img src="https://raw.githubusercontent.com/davidusb-geek/emhass/master/docs/images/EMHASS_Add_on_button.svg" alt="EMHASS Add-on">
  </a>
  <a style="text-decoration:none" href="https://github.com/davidusb-geek/emhass">
     <img src="https://raw.githubusercontent.com/davidusb-geek/emhass/master/docs/images/EMHASS_button.svg" alt="EMHASS">
  </a>
</div>

---

### A Home Assistant Add-on for the EMHASS (Energy Management for Home Assistant) module

</br>

<div style="display: flex;">
This add-on uses the EMHASS core module from the following GitHub repository:
&nbsp; &nbsp;
<a style="text-decoration:none" href="https://github.com/davidusb-geek/emhass">
    <img src="https://raw.githubusercontent.com/davidusb-geek/emhass/master/docs/images/EMHASS_button.svg" alt="EMHASS">
</a>
</div>

</br>

<div style="display: flex;">
The complete documentation for this module can be found here:
&nbsp; &nbsp;
<a style="text-decoration:none" href="https://emhass.readthedocs.io/en/latest/">
    <img src="https://raw.githubusercontent.com/davidusb-geek/emhass/master/docs/images/Documentation_button.svg" alt="Documentation">
</a>
</div>

</br>

<div style="display: flex;">
For any questions on EMHASS or EMHASS-Add-on:
&nbsp; &nbsp;
<a style="text-decoration:none" href="https://community.home-assistant.io/t/emhass-an-energy-management-for-home-assistant/338126">
    <img src="https://raw.githubusercontent.com/davidusb-geek/emhass/master/docs/images/Community_button.svg" alt="Community">
</a>
</div>

</br>

<div style="display: flex;">
For any Issues/Feature Requests for the EMHASS core module, create a new issue here:
&nbsp; &nbsp;
<a style="text-decoration:none" href="https://github.com/davidusb-geek/emhass/issues">
    <img src="https://raw.githubusercontent.com/davidusb-geek/emhass/master/docs/images/Issues_button.svg" alt="Issues">
</a>
</div>

## Electric Vehicle (EV) Charging Optimization

EMHASS-EV extends the original EMHASS with support for optimizing electric vehicle charging. The system can optimize when to charge your EV based on:

- Solar production forecasts
- Energy prices (dynamic tariffs)
- Trip planning and required range
- Vehicle availability (home/away)
- Battery capacity and charging efficiency

### EV Configuration

To enable EV optimization, configure the following parameters in the add-on configuration:

#### Basic EV Settings

- **number_of_ev_loads**: Number of EVs to optimize (set to 0 to disable EV optimization, 1-5 for multiple vehicles)
- **ev_battery_capacity**: Battery capacity in Wh (JSON array, e.g., `[77000]` for 77 kWh)
- **ev_charging_efficiency**: Charging efficiency 0-1 (JSON array, e.g., `[0.9]` for 90%)
- **ev_nominal_charging_power**: Maximum charging power in W (JSON array, e.g., `[4600]` for 4.6 kW charger)
- **ev_minimum_charging_power**: Minimum charging power when charging in W (JSON array, e.g., `[1380]`)
- **ev_consumption_efficiency**: Vehicle energy consumption in kWh/km (JSON array, e.g., `[0.15]`)

#### Multi-Vehicle Example

For two vehicles:
```json
{
  "number_of_ev_loads": 2,
  "ev_battery_capacity": "[77000, 40000]",
  "ev_charging_efficiency": "[0.9, 0.85]",
  "ev_nominal_charging_power": "[4600, 3680]",
  "ev_minimum_charging_power": "[1380, 1150]",
  "ev_consumption_efficiency": "[0.15, 0.18]"
}
```

### EV API Endpoints

EMHASS-EV provides several API endpoints to communicate EV data:

#### Set State of Charge (SOC)
```bash
curl -X POST http://localhost:5001/action/ev-soc \
  -H "Content-Type: application/json" \
  -d '{"ev_id": 0, "soc_percent": 65.5}'
```

#### Set Vehicle Availability
Provide a time-series array indicating when the vehicle is available for charging (1 = available, 0 = away):
```bash
curl -X POST http://localhost:5001/action/ev-availability \
  -H "Content-Type: application/json" \
  -d '{"availability": [1,1,1,0,0,0,1,1,1,1...]}'
```

#### Set Minimum Range Requirements
Provide minimum required range in km for each time step:
```bash
curl -X POST http://localhost:5001/action/ev-range-requirements \
  -H "Content-Type: application/json" \
  -d '{"min_range_km": [0,0,0,150,150,200,0,0...]}'
```

#### Get EV Status
```bash
curl http://localhost:5001/action/ev-status?ev_id=0
```

### Home Assistant Sensors

After optimization, EMHASS-EV publishes the following sensors to Home Assistant:

- **sensor.p_ev0**, **sensor.p_ev1**, etc.: Optimal charging power schedule (W) for each EV
- **sensor.soc_ev0**, **sensor.soc_ev1**, etc.: Predicted state of charge (%) for each EV

These sensors can be used in automations to control your EV charger.

### Example Automation

Here's an example automation to control an EV charger based on EMHASS optimization:

```yaml
automation:
  - alias: "EMHASS EV Charging Control"
    trigger:
      - platform: state
        entity_id: sensor.p_ev0
    action:
      - choose:
          - conditions:
              - condition: template
                value_template: "{{ states('sensor.p_ev0')|float(0) > 0 }}"
            sequence:
              - service: switch.turn_on
                entity_id: switch.ev_charger
              - service: number.set_value
                target:
                  entity_id: number.ev_charger_current
                data:
                  value: "{{ (states('sensor.p_ev0')|float(0) / 230) | round(1) }}"
        default:
          - service: switch.turn_off
            entity_id: switch.ev_charger
```

### Integration with Google Calendar (Node-RED)

For automatic trip planning, you can integrate Google Calendar events using Node-RED:

1. **Google Calendar Integration**: Set up Google Calendar integration in Home Assistant
2. **Node-RED Flow**: Create a flow that:
   - Reads upcoming calendar events
   - Extracts destination addresses from event locations
   - Calculates distance to destination (using Google Maps/HERE API)
   - Converts distance to energy requirements
   - Generates availability array (0 during trip, 1 when home)
   - Generates minimum range array (required range before trip)
   - Posts data to EMHASS-EV API endpoints

A detailed Node-RED flow example and setup guide will be provided in future documentation updates.

### Web Interface

The EMHASS web interface (accessible at `http://homeassistant.local:5001` or via Ingress) includes:

- **Configuration Tab**: Configure all EV parameters
- **Optimization Charts**: View charging power (P_EV) and battery SOC schedules
- **Results Table**: Detailed optimization results including P_EV and SOC_EV for each time step

---

## Developing EMHASS/EMHASS-Add-on

#### **EMHASS**
For those who want to develop the EMHASS package itself. Have a look at the [Develop page](https://emhass.readthedocs.io/en/latest/develop.html). _(EMHASS docs)_ 

#### **EMHASS-Add-on**
For those who want to test the EMHASS addon _(EMHASS inside of a virtual Home Assistant Environment)_. Have a look at [Test Markdown](./emhass/Test.md).

## License

MIT License

Copyright (c) 2021-2023 David HERNANDEZ

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
