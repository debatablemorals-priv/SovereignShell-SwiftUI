import SwiftUI

struct LogPanelView: View {

    @EnvironmentObject private var container: AppContainer

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {

            HStack {
                Text("Security Event Log")
                    .font(ThemeAuthority.font)

                Spacer()
            }

            Divider()

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {

                    ForEach(container.logger.events.reversed()) { event in
                        HStack(alignment: .top) {

                            Text(timestamp(event.timestamp))
                                .foregroundColor(.gray)
                                .font(ThemeAuthority.font)

                            Text(event.level.rawValue.uppercased())
                                .foregroundColor(color(for: event.level))
                                .font(ThemeAuthority.font)

                            Text(event.message)
                                .foregroundColor(ThemeAuthority.terminalText)
                                .font(ThemeAuthority.font)

                            Spacer()
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding(8)
        .background(ThemeAuthority.background)
    }

    private func timestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }

    private func color(for level: AuditEvent.Level) -> Color {
        switch level {
        case .info:
            return ThemeAuthority.terminalText
        case .warning:
            return ThemeAuthority.warning
        case .error:
            return ThemeAuthority.error
        case .security:
            return ThemeAuthority.accent
        }
    }
}
