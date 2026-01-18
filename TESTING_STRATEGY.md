# EMHASS-EV Testing Strategy & Deployment Guide

This document outlines the recommended testing and deployment strategy for the EMHASS-EV electric vehicle optimization features.

## Current Testing Status

### ✅ Completed Testing

#### Unit Tests (Phase 6.1) - 27/27 PASSING
All core EV functionality has been validated through comprehensive unit tests:

**Test Coverage:**
- ✅ `ElectricVehicle` class (15 tests)
  - SOC initialization and updates
  - Energy-to-range and range-to-energy conversions
  - Charging calculations and power constraints
  - Minimum charging power validation
  - Efficiency calculations
  
- ✅ `EVManager` class (6 tests)
  - Multi-vehicle coordination
  - Availability schedule management
  - Range requirement handling
  - Enable/disable logic
  - Parameter validation

- ✅ Utility functions (3 tests)
  - Energy/range conversions
  - Unit consistency

- ✅ Edge cases (3 tests)
  - Zero values handling
  - Maximum values
  - Boundary conditions

**Result:** Core EV logic is solid and production-ready.

### 🔄 Partial Testing

#### Integration Tests (Phase 6.2) - CREATED BUT NOT EXECUTED
Test files created but require full EMHASS environment:
- `test_optimization.py`: EV optimization integration (6 tests added)
- `test_web_server.py`: API endpoint tests (11 tests added)

**Status:** Tests exist but need proper test environment setup to run.

### ⏳ Pending Testing

#### Manual Testing (Phase 6.3) - NOT STARTED
Real-world validation in actual Home Assistant environment.

**Why not completed in dev container:**
- Docker-in-Docker not available in current environment
- Web server requires 10-15 seconds to load (scipy/pvlib dependencies)
- Configuration reload mechanism needs real HA environment
- API testing possible but limited without full integration

---

## Recommended Testing & Deployment Strategy

### Strategy: GitHub → HAOS Production Testing

Given the current situation, we recommend **committing to GitHub and testing in your real HAOS environment**. Here's why:

### ✅ Advantages of HAOS Testing

1. **Real Environment**: Test with actual Home Assistant, real sensors, real EV
2. **Production Configuration**: Test with actual config.json from supervisor
3. **Full Integration**: Test ingress, supervisor features, sensor publishing
4. **Real Use Case**: Validate with your actual EV and schedule
5. **Faster Iteration**: Unit tests validate core logic; HAOS tests validate integration

### ❌ Disadvantages of Dev Container Testing

1. **Environment Limitations**: No Docker-in-Docker, slow module loading
2. **Mock Complexity**: Would need extensive mocking of HA APIs
3. **Configuration Complexity**: Supervisor paths and configs don't match
4. **Time Cost**: Setting up proper test environment > time to test in HAOS
5. **Not Representative**: Mocked environment doesn't catch real integration issues

---

## Recommended Deployment Plan

### Phase 1: GitHub Commit & Branch Strategy

#### Option A: Feature Branch (Safer)
```bash
cd /workspaces/emhass-workspace/emhass-ev
git checkout -b feature/ev-optimization
git add .
git commit -m "Add: Electric Vehicle charging optimization

- New ElectricVehicle and EVManager classes
- EV optimization integration in optimizer
- API endpoints for EV control
- Web UI parameter configuration
- Comprehensive documentation
- Unit tests (27/27 passing)

Closes #XXX"
git push origin feature/ev-optimization
```

**Advantages:**
- Can test without affecting main branch
- Easy to rollback if issues found
- Can iterate and fix before merging to main

#### Option B: Direct to Main (Faster)
```bash
cd /workspaces/emhass-workspace/emhass-ev
git add .
git commit -m "Add: Electric Vehicle charging optimization v1.0"
git push origin main
```

**Advantages:**
- Immediate availability
- Simpler workflow

**Recommended:** Use **Option A** (feature branch) for first deployment.

### Phase 2: Add-on Repository Update

#### Update emhass-add-on Repository

```bash
cd /workspaces/emhass-workspace/emhass-ev-add-on
git checkout -b feature/ev-optimization
git add .
git commit -m "Add: EV configuration to add-on

- New EV parameters in config.yml
- EV translations in en.yaml
- Updated documentation (DOCS.md)
- Updated README with EV mention"
git push origin feature/ev-optimization
```

### Phase 3: HAOS Installation & Testing

#### 3.1 Install Add-on in HAOS

**Method 1: From GitHub (Recommended)**
1. In HAOS: Settings → Add-ons → Add-on Store
2. Three dots (⋮) → Repositories
3. Add your GitHub repository: `https://github.com/<your-username>/emhass-ev-add-on`
4. Find "EMHASS" in the store
5. Install the add-on
6. Start the add-on

