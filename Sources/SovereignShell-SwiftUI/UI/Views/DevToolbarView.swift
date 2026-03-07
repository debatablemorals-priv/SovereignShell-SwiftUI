import SwiftUI

struct DevToolbarView: View {
    @EnvironmentObject private var container: AppContainer
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Text("DEV")
                    .font(.system(.caption, design: .monospaced))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Spacer()

                StatusPill(label: "AIS", value: aisStatusText)
                StatusPill(label: "NODE", value: "OFF")
                StatusPill(label: "OAUTH", value: oauthStatusText)
                StatusPill(label: "SSH", value: "OFF")

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(Color.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(red: 0.07, green: 0.07, blue: 0.09))

            if isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    ToolbarRow(label: "Toolchain", value: "Uninitialized")
                    ToolbarRow(label: "Node Status", value: "Disconnected")
                    ToolbarRow(label: "OAuth Status", value: oauthDetailText)
                    ToolbarRow(label: "AIS Status", value: aisDetailText)
                    ToolbarRow(label: "RollbackCounter", value: "\(container.rollbackCounter.current())")
                    ToolbarRow(label: "Execution Model", value: "Remote Node")
                    ToolbarRow(label: "SSH Session", value: "Inactive")
                    ToolbarRow(label: "Lock State", value: container.securityState.isLocked ? "Locked" : "Unlocked")
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(red: 0.08, green: 0.08, blue: 0.10))
            }
        }
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1),
            alignment: .bottom
        )
    }

    private var aisStatusText: String {
        container.securityState.isAISValid ? "OK" : "FAIL"
    }

    private var oauthStatusText: String {
        container.securityState.isOAuthValid ? "ON" : "OFF"
    }

    private var aisDetailText: String {
        container.securityState.isAISValid ? "Valid" : "Invalid"
    }

    private var oauthDetailText: String {
        container.securityState.isOAuthValid ? "Available" : "Unavailable"
    }
}

private struct ToolbarRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.gray)
                .frame(width: 140, alignment: .leading)

            Text(value)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.white)

            Spacer()
        }
    }
}

private struct StatusPill: View {
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .foregroundColor(.gray)

            Text(value)
                .foregroundColor(.white)
        }
        .font(.system(size: 10, weight: .medium, design: .monospaced))
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(Color.white.opacity(0.06))
        .clipShape(Capsule())
    }
}