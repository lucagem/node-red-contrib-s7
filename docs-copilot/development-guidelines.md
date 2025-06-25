# Development Guidelines for GitHub Copilot Agent

## Code Analysis Priority
1. **Start by exploring** the existing codebase structure in `/red/` and `/src/` directories
2. **Identify** the main configuration node files (likely HTML + JS pairs)
3. **Locate** PLC connection initialization code
4. **Find** existing tag import/export functionality

## Implementation Strategy

### Phase 1: UI Configuration Enhancement
- Add two new input fields to configuration form
- Implement proper validation for file paths
- Add help text and examples for environment variables

### Phase 2: Environment Variable Logic
- Create utility function for environment variable resolution
- Integrate check into connection logic
- Add proper error handling and logging

### Phase 3: CSV Configuration Loading
- Implement file existence check
- Integrate with existing tag management functions
- Add error handling for file operations
- Ensure CSV format compatibility

## Coding Standards
- Follow existing code style and patterns
- Add comprehensive error handling
- Include debug logging for troubleshooting
- Maintain Node-RED convention compliance

## Testing Approach
- Test with environment variables set/unset
- Test with valid/invalid CSV files
- Test backward compatibility with existing flows
- Verify debug configuration works with changes

## Key Functions to Understand
Look for existing functions related to:
- `clearTags()` or similar tag clearing functionality
- `importCSV()` or CSV import functionality
- PLC connection initialization
- Configuration validation

## Environment Variables Best Practices
- Use descriptive variable names
- Support both `0`/`1` and `true`/`false` values
- Provide clear error messages for invalid values
- Log current state for debugging

## File Path Handling
- Validate file existence before processing
- Handle relative and absolute paths
- Provide meaningful error messages
- Support standard CSV formats
