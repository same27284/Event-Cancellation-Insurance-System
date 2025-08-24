# Event Cancellation Insurance System

A comprehensive blockchain-based insurance system for event organizers and venues, providing automated coverage for cancellations due to weather, force majeure events, and other covered circumstances.

## System Overview

The Event Cancellation Insurance System consists of five interconnected smart contracts that work together to provide end-to-end insurance coverage:

### Core Contracts

1. **Policy Management Contract** (`policy-management.clar`)
    - Creates and manages insurance policies
    - Handles premium calculations and payments
    - Tracks policy status and coverage details

2. **Weather Oracle Contract** (`weather-oracle.clar`)
    - Monitors weather conditions and severe weather alerts
    - Provides weather data for claim validation
    - Maintains historical weather records

3. **Claims Processing Contract** (`claims-processing.clar`)
    - Handles claim submissions and validation
    - Automates claim approval for qualifying events
    - Manages payout calculations and distributions

4. **Vendor Coordination Contract** (`vendor-coordination.clar`)
    - Tracks vendor contracts and cancellation costs
    - Coordinates refunds and cost recovery
    - Manages vendor payment distributions

5. **Risk Assessment Contract** (`risk-assessment.clar`)
    - Evaluates risk factors for different event types
    - Calculates premium adjustments based on risk
    - Maintains risk scoring algorithms

## Key Features

### Automated Weather Monitoring
- Real-time weather condition tracking
- Severe weather alert integration
- Historical weather pattern analysis
- Automated claim triggering for weather-related cancellations

### Force Majeure Coverage
- Government-mandated event cancellations
- Natural disaster coverage
- Public health emergency provisions
- Civil unrest and security concerns

### Vendor Cost Recovery
- Automated vendor notification system
- Cost tracking and reimbursement
- Vendor contract integration
- Payment coordination and distribution

### Customer Communication
- Automated refund processing
- Real-time status updates
- Multi-channel communication support
- Transparent claim tracking

### Risk-Based Pricing
- Dynamic premium calculation
- Event-type specific risk factors
- Historical data analysis
- Seasonal adjustment factors

## Contract Architecture

\`\`\`
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ Policy          │    │ Weather         │    │ Claims          │
│ Management      │◄──►│ Oracle          │◄──►│ Processing      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
│                       │                       │
│                       │                       │
▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ Risk            │    │ Vendor          │    │ Customer        │
│ Assessment      │    │ Coordination    │    │ Communication   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
\`\`\`

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Node.js and npm for testing
- Stacks wallet for contract deployment

### Installation
\`\`\`bash
npm install
clarinet check
clarinet test
\`\`\`

### Testing
\`\`\`bash
npm test
\`\`\`

### Deployment
\`\`\`bash
clarinet deploy --testnet
\`\`\`

## Usage Examples

### Creating a Policy
```clarity
(contract-call? .policy-management create-policy 
  "Summer Music Festival" 
  u1000000 ;; coverage amount in microSTX
  u1625097600 ;; event date timestamp
  "outdoor-music" ;; event type
  { latitude: 40.7128, longitude: -74.0060 } ;; venue location
)
