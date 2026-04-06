import ActivityKit
import Foundation

// MARK: - LiveActivitiesAppAttributes
// ชื่อต้องเป็น LiveActivitiesAppAttributes เท่านั้น — live_activities package กำหนดไว้
// ข้อมูลจาก Flutter จะถูกส่งผ่าน UserDefaults (AppGroup) ไม่ใช่ ContentState โดยตรง

public struct LiveActivitiesAppAttributes: ActivityAttributes, Identifiable {
    public typealias LiveDeliveryData = ContentState // จำเป็นต้องมี

    public struct ContentState: Codable, Hashable {}

    public var id = UUID()
}


// MARK: - prefixedKey extension (จำเป็นสำหรับ live_activities package)
extension LiveActivitiesAppAttributes {
    func prefixedKey(_ key: String) -> String {
        return "\(id)_\(key)"
    }
}