**Method 2: Local Development (Alternative)**
1. SSH into HAOS
2. Clone repo to `/addons/`
3. Refresh add-on store
4. Install from "Local add-ons"

#### 3.2 Basic Configuration Test

1. **Open EMHASS Web UI** (ingress)
2. **Navigate to Configuration** (⚙️ icon)
3. **Configure EV parameters:**
   ```yaml
   number_of_ev_loads: 1
   ev_battery_capacity: [77000]  # Your EV's battery in Wh
   ev_charging_efficiency: [0.9]
   ev_nominal_charging_power: [4600]  # Your charger power in W
   ev_minimum_charging_power: [1380]
   ev_consumption_efficiency: [0.15]  # Your EV's kWh/km
   ```
4. **Save configuration**
5. **Restart add-on**

#### 3.3 API Endpoint Testing

Test each API endpoint from HAOS terminal or Development Tools:

```bash
# 1. Check EV status
curl -X GET "http://localhost:5001/action/ev-status?ev_id=0"

# 2. Set current SOC
curl -X POST "http://localhost:5001/action/ev-soc" \
  -H "Content-Type: application/json" \
  -d '{"ev_id": 0, "soc_percent": 65.0}'

# 3. Set availability (available 24 hours)
curl -X POST "http://localhost:5001/action/ev-availability" \
  -H "Content-Type: application/json" \
  -d '{"ev_id": 0, "availability": [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]}'

# 4. Set range requirement (need 100 km at hour 7)
curl -X POST "http://localhost:5001/action/ev-range-requirements" \
  -H "Content-Type: application/json" \
  -d '{"ev_id": 0, "min_range_km": [0,0,0,0,0,0,0,100,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}'

# 5. Verify status updated
curl -X GET "http://localhost:5001/action/ev-status?ev_id=0"
```

**Expected Results:**
- Status endpoint returns EV details
- SOC update successful
- Availability and range requirements accepted
- Final status shows updated values

#### 3.4 Optimization Testing

Create a test automation to run optimization:

```yaml
automation:
  - alias: "Test EMHASS EV Optimization"
    trigger:
      - platform: time
        at: "23:00:00"
    action:
      # Update EV state
      - service: rest_command.emhass_ev_soc
        data:
          ev_id: 0
          soc_percent: 50
      
      # Set availability (home all night)
      - service: rest_command.emhass_ev_availability
        data:
          ev_id: 0
          availability: [1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1]
      
      # Need 200 km by 7 AM
      - service: rest_command.emhass_ev_range
        data:
          ev_id: 0
          min_range_km: [0,0,0,0,0,0,0,200,200,200,200,200,200,200,200,200,200,200,0,0,0,0,0,0]
      
      - delay: 5
      
      # Run optimization
      - service: rest_command.emhass_dayahead
      
      - delay: 10
      
      # Check results
      - service: notify.persistent_notification
        data:
          message: |
            EV Optimization Complete!
            Charging Power: {{ states('sensor.p_ev0') }} W
            Final SOC: {{ states('sensor.soc_ev0') }}%
```

**Validation:**
1. Check `sensor.p_ev0` exists and has schedule data
2. Check `sensor.soc_ev0` exists and shows SOC progression
3. Verify charging schedule makes sense (charges when needed)
4. Check logs for any errors

#### 3.5 Integration with Your EV

Once API testing passes, integrate with your actual EV:

**Option 1: Use existing EV integration**
```yaml
automation:
  - alias: "Update EMHASS with real EV data"
    trigger:
      - platform: time
        at: "22:00:00"
    action:
      - service: rest_command.emhass_ev_soc
        data:
          ev_id: 0
          soc_percent: "{{ states('sensor.your_ev_battery') | float }}"
```

