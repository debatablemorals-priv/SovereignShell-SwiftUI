import SwiftUI

struct LogPanelView: View {
    @EnvironmentObject private var container: AppContainer
    @State private var isExpanded = false

    private var placeholderEvents: [LogEventRowModel] {
        [
            LogEventRowModel(
                category: "AIS",
                message: container.securityState.isAISValid ? "Ledger state valid" : "Ledger validation failed",
                level: container.securityState.isAISValid ? .info : .critical
            ),
            LogEventRowModel(
                category: "LEDGER",
                message: "Rollback counter: \(container.rollbackCounter.current())",
                level: .info
            ),
            LogEventRowModel(
                category: "OAUTH",
                message: container.securityState.isOAuthValid ? "Credential state available" : "Credential state unavailable",
                level: container.securityState.isOAuthValid ? .info : .warning
            ),
            LogEventRowModel(
                category: "RUNTIME",
                message: container.securityState.runtimeViolationDetected ? "Runtime violation detected" : "No runtime violations detected",
                level: container.securityState.runtimeViolationDetected ? .critical : .info
            )
        ]
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Text("LOG")
                    .font(.system(.caption, design: .monospaced))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Spacer()

                Text(isExpanded ? "VISIBLE" : "HIDDEN")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.06))
                    .clipShape(Capsule())

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.up")
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
            .overlay(
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 1),
                alignment: .top
            )

            if isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(placeholderEvents) { event in
                        LogEventRow(event: event)
                    }
                }
                .background(Color(red: 0.07, green: 0.07, blue: 0.09))
                .overlay(
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
            }
        }
    }
}

private struct LogEventRow: View {
    let event: LogEventRowModel

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text(event.category)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundColor(event.level.categoryColor)
                .frame(width: 72, alignment: .leading)

            Text(event.message)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(event.level.label)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(event.level.badgeColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.06))
                .clipShape(Capsule())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(red: 0.07, green: 0.07, blue: 0.09))
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

private struct LogEventRowModel: Identifiable {
    enum Level {
        case info
        case warning
        case critical

        var label: String {
            switch self {
            case .info:
                return "INFO"
            case .warning:
                return "WARN"
            case .critical:
                return "CRIT"
            }
        }

        var badgeColor: Color {
            switch self {
            case .info:
                return .white
            case .warning:
                return .yellow
            case .critical:
                return .red
            }
        }

        var categoryColor: Color {
            switch self {
            case .info:
                return .gray
            case .warning:
                return .yellow
            case .critical:
                return .red
            }
        }
    }

    let id = UUID()
    let category: String
    let message: String
    let level: Level
}