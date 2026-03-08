# SovereignShell

Deterministic Secure Execution Environment for Mobile Platforms

SovereignShell is a terminal-first, security-focused execution environment designed for sandboxed mobile operating systems. The project emphasizes deterministic system behavior, fail-closed integrity enforcement, and privacy-preserving execution verification through the Atomic Integrity Seal (AIS).

The iOS implementation serves as the canonical reference architecture.

---

# Core Principles

SovereignShell is built on the following foundational principles:

Deterministic execution  
Fail-closed integrity enforcement  
Minimal attack surface  
Strict rollback protection  
Privacy-preserving attestation  
Structured concurrency  
No silent recovery paths

Execution integrity takes precedence over availability.

---

# Atomic Integrity Seal (AIS)

AIS is the integrity primitive that governs execution trust within SovereignShell.

AIS provides:

Append-only execution ledger  
Cryptographically chained integrity verification  
Rollback protection  
Tamper-evident state continuity  
Environment-bound execution state

AIS is **not**:

• a blockchain  
• a distributed ledger  
• an audit logging framework

AIS behaves as a lightweight, installation-scoped integrity authority designed for constrained sandbox environments.

Full technical specifications are located in:

Docs/AIS/

---

# Architecture Overview

Major system components include:

Terminal Engine  
Command Router  
Execution Engine  
Security State Controller  
AIS Execution Ledger  
SSH Subsystem  
Remote Node Execution Layer  
SwiftUI Terminal Interface

Execution state transitions are deterministic and validated before subsystem activation.

---

# Execution Model

SovereignShell uses a remote node execution model.

The iOS client:

• manages the terminal interface  
• validates toolchain manifests  
• enforces AIS integrity  
• dispatches execution requests  

Remote nodes provide:

• language runtimes  
• isolated execution environments  
• toolchain provisioning

No user code executes directly on-device.

---

# AI Integration

SovereignShell integrates Google's Generative AI API using the official Swift SDK.

Supported authentication modes:

API Key Mode  
OAuth 2.0 PKCE Mode

All AI interactions:

• occur over HTTPS  
• use ephemeral URLSession sessions  
• are cancellable via structured concurrency  
• require AIS ledger commit before response rendering

---

# SSH Support

SovereignShell includes native SSH functionality built using SwiftNIO SSH.

Supported capabilities:

Remote shell sessions  
Remote command execution  
SCP file transfer  
SFTP file browsing  
Port forwarding  

All SSH operations are ledger-bound and fail-closed on integrity violations.

---

# Repository Structure:


