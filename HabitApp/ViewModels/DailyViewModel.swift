import Foundation
import CoreData
import SwiftUI

class DailyViewModel: ObservableObject {
    @Published var todayReview: Review?
    @Published var reviewText: String = ""
    @Published var aiSuggestion: String = ""
    @Published var isLoading = false
    @Published var isWeeklyLoading = false
    @Published var errorMessage: String?
    @Published var showSaveSuccess = false
    @Published var weeklySummary: String = ""
    @Published var usingMockSuggestion = false
    @Published var usingMockWeeklySummary = false
    
    private let coreDataManager = CoreDataManager.shared
    private static let weeklySummaryCacheKey = "weekly_summary_cache"
    
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
        showSaveHint()
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
        usingMockSuggestion = false
        let prompt = buildPrompt(for: habits)
        
        // 如果没有配置 Key，直接走模拟
        guard let apiKey = currentAPIKey(), !apiKey.isEmpty else {
            aiSuggestion = generateMockSuggestion(for: habits)
            saveAISuggestion()
            isLoading = false
            errorMessage = "AI 配置缺失，已使用模拟建议（需在构建配置中提供 OPENAI_API_KEY）"
            usingMockSuggestion = true
            return
        }
        
        let service = OpenAIService(apiKey: apiKey)
        Task {
            do {
                let suggestion = try await service.fetchSuggestion(prompt: prompt)
                await MainActor.run {
                    self.aiSuggestion = suggestion
                    self.saveAISuggestion()
                    self.isLoading = false
                    self.usingMockSuggestion = false
                }
            } catch {
                await MainActor.run {
                    self.aiSuggestion = self.generateMockSuggestion(for: habits)
                    self.saveAISuggestion()
                    self.isLoading = false
                    self.errorMessage = "AI 生成失败，已使用模拟建议"
                    self.usingMockSuggestion = true
                }
            }
        }
    }
    
    private func generateMockSuggestion(for habits: [Habit]) -> String {
        let stats = collectStats(for: habits)
        let totalHabits = habits.count
        let averageRate = totalHabits > 0 ? stats.totalCompletionRate / Double(totalHabits) : 0.0
        
        // 根据完成率和今日表现生成建议
        if averageRate >= 0.8 {
            if stats.completedToday == totalHabits {
                return "太棒了！今天所有习惯都完成了，继续保持这个完美的节奏！"
            } else {
                return "你的完成率很高，试着把剩余的习惯也完成，今天就能达到100%了！"
            }
        } else if averageRate >= 0.5 {
            if stats.completedToday > 0 {
                return "不错的开始！试着把最重要的习惯放在早上完成，这样成功率会更高。"
            } else {
                return "今天还没开始，选择一个最简单的习惯先完成，建立信心。"
            }
        } else {
            if stats.completedToday > 0 {
                return "很好，至少完成了一个习惯。明天试着完成更多，慢慢建立习惯。"
            } else {
                return "没关系，重新开始总是需要勇气的。选择一个习惯，从今天开始。"
            }
        }
    }
    
    // MARK: - Weekly Summary
    func generateWeeklySummary(for habits: [Habit]) {
        if habits.isEmpty {
            weeklySummary = "本周暂无习惯数据"
            usingMockWeeklySummary = false
            return
        }
        
        isWeeklyLoading = true
        usingMockWeeklySummary = false
        let report = weeklyCompletionReport(for: habits)
        
        guard SubscriptionManager.shared.isSubscribed else {
            weeklySummary = "免费用户仅显示完成率：\(getWeeklyCompletionText(for: habits))。订阅后可生成 AI 周总结。"
            isWeeklyLoading = false
            return
        }
        
        guard let apiKey = currentAPIKey(), !apiKey.isEmpty else {
            weeklySummary = generateMockWeeklySummary(for: habits)
            cacheWeeklySummary(weeklySummary, for: Date())
            isWeeklyLoading = false
            errorMessage = "AI 配置缺失，已使用模拟周总结（需在构建配置中提供 OPENAI_API_KEY）"
            usingMockWeeklySummary = true
            return
        }
        
        let service = OpenAIService(apiKey: apiKey)
        Task {
            do {
                let suggestion = try await service.fetchSuggestion(prompt: report)
                await MainActor.run {
                    self.weeklySummary = suggestion
                    self.cacheWeeklySummary(suggestion, for: Date())
                    self.isWeeklyLoading = false
                    self.usingMockWeeklySummary = false
                }
            } catch {
                await MainActor.run {
                    self.weeklySummary = self.generateMockWeeklySummary(for: habits)
                    self.cacheWeeklySummary(self.weeklySummary, for: Date())
                    self.isWeeklyLoading = false
                    self.errorMessage = "AI 周总结生成失败，已使用模拟内容"
                    self.usingMockWeeklySummary = true
                }
            }
        }
    }
    
    func loadWeeklySummaryFromCache(for habits: [Habit]) {
        guard !habits.isEmpty else {
            weeklySummary = "本周暂无习惯数据"
            return
        }
        if let cached = cachedWeeklySummary(for: Date()) {
            weeklySummary = cached
        }
    }
    
    private func saveAISuggestion() {
        coreDataManager.createOrUpdateReview(
            date: Date(),
            text: reviewText.isEmpty ? nil : reviewText,
            aiSuggestion: aiSuggestion
        )
        loadTodayReview()
        Self.clearWeeklySummaryCache()
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
    
    private func showSaveHint() {
        showSaveSuccess = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.showSaveSuccess = false
        }
    }
    
    private func currentAPIKey() -> String? {
        let key = AIConfig.apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        return key.isEmpty ? nil : key
    }
    
    private func collectStats(for habits: [Habit]) -> (totalCompletionRate: Double, completedToday: Int, skippedToday: Int) {
        var totalCompletionRate = 0.0
        var completedToday = 0
        var skippedToday = 0
        
        for habit in habits {
            totalCompletionRate += coreDataManager.getCompletionRate(for: habit, days: 7)
            if let record = coreDataManager.getTodayRecord(for: habit) {
                switch record.status {
                case 1: completedToday += 1
                case 2: skippedToday += 1
                default: break
                }
            }
        }
        
        return (totalCompletionRate, completedToday, skippedToday)
    }
    
    private func buildPrompt(for habits: [Habit]) -> String {
        let stats = collectStats(for: habits)
        let totalHabits = max(habits.count, 1)
        let averageRate = stats.totalCompletionRate / Double(totalHabits)
        let review = reviewText.trimmingCharacters(in: .whitespacesAndNewlines)
        let reviewTextForPrompt = review.isEmpty ? "无" : review
        
        return """
        过去7天平均完成率：\(Int(averageRate * 100))%
        今日完成情况：已完成 \(stats.completedToday) / \(totalHabits)，跳过 \(stats.skippedToday)
        今日复盘：\(reviewTextForPrompt)
        请输出 1 句中文的具体可执行建议，不要复述输入。
        """
    }
    
    private func weeklyCompletionReport(for habits: [Habit]) -> String {
        let totalHabits = max(habits.count, 1)
        var lines: [String] = []
        var totalRate: Double = 0.0
        
        for habit in habits {
            let rate = coreDataManager.getCompletionRate(for: habit, days: 7)
            totalRate += rate
            let todayStatus = coreDataManager.getTodayRecord(for: habit)?.status ?? 0
            let statusText: String
            switch todayStatus {
            case 1: statusText = "今日完成"
            case 2: statusText = "今日跳过"
            default: statusText = "今日未填"
            }
            lines.append("- \(habit.title ?? "未命名"): 7日完成率 \(Int(rate * 100))%，\(statusText)")
        }
        
        let averageRate = totalRate / Double(totalHabits)
        let overall = "整体7日平均完成率：\(Int(averageRate * 100))%"
        let review = reviewText.trimmingCharacters(in: .whitespacesAndNewlines)
        let reviewTextForPrompt = review.isEmpty ? "本周暂无特别复盘" : review
        
        return """
        \(overall)
        习惯列表：
        \(lines.joined(separator: "\n"))
        本周复盘摘录：\(reviewTextForPrompt)
        请输出一段中文周总结，聚焦可执行改进，不要复述输入。
        """
    }
    
    private func generateMockWeeklySummary(for habits: [Habit]) -> String {
        let totalHabits = max(habits.count, 1)
        var totalRate: Double = 0.0
        for habit in habits {
            totalRate += coreDataManager.getCompletionRate(for: habit, days: 7)
        }
        let average = totalRate / Double(totalHabits)
        
        switch average {
        case let x where x >= 0.8:
            return "本周完成率很高，保持当前节奏，下周可以微调时间段提升稳定性。"
        case let x where x >= 0.5:
            return "本周有一定进展，挑一到两个关键习惯放到精力最好的时段去做，提升成功率。"
        default:
            return "本周完成度偏低，先挑一个最重要且最容易执行的习惯，设定固定时间坚持一周。"
        }
    }
    
    // MARK: - Weekly Summary Cache
    private func cacheWeeklySummary(_ summary: String, for date: Date) {
        var cache = UserDefaults.standard.dictionary(forKey: Self.weeklySummaryCacheKey) as? [String: String] ?? [:]
        cache[weekKey(for: date)] = summary
        UserDefaults.standard.set(cache, forKey: Self.weeklySummaryCacheKey)
    }
    
    private func cachedWeeklySummary(for date: Date) -> String? {
        let cache = UserDefaults.standard.dictionary(forKey: Self.weeklySummaryCacheKey) as? [String: String]
        return cache?[weekKey(for: date)]
    }
    
    private func weekKey(for date: Date) -> String {
        let start = date.startOfWeek
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: start)
    }
    
    static func clearWeeklySummaryCache() {
        UserDefaults.standard.removeObject(forKey: weeklySummaryCacheKey)
    }
}
