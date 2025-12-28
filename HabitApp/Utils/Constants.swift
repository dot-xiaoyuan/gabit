import Foundation

struct Constants {
    // 免费用户习惯数量限制
    static let freeUserHabitLimit = 3
    
    // 应用信息
    static let appName = "习惯追踪"
    static let appVersion = "1.0.0"
    
    // 颜色主题
    struct Colors {
        static let primary = "blue"
        static let success = "green"
        static let warning = "orange"
        static let danger = "red"
    }
    
    // 通知标识符
    struct Notifications {
        static let dailyReminder = "daily_reminder"
        static let weeklySummary = "weekly_summary"
    }
    
    // 内购产品 ID
    struct Product {
        // 示例 ID，发布前请与 App Store Connect 保持一致
        static let subscription = "com.habitapp.subscription.pro"
    }
    
    // 用户默认设置键
    struct UserDefaults {
        static let isFirstLaunch = "is_first_launch"
        static let reminderTime = "reminder_time"
        static let isSubscribed = "is_subscribed"
        static let openAIKeyOverride = "openai_key_override"
        static let reminderEnabled = "reminder_enabled"
    }
}
