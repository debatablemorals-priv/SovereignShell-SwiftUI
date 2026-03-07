import Foundation

/// AISSecretDisposition defines the outcome AIS may request or record
/// when trust has been broken inside the SovereignShell sandbox.
///
/// AIS does not hold or inspect secrets directly.
/// It only records the disposition state of sandbox-owned trust anchors
/// and other application-owned sensitive material.

enum AISSecretDisposition {

    /// No secret action was required
    case notApplicable

    /// Sandbox-owned sensitive material was locked
    case locked

    /// Sandbox-owned sensitive material was cryptographically erased
    case erased

    /// Erasure was attempted but failed
    case eraseFailed
}
