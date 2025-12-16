import Foundation
import Combine

final class HistoryViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published private(set) var recordStatusByHabit: [UUID: HabitStatus] = [:]
    @Published private(set) var reviewText: String = ""
    @Published private(set) var aiSuggestion: String = ""
    
    private let coreDataManager = CoreDataManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // 监听日期变动后自动加载
        $selectedDate
            .removeDuplicates { Calendar.current.isDate($0, inSameDayAs: $1) }
            .sink { [weak self] date in
                self?.load(for: date)
            }
            .store(in: &cancellables)
    }
    
    func load(for date: Date) {
        loadRecords(for: date)
        loadReview(for: date)
    }
    
    func status(for habit: Habit) -> HabitStatus {
        guard let id = habit.id else { return .none }
        return recordStatusByHabit[id] ?? .none
    }
    
    // MARK: - Private
    private func loadRecords(for date: Date) {
        let records = coreDataManager.fetchDailyRecords(on: date)
        var statusMap: [UUID: HabitStatus] = [:]
        
        records.forEach { record in
            guard let habitId = record.habit?.id else { return }
            switch record.status {
            case 1: statusMap[habitId] = .completed
            case 2: statusMap[habitId] = .skipped
            default: statusMap[habitId] = .none
            }
        }
        
        recordStatusByHabit = statusMap
    }
    
    private func loadReview(for date: Date) {
        let review = coreDataManager.getReview(for: date)
        reviewText = review?.text ?? ""
        aiSuggestion = review?.aiSuggestion ?? ""
    }
}
