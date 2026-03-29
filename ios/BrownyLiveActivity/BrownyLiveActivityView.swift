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
    var machineName: String   { sharedDefault.string(forKey: attributes.prefixedKey("machine_name")) ?? "" }
    var startTime: String     { sharedDefault.string(forKey: attributes.prefixedKey("start_time")) ?? "" }
    var finishTime: String    { sharedDefault.string(forKey: attributes.prefixedKey("finish_time")) ?? "" }

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
        return "\(m) นาที"
    }

    var formattedRemainingCompact: String {
        guard !isCompleted else { return "✓" }
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    var displayMachineName: String {
        if !machineName.isEmpty { return machineName }
        let serviceLabel: String
        switch serviceType {
        case "wash":     serviceLabel = "เครื่องซัก"
        case "dry":      serviceLabel = "เครื่องอบ"
        case "wash_dry": serviceLabel = "เครื่องซัก+อบ"
        default:         serviceLabel = "เครื่อง"
        }
        return "\(serviceLabel) \(machineNumber)"
    }
}

// MARK: - Colors
private extension Color {
    static let brownyGreen = Color(red: 0.18, green: 0.73, blue: 0.22)   // #2fba38
    static let brownyLightGreen = Color(red: 0.67, green: 0.94, blue: 0.69) // #abf0af
    static let brownyBrown = Color(red: 0.35, green: 0.22, blue: 0.09)   // #593817
    static let brownyGray = Color(red: 0.59, green: 0.59, blue: 0.59)    // #949494
    static let brownyTrackGray = Color(red: 0.80, green: 0.80, blue: 0.80) // #cdcdcd
    static let brownyGradientTop = Color(red: 0.56, green: 0.80, blue: 0.54) // #8fcb8a
    static let brownyGradientMid = Color(red: 0.92, green: 1.0, blue: 0.86) // #eaffdb
}

// MARK: - Lock Screen / Notification Banner View

let fontFamily = "Prompt-Medium"

struct BrownyLockScreenView: View {
    let context: ActivityViewContext<LiveActivitiesAppAttributes>

    var body: some View {
        ZStack {
            // Background gradient fills full banner frame edge-to-edge
            LinearGradient(
                stops: [
                    .init(color: Color.brownyGradientTop.opacity(0.84), location: 0),
                    .init(color: Color.brownyGradientMid.opacity(0.84), location: 0.25),
                    .init(color: Color.white, location: 0.57),
                    .init(color: Color.white, location: 1.0),
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // Content with explicit inset from banner edges
            VStack(spacing: 0) {
                // Header section
                headerSection

                // Separator
                Rectangle()
                    .fill(Color.brownyTrackGray)
                    .frame(height: 1)

                // Progress section
                progressSection
            }
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .padding(.top, 15)
            .padding(.bottom, 15)
            
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack(alignment: .top, spacing: 8) {
            // Machine icon — PNG ตรงๆ 40x40
            Image("ic_machine")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .padding(.trailing, 8)

            // Machine name + branch name
            VStack(alignment: .leading, spacing: 0) {
                Text(context.displayMachineName)
                    .font(.custom(fontFamily, size: 13, ))
                    .foregroundColor(.brownyBrown)
                    .lineLimit(1)
                Text(context.branchName)
                    .font(.custom(fontFamily, size: 11, ))
                    .foregroundColor(.brownyGray)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            // Browny character (top-right) — 73x52 ชิดขอบ
            Image("browny_love")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 73, height: 52)
        }
        .padding(.top, 16)
//        .padding(.bottom, 0)
    }

    // MARK: - Progress
    private var progressSection: some View {
        VStack(spacing: 0) {
            // Progress track row
            HStack(alignment: .center, spacing: 0) {
                // Left: Paw icon
                startCircle

                // Track with bubble
                progressTrack

                // Right: Checkmark icon
                endCircle
            }
            .padding(.top, 16)

            // Labels row
            HStack {
                // เริ่มต้น + time
                VStack(spacing: 2) {
                    Text("เริ่มต้น")
                        .font(.custom(fontFamily, size: 9, ))
                        .foregroundColor(.brownyBrown)
                        .padding(.top, -10)
                    Text(context.startTime.isEmpty ? "--:--" : context.startTime)
                        .font(.custom(fontFamily, size: 9, ))
                        .foregroundColor(.brownyGray)
                }

                Spacer()

                // เสร็จสิ้น + time
                VStack(spacing: 2) {
                    Text("เสร็จสิ้น")
                        .font(.custom(fontFamily, size: 9, ))
                        .foregroundColor(.brownyBrown)
                        .padding(.top, -10)
                    Text(context.finishTime.isEmpty ? "--:--" : context.finishTime)
                        .font(.custom(fontFamily, size: 9, ))
                        .foregroundColor(.brownyGray)
                }
            }
            .padding(.bottom, 15)
        }
    }

    // MARK: - Start icon (paw) — PNG ตรงๆ 31x30
    private var startCircle: some View {
        Image("ic_paw")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 31, height: 30)
    }

    // MARK: - End icon (checkmark) — PNG ตรงๆ 31x30
    // ic_check_inactive ขณะยังทำงานอยู่, ic_checked เมื่อเสร็จ
    private var endCircle: some View {
        Image(context.isCompleted ? "ic_checked" : "ic_check_inactive")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 31, height: 30)
    }

    // MARK: - Progress track with bubble + browny character
    private var progressTrack: some View {
        GeometryReader { geo in
            let trackWidth = geo.size.width
            let progressX = trackWidth * context.progress
            let trackCenterY = geo.size.height / 2

            ZStack(alignment: .topLeading) {
                // Inactive track (gray) — อยู่กึ่งกลางแนวตั้ง
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.brownyLightGreen)
                    .frame(height: 4)
                    .offset(y: trackCenterY - 2)

                // Active track (green)
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.brownyGreen)
                    .frame(width: max(0, progressX), height: 4)
                    .offset(y: trackCenterY - 2)

                // Browny character on progress point
                if !context.isCompleted {
                    brownyProgressIndicator(at: progressX, trackWidth: trackWidth, trackCenterY: trackCenterY)
                }
            }
        }
        .frame(height: 55)
    }

    // MARK: - Browny progress indicator (character + speech bubble)
    private func brownyProgressIndicator(at x: CGFloat, trackWidth: CGFloat, trackCenterY: CGFloat) -> some View {
        let characterSize: CGFloat = 24
        let bubbleHeight: CGFloat = 22 // bubble + triangle โดยประมาณ
        let spacing: CGFloat = 1

        // คำนวณ Y ให้ character อยู่กึ่งกลาง track แล้ว bubble อยู่ข้างบน
        let characterY = trackCenterY - (characterSize / 1.6)
//        let totalHeight = bubbleHeight + spacing + characterSize
        let topY = characterY - bubbleHeight - spacing

        return VStack(spacing: spacing) {
            // Speech bubble with remaining time
            speechBubble

            // Browny character image
            Image("browny_progress")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: characterSize, height: characterSize)
        }
        .offset(
            x: clampedOffset(x: x, trackWidth: trackWidth),
            y: topY
        )
    }

    private func clampedOffset(x: CGFloat, trackWidth: CGFloat) -> CGFloat {
        let halfWidth: CGFloat = 20 // half of the indicator width
        let minX: CGFloat = 0
        let maxX = trackWidth - halfWidth * 2
        return min(max(x - halfWidth, minX), maxX)
    }

    // MARK: - Speech bubble
    private var speechBubble: some View {
        VStack(spacing: -1) {
            // Bubble
            Text(context.formattedRemaining)
                .font(.custom(fontFamily, size: 10))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.brownyGreen)
                )

            // Triangle tail
            Triangle()
                .fill(Color.brownyGreen)
                .frame(width: 6, height: 5)
        }
    }
}

// MARK: - Triangle shape for speech bubble tail
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Dynamic Island Views


struct BrownyDynamicIslandCompactLeading: View {
    let context: ActivityViewContext<LiveActivitiesAppAttributes>
    var body: some View {
        HStack(spacing: 4) {
            Image("ic_machine")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 20)
                .padding(.trailing, 8)
            Text(context.machineNumber)
                .font(.custom(fontFamily, size: 11))
        }
    }
}

