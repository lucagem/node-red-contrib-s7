# Enhanced Features for node-red-contrib-s7

## New Features Added

### 1. PLC Connection Control via Environment Variables

**Purpose**: Allow dynamic enabling/disabling of PLC connections without modifying flows, useful for development/production environments.

**Implementation**:
- Added `plc_enabled` field to S7 Endpoint configuration
- Supports both direct values and environment variable templates like {PLC1_ENABLED}
- When disabled, creates mock endpoint to prevent errors
- Status shows as "offline" when PLC is disabled

**Use Cases**:
- Mantain the same flows.json on many deploy site even when no PLC S7 is connected
- Conditional PLC connections based on deployment environment

### 2. External CSV Tag Table Loading

**Purpose**: Dynamic load variable definitions from CSV file at Flow start.

**Implementation**:
- Added `csvPath` field to S7 Endpoint configuration
- Supports environment variable templates for dynamic paths like {CSV_FILE_PATH}
- Uses same CSV format as existing import/export functionality
- CSV format: `address;name` or `address\tname` (tab or semicolon separated)
- Graceful fallback to manual configuration if CSV fails

**Use Cases**:
- Mantain the same flows.json file on many deploy site
- Tag definitions shared across multiple deployments
- Integration with PLC engineering tools that export CSV
- Dynamic tag loading based on deployment environment

### 3. Environment Variable Template System for the 2 new parameters

**Format**: `{VARIABLE_NAME}`
- Any field value wrapped in curly braces is treated as an environment variable reference
- Example: `{PLC1_ENABLED}` resolves to the value of `process.env.PLC1_ENABLED`
- Falls back to literal value if environment variable doesn't exist

## Technical Details

### Modified Files:
- `red/s7.html`: Added UI fields and configuration handling
- `red/s7.js`: Added logic for PLC control and CSV loading

### Configuration Schema Changes:
```javascript
// New fields added to S7 Endpoint defaults:
plc_enabled: { value: "" },    // PLC enable/disable control
csvPath: { value: "" }         // Path to external CSV file
```

### Backward Compatibility:
- All existing configurations continue to work unchanged
- New fields are optional with empty defaults
- No breaking changes to existing API

## Code Quality:
- Follows existing code patterns and style
- Comprehensive error handling with user-friendly warnings
- Logging for debugging and troubleshooting
- No external dependencies added

## Testing Scenarios:
1. PLC enabled with manual tag configuration (existing behavior)
2. PLC disabled via environment variable
3. CSV loading with valid file
4. CSV loading with invalid/missing file (graceful fallback)
5. Environment variable resolution
6. Mixed configuration (some env vars, some direct values)