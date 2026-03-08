# AIS — Cryptographic Construction
## Hash Domains, Binding Derivation, and Ledger Integrity

Version: 1.0  
Status: Cryptographic Specification

---

# 1. Purpose

This document specifies the cryptographic constructions used by AIS.

AIS relies on cryptographic hash functions to provide:

tamper detection  
ledger integrity  
environment binding  
self-authentication  

AIS intentionally avoids storing or processing sensitive data such as:

keys  
plaintext  
ciphertext  
identity  

The cryptographic layer ensures integrity without observing protected data.

---

# 2. Cryptographic Primitive

AIS uses a collision-resistant hash function.

Recommended algorithms:

SHA-256  
SHA-384  
SHA-512/256  
BLAKE2b  

Required properties:

collision resistance  
second-preimage resistance  
preimage resistance  

Hash output must be deterministic.

---

# 3. Domain Separation

AIS uses domain separation to prevent cross-context hash collisions.

Each AIS hash construction begins with a domain tag.

Example tags:

AIS_BINDING  
AIS_EVENT  
AIS_ATTESTATION  
AIS_LEDGER_ROOT  

Domain-separated hash construction:

H(tag || data)

This prevents collisions between different AIS structures.

---

# 4. Environment Binding Construction

The binding identifier ties AIS to a specific environment.

Binding digest construction:

binding_digest =
H(
  "AIS_BINDING" ||
  environment_root ||
  sandbox_measurement ||
  terminal_measurement ||
  policy_version ||
  ledger_domain
)

This digest uniquely represents the environment state.

---

# 5. Binding Identifier

The binding identifier is a public representation of the binding digest.

binding_id =
Base58(truncate(binding_digest))

Properties:

human-safe identifier  
non-sensitive representation  
does not expose raw measurements

Truncation length must preserve adequate collision resistance.

---

# 6. Ledger Event Hash Construction

Each ledger event includes a hash linking it to the previous event.

event_hash =
H(
  "AIS_EVENT" ||
  previous_hash ||
  rollback_counter ||
  operation_class ||
  timestamp
)

Properties:

tamper evidence  
event ordering enforcement  
deterministic verification

---

# 7. Ledger Chain Integrity

Ledger events form a hash-linked chain.

L = [e0, e1, e2 ... en]

Where:

ei.previous_hash = hash(e(i-1))

Verification requires validating the entire chain.

If any event is modified:

hash mismatch occurs.

Verification fails.

---

# 8. Ledger Root Hash

The ledger head hash represents the current integrity state.

ledger_root =
event_hash(n)

This value may be used in attestation.

---

# 9. Attestation Hash Construction

Attestation statements may include a cryptographic summary.

attestation_hash =
H(
  "AIS_ATTESTATION" ||
  binding_id ||
  ledger_root ||
  trust_verdict ||
  policy_version ||
  attestation_timestamp
)

Attestations confirm integrity without revealing identity or content.

---

# 10. Truncation Safety

Binding identifiers may truncate the binding digest.

Requirements:

minimum 128-bit security margin  
no exposure of full environment measurement  

Example truncation:

binding_id_length = 128 bits

Truncation reduces identifier size while preserving collision resistance.

---

# 11. Collision Considerations

AIS security assumes the hash function remains collision resistant.

If collisions become feasible:

ledger tamper detection may weaken.

Mitigation strategies:

upgrade hash algorithm  
increase truncation length  
introduce hash agility  

---

# 12. Replay Resistance

Replay attacks attempt to reinsert old events.

AIS prevents replay through the rollback counter.

rollback_counter must increase monotonically.

event_hash construction includes rollback_counter.

Replay attempts break chain validity.

---

# 13. Cryptographic Security Properties

AIS cryptographic construction ensures:

hash chain tamper detection  
environment-specific binding  
replay attack resistance  
ledger integrity verification  

These guarantees are provided without exposing sensitive information.


---

# 14. Cryptographic Agility

AIS must support future cryptographic upgrades.

Recommended design:

hash_algorithm parameter  
versioned policy rules  

This allows upgrading hash functions if cryptographic weaknesses emerge.

---

# 15. Implementation Guidance

The AIS Swift implementation should use secure system cryptography libraries.

Recommended APIs:

CryptoKit  
CommonCrypto  

Hash operations must remain deterministic.

Randomness is not required for ledger construction.

---

# 16. Security Summary

The AIS cryptographic layer provides:

tamper-evident ledger chaining  
environment-bound identifiers  
replay resistance  
attestation integrity  

while preserving privacy and anonymity.

---

# 17. Future Extensions

Potential improvements include:

post-quantum hash constructions  
Merkle tree ledger structures  
multi-root distributed attestation  

These extensions may increase AIS scalability and resilience.

