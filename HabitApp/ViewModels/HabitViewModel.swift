import Foundation
import CoreData
import SwiftUI

class HabitViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let coreDataManager = CoreDataManager.shared
    
    init() {
        loadHabits()
    }
    
    // MARK: - Load Data
    func loadHabits() {
        habits = coreDataManager.fetchHabits()
    }
    
    // MARK: - Habit Management
    func createHabit(title: String) -> Bool {
        // 免费版限制 + 唯一性校验
        // 检查免费用户限制
        if !isSubscribed() && habits.count >= Constants.freeUserHabitLimit {
            errorMessage = "免费用户最多只能创建\(Constants.freeUserHabitLimit)个习惯"
            return false
        }
        
        // 检查标题是否为空
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "习惯标题不能为空"
            return false
        }
        
        // 检查是否已存在相同标题的习惯
        if habits.contains(where: { ($0.title ?? "").lowercased() == title.lowercased() }) {
            errorMessage = "已存在相同名称的习惯"
            return false
        }
        
        let habit = coreDataManager.createHabit(title: title.trimmingCharacters(in: .whitespacesAndNewlines))
        habits.append(habit)
        errorMessage = nil
        return true
    }
    
    func deleteHabit(_ habit: Habit) {
        coreDataManager.deleteHabit(habit)
        habits.removeAll { $0.id == habit.id }
    }
    
    func updateHabit(_ habit: Habit, newTitle: String) -> Bool {
        // 检查标题是否为空
        if newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "习惯标题不能为空"
            return false
        }
        
        // 检查是否已存在相同标题的习惯（排除当前习惯）
        if habits.contains(where: { $0.id != habit.id && ($0.title ?? "").lowercased() == newTitle.lowercased() }) {
            errorMessage = "已存在相同名称的习惯"
            return false
        }
        
        habit.title = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        coreDataManager.save()
        errorMessage = nil
        return true
    }
    
    // MARK: - Daily Record Management
    func updateTodayRecord(for habit: Habit, status: HabitStatus, note: String? = nil) {
        let statusValue: Int16
        switch status {
        case .none: statusValue = 0
        case .completed: statusValue = 1
        case .skipped: statusValue = 2
        }
        
        coreDataManager.createOrUpdateDailyRecord(
            for: habit,
            date: Date(),
            status: statusValue,
            note: note
        )
        
        // Core Data 更新不会自动触发 SwiftUI 刷新，这里手动通知
        objectWillChange.send()
    }
    
    func getTodayRecord(for habit: Habit) -> DailyRecord? {
        return coreDataManager.getTodayRecord(for: habit)
    }
    
    func getTodayStatus(for habit: Habit) -> HabitStatus {
        guard let record = getTodayRecord(for: habit) else { return .none }
        
        switch record.status {
        case 1: return .completed
        case 2: return .skipped
        default: return .none
        }
    }
    
    // MARK: - Statistics
    func getCompletionRate(for habit: Habit, days: Int = 7) -> Double {
        return coreDataManager.getCompletionRate(for: habit, days: days)
    }
    
    func getCompletionRateText(for habit: Habit, days: Int = 7) -> String {
        let rate = getCompletionRate(for: habit, days: days)
        return String(format: "%.0f%%", rate * 100)
    }
    
    // MARK: - Subscription Check
    private func isSubscribed() -> Bool {
        SubscriptionManager.shared.isSubscribed
    }
    
    // MARK: - Error Handling
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - Habit Status Enum
enum HabitStatus {
    case none, completed, skipped
    
    var color: Color {
        switch self {
        case .none: return .gray
        case .completed: return .green
        case .skipped: return .orange
        }
    }
    
    var icon: String {
        switch self {
        case .none: return "circle"
        case .completed: return "checkmark.circle.fill"
        case .skipped: return "minus.circle.fill"
        }
    }
    
    var text: String {
        switch self {
        case .none: return "未完成"
        case .completed: return "已完成"
        case .skipped: return "跳过"
        }
    }
}
