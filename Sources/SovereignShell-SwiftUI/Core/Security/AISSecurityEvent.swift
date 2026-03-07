import Foundation

/// AISSecurityEvent represents a breach or integrity violation
/// detected within the SovereignShell trust domain.
///
/// AIS remains passive during normal operation but becomes
/// self-protective when one of these events occurs.
///
/// These events never contain secrets, metadata, or user identity.
/// They exist only to classify integrity failures.

enum AISSecurityEvent {

    /// Ledger structure failed validation
    case ledgerCorruption

    /// Rollback counter mismatch detected
    case rollbackViolation

    /// Trust transition violated deterministic rules
    case invalidTrustTransition

    /// Execution environment integrity violation detected
    case runtimeIntegrityFailure

    /// Trust boundary breach detected
    case trustBoundaryBreach

    /// Secret disposition attempt failed
    case eraseFailure

}