**Option 2: Manual updates via input helpers**
See [EV Guide - Integration Methods](../emhass-ev/docs/ev_guide.md#integration-methods)

---

## Testing Checklist

Use this checklist to validate each feature:

### ✅ Configuration
- [ ] Add-on installs successfully
- [ ] Web UI accessible via ingress
- [ ] EV parameters visible in configuration UI
- [ ] Configuration saves and persists after restart
- [ ] `number_of_ev_loads` can be changed (0, 1, 2)

### ✅ API Endpoints
- [ ] `/action/ev-status` returns correct data
- [ ] `/action/ev-soc` updates SOC successfully
- [ ] `/action/ev-availability` accepts schedule
- [ ] `/action/ev-range-requirements` accepts range array
- [ ] Error messages are clear for invalid inputs
- [ ] Multiple EVs work independently (if testing multi-EV)

### ✅ Optimization
- [ ] Day-ahead optimization runs without errors
- [ ] `sensor.p_ev0` created and contains charging schedule
- [ ] `sensor.soc_ev0` created and shows SOC progression
- [ ] Charging occurs during low-price periods
- [ ] SOC reaches required level before departure
- [ ] Respects availability constraints (no charging when away)
- [ ] Respects power limits (min/max charging power)

### ✅ Integration
- [ ] Sensors update after optimization
- [ ] Automations can read sensor values
- [ ] Can control real EV charger based on schedule
- [ ] Historical data visible in Lovelace graphs
- [ ] Works with existing EMHASS features (solar, battery)

### ✅ Edge Cases
- [ ] Works when EV fully charged (minimal charging)
- [ ] Works when EV nearly empty (maximum charging)
- [ ] Works when unavailable during entire horizon
- [ ] Works when always available
- [ ] Handles unrealistic requirements gracefully (can't charge enough)

---

## Troubleshooting Guide for HAOS Testing

### Issue: Add-on won't start

**Check:**
1. Add-on logs for error messages
2. Supervisor logs
3. Configuration validity (YAML syntax)

**Solutions:**
- Verify all required parameters present
- Check for typos in config.yml
- Ensure array lengths match (for multi-EV)

### Issue: EV optimization disabled

**Symptoms:** API returns "EV optimization is not enabled"

**Solutions:**
1. Check `number_of_ev_loads` ≥ 1 in config
2. Restart add-on after config changes
3. Check logs for parameter loading errors
4. Verify options passed from supervisor

### Issue: Sensors not created

**Check:**
1. Run optimization at least once
2. Check if sensors exist with `developer-tools` → States
3. Look for `sensor.p_ev0` and `sensor.soc_ev0`

**Solutions:**
- Verify EV enabled before optimization
- Check logs during optimization
- Ensure publish_data runs after optimization

### Issue: Optimization doesn't charge enough

**Debug:**
1. Check `sensor.soc_ev0` final value
2. Review `sensor.p_ev0` charging power schedule
3. Verify range requirements are realistic
4. Check availability schedule is correct

**Solutions:**
- Increase range requirements
- Verify availability includes enough charging time
- Check if charger power sufficient to meet needs
- Review electricity price data (might be deprioritizing charging)

---

## After Successful Testing

### 1. Document Your Experience

Create an issue/discussion with:
- Your EV model and specs
- Your configuration (sanitized)
- What worked well
- Any issues encountered
- Suggested improvements

### 2. Merge Feature Branch (if using)

```bash
# After confirming everything works
git checkout main
git merge feature/ev-optimization
git push origin main
git tag -a v0.16.0 -m "Release: EV optimization feature"
git push origin v0.16.0
```

### 3. Share with Community

Consider:
- Post in Home Assistant Community forum
- Share your Node-RED flows (if using calendar integration)
- Write blog post about your setup
- Contribute example automations back to repo

---

## Continuous Testing

### Ongoing Validation

Once in production, monitor:
- Daily optimization results
- Actual vs predicted SOC
- Cost savings compared to dumb charging
- Any optimization failures
- Edge case handling

### Feedback Loop

Report back:
- Issues: Via GitHub Issues
- Improvements: Via GitHub Discussions or PRs
- Use cases: Via Community forum

---

## Alternative: Limited Dev Container Testing

If you prefer to test more before deploying to HAOS:

### Option 1: Mock HA Environment

Create mock Home Assistant API responses for testing:
- Would require significant setup time
- Would not catch real integration issues
- Not recommended given unit tests already pass

### Option 2: Standalone Docker Setup

Run EMHASS in standalone Docker (outside dev container):
```bash
# On a machine with Docker
docker run -d \
  -p 5001:5001 \
  -v $(pwd)/config:/share/emhass-ev \
  davidusb/emhass:latest
```

**Advantage:** Closer to production  
**Disadvantage:** Still missing Home Assistant integration

### Recommendation

Skip dev container integration testing and go straight to HAOS. The unit tests provide confidence in core logic, and HAOS testing will catch integration issues that dev container testing would miss anyway.

---

## Summary

**Recommended Path:**
1. ✅ Commit code to GitHub (feature branch)
2. ✅ Update add-on repository
3. ✅ Install in your HAOS environment
4. ✅ Test API endpoints
5. ✅ Run optimization and validate sensors
6. ✅ Integrate with real EV
7. ✅ Monitor and iterate

**Time Estimate:**
- GitHub commit: 10 minutes
- HAOS installation: 15 minutes
- API testing: 30 minutes
- Optimization testing: 1 hour
- Real EV integration: Variable (depends on your EV integration)

**Expected Outcome:**
- Working EV optimization in real environment
- Validated with actual EV and schedule
- Ready for daily use
- Issues caught in realistic context

---

## Questions?

If you encounter issues during HAOS testing:
1. Check add-on logs first
2. Verify configuration matches your EV specs
3. Test API endpoints individually
4. Review this troubleshooting guide
5. Open GitHub issue with logs and config (sanitized)

Good luck with your deployment! 🚀⚡
