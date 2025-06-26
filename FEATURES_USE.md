# Enhanced Configuration Options

## Environment-Based PLC Control

### PLC Enabled Field

Control whether the PLC connection is established, useful for development and testing environments.

**Configuration Options:**

1. **Direct Values:**
   - `true` or `1` - Enable PLC connection (default behavior)
   - `false` or `0` - Disable PLC connection
   - Empty - Enable PLC connection

2. **Environment Variables:**
   - `{VARIABLE_NAME}` - Use value from environment variable
   - Example: `{PLC1_ENABLED}` reads from `process.env.PLC1_ENABLED`

**Examples:**

```bash
# Set environment variable
export PLC1_ENABLED=false

# Or on Windows
set PLC1_ENABLED=false
```

Then configure the PLC Enabled field with: `{PLC1_ENABLED}`

**Use Cases:**
- **Development**: Disable PLC connections when developing without hardware
- **Testing**: Run flows in test mode without actual PLC communication
- **Environment-specific**: Different behavior for dev/staging/production

---

## External CSV Tag Loading

### CSV File Path Field

Load variable definitions from an external CSV file instead of manual configuration.

**Configuration Options:**

1. **Direct Path:**
   - `C:\data\plc_tags.csv` - Absolute path
   - `./tags.csv` - Relative path
   - Empty - Use manual tag configuration

2. **Environment Variables:**
   - `{CSV_FILE_PATH}` - Use path from environment variable
   - Example: `{TAG_FILE}` reads from `process.env.TAG_FILE`

**CSV File Format:**

The CSV file should use the same format as the built-in import/export functionality:

```csv
DB100.I0;MotorSpeed
DB100.I2;Temperature
M0.0;AlarmStatus
DB200.R10;SetPoint
```

**Supported Separators:**
- Semicolon (`;`) - Recommended
- Tab character (`\t`)

**Examples:**

```bash
# Set environment variable
export TAG_FILE=/var/data/production_tags.csv

# Or on Windows
set TAG_FILE=C:\PLC_Data\tags.csv
```

Then configure the CSV File Path field with: `{TAG_FILE}`

**Behavior:**
- If CSV file is found and valid: Uses CSV tags
- If CSV file is missing/invalid: Falls back to manual configuration
- If CSV file is empty: Falls back to manual configuration
- Warnings are logged for troubleshooting

**Use Cases:**
- **Large tag lists**: Manage hundreds of tags externally
- **Shared configurations**: Use same tag file across multiple Node-RED instances
- **Integration**: Export tags from PLC engineering tools (TIA Portal, Step 7)
- **Dynamic loading**: Different tag sets for different environments

---

## Environment Variable Template System

### How It Works

Any configuration field can reference environment variables using the format `{VARIABLE_NAME}`.

**Resolution Process:**
1. Check if value starts with `{` and ends with `}`
2. Extract variable name (remove curly braces)
3. Look up `process.env[VARIABLE_NAME]`
4. Use environment value if found, otherwise use empty value

**Examples:**

| Configuration Field | Environment Variable | Resolved Value |
|---------------------|---------------------|----------------|
| `{PLC_ENABLED}` | `PLC_ENABLED=false` | `false` |
| `{CSV_PATH}` | `CSV_PATH=/data/tags.csv` | `/data/tags.csv` |
| `false` | (any) | `false` |
| `{MISSING_VAR}` | (not set) | `{MISSING_VAR}` |

### Setting Environment Variables

**Linux/macOS:**
```bash
export PLC1_ENABLED=false
export CSV_FILE_PATH=/var/data/tags.csv
node-red
```

**Windows:**
```cmd
set PLC1_ENABLED=false
set CSV_FILE_PATH=C:\Data\tags.csv
node-red
```

**Docker:**
```yaml
# docker-compose.yml
environment:
  - PLC1_ENABLED=false
  - CSV_FILE_PATH=/data/tags.csv
```

**Node-RED settings.js:**
```javascript
// Add to settings.js
process.env.PLC1_ENABLED = 'false';
process.env.CSV_FILE_PATH = '/data/tags.csv';
```

---

## Complete Configuration Example

### Scenario: Production vs Development

**Environment Variables:**
```bash
# Production
export NODE_ENV=production
export PLC1_ENABLED=true
export PLC1_CSV=/data/production_tags.csv

# Development  
export NODE_ENV=development
export PLC1_ENABLED=false
export PLC1_CSV=/dev/test_tags.csv
```

**S7 Endpoint Configuration:**
- **PLC Enabled**: `{PLC1_ENABLED}`
- **CSV File Path**: `{PLC1_CSV}`

**Result:**
- **Production**: Connects to real PLC, loads production tags
- **Development**: No PLC connection, loads test tags for simulation

This allows the same Node-RED flow to work in different environments without modification.

---

## Troubleshooting

### Check Environment Variables
```javascript
// In a function node, check what's available:
msg.payload = {
    env: process.env,
    plc_vars: Object.keys(process.env).filter(k => k.includes('PLC'))
};
return msg;
```

### Debug Logging
Monitor Node-RED logs for messages like:
- `Resolved environment variable PLC1_ENABLED = false`
- `Loaded 45 variables from CSV: /data/tags.csv`
- `CSV file not found: /missing/file.csv. Using config.vartable.`

### Common Issues
1. **Variable not resolving**: Check spelling and case sensitivity
2. **CSV not loading**: Verify file path and permissions
3. **PLC still connecting**: Ensure PLC Enabled field contains valid false value