# SovereignShell iOS — Unified SwiftUI Project Specification  
## Canonical Phase I Blueprint (Deterministic + AIS-Enforced Build)

Version: 1.0
Platform: iOS 17+  
Architecture Status: Phase I — Production Hardening Active  
Authority: iOS Canonical Reference Build  

---

# 1. PROJECT IDENTITY

SovereignShell is a deterministic, terminal-first, AI-augmented execution environment engineered specifically for secure, sandboxed mobile platforms.

It is NOT:
- A Linux distro
- A background daemon
- A hidden execution layer
- A container runtime
- A dynamic code injection engine

It is:
- A secure execution console
- An AI-assisted development surface
- A deterministic state machine
- A fail-closed integrity system
- A cryptographically bound execution ledger (AIS)

The iOS implementation is the architectural authority for all future deployments.

---

# 2. ARCHITECTURAL GOVERNANCE (FROZEN SCOPE)

Phase I architecture is frozen.

Permitted changes:
- Hardening corrections
- Audit corrections
- Release validation fixes

Prohibited:
- Ledger redesign
- Security relaxation
- Substrate integration
- Cross-platform abstraction
- Configuration downgrade path
- Silent recovery logic
- Architectural expansion during hardening

Execution discipline:
- No phase skipping
- No structural drift
- Structured concurrency only
- No debug logic in release
- No silent mutation
- Fail-closed integrity posture
- Ledger and configuration rollbackCounters strictly bound

---

# 3. DETERMINISTIC INITIALIZATION ORDER

Boot sequence must be strictly:

1. SecurityState initialization  
2. Configuration load  
3. HMAC validation  
4. Schema monotonic validation  
5. Rollback monotonic validation  
6. AIS ledger load (rollback bound)  
7. Full chain verification  
8. Service activation  
9. Terminal engine activation  
10. AI executor injection  
11. UI binding  

No service activates before integrity validation completes.

---

# 4. CORE SYSTEM COMPONENTS

## 4.1 App Entry Layer

Files:
- SovereignShellApp.swift
- RootView.swift
- AppContainer.swift

Responsibilities:
- SwiftUI lifecycle authority
- Deterministic dependency injection
- ScenePhase monitoring
- Background lock enforcement
- Single container authority

No global singletons except:
- SecureLogger
- SecurityState

---

## 4.2 Theme System (SwiftUI)

Centralized ThemeAuthority.

