import SwiftUI
import WidgetKit
import ActivityKit

// MARK: - App Group UserDefaults
// ต้องตรงกับ _appGroupId ใน LaundryLiveActivityService (Dart)
private let sharedDefault = UserDefaults(suiteName: "group.com.brownywash.brownyapplications.liveactivity")!

// MARK: - Helper: อ่านค่าจาก UserDefaults ผ่าน prefixedKey
private extension ActivityViewContext<LiveActivitiesAppAttributes> {
    var remainingSeconds: Int { sharedDefault.integer(forKey: attributes.prefixedKey("remaining_seconds")) }
    var totalSeconds: Int     { sharedDefault.integer(forKey: attributes.prefixedKey("total_seconds")) }
    var isCompleted: Bool     { sharedDefault.bool(forKey: attributes.prefixedKey("is_completed")) }
    var machineNumber: String { sharedDefault.string(forKey: attributes.prefixedKey("machine_number")) ?? "" }
    var serviceType: String   { sharedDefault.string(forKey: attributes.prefixedKey("service_type")) ?? "wash" }
    var branchName: String    { sharedDefault.string(forKey: attributes.prefixedKey("branch_name")) ?? "" }

    // Computed
    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        if isCompleted { return 1.0 }
        let elapsed = Double(totalSeconds - remainingSeconds)
        return min(max(elapsed / Double(totalSeconds), 0), 1)
    }

    var formattedRemaining: String {
        guard !isCompleted else { return "เสร็จสิ้น" }
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    var serviceLabel: String {
        switch serviceType {
        case "wash":     return "ซัก"
        case "dry":      return "อบ"
        case "wash_dry": return "ซัก+อบ"
        default:         return serviceType
        }
    }

    var serviceEmoji: String {
        switch serviceType {
        case "wash":     return "🫧"
        case "dry":      return "♨️"
        case "wash_dry": return "🫧"
        default:         return "🫧"
        }
    }
}

// MARK: - Browny Green Color
private extension Color {
    static let brownyGreen = Color(red: 0.18, green: 0.55, blue: 0.34)
}

// MARK: - Lock Screen / Notification Banner View

struct BrownyLockScreenView: View {
    let context: ActivityViewContext<LiveActivitiesAppAttributes>

    var body: some View {
        VStack(spacing: 8) {
            // Header
            HStack(alignment: .center) {
                HStack(spacing: 6) {
                    Text(context.serviceEmoji).font(.system(size: 20))
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Browny \(context.serviceLabel)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(context.isCompleted ? .green : .primary)
                        Text("เครื่อง \(context.machineNumber)")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                Text(context.branchName)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(context.isCompleted ? Color.green : .brownyGreen)
                        .frame(width: geo.size.width * context.progress, height: 8)
                        .animation(.easeInOut(duration: 0.5), value: context.progress)
                }
            }
            .frame(height: 8)
            .padding(.horizontal, 16)

            // Footer
            HStack {
                if context.isCompleted {
                    Label("ซัก\(context.serviceLabel)เสร็จแล้ว! แตะเพื่อให้คะแนน ⭐", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.green)
                } else {
                    Label(context.formattedRemaining, systemImage: "timer")
                        .font(.system(size: 12, weight: .medium))
                }
                Spacer()
                if !context.isCompleted {
                    Text("\(Int(context.progress * 100))%")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .background(Color(UIColor.systemBackground))
    }
}

// MARK: - Dynamic Island Views

struct BrownyDynamicIslandCompactLeading: View {
    let context: ActivityViewContext<LiveActivitiesAppAttributes>
    var body: some View {
        HStack(spacing: 4) {
            Text(context.serviceEmoji).font(.system(size: 14))
            Text(context.machineNumber)
                .font(.system(size: 12, weight: .semibold))
        }
    }
}

struct BrownyDynamicIslandCompactTrailing: View {
    let context: ActivityViewContext<LiveActivitiesAppAttributes>
    var body: some View {
        if context.isCompleted {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 14))
        } else {
            Text(context.formattedRemaining)
                .font(.system(size: 12, weight: .semibold))
                .monospacedDigit()
        }
    }
}

struct BrownyDynamicIslandMinimal: View {
    let context: ActivityViewContext<LiveActivitiesAppAttributes>
    var body: some View {
        if context.isCompleted {
            Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
        } else {
            Text(context.formattedRemaining)
                .font(.system(size: 10, weight: .bold))
                .monospacedDigit()
        }
    }
}

// MARK: - Widget Configuration

struct BrownyLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
            BrownyLockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    BrownyDynamicIslandCompactLeading(context: context)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if context.isCompleted {
                        Text("✅")
                    } else {
                        Text(context.formattedRemaining)
                            .font(.system(size: 16, weight: .bold))
                            .monospacedDigit()
                    }
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.branchName)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(context.isCompleted ? Color.green : .brownyGreen)
                                .frame(width: geo.size.width * context.progress, height: 6)
                        }
                    }
                    .frame(height: 6)
                    .padding(.horizontal, 4)
                }
            } compactLeading: {
                BrownyDynamicIslandCompactLeading(context: context)
            } compactTrailing: {
                BrownyDynamicIslandCompactTrailing(context: context)
            } minimal: {
                BrownyDynamicIslandMinimal(context: context)
            }
        }
    }
}