struct BrownyDynamicIslandExtendedLeading: View {
    let context: ActivityViewContext<LiveActivitiesAppAttributes>
    var body: some View {
        HStack(spacing: 4) {
            Image("ic_machine")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .padding(.trailing, 8)
            Text(context.machineNumber)
                .font(.custom(fontFamily, size: 11))
        }
        .padding(.top, 8)
    }
}

struct BrownyDynamicIslandCompactTrailing: View {
    let context: ActivityViewContext<LiveActivitiesAppAttributes>
    var body: some View {
        if context.isCompleted {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.custom(fontFamily, size: 13))
        } else {
            Text(context.formattedRemainingCompact)
                .font(.custom(fontFamily, size: 11))
                .monospacedDigit()
        }
    }
}

struct BrownyDynamicIslandExtendedTrailing: View {
    let context: ActivityViewContext<LiveActivitiesAppAttributes>
    var body: some View {
        if context.isCompleted {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.custom(fontFamily, size: 13))
        } else {
            Text(context.formattedRemainingCompact)
                .font(.custom(fontFamily, size: 11))
                .monospacedDigit()
                .padding(.top, 16)
        }
    }
}

struct BrownyDynamicIslandMinimal: View {
    let context: ActivityViewContext<LiveActivitiesAppAttributes>
    var body: some View {
        if context.isCompleted {
            Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
        } else {
            Text(context.formattedRemainingCompact)
                .font(.custom(fontFamily, size: 10))
                .monospacedDigit()
        }
    }
}

// MARK: - Widget Configuration

struct BrownyLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
            BrownyLockScreenView(context: context)
                .activityBackgroundTint(.clear)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    BrownyDynamicIslandExtendedLeading(context: context)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if context.isCompleted {
                        Text("✅")
                    } else {
                        BrownyDynamicIslandExtendedTrailing(context: context)
//                        Text(context.formattedRemainingCompact)
//                            .font(.system(size: 16, weight: .bold))
//                            .monospacedDigit()
                    }
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.displayMachineName)
                        .font(.custom(fontFamily, size: 10))
                        .foregroundColor(.white)
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

// MARK: - Preview

#if DEBUG
private func makeMockAttributes() -> LiveActivitiesAppAttributes {
    let attr = LiveActivitiesAppAttributes()
    let prefix = "\(attr.id)_"
    let defaults = UserDefaults(suiteName: "group.com.brownywash.brownyapplications.liveactivity")
        ?? UserDefaults.standard
    defaults.set("เครื่องซัก 2 - 16 กก.", forKey: "\(prefix)machine_name")
    defaults.set("สาขาปั้มเทสโก้ บางหว้า เพชรเกษม 33", forKey: "\(prefix)branch_name")
    defaults.set("5",    forKey: "\(prefix)machine_number")
    defaults.set("wash", forKey: "\(prefix)service_type")
    defaults.set("16:00", forKey: "\(prefix)start_time")
    defaults.set("16:30", forKey: "\(prefix)finish_time")
    defaults.set(21 * 60, forKey: "\(prefix)remaining_seconds")
    defaults.set(30 * 60, forKey: "\(prefix)total_seconds")
    defaults.set(false,   forKey: "\(prefix)is_completed")
    return attr
}

@available(iOS 17.0, *)
#Preview("Lock Screen", as: .content, using: makeMockAttributes()) {
    BrownyLiveActivityWidget()
} contentStates: {
    LiveActivitiesAppAttributes.ContentState()
}

@available(iOS 17.0, *)
#Preview("Dynamic Island Expanded", as: .dynamicIsland(.expanded), using: makeMockAttributes()) {
    BrownyLiveActivityWidget()
} contentStates: {
    LiveActivitiesAppAttributes.ContentState()
}

@available(iOS 17.0, *)
#Preview("Dynamic Island Compact", as: .dynamicIsland(.compact), using: makeMockAttributes()) {
    BrownyLiveActivityWidget()
} contentStates: {
    LiveActivitiesAppAttributes.ContentState()
}
#endif
