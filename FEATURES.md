# Documentation for New Features

![Dynamic endpoint configuration](./docs/configuration-screenshot.png)

## Additions to S7 endpoint Help section

### Dynamic Configuration Management

#### PLC Enabled
The **PLC Enabled** field allows you to completely disable PLC communication without removing the configuration. This is useful for:
- Testing flows without a physical PLC available
- Deploying to different environments with different configurations
- Temporary communication disabling

Accepted values:
- Empty or `true`: PLC enabled (default behavior)
- `false` or `0`: PLC disabled
- `${S7_ENABLE}` or other: Environment variable

When PLC is disabled:
- The endpoint remains in "offline" state
- Write operations fail with "PLC disabled" error
- No connection attempts are made

#### CSV File Path
The **CSV File Path** field allows loading the variable list from an external CSV file instead of the node configuration. This facilitates:
- Reusing the same configuration across different installations
- Centralized tag management
- Synchronization with external configuration systems

CSV file format:
```
address<TAB|;>name
DB1,REAL0	Temperature_1
DB1,REAL4	Temperature_2
MB100	Memory_Byte_100
```

The CSV file takes priority over internal configuration. If the file doesn't exist or is empty, the node configuration is used.

Accepted values:
- Absolute path: `C:\config\s7_tags.csv`
- Relative path: `./config/tags.csv`
- Environment variable: `${S7_CSV_FILE}` or other

#### Environment Variables in Connection Parameters

The following parameters now support environment variables:

- **Port**: `102` or `${S7_PORT}` or other
- **Rack**: `0` or `${S7_RACK}` or other 
- **Slot**: `2` or `${S7_SLOT}` or other

This allows configuring different environments (development, test, production) using the same flow but with different connection parameters.

### Technical Notes

- Environment variables are automatically resolved by Node-RED
- CSV loading occurs only at node startup
- In case of CSV errors, the node configuration is used with a warning message
- CSV parsing supports TAB (	) and semicolon (;) separators
- Empty lines in CSV are ignored