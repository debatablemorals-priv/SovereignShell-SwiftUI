import SwiftUI

struct LogPanelView: View {
    @EnvironmentObject private var container: AppContainer

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Security Log")
                .font(.headline)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 6) {
                    ForEach(container.logger.events.reversed()) { event in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(levelLabel(for: event))
                                .font(.caption.bold())
                                .foregroundStyle(color(for: event))

                            Text(event.message)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(rowBackground(for: event))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    if container.logger.events.isEmpty {
                        Text("No security events recorded.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 4)
                    }
                }
            }
        }
        .padding()
    }

    private func levelLabel(for event: AuditEvent) -> String {
        event.level.rawValue.uppercased()
    }

    private func color(for event: AuditEvent) -> Color {
        switch event.level {
        case .info:
            return .secondary
        case .warning:
            return .yellow
        case .error:
            return .red
        case .security:
            return .orange
        }
    }

    private func rowBackground(for event: AuditEvent) -> Color {
        switch event.level {
        case .info:
            return Color.secondary.opacity(0.08)
        case .warning:
            return Color.yellow.opacity(0.12)
        case .error:
            return Color.red.opacity(0.12)
        case .security:
            return Color.orange.opacity(0.12)
        }
    }
}
