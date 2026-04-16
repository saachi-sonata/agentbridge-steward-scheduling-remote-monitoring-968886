# Architecture Documentation

## Overview
This Decompose-Route implements Steward • Scheduling (Remote Monitoring) for Healthcare & Life Sciences use cases.

## Components
1. **Order Intake**: Collect, validate and normalize demographics from Care Management; attach a runId and timestamp for traceability.
2. **Decompose**: Execute decompose phase for the Decompose-Route pattern: persist interim state, enforce guardrails, and emit structured JSON results.
3. **Route**: Execute route phase for the Decompose-Route pattern: persist interim state, enforce guardrails, and emit structured JSON results.
4. **Monitoring**: Monitoring across joined datasets; branch on thresholds using decision gates; write metrics (success/error counts) for observability.
5. **Eligibility Match**: Eligibility Match across joined datasets; branch on thresholds using decision gates; write metrics (success/error counts) for observability.
6. **Optimization**: Optimization across joined datasets; branch on thresholds using decision gates; write metrics (success/error counts) for observability.
7. **Normalization**: Normalization across joined datasets; branch on thresholds using decision gates; write metrics (success/error counts) for observability.
8. **Risk Scoring**: Risk Scoring across joined datasets; branch on thresholds using decision gates; write metrics (success/error counts) for observability.
9. **Finalize Plan**: Assemble final payload with status, artifacts, KPIs and audit trail; store to LIS; return response JSON for the client.

## Data Flow
- Input: Order Intake
- Processing: 9 sequential steps
- Output: Finalize Plan
