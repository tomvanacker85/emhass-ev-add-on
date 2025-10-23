# EMHASS EV Addon - Installation & Usage Guide

## 🎯 Repository Purpose

This repository provides a **separate, enhanced EMHASS add-on** specifically for **Electric Vehicle charging optimization**.

### 🔄 Relationship with Original EMHASS

- **Original EMHASS**: https://github.com/davidusb-geek/emhass-add-on (keep using this)
- **EV Extension**: https://github.com/tomvanacker85/emhass-ev-addon (this repository)
- **Core Fork**: https://github.com/tomvanacker85/emhass (EV-enhanced EMHASS core)

## 🏠 Installation in Home Assistant

### Step 1: Add EV Repository

```
Home Assistant → Settings → Add-ons → Add-on Store → ⋮ (menu) → Repositories
Add URL: https://github.com/tomvanacker85/emhass-ev-addon
```

### Step 2: Install EV Add-on

- Find "EMHASS EV Charging Optimizer" in the store
- Click Install
- Configure EV parameters
- Start the add-on

## 🚀 Parallel Usage

You can run **both** add-ons simultaneously:

| **Add-on**          | **Repository**                  | **Port** | **Data Path**      |
| ------------------- | ------------------------------- | -------- | ------------------ |
| **Original EMHASS** | `davidusb-geek/emhass-add-on`   | 5002     | `/share/emhass`    |
| **EV Optimizer**    | `tomvanacker85/emhass-ev-addon` | 5003     | `/share/emhass-ev` |

## 🎉 Result

- **No conflicts** between add-ons
- **Separate configurations** and data
- **Different capabilities** for different use cases
- **Full EV optimization** with availability windows and SOC management
