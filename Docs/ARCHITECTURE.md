# SovereignShell Architecture

## Overview

SovereignShell is a deterministic, security-oriented terminal environment designed to provide a structured command execution pipeline with auditable runtime behavior.

The project is organized around a strict separation of concerns:

- App entry and container authority
- Terminal core
- Security and rollback state
- UI composition
- External service integration

## Current Execution Flow

The current terminal pipeline is:

KeyboardInputBar
→ TerminalEngine.execute()
→ CommandRouter.route()
→ TerminalSession mutation
→ TerminalView render

This ensures commands do not bypass the routing layer.

## Core Components

### App Entry Layer
- `SovereignShellApp.swift`
- `AppContainer.swift`
- `RootView.swift`

These files establish the application entry point, own shared state, and compose the top-level UI.

### Terminal Core
- `CommandHistory.swift`
- `CommandRouter.swift`
- `TerminalEngine.swift`
- `TerminalSession.swift`

These files define command intake, routing, execution control, and terminal state/output.

### Security Core
- `SecurityState.swift`
- `RollbackCounter.swift`
- `AISExecutionLedger.swift`

These files define lock state, rollback protection, and execution ledger behavior.

### UI Layer
- `RootView.swift`
- `TerminalView.swift`
- `KeyboardInputBar.swift`
- `DevToolbarView.swift`
- `LogPanelView.swift`

These files render the terminal surface and developer-facing runtime information.

## Design Principles

### Deterministic Routing
All terminal commands must pass through `CommandRouter` before mutating terminal state.

### Shared Container Authority
`AppContainer` owns the shared runtime objects used by the UI and terminal core.

### Explicit Security Gating
Security-sensitive execution must be gated through `SecurityState`.

### Monotonic Rollback Protection
`RollbackCounter` must never move backward.

## Current Status

The project currently builds successfully in GitHub Actions and includes:

- Swift Package Manager configuration
- Google Generative AI dependency integration
- Swift NIO SSH dependency integration
- Working terminal UI scaffold
- Working terminal command pipeline
- CI-based remote build validation

## Next Planned Milestones

1. Expand terminal command set
2. Connect terminal execution to AIS ledger events
3. Introduce AI command assistance flow
4. Introduce SSH session integration
5. Harden configuration and runtime validation
