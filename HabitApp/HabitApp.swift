import SwiftUI
import CoreData

@main
struct HabitApp: App {
    let persistenceController = CoreDataManager.shared
    @State private var hasRequestedNotification = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.context)
                .onAppear {
                    scheduleReminderIfNeeded()
                }
        }
    }
    
    private func scheduleReminderIfNeeded() {
        // 只在首次出现时尝试调度，避免重复请求
        guard !hasRequestedNotification else { return }
        hasRequestedNotification = true
        
        let enabled = UserDefaults.standard.bool(forKey: Constants.UserDefaults.reminderEnabled)
        guard enabled else { return }
        
        NotificationManager.shared.requestPermission { granted in
            guard granted else { return }
            let time = UserDefaults.standard.object(forKey: Constants.UserDefaults.reminderTime) as? Date ?? defaultReminderTime()
            let comps = Calendar.current.dateComponents([.hour, .minute], from: time)
            NotificationManager.shared.scheduleDailyReminder(at: comps.hour ?? 20, minute: comps.minute ?? 0)
        }
    }
    
    private func defaultReminderTime() -> Date {
        var components = DateComponents()
        components.hour = 20
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
}
