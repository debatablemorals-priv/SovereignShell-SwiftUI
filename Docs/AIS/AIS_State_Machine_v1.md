# AIS — State Machine Specification
## Deterministic Trust-State Control for the AIS Integrity Ledger

Version: 1.0  
Status: Canonical Runtime State Machine

---

# 1. Purpose

This document defines the AIS runtime state machine.

The AIS state machine controls:

• trust initialization  
• ledger operation  
• integrity validation  
• breach detection  
• fail-closed enforcement  

AIS must behave deterministically under all conditions.

Unexpected states must never produce undefined behavior.

---

# 2. State Machine Objectives

The AIS state machine guarantees:

deterministic transitions  
fail-closed security behavior  
predictable breach handling  
environment-bound trust control  

All integrity failures must transition to a locked state.

---

# 3. State Definitions

AIS operates with the following states.

INITIALIZING

System startup and environment measurement.

ACTIVE

Normal execution and ledger operation.

BREACH_DETECTED

Integrity violation has been detected.

LOCKED

AIS is permanently locked until environment reset.

RESET_REQUIRED

System must be restarted before trust can be restored.

---

# 4. State Descriptions

## INITIALIZING

This state occurs at system startup.

Operations performed:

environment measurement  
binding derivation  
policy validation  
ledger initialization  

Allowed transitions:

INITIALIZING → ACTIVE  
INITIALIZING → LOCKED

If environment validation fails:

transition to LOCKED.

---

## ACTIVE

The system operates normally.

Allowed operations:

ledger event append  
ledger verification  
attestation generation  

Integrity checks occur continuously.

Allowed transitions:

ACTIVE → BREACH_DETECTED  
ACTIVE → LOCKED

---

## BREACH_DETECTED

An integrity violation has been detected.

Example triggers:

hash chain mismatch  
rollback counter violation  
binding mismatch  
policy mismatch  

Operations:

record breach event  
halt ledger operations  
revoke execution trust  

Allowed transitions:

BREACH_DETECTED → LOCKED

---

## LOCKED

AIS is locked due to integrity failure.

Operations denied:

ledger append  
attestation generation  
trust validation  

Allowed transitions:

LOCKED → RESET_REQUIRED

---

## RESET_REQUIRED

AIS cannot continue execution until reset.

Recovery requires:

system restart  
environment re-measurement  
ledger reinitialization

Allowed transitions:

RESET_REQUIRED → INITIALIZING

---

# 5. State Transition Table

| Current State | Event | Next State |
|---------------|-------|------------|
| INITIALIZING | environment valid | ACTIVE |
| INITIALIZING | validation failure | LOCKED |
| ACTIVE | integrity failure | BREACH_DETECTED |
| ACTIVE | policy violation | BREACH_DETECTED |
| BREACH_DETECTED | breach recorded | LOCKED |
| LOCKED | system reset request | RESET_REQUIRED |
| RESET_REQUIRED | system restart | INITIALIZING |

---

# 6. Failure Triggers

The following events trigger integrity failure.

Hash Chain Violation

event_hash mismatch.

Rollback Counter Violation

rollback_counter not monotonic.

Environment Binding Failure

binding mismatch detected.

Policy Mismatch

policy_version mismatch.

Ledger Structure Corruption

ledger structure invalid.

Any of these transitions the system to BREACH_DETECTED.

---

# 7. Fail-Closed Enforcement

AIS must enforce deterministic fail-closed behavior.

Upon integrity violation:

1 trust state becomes BREACH_DETECTED  
2 breach event recorded if possible  
3 state transitions to LOCKED  
4 ledger operations halt  
5 attestation stops  

Execution cannot continue in trusted mode.

---

# 8. Ledger Interaction Rules

Ledger operations are permitted only in ACTIVE state.

Allowed operations:

append event  
verify chain  
generate attestation  

If system state ≠ ACTIVE:

ledger operations must be denied.

---

# 9. Attestation Interaction Rules

Attestations may only be generated when:

state == ACTIVE

If state ≠ ACTIVE:

attestation requests must be rejected.

---

# 10. Determinism Requirement

AIS state transitions must be deterministic.

Given the same input conditions:

state transitions must always produce identical results.

This ensures predictable security behavior.

---

# 11. Runtime Error Handling

AIS must maintain near-zero runtime errors.

Runtime errors must not corrupt ledger state.

If an unrecoverable error occurs:

transition to LOCKED.

---

# 12. Attack Resistance

The state machine prevents attackers from:

continuing execution after compromise  
bypassing integrity validation  
issuing attestations during breach  

Fail-closed locking prevents partial compromise.

---

# 13. Security Summary

The AIS state machine ensures:

deterministic trust control  
predictable failure handling  
fail-closed enforcement  
integrity-first execution policy  

These properties are essential for hardened execution environments.

---

# 14. Future Enhancements

Potential state machine extensions:

distributed trust validation states  
multi-node attestation states  
hardware-root verification states

