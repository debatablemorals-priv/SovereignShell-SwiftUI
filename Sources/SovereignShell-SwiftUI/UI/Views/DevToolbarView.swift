import SwiftUI

struct DevToolbarView: View {
    @EnvironmentObject private var container: AppContainer

    var body: some View {
        HStack(spacing: 12) {
            statusChip(
                title: "AIS",
                value: container.securityState.isAISValid ? "VALID" : "INVALID",
                color: container.securityState.isAISValid ? .green : .red
            )

            statusChip(
                title: "LOCK",
                value: container.securityState.isLocked ? "ON" : "OFF",
                color: container.securityState.isLocked ? .red : .green
            )

            statusChip(
                title: "SESSION",
                value: container.terminalSession.isLocked ? "LOCKED" : "ACTIVE",
                color: container.terminalSession.isLocked ? .red : .green
            )

            statusChip(
                title: "RB",
                value: "\(container.rollbackCounter.current())",
                color: .blue
            )

            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.thinMaterial)
    }

    private func statusChip(title: String, value: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text("\(title): \(value)")
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.primary.opacity(0.06))
        .clipShape(Capsule())
    }
}
