import SwiftUI

struct LogPanelView: View {

    @EnvironmentObject private var container: AppContainer

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {

            HStack {
                Text("Security Event Log")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))

                Spacer()
            }

            Divider()

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {

                    ForEach(container.logger.events.reversed()) { event in
                        HStack(alignment: .top) {

                            Text(timestamp(event.timestamp))
                                .foregroundColor(.gray)
                                .font(.system(size: 11, design: .monospaced))

                            Text(event.level.rawValue.uppercased())
                                .foregroundColor(color(for: event.level))
                                .font(.system(size: 11, weight: .bold, design: .monospaced))

                            Text(event.message)
                                .foregroundColor(.white)
                                .font(.system(size: 11, design: .monospaced))

                            Spacer()
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding(8)
        .background(Color.black.opacity(0.85))
    }

    private func timestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }

    private func color(for level: AuditEvent.Level) -> Color {
        switch level {
        case .info:
            return .green
        case .warning:
            return .orange
        case .error:
            return .red
        case .security:
            return .purple
        }
    }
}
