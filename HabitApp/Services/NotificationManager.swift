import Foundation
import UserNotifications

/// 负责本地通知权限与调度
final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}
    
    /// 请求通知权限
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    /// 调度每日提醒
    func scheduleDailyReminder(at hour: Int, minute: Int) {
        cancelDailyReminder()
        
        let content = UNMutableNotificationContent()
        content.title = "今日习惯提醒"
        content.body = "记录一下今天的习惯完成情况和复盘吧！"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: Constants.Notifications.dailyReminder, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Schedule reminder error: \(error)")
            }
        }
    }
    
    /// 取消每日提醒
    func cancelDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [Constants.Notifications.dailyReminder])
    }
}
