# CONDIDATOR Smart Contract for PCO Metaverse

## Overview
This repository contains the Candidate Smart Contract, utilized in the PCO Metaverse for the candidature and investment processes within the metaverse's governance model. It facilitates users to become candidates in the ecosystem's governance, as well as allowing stakeholders to invest in these candidates.

## Specification
- **Solidity Version**: 0.8.20
- **License**: MIT
- **Dependencies**: Imports OpenZeppelin's ERC-20 Interface (IERC20)

## Features
- Candidature for the metaverse's governance season
- Investment in candidates by stakeholders
- Interaction with the ValidatorPoolContract for profit calculations

## Events
- becomeCandidateEvent: Triggers when a user becomes a candidate.

## Functions
- becomeCandidate: Register as a candidate for the current season.
- investMent: Stakeholders can invest in candidates.
- getInvestorDetails: Fetch investment details for profit calculation.
- withdrawAmount: Withdraw candidacy costs by the owner/operators.
- addOperator: Assign operator roles.
- removeOperator: Revoke operator roles.
