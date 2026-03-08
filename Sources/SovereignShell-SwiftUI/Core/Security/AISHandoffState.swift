import Foundation

/// AISHandoffState represents the lifecycle state of a trust transfer
/// between SovereignShell and another trust domain.
///
/// AIS records handoff states without revealing identity information.
/// Instead of storing explicit identifiers, AIS uses opaque peer binding
/// tokens derived from normalized endpoint context.
///
/// This preserves privacy while allowing deterministic trust continuity.

enum AISHandoffState {

    /// Trust handoff has begun but not yet accepted
    case start

    /// Receiving party has accepted the trust transfer
    case accepted

    /// Trust transfer successfully completed
    case completed

    /// Trust transfer failed or was aborted
    case failed
}