Theme: Sovereign Obsidian  
Primary Colors:
- Obsidian Black (#0A0A0C)
- Ultraviolet (#5F00FF)
- Pearl White (#F5F5FF)
- Deep Obsidian Surface (#111116)
- Log Surface (#121218)

No inline styling permitted.

---

## 4.3 Logging Layer

Components:
- SecureLogger
- LogSanitizer
- AuditEvent

Rules:
- No print()
- Structured logging only
- No state mutation from logger
- Debug disabled in release
- Redaction enforced
- OSLog integrated

---

## 4.4 Terminal Core Engine

Files:
- TerminalEngine.swift
- CommandRouter.swift
- TerminalSession.swift

Features:
- Deterministic command routing
- Built-in commands:
  - help
  - echo
  - clear
  - lock
- Command history
- Structured execution pipeline

Rules:
- No filesystem mutation without explicit approval
- No AI bypassing ledger
- No execution outside router

---

## 4.5 Security Layer

Files:
- SecurityState.swift
- AISKeyManager.swift
- SecureConfigurationStore.swift
- AppSecurityConfiguration.swift
- RollbackCounter.swift
- GeminiCredentialState.swift
- AuthenticationMode.swift

Responsibilities:
- Lock/unlock authority
- Biometric authentication
- Background auto-lock
- Credential isolation
- Configuration HMAC sealing
- Monotonic schema enforcement
- Strict rollback enforcement

Fail-closed on:
- HMAC mismatch
- Rollback regression
- Schema downgrade
- Token invalidation

---

#5. AIS — ATOMIC INTEGRITY SEAL

AIS (Atomic Integrity Seal) is a proprietary, purpose-built integrity enforcement system created specifically for SovereignShell.

It is not:
- A blockchain  
- A distributed ledger  
- A logging framework  
- A generalized audit database  

AIS is a secure, deterministic, installation-scoped integrity authority engineered to provide dependable state continuity under mobile sandbox constraints.

#5.1 Formal Definition
 
A proprietary, fail-closed, append-only, canonically serialized, hash-chained integrity ledger where each state mutation is sealed atomically, verified at boot, cryptographically bound to a strictly monotonic configuration rollback counter, and enforced under platform file-protection guarantees.

AIS operates entirely within platform security boundaries and does not depend on external trust anchors or distributed consensus.

# 5.2 AIS Guarantees

1. Append-only semantics  
2. Canonical hash-chained continuity  
3. Atomic commit enforcement  
4. Deterministic genesis envelope auto-creation  
5. Strict monotonic rollback enforcement  
6. Ledger rollback bound to configuration rollbackCounter  
7. Boot-time full chain verification  
8. Pre-append full verification  
9. Fail-closed corruption response  
10. NSFileProtectionComplete enforcement  
11. iCloud backup exclusion  
12. No secret material storage  
13. Isolated mutation authority  
14. No silent recovery pathways  

Integrity violations halt execution.

AIS Structural Enforcement Model

# 5.3 Genesis Auto-Creation

If the ledger file does not exist at boot:

- A deterministic Genesis envelope is created  
- rollbackCounter initialized  
- Envelope sealed via canonical hash  
- File protection attributes applied  
- Ledger written atomically  

Ledger absence never produces undefined state.


---

## 5.4 Ledger Structure

Directory:
Core/Security/Ledger/

Files:
- AISExecutionLedger.swift
- LedgerEntry.swift
- LedgerStore.swift
- LedgerChainValidator.swift
- LedgerError.swift

Runtime Location:
ApplicationSupport/Security/ledger.chain

Protection:
- FileProtectionType.complete
- iCloud excluded
- Atomic writes only
- Enclave-signed sealing
- Rollback bound

---

#5.5 AIS Structural Enforcement Model

AIS enforces integrity through three interlocking mechanisms:
	∙	Chain continuity — every entry’s previousHash must equal the SHA256 of the canonical serialization of the preceding entry. Any break halts execution immediately.
	∙	Rollback binding — the ledger’s rollbackCounter is strictly bound to the configuration rollbackCounter. A mismatch between the two is treated as a tamper event and triggers fail-closed lock.
	∙	Atomic commit — no ledger entry is considered valid until it has been written atomically under NSFileProtectionComplete. Partial writes are rejected.

#5.6 Ledger Entry Model

LedgerEntry contains:

- entryID (UUID)
- timestamp
- rollbackCounter
- previousHash
- requestHash
- responseHash
- envelopeHash

Rules:
- Append-only
- Strict monotonic rollbackCounter
- Genesis auto-created deterministically
- Full chain verified at launch
- Pre-append verification
- Pre-export verification

---

#5.7 Hash Chain Rule

For entry[i]:

expectedHash = SHA256(canonicalSerialize(entry[i-1]))  
actualHash = entry[i].previousHash  

Integrity condition:
expectedHash == actualHash

Failure → Immediate fail-closed lock.

---

## 5.8 Enforcement Policy

If verification fails:

- App enters locked state
- AI disabled
- Append prohibited
- Export prohibited
- Critical log emitted
- No silent recovery
- No auto-repair

User intervention required.

---

#6. AI LAYER — GEMINI CLI & GOOGLE GENERATIVE AI INTEGRATION

#6.1 Core Principle

Gemini CLI is written directly into the source code and serves as the deterministic AI execution surface. It connects natively from Swift via URLSession over HTTPS to the Google Generative AI API at https://generativelanguage.googleapis.com. 
This endpoint is the default base URL.

Swift Package Manager dependency (Google’s official Swift SDK): https://github.com/google/generative-ai-swift

All Swift URLSession calls must use HTTPS. HTTP is not permitted. No external CLI binary execution permitted. All Gemini operations occur via controlled HTTPS client inside GeminiClient.swift. The Swift SDK is integrated via Swift Package Manager at build time and is not invoked as a shell process. 

#6.2 Gemini Authentication Modes

1. API Key Mode
	∙	User supplies Google API key
	∙	Stored securely in Keychain via SecItemAdd / SecItemCopyMatching
	∙	Injected at runtime only via credentialState
	∙	Never logged
	∙	Never stored in AIS
Swift usage via Google Swift SDK:
import GoogleGenerativeAI

let model = GenerativeModel(
    name: "gemini-2.0-flash",
    apiKey: KeychainHelper.retrieve(key: "GEMINI_API_KEY")
)

Or via raw URLSession:
var request = URLRequest(url: URL(string:
    "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=\(apiKey)"
)!)
request.httpMethod = "POST"
request.setValue("application/json", forHTTPHeaderField: "Content-Type")

API Endpoint:
POST https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=YOUR_API_KEY
Content-Type: application/json

2. OAuth Mode (Google Account Login)
	∙	Google OAuth 2.0 PKCE flow via ASWebAuthenticationSession
	∙	Token stored in Keychain
	∙	Refresh token rotation enforced
	∙	Token invalidation triggers fail-closed AI disable
Swift OAuth flow entry point:
import AuthenticationServices

let session = ASWebAuthenticationSession(
    url: authorizationURL,
    callbackURLScheme: "your.app"
) { callbackURL, error in
    // Exchange code for token
}
session.presentationContextProvider = self
session.start()

OAuth Endpoints:
Authorization URL:    https://accounts.google.com/o/oauth2/v2/auth
Token Exchange URL:   https://oauth2.googleapis.com/token
Token Revocation URL: https://oauth2.googleapis.com/revoke

Scopes required:
https://www.googleapis.com/auth/generative-language
https://www.googleapis.com/auth/cloud-platform

PKCE Parameters:
code_challenge_method: S256
response_type: code
redirect_uri: your.app://oauth/callback

Authorization header injected after token retrieval:
Authorization: Bearer <OAUTH_TOKEN>

No token written to logs, ledger, or disk plaintext.



#6.3 Default Endpoint Behavior

By default, GeminiClient must connect via Swift URLSession over HTTPS to:
https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent

Full REST endpoint (API Key mode):
POST https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=YOUR_API_KEY
Content-Type: application/json

Full REST endpoint (OAuth mode):
POST https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent
Authorization: Bearer <OAUTH_TOKEN>
Content-Type: application/json

Swift URLSession request pattern:
func buildGeminiRequest(endpoint: URL, token: String, body: Data) -> URLRequest {
    var request = URLRequest(url: endpoint)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    request.httpBody = body
    request.timeoutInterval = 30
    return request
}

If endpoint is unset: fail-closed AI disable, log critical event, do not fallback silently.



#6.4 Base URL Override

Swift configuration constant:
enum GeminiConfig {
    static let baseURL: String = ProcessInfo.processInfo
        .environment["GOOGLE_GEMINI_BASE_URL"]
        ?? "https://generativelanguage.googleapis.com"
}

URL validation in Swift:
func validateBaseURL(_ rawURL: String) throws -> URL {
    guard let url = URL(string: rawURL),
          url.scheme == "https" else {
        throw GeminiError.invalidBaseURL
    }
    return url
}

Rules: must be explicitly set, must be HTTPS, must pass URLComponents validation, must be logged (hashed), must be sealed into AIS on first use. Override does not bypass ledger commit, integrity validation, or containment rules.


#6.5 MCP Server Support

Local HTTP streaming endpoint: http://localhost:8080/mcp

MCP local endpoints may use HTTP only when bound to localhost. All remote MCP endpoints must use HTTPS.

Swift streaming via URLSession AsyncBytes:
let (asyncBytes, _) = try await URLSession.shared.bytes(for: mcpRequest)
for try await line in asyncBytes.lines {
    // handle streamed response lines
}

MCP mode rules: explicitly selected, cannot be auto-detected, logged in ledger, endpoint hashed in ledger entry, containment-capable, streaming cancellable via Swift Task cancellation. No insecure fallback 



#6.6 Swift Package Reference

All Gemini functionality routes through Swift-native dependencies integrated via Swift Package Manager.

GoogleGenerativeAI is sourced from https://github.com/google/generative-ai-swift and handles all core Gemini API calls.

AuthenticationServices is a built-in Apple SDK framework and handles OAuth 2.0 PKCE flow via ASWebAuthenticationSession, authorization code exchange, and redirect URI handling.

Security is a built-in Apple SDK framework and handles Keychain storage of API keys and OAuth tokens, token retrieval at runtime via SecItemCopyMatching, and token deletion on revocation via SecItemDelete.


Add to Package.swift:
dependencies: [
    .package(
        url: "https://github.com/google/generative-ai-swift",
        from: "0.5.0"
    )
],
targets: [
    .target(
        name: "YourApp",
        dependencies: ["GoogleGenerativeAI"]
    )
]

Or add via Xcode: File → Add Package Dependencies → paste https://github.com/google/generative-ai-swift
No other packages or frameworks may be used for authentication or AI requests.



#6.7 Execution Flow (AI)

Terminal
→ CommandRouter
→ ExecutionEngine
→ GeminiClient (URLSession / HTTPS)
→ https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent
→ Response received
→ AILedgerBridge.commit()
→ AISExecutionLedger.append()
→ rollbackCounter increment
→ UI render

No AI response renders before ledger commit success.



#6.8 Network & Containment Controls

GeminiClient must support global cancellation via Swift Task and TaskGroup, timeout enforcement via URLRequest.timeoutInterval, containment mode, structured concurrency only (async/await), no detached tasks (Task.detached prohibited), no retry loops without explicit policy, and all connections over HTTPS only. URLSession must use .ephemeral configuration to prevent disk caching.

actor GeminiClient: NetworkContainable, SecurePurgeable {
    private let session = URLSession(configuration: .ephemeral)
    private var currentTask: Task<GeminiResponse, Error>?

    func cancel() {
        currentTask?.cancel()
        currentTask = nil
    }
}


Cancellation triggers: app background (scenePhase == .background), lock event (UIApplication.didEnterBackgroundNotification), ledger failure, OAuth invalidation, network containment activation.



#6.9 File & Capability Reference

Files:
	∙	GeminiClient.swift
	∙	GeminiRequest.swift
	∙	GeminiResponse.swift
	∙	ExecutionEngine.swift
	∙	ExecutionRequest.swift
	∙	ExecutionResponse.swift
	∙	AILedgerBridge.swift
Capabilities:
	∙	API Key Mode
	∙	OAuth 2.0 PKCE Mode via ASWebAuthenticationSession
	∙	Swift SDK integration via Swift Package Manager (GoogleGenerativeAI)
	∙	Structured concurrency (async/await)
	∙	Global cancellation
	∙	Markdown-only enforcement
	∙	NetworkContainable compliance
	∙	SecurePurgeable compliance
Rules:
	∙	No plaintext token logging
	∙	Token injected via credentialState
	∙	All responses sealed before UI display
	∙	No response returned before ledger commit
	∙	All URLSession calls made over HTTPS only
	∙	Cancellation triggered on lock, background, or network containment
Execution Flow:
Terminal → CommandRouter
→ ExecutionEngine
→ GeminiClient (URLSession / HTTPS)
→ https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent
→ Response
→ AILedgerBridge.commit()
→ AISExecutionLedger.append()
→ Config rollback update
→ UI render

---

# 7. FILESYSTEM LAYER

Files:
- SecureFileManager.swift
- SandboxManager.swift
- FileProtectionPolicy.swift

Rules:
- No direct FileManager usage outside layer
- Atomic writes only
- Secure wipe support
- NSFileProtectionComplete enforced
- iCloud exclusion for security files
- No silent mutation

---

# 8. TOOLCHAIN & NODE MODEL

# 8.1 Execution Model

Execution Model: Remote Node (Primary)
The iOS app dispatches execution requests to a remote SovereignShell Node over a secured HTTPS connection. No code execution occurs on-device. The node handles all language runtimes, toolchain management, and execution isolation.
Directory:
SovereignShell-Node/
Includes:
	∙	Dockerfile
	∙	docker-compose.yml
	∙	nix/flake.nix
	∙	runtime/
	∙	execution_server.py
	∙	execution_server.rs
	∙	protocol_schema.json
	∙	toolchains/
	∙	install.sh
	∙	manifest.lock
	
#8.2 Toolchain Installation 
Strategy

Toolchains are split into two tiers to minimize baseline node storage while preserving full language support on demand.
Tier 1 — Core (Preinstalled, ~500MB total)
These are installed at node startup and remain resident:
	∙	openssl
	∙	openssh
	∙	git
	∙	gnupg
	∙	python3
	∙	pip
	∙	numpy
	∙	sqlite3
	∙	nodejs
	∙	npm
	∙	wget
	∙	curl
These cover the most common execution workloads and security tooling. Storage footprint is minimal and startup is fast.
Tier 2 — On-Demand (Pulled and cached per request)
These are fetched, verified, and cached only when a job requiring them is dispatched:
	∙	Rust + cargo (~500MB)
	∙	Go (~400MB)
	∙	Zig (~150MB)
	∙	Julia (~600MB)
	∙	Java (~300MB)
	∙	gcc / g++ / clang (~300MB)
	∙	Ruby (~100MB)
	∙	wasmtime (~50MB)
	∙	JAX (Python extension, ~200MB)
	∙	ADA/SPARK (remote toolchain, ~300MB)
	∙	C# / .NET (~400MB)
Once pulled, Tier 2 toolchains are cached on the node and do not need to be re-fetched unless the pinned version changes. Cache is validated against manifest hashes before each use.
All versions pinned and hashed in manifest.lock.

# 8.3 Toolchain Manifest (iOS Side)
Resources/ToolchainManifest.json defines:
	∙	Allowed languages
	∙	Allowed versions
	∙	Hashes
	∙	Tier designation (core or on-demand)
	∙	Memory limits
	∙	Execution timeouts
	∙	Execution constraints
ExecutionEngine must validate manifest before dispatch. If a requested language is Tier 2 and not yet cached on the node, the node returns a provisioning status to the iOS client before execution begins. The iOS UI must surface this state clearly — execution does not begin silently.

# 8.4 Supported Languages
Tier 1 (always available):
	∙	Python
	∙	JavaScript
	∙	SQL
Tier 2 (on-demand, cached after first use):
	∙	Rust
	∙	Go
	∙	Zig
	∙	Julia
	∙	Java
	∙	C
	∙	C++
	∙	C#
	∙	Ruby
	∙	WASM
	∙	JAX
	∙	ADA/SPARK
	∙	Swift
	∙	Kotlin
	
ADA/SPARK via remote toolchain only. Swift and Kotlin execution occur on the node, not on-device.

# 8.5 Node Security Rules
	∙	All node communication over HTTPS only
	∙	Node endpoint URL validated before dispatch
	∙	Execution results returned as sealed response objects
	∙	No execution result stored on node beyond request lifetime
	∙	Node does not retain user code between sessions
	∙	Manifest hash verified before every Tier 2 cache use
	∙	Node compromise triggers fail-closed execution disable on iOS side


# 8.6 SSH CAPABILITY

# 8.6.1 Core Principle

SSH connectivity is a first-class feature of SovereignShell. It is implemented as a controlled, ledger-aware, fail-closed subsystem. All SSH operations are routed through the SSHClient layer and are subject to the same integrity and containment rules as all other execution surfaces.
No SSH library binary execution is permitted outside the controlled client layer.

# 8.6.2 Implementation

SSH is implemented natively in Swift using the SwiftNIO SSH library, maintained by Apple and the Swift Server ecosystem.

Swift Package Manager dependency:
https://github.com/apple/swift-nio-ssh

Add to Package.swift:
dependencies: [
    .package(
        url: "https://github.com/apple/swift-nio-ssh",
        from: "0.8.0"
    )
],
targets: [
    .target(
        name: "YourApp",
        dependencies: ["NIOSSH"]
    )
]

# 8.6.3 Supported SSH Operations

	∙	Remote shell session (interactive)
	∙	Remote command execution (non-interactive)
	∙	SCP file transfer (send and receive)
	∙	SFTP file transfer
	∙	Port forwarding (local and remote)
	∙	Key-based authentication (Ed25519, ECDSA, RSA)
	∙	Password authentication (with explicit user consent)
	
# 8.6.4 Authentication & Credential Management

	∙	All SSH credentials stored in Keychain via SecItemAdd / SecItemCopyMatching
	∙	Private keys never written to disk in plaintext
	∙	Private keys never logged
	∙	Private keys never stored in AIS
	∙	Key passphrase injected at runtime only
	∙	Password authentication requires explicit user confirmation per session
	∙	Known hosts stored and validated — connection to unknown host requires explicit user approval
	
# 8.6.5 Known Hosts Enforcement

	∙	Known hosts file maintained in ApplicationSupport/Security/ssh_known_hosts
	∙	Protected under NSFileProtectionComplete
	∙	iCloud excluded
	∙	Host key verified on every connection
	∙	Host key mismatch triggers immediate connection abort and critical log event
	∙	No silent acceptance of changed host keys
	∙	User must explicitly approve new or changed host keys before connection proceeds

# 8.6.6 Session Lifecycle & Containment
	∙	All SSH sessions managed under Swift structured concurrency (async/await)
	∙	No detached tasks
	∙	Sessions are globally cancellable via Task cancellation
	∙	Session state tracked in SSHSessionManager
Session termination triggers:
	∙	App background (scenePhase == .background)
	∙	Lock event
	∙	Ledger failure
	∙	Network containment activation
	∙	OAuth invalidation
	∙	User explicit disconnect
No SSH session persists after app enters background.

# 8.6.7 Ledger Integration
Every SSH session is ledger-bound:
	∙	Session open event committed to AISExecutionLedger before connection proceeds
	∙	Session close event committed on termination
	∙	Remote command executions committed as individual ledger entries
	∙	File transfer operations committed as individual ledger entries
	∙	Host key approval events committed as ledger entries
	∙	No SSH operation executes before its ledger entry is committed
	
# 8.6.8 UI Surface

SSH sessions surface in the terminal view as a distinct session context. The terminal view displays:
	∙	Connected host
	∙	Authentication method used
	∙	Session duration
	∙	Active/inactive state
Input is blocked if:
	∙	Ledger commit fails
	∙	Host key is unverified
	∙	Session is in containment mode
	∙	App is transitioning to background
	
# 8.6.9 Files

	∙	SSHClient.swift
	∙	SSHSessionManager.swift
	∙	SSHCredentialStore.swift
	∙	SSHKnownHostsManager.swift
	∙	SSHLedgerBridge.swift
	∙	SSHRequest.swift
	∙	SSHResponse.swift

# 8.6.10 Security Rules

	∙	No SSH connection without prior ledger commit
	∙	No plaintext credential storage
	∙	No silent host key acceptance
	∙	No session persistence in background
	∙	No retry loops without explicit policy
	∙	All connections over port 22 by default — non-standard ports require explicit user configuration
	∙	Connection timeout enforced via NIOSSHHandler timeout policy
	∙	Fail-closed on any session integrity violation
	
	
# 8.7 REMOTE WORKSPACES

# 8.7.1 Core Principle

A Remote Workspace is a named, persistent, ledger-bound execution context that binds a terminal session to a remote host over SSH. It is a first-class feature of SovereignShell and is subject to the same integrity, containment, and fail-closed rules as all other execution surfaces.
A Remote Workspace is not:
	∙	A background sync process
	∙	A persistent daemon
	∙	A silent connection
	∙	A filesystem mirror
A Remote Workspace is:
	∙	A named, user-configured connection profile
	∙	A terminal context bound to a remote shell
	∙	An SFTP-backed file browsing surface
	∙	A ledger-bound execution environment

# 8.7.2 Workspace Profile
Each Remote Workspace is defined by a named profile stored securely in Keychain:
	∙	Profile name (user-defined)
	∙	Remote host (hostname or IP)
	∙	Port (default 22)
	∙	Username
	∙	Authentication method (key-based or password)
	∙	Private key reference (Keychain identifier)
	∙	Default remote working directory
	∙	Connection timeout policy
	∙	Known host fingerprint (validated against SSHKnownHostsManager)
Profiles are never stored in plaintext. Profile creation and modification are committed to the AIS ledger.


# 8.7.3 Workspace Lifecycle

User selects workspace profile
→ SSHSessionManager opens SSH connection
→ Known host verified (SSHKnownHostsManager)
→ Ledger entry committed (session open)
→ Remote shell bound to TerminalView
→ SFTP subsystem activated (file browsing)
→ Workspace marked active in DevToolbarView
→ User works in remote context
→ Session termination event
→ Ledger entry committed (session close)
→ Buffers purged
→ Workspace marked inactive

No workspace session proceeds before its ledger entry is committed. No workspace session persists after app enters background.

# 8.7.4 Terminal Integration
When a Remote Workspace is active the terminal operates in remote context mode:
	∙	All commands executed on the remote host via SSH
	∙	Prompt reflects remote host and working directory
	∙	Command history scoped to workspace session
	∙	Local built-in commands (help, clear, lock) remain available
	∙	Remote execution results sealed before UI render
	∙	Ledger commit required before each result renders
	
8.7.5 SFTP File Browsing
Remote Workspaces expose an SFTP-backed file browser surfaced within the terminal context:
	∙	Directory listing via SFTP
	∙	File read and write via SFTP
	∙	File transfer (upload and download) via SFTP
	∙	All file operations committed to ledger as individual entries
	∙	No file operation proceeds before ledger commit
	∙	File transfers display progress in terminal view
	∙	No partial writes — atomic transfer enforcement
	
# 8.7.6 Containment & Cancellation

Remote Workspace sessions are fully containment-capable:
Session termination triggers:
	∙	App background (scenePhase == .background)
	∙	Lock event
	∙	Ledger failure
	∙	Network containment activation
	∙	OAuth invalidation
	∙	SSH host key mismatch
	∙	User explicit disconnect
	∙	Connection timeout
On termination:
	∙	Remote shell closed
	∙	SFTP subsystem closed
	∙	Session buffers purged
	∙	Workspace marked inactive in DevToolbarView
	∙	Ledger entry committed for termination event
	
# 8.7.7 Security Rules
	∙	No workspace profile stored in plaintext
	∙	No workspace session without prior ledger commit
	∙	No silent reconnection after termination
	∙	No session persistence in background
	∙	Host key must be verified before every connection — no exceptions
	∙	Changed host key triggers immediate abort and critical log event
	∙	All file operations ledger-bound
	∙	Workspace profiles conform to SecurePurgeable — purged on lock and session termination
	∙	No retry loops without explicit user-initiated reconnect
	
# 8.7.8 Files
	∙RemoteWorkspaceManager.swift
	∙	WorkspaceProfile.swift
	∙	WorkspaceLedgerBridge.swift
	∙	WorkspaceSFTPClient.swift
	∙	WorkspaceSessionState.swift


# 9. SWIFTUI UI SPECIFICATION

## 9.1 Root Layout

ZStack  
 ├── Obsidian Background  
 └── VStack  
      ├── DevToolbarView (collapsible)  
      ├── TerminalView  
      ├── LogPanelView (collapsible)  
      └── KeyboardInputBar  

---

## 9.2 Dev Toolbar

Displays:

	∙	Toolchain status
	∙	Node status
	∙	OAuth status
	∙	AIS status
	∙	RollbackCounter
	∙	Execution model
	∙	SSH session status
	
Default: collapsed
Animated deterministically (≤0.2s)

No flashing indicators.

---

## 9.3 Terminal View

ScrollViewReader  
→ LazyVStack  

Monospaced font  
Obsidian background  (#0A0A0C)
Pearl White text (#F5F5FF) With Ultraviolet outline (#5F00FF)

No rainbow syntax.  
Errors: Muted Crimson  
Success: Electric Cyan  

Auto-scroll to bottom.

---

## 9.4 Secure Log Panel

Displays:

	∙	AIS events
	∙	Ledger commits
	∙	OAuth validation
	∙	Runtime policy violations
	∙	Chain verification events
	∙	SSH session events
	∙	Host key approval events
Chain failure state:
	∙	Crimson border
	∙	Input disabled
	∙	System halted message

---

## 9.5 Keyboard Input Bar

HStack:
 ├── Prompt indicator
 ├── TextField
 └── Execute button

Blocked if:

	∙	Ledger invalid
	∙	OAuth invalid
	∙	AIS failure
	∙	Runtime violation
	∙	SSH host key unverified

---

## 9.6 UI Security Invariants

No AI response renders before ledger commit success.

No SSH command executes before ledger commit success.

No remote workspace operation proceeds with an unverified host key.

Tamper →
Freeze input
Highlight log
Display:
CHAIN VALIDATION FAILURE — SYSTEM HALTED

---

# 10. CONCURRENCY RULES

Structured concurrency only

	∙	No detached tasks
	∙	No race conditions
	∙	Actor isolation enforced
	∙	All async cancellable
	∙	Cancellation on:
	∙	Lock
	∙	Background
	∙	Containment
	∙	Ledger failure
	∙	SSH session integrity violation
	∙	OAuth invalidation
	
Zero race condition tolerance.

# 11. ERROR TAXONOMY

No generic Error:

	∙	Domain-specific enums
	∙	No force unwrap
	∙	No silent failure
	∙	Deterministic error logging
Domain error types:
	∙	GeminiError — AI execution and endpoint failures
	∙	LedgerError — AIS chain and commit failures
	∙	SSHError — SSH session, host key, and credential failures
	∙	AuthenticationError — OAuth, biometric, and credential state failures
	∙	ConfigurationError — HMAC, schema, and rollback counter failures
	∙	ExecutionError — Command routing and execution pipeline failures
	∙	FilesystemError — Secure file operations and protection policy failures
	∙	NetworkError — Connectivity, containment, and timeout failures
Rules:
	∙	Every error domain maps to exactly one Swift enum
	∙	All cases carry associated context values — no empty error cases
	∙	All errors routed through SecureLogger — never printed directly
	∙	No error triggers silent recovery
	∙	All errors deterministically logged before any state change occurs
	
---

# 12. MEMORY SAFETY

Weak capture validation:
	∙	Retain cycle detection
	∙	Memory pressure testing
	∙	Secure purge validation
	∙	No unbounded growth
	
Rules:
	∙	All closures audited for weak capture requirements
	∙	[weak self] enforced in all async closures touching UI or session state
	∙	Actor isolation used as primary tool for preventing retain cycles across concurrency boundaries
	∙	Memory pressure events trigger controlled degradation — never silent failure
	∙	All sensitive data types conform to SecurePurgeable — credentials, tokens, keys, and AI responses purged explicitly on lock, background, and session termination
	∙	Terminal output buffer capped — no unbounded LazyVStack growth
	∙	SSH session buffers explicitly released on session termination
	∙	Ledger chain held in memory only during verification — not retained beyond boot validation
	∙	Instruments memory profiling required before every release candidate
	∙	Zero tolerance for memory-based credential leakage
	
	
# 13. RELEASE HARDENING CHECKLIST

Must validate:

	∙	Clean archive build
	∙	No warnings
	∙	No debug entitlements
	∙	Hardened runtime
	∙	Privacy manifest complete
	∙	OAuth redirect validated
	∙	Keychain accessibility validated
	∙	Network entitlements minimal
	∙	Ledger frozen
	∙	Version tag created
	∙	Artifact checksum recorded
	∙	SSH known hosts file validated
	∙	All Tier 2 toolchain manifest hashes verified
	∙	SecurePurgeable conformance verified on all credential types
	∙	Actor isolation audit complete
	∙	No force unwrap in release build
	∙	No print() statements in release build
	∙	All async operations confirmed cancellable
	∙	AIS full chain verification passes on clean install
	∙	AIS genesis auto-creation verified on first launch
	∙	Remote workspace profiles validated against known hosts
	∙	Memory pressure test passed
	∙	Instruments leak audit passed
	∙	All error domains confirmed — no generic Error in release build
	∙	RollbackCounter monotonic progression verified
	∙	App Transport Security exceptions confirmed minimal or absent

---

# 14. PHASE COMPLETION CRITERIA

Phase I complete when:

✓ Deterministic boot verified
✓ Configuration downgrade impossible
✓ AIS full chain validation passes
✓ AIS genesis auto-creation verified on clean install
✓ Tamper simulation fails closed
✓ Zero race conditions
✓ All async cancellable
✓ All secrets purgeable
✓ All credential types conform to SecurePurgeable
✓ Logging sanitized
✓ No print() or debug logic in release build
✓ No force unwrap in release build
✓ No generic Error in release build
✓ SSH known hosts enforcement verified
✓ SSH session termination on background confirmed
✓ Remote workspace ledger binding verified
✓ Gemini integration verified over HTTPS only
✓ OAuth PKCE flow validated end to end
✓ Keychain credential isolation verified
✓ Tier 1 toolchain resident and verified
✓ Tier 2 toolchain on-demand pull and cache verified
✓ Toolchain manifest hashes validated
✓ Memory pressure test passed
✓ Instruments leak audit passed
✓ RollbackCounter monotonic progression verified
✓ Release archive validated
✓ Ledger frozen
✓ Artifact archived with checksum
Only then may Android development begin.

---

# 15. PROJECT BLUEPRINT SUMMARY

iOS/SovereignShell/
├── SovereignShellApp.swift
├── Core/
│   ├── Terminal/
│   │   ├── TerminalEngine.swift
│   │   ├── CommandRouter.swift
│   │   └── TerminalSession.swift
│   ├── AI/
│   │   ├── GeminiClient.swift
│   │   ├── GeminiRequest.swift
│   │   ├── GeminiResponse.swift
│   │   ├── ExecutionEngine.swift
│   │   ├── ExecutionRequest.swift
│   │   ├── ExecutionResponse.swift
│   │   └── AILedgerBridge.swift
│   ├── Security/
│   │   ├── SecurityState.swift
│   │   ├── AISKeyManager.swift
│   │   ├── SecureConfigurationStore.swift
│   │   ├── AppSecurityConfiguration.swift
│   │   ├── RollbackCounter.swift
│   │   ├── GeminiCredentialState.swift
│   │   ├── AuthenticationMode.swift
│   │   └── Ledger/
│   │       ├── AISExecutionLedger.swift
│   │       ├── LedgerEntry.swift
│   │       ├── LedgerStore.swift
│   │       ├── LedgerChainValidator.swift
│   │       └── LedgerError.swift
│   ├── SSH/
│   │   ├── SSHClient.swift
│   │   ├── SSHSessionManager.swift
│   │   ├── SSHCredentialStore.swift
│   │   ├── SSHKnownHostsManager.swift
│   │   ├── SSHLedgerBridge.swift
│   │   ├── SSHRequest.swift
│   │   └── SSHResponse.swift
│   ├── Filesystem/
│   │   ├── SecureFileManager.swift
│   │   ├── SandboxManager.swift
│   │   └── FileProtectionPolicy.swift
│   └── Logging/
│       ├── SecureLogger.swift
│       ├── LogSanitizer.swift
│       └── AuditEvent.swift
└── UI/
    ├── Views/
    │   ├── RootView.swift
    │   ├── DevToolbarView.swift
    │   ├── TerminalView.swift
    │   ├── LogPanelView.swift
    │   └── KeyboardInputBar.swift
    └── Theme/
        └── ThemeAuthority.swift

SovereignShell-Node/
├── runtime/
│   ├── execution_server.py
│   ├── execution_server.rs
│   └── protocol_schema.json
├── toolchains/
│   ├── install.sh
│   └── manifest.lock
└── nix/
    └── flake.nix


---

# 16. GOVERNANCE PRINCIPLES (LOCKED)

1.	Deterministic initialization
	2.	No silent mutation
	3.	Explicit file mutation approval
	4.	Markdown-only AI code
	5.	All credentials purgeable
	6.	Network containment capability
	7.	Immutable mobile toolchain
	8.	Append-only integrity semantics
	9.	Strict monotonic configuration evolution
	10.	Fail-closed posture
	11.	No external trust anchors
	12.	Ledger authority is absolute — no subsystem bypasses ledger commit
	13.	All SSH operations ledger-bound
	14.	No plaintext credential storage at any layer
	15.	Structured concurrency enforced across all execution surfaces
	16.	Zero silent recovery pathways
	
---

# 17. APP TRANSPORT SECURITY (ATS) CONFIGURATION

# 17.1 Core Principle

App Transport Security is configured to its strictest permissible posture. No ATS exceptions are permitted in release builds. All network communication from SovereignShell must occur over HTTPS with TLS 1.2 or higher. HTTP is not permitted under any circumstance in production.
ATS configuration is locked at the same time as the Phase I architecture freeze. No ATS relaxation is permitted without a formal audit correction as defined in Section 2.

# 17.2 Required ATS Configuration

The following must be present in Info.plist:
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    <key>NSAllowsLocalNetworking</key>
    <true/>
</dict>

NSAllowsArbitraryLoads must be false in all release builds. No exceptions.
NSAllowsLocalNetworking is permitted as true solely to support MCP local server connections bound to localhost as defined in Section 6.5. This does not permit arbitrary local HTTP — only explicitly configured localhost MCP endpoints are permitted.


# 17.3 TLS Requirements

	∙	Minimum TLS version: TLS 1.2
	∙	Preferred TLS version: TLS 1.3
	∙	Certificate validation: enforced — no self-signed certificates permitted in production
	∙	Certificate pinning: required for all Gemini API endpoints
	∙	Forward secrecy: required
	∙	Weak cipher suites: prohibited


# 17.4 Certificate Pinning
Certificate pinning is enforced for the following endpoints:
	∙	generativelanguage.googleapis.com — Gemini API
	∙	accounts.google.com — OAuth authorization
	∙	oauth2.googleapis.com — OAuth token exchange and revocation
Pinning is implemented via URLSession delegate with URLAuthenticationChallenge validation:
func urlSession(
    _ session: URLSession,
    didReceive challenge: URLAuthenticationChallenge,
    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
) {
    guard let serverTrust = challenge.protectionSpace.serverTrust,
          PinningValidator.validate(serverTrust, for: challenge.protectionSpace.host) else {
        completionHandler(.cancelAuthenticationChallenge, nil)
        return
    }
    completionHandler(.useCredential, URLCredential(trust: serverTrust))
}

Pin mismatch triggers:
	∙	Connection abort
	∙	Critical log event via SecureLogger
	∙	Fail-closed AI disable if Gemini endpoint affected
	∙	Ledger entry committed for pin failure event
	

# 17.5 SSH Network Exemption
SSH connections managed by SSHClient via SwiftNIO SSH operate outside the ATS domain as they use a raw TCP transport on port 22, not HTTPS. SSH security is governed entirely by Section 8.6 and is not subject to ATS policy. This exemption is intentional and does not constitute a security relaxation.


# 17.6 Release Validation
ATS configuration must be validated as part of the release hardening checklist defined in Section 13:
	∙	NSAllowsArbitraryLoads confirmed false
	∙	No domain-specific ATS exceptions present
	∙	TLS 1.2 minimum confirmed
	∙	Certificate pins verified for all Gemini and OAuth endpoints
	∙	Pin validation unit tests passing
	∙	No ATS warnings in clean archive build
	
	
# 18. PRIVACY MANIFEST

# 18.1 Core Principle

SovereignShell must include a complete and accurate PrivacyInfo.xcprivacy file as required by Apple for App Store submission. The privacy manifest is a formal declaration of all data types collected, all required reason APIs used, and all third-party SDK privacy practices. It is treated as a locked configuration artifact — changes require the same audit discipline as architecture changes defined in Section 2.

# 18.2 Required File
File: SovereignShell/PrivacyInfo.xcprivacy
This file must be included in the app target and validated as part of the release hardening checklist defined in Section 13

# 18.3 Data Collection Declaration
SovereignShell does not collect, observe, store, transmit, or retain any user data. The AIS (Atomic Integrity Seal) is an installation-scoped integrity authority that seals execution state — it does not record, inspect, or expose user content in any form. SovereignShell never sees user data. The app is a deterministic execution surface, not a data collection surface.
The following declarations must be present in the privacy manifest:
	∙	No user content collected or retained by SovereignShell
	∙	No identifiers collected or transmitted
	∙	No diagnostics or crash data collected by the app
	∙	No analytics
	∙	No advertising data
	∙	No tracking of any kind
	∙	No third-party data sharing
	∙	No contact, location, browsing history, or purchase data collected
	∙	AI prompt content is transmitted directly from the device to the Google Generative AI API solely at the user’s explicit request — SovereignShell does not store, log, inspect, or retain prompt content or responses at the application layer
	
# 18.4 Required Reason APIs
Apple requires declared reasons for use of the following API categories. SovereignShell must declare the following:
File timestamp APIs
	∙	Reason: C617.1 — used for ledger entry timestamping within the AIS integrity system. Access is scoped to app-created files only. No user content is read or retained.
System boot time APIs
	∙	Reason: 35F9.1 — used for deterministic initialization sequencing during boot as defined in Section 3.
Disk space APIs
	∙	Reason: E174.1 — used to validate available storage before ledger writes and toolchain cache operations.
User defaults APIs
	∙	Reason: CA92.1 — used for non-sensitive app configuration state only. No credentials, user content, or security-sensitive values stored in user defaults.
	
# 18.5 Third-Party SDK Declarations
The following third-party SDKs are integrated and must be declared in the privacy manifest:
GoogleGenerativeAI (https://github.com/google/generative-ai-swift)
	∙	Purpose: AI execution surface as defined in Section 6
	∙	Data transmitted: user prompt content over HTTPS directly to Google Generative AI API at the user’s explicit request only
	∙	SovereignShell does not store, inspect, or retain prompt content or AI responses
	∙	Google’s own privacy policy governs data handling on their infrastructure
	∙	No data retained by the SDK beyond the request lifetime
NIOSSH (https://github.com/apple/swift-nio-ssh)
	∙	Purpose: SSH connectivity as defined in Section 8.6
	∙	Data transmitted: user-initiated SSH session data to user-configured remote hosts only
	∙	SovereignShell does not store, inspect, or retain SSH session content
	∙	No data collected or retained by the SDK
Both SDKs must provide or have available an Apple-format privacy manifest. If either SDK does not provide one, SovereignShell must declare their data practices directly in its own manifest.

# 18.6 Keychain & Credential Privacy
All credentials, tokens, and private keys are stored exclusively in the iOS Keychain under NSFileProtectionComplete. No credential material is ever transmitted to any party other than its intended authentication endpoint. No credential material is observable at the application layer. Keychain data is not declared as collected data because it never leaves the device except as authenticated credentials to their intended services.

# 18.7 Release Validation
The privacy manifest must be validated as part of the release hardening checklist defined in Section 13:
	∙	PrivacyInfo.xcprivacy present in app target
	∙	Data collection declared as none
	∙	All required reason APIs declared with correct reason codes
	∙	All third-party SDKs declared
	∙	No undeclared API usage detected in privacy report generated by Xcode
	∙	No data collection beyond declared types
	∙	Legal review completed before first App Store submission

--------------------------------

SovereignShell Phase I is a constrained, deterministic execution authority.

It does not expand until it is cryptographically and operationally stable.

End of Unified SwiftUI Project Specification.
