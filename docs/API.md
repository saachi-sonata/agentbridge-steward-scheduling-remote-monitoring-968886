# API Documentation

## Endpoints
### Order Intake
- **Description**: Collect, validate and normalize demographics from Care Management; attach a runId and timestamp for traceability.
- **Type**: Processing

### Decompose
- **Description**: Execute decompose phase for the Decompose-Route pattern: persist interim state, enforce guardrails, and emit structured JSON results.
- **Type**: Processing

### Route
- **Description**: Execute route phase for the Decompose-Route pattern: persist interim state, enforce guardrails, and emit structured JSON results.
- **Type**: Processing

### Monitoring
- **Description**: Monitoring across joined datasets; branch on thresholds using decision gates; write metrics (success/error counts) for observability.
- **Type**: Processing

### Eligibility Match
- **Description**: Eligibility Match across joined datasets; branch on thresholds using decision gates; write metrics (success/error counts) for observability.
- **Type**: Processing

### Optimization
- **Description**: Optimization across joined datasets; branch on thresholds using decision gates; write metrics (success/error counts) for observability.
- **Type**: Processing

### Normalization
- **Description**: Normalization across joined datasets; branch on thresholds using decision gates; write metrics (success/error counts) for observability.
- **Type**: Processing

### Risk Scoring
- **Description**: Risk Scoring across joined datasets; branch on thresholds using decision gates; write metrics (success/error counts) for observability.
- **Type**: Processing

### Finalize Plan
- **Description**: Assemble final payload with status, artifacts, KPIs and audit trail; store to LIS; return response JSON for the client.
- **Type**: Processing
