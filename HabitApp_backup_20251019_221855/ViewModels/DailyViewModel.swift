import Foundation
import CoreData
import SwiftUI

class DailyViewModel: ObservableObject {
    @Published var todayReview: Review?
    @Published var reviewText: String = ""
    @Published var aiSuggestion: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let coreDataManager = CoreDataManager.shared
    
    init() {
        loadTodayReview()
    }
    
    // MARK: - Load Data
    func loadTodayReview() {
        todayReview = coreDataManager.getTodayReview()
        reviewText = todayReview?.text ?? ""
        aiSuggestion = todayReview?.aiSuggestion ?? ""
    }
    
    // MARK: - Review Management
    func saveReview() -> Bool {
        // 检查文本长度
        let trimmedText = reviewText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedText.count > 200 {
            errorMessage = "复盘内容不能超过200个字符"
            return false
        }
        
        coreDataManager.createOrUpdateReview(
            date: Date(),
            text: trimmedText.isEmpty ? nil : trimmedText
        )
        
        // 重新加载数据
        loadTodayReview()
        errorMessage = nil
        return true
    }
    
    func clearReview() {
        reviewText = ""
        saveReview()
    }
    
    // MARK: - AI Suggestion
    func generateAISuggestion(for habits: [Habit]) {
        isLoading = true
        errorMessage = nil
        
        // 模拟异步操作
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.aiSuggestion = self.generateMockSuggestion(for: habits)
            self.saveAISuggestion()
            self.isLoading = false
        }
    }
    
    private func generateMockSuggestion(for habits: [Habit]) -> String {
        let habitViewModel = HabitViewModel()
        var totalCompletionRate = 0.0
        var completedToday = 0
        var totalHabits = habits.count
        
        for habit in habits {
            let rate = habitViewModel.getCompletionRate(for: habit, days: 7)
            totalCompletionRate += rate
            
            if habitViewModel.getTodayStatus(for: habit) == .completed {
                completedToday += 1
            }
        }
        
        let averageRate = totalHabits > 0 ? totalCompletionRate / Double(totalHabits) : 0.0
        
        // 根据完成率和今日表现生成建议
        if averageRate >= 0.8 {
            if completedToday == totalHabits {
                return "太棒了！今天所有习惯都完成了，继续保持这个完美的节奏！"
            } else {
                return "你的完成率很高，试着把剩余的习惯也完成，今天就能达到100%了！"
            }
        } else if averageRate >= 0.5 {
            if completedToday > 0 {
                return "不错的开始！试着把最重要的习惯放在早上完成，这样成功率会更高。"
            } else {
                return "今天还没开始，选择一个最简单的习惯先完成，建立信心。"
            }
        } else {
            if completedToday > 0 {
                return "很好，至少完成了一个习惯。明天试着完成更多，慢慢建立习惯。"
            } else {
                return "没关系，重新开始总是需要勇气的。选择一个习惯，从今天开始。"
            }
        }
    }
    
    private func saveAISuggestion() {
        coreDataManager.createOrUpdateReview(
            date: Date(),
            text: reviewText.isEmpty ? nil : reviewText,
            aiSuggestion: aiSuggestion
        )
        loadTodayReview()
    }
    
    // MARK: - Weekly Summary
    func getWeeklyCompletionRate(for habits: [Habit]) -> Double {
        let habitViewModel = HabitViewModel()
        var totalRate = 0.0
        
        for habit in habits {
            totalRate += habitViewModel.getCompletionRate(for: habit, days: 7)
        }
        
        return habits.isEmpty ? 0.0 : totalRate / Double(habits.count)
    }
    
    func getWeeklyCompletionText(for habits: [Habit]) -> String {
        let rate = getWeeklyCompletionRate(for: habits)
        return String(format: "本周完成率: %.0f%%", rate * 100)
    }
    
    // MARK: - Error Handling
    func clearError() {
        errorMessage = nil
    }
}