SovereignShell-SwiftUI
│
├── .github/
│   └── workflows/
│
├── Docs/
│   │
│   ├── AIS/
│   │   ├── AIS_Adversarial_Attack_Catalog_v1.md
│   │   ├── AIS_Comparative_Analysis_v1.md
│   │   ├── AIS_Cryptographic_Construction_v1.md
│   │   ├── AIS_Evaluation_Methodology_v1.md
│   │   ├── AIS_Formal_Model_v1.md
│   │   ├── AIS_Formal_Security_Properties_v1.md
│   │   ├── AIS_Formal_Verification_Plan_v1.md
│   │   ├── AIS_Performance_Benchmark_Spec_v1.md
│   │   ├── AIS_RedTeam_BlueTeam_TestPlan_v1.md
│   │   ├── AIS_Reference_Implementation_Requirements_v1.md
│   │   ├── AIS_State_Machine_v1.md
│   │   ├── AIS_System_Architecture_v1.md
│   │   └── AIS_Threat_Analysis_v1.md
│   │
│   ├── ARCHITECTURE.md
│   ├── CONTRIBUTING.md
│   ├── LICENSE
│   ├── SECURITY.md
│   └── SovereignShell_System_Specification.md
│
├── Sources/
│   └── SovereignShell/
│       │
│       ├── Core/
│       │   ├── AI/
│       │   │   ├── AILedgerBridge.swift
│       │   │   ├── ExecutionEngine.swift
│       │   │   ├── ExecutionRequest.swift
│       │   │   ├── ExecutionResponse.swift
│       │   │   ├── GeminiClient.swift
│       │   │   ├── GeminiRequest.swift
│       │   │   └── GeminiResponse.swift
│       │   │
│       │   ├── Filesystem/
│       │   │   ├── FileProtectionPolicy.swift
│       │   │   ├── SandboxManager.swift
│       │   │   └── SecureFileManager.swift
│       │   │
│       │   ├── Logging/
│       │   │   ├── AuditEvent.swift
│       │   │   ├── LogSanitizer.swift
│       │   │   └── SecureLogger.swift
│       │   │
│       │   ├── Security/
│       │   │   ├── AISKeyManager.swift
│       │   │   ├── AppSecurityConfiguration.swift
│       │   │   ├── AuthenticationMode.swift
│       │   │   ├── GeminiCredentialState.swift
│       │   │   ├── RollbackCounter.swift
│       │   │   ├── SecurityState.swift
│       │   │   ├── SecureConfigurationStore.swift
│       │   │   │
│       │   │   └── Ledger/
│       │   │       ├── AISExecutionLedger.swift
│       │   │       ├── LedgerChainValidator.swift
│       │   │       ├── LedgerEntry.swift
│       │   │       ├── LedgerError.swift
│       │   │       └── LedgerStore.swift
│       │   │
│       │   ├── SSH/
│       │   │   ├── SSHClient.swift
│       │   │   ├── SSHCredentialStore.swift
│       │   │   ├── SSHKnownHostsManager.swift
│       │   │   ├── SSHLedgerBridge.swift
│       │   │   ├── SSHRequest.swift
│       │   │   ├── SSHResponse.swift
│       │   │   └── SSHSessionManager.swift
│       │   │
│       │   └── Terminal/
│       │       ├── CommandRouter.swift
│       │       ├── TerminalEngine.swift
│       │       └── TerminalSession.swift
│       │
│       └── UI/
│           ├── Theme/
│           │   └── ThemeAuthority.swift
│           │
│           └── Views/
│               ├── DevToolbarView.swift
│               ├── KeyboardInputBar.swift
│               ├── LogPanelView.swift
│               ├── RootView.swift
│               └── TerminalView.swift
│
├── Tests/
│   └── SovereignShellTests/
│
├── .editorconfig
├── .gitignore
├── Package.swift
└── README.md


---

# Security Model

SovereignShell enforces strict execution guarantees:

• append-only integrity semantics  
• deterministic initialization  
• strict rollback monotonicity  
• ledger-bound execution surfaces  
• credential isolation via Keychain  
• structured concurrency enforcement  
• fail-closed runtime behavior

Integrity violations immediately halt execution.

---

# Documentation

Primary documentation is located in the Docs directory.

System Specification  
Docs/SovereignShell_System_Specification.md

AIS Security Specifications  
Docs/AIS/

Architecture and governance documents  
Docs/

---

# Development Status

Phase I — Production Hardening Active

Current focus areas:

AIS verification and adversarial testing  
Deterministic execution guarantees  
Security hardening and audit readiness  
Remote node execution validation

Cross-platform expansion will begin only after Phase I stabilization.

---

# Contributing

See:

Docs/CONTRIBUTING.md

Contributions must maintain:

deterministic behavior  
fail-closed security posture  
structured concurrency rules  
AIS integrity guarantees

---

# Security Reporting

Security issues should be reported privately according to:

Docs/SECURITY.md

Do not disclose vulnerabilities publicly before coordinated disclosure.

---

# License

This project is licensed under the **Apache License, Version 2.0**.

Copyright © 2026 SovereignShell Contributors

Licensed under the Apache License, Version 2.0 (the "License");  
you may not use this project except in compliance with the License.

You may obtain a copy of the License at:

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an **"AS IS" BASIS**, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied.

See the LICENSE file for the full license text.

---

SovereignShell is a deterministic execution authority designed for secure development in hostile environments.

