# AIS — Formal Security Properties
## Mathematical Definition of AIS Security Guarantees

Version: 1.0  
Status: Formal Security Specification

---

# 1. Purpose

This document defines the formal security properties guaranteed by AIS.

AIS provides a privacy-preserving integrity attestation system that ensures:

environment integrity  
ledger tamper detection  
environment non-portability  
anonymity preservation  
deterministic fail-closed enforcement  

These guarantees hold under the adversary model defined in the AIS Threat Analysis.

---

# 2. System Model

AIS is defined as the tuple:

AIS = (E, S, M, L, A)

Where:

E = Environment  
S = Execution State  
M() = Measurement Function  
L = Ledger  
A = Attestation

---

# 3. Environment Definition

The environment is defined as:

E = (R, SB, TM, PV, LD)

Where:

R  = environment_root  
SB = sandbox_measurement  
TM = terminal_measurement  
PV = policy_version  
LD = ledger_domain  

---

# 4. Ledger Definition

The ledger is an append-only sequence of events.

L = [e0, e1, e2 … en]

Each event:

ei = (
previous_hash,
event_hash,
rollback_counter,
operation_class,
timestamp,
trust_status,
binding_id,
policy_version
)

---

# 5. Binding Definition

Binding ensures AIS is tied to a specific environment.

binding_digest =
H(
environment_root ||
sandbox_measurement ||
terminal_measurement ||
policy_version ||
ledger_domain
)

binding_id =
Base58(truncate(binding_digest))

---

# 6. Integrity Property

Definition:

Integrity(E,S) holds if the execution environment and ledger state have not been modified without detection.

Formally:

Integrity(E,S) ⇔

verify_binding(E) = true  
verify_chain(L) = true  
rollback_monotonic(L) = true  
policy_compatible(E, L) = true  

If any condition fails:

Integrity(E,S) = false

---

# 7. Ledger Tamper Detection

Definition:

Tamper-detection(L) holds if any unauthorized modification to the ledger is detectable.

Let:

L' be a modified ledger.

Then:

verify_chain(L') = false

for any mutation including:

event modification  
event deletion  
event insertion  
event reordering

---

# 8. Environment Non-Portability

Definition:

Non-portability(E) holds if a valid AIS ledger cannot be reused in another environment.

Let:

E1 ≠ E2

Then:

binding_id(E1) ≠ binding_id(E2)

Thus:

verify(L, E2) = false

for ledger L generated in E1.

---

# 9. Anonymity Property

Definition:

Anonymity(E) holds if AIS operations do not reveal identifying information.

AIS must not store or process:

user identity  
endpoint identifiers  
network addresses  
payload data  
cryptographic keys  
plaintext or ciphertext

Thus verification reveals only integrity state.

---

# 10. Non-Observability

Definition:

AIS must not observe protected data.

Let:

D = protected data set

D = {keys, plaintext, ciphertext, identity, payload}

Then:

observe(AIS, D) = ∅

AIS cannot leak protected data through the ledger or attestation.

---

# 11. Replay Resistance

Definition:

Replay attacks attempt to reuse previous events.

AIS prevents replay using rollback counters.

Let:

e_i, e_j be events.

Then:

rollback_counter(e_j) > rollback_counter(e_i)

must always hold for j > i.

If violated:

verification fails.

---

# 12. Deterministic Fail-Closed Behavior

Definition:

AIS must transition to a locked state upon any integrity violation.

Let:

V = integrity violation

Then:

state(AIS) = BREACH_DETECTED  
→ state(AIS) = LOCKED

Once locked:

no further trusted execution occurs.

---

# 13. Verification Function

Ledger verification is defined as:

verify(L):

for each event e_i in L:

check hash linkage  
check rollback monotonicity  
check binding compatibility  
check policy compatibility  

If all checks pass:

verify(L) = true

Else:

verify(L) = false

---

# 14. Attack Resistance Condition

Let:

A = attack attempt

AIS is secure if:

Pr[attack_success(A)] = 0

under the evaluation campaign defined in AIS Evaluation Methodology.

Minimum validation:

250,000 simulated attacks.

---

# 15. Security Summary

AIS guarantees:

Integrity(E,S)  
Tamper-detection(L)  
Non-portability(E)  
Anonymity(E)  
Replay resistance  
Deterministic fail-closed behavior  

These properties allow AIS to operate in hostile environments while preserving privacy.

---

# 16. Future Formalization

Future work may include:

formal verification proofs  
model checking  
cryptographic security reductions  

These techniques may further strengthen AIS security guarantees.

