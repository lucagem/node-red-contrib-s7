# Node-RED Contrib S7 Enhancement Project

## Project Overview
This project enhances the existing `node-red-contrib-s7` library with two main features to improve flexibility and dynamic configuration management.

## Current Library Status
The current library works correctly but lacks:
1. Dynamic connection control capability
2. External CSV-based tag configuration loading

## Enhancement Goals

### Feature 1: Dynamic PLC Connection Control
- Add a text field in the PLC configuration interface
- Allow environment variable reference (e.g., `{PLC_ENABLED}`)
- Disable connection attempts when value is `0` or `false`
- Prevent all PLC communication when disabled

### Feature 2: External CSV Tag Configuration
- Add a file path field in the PLC configuration interface
- Load tag configuration from external CSV file
- Override flow.json stored tags when CSV file exists
- Use existing clear/import functions for tag management
- Load CSV tags before first PLC connection attempt

## Technical Implementation Points
- Modify PLC configuration UI to add two new fields
- Implement environment variable resolution
- Add CSV file existence check and loading logic
- Integrate with existing tag management functions
- Ensure backward compatibility with current configurations

## Files to Modify
- Configuration HTML files (UI)
- Main PLC connection logic
- Tag management functions
- Configuration validation logic
