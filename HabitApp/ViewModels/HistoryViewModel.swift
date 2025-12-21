import Foundation
import Combine

final class HistoryViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published private(set) var recordStatusByHabit: [UUID: HabitStatus] = [:]
    @Published private(set) var noteByHabit: [UUID: String] = [:]
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
    
    func note(for habit: Habit) -> String {
        guard let id = habit.id else { return "" }
        return noteByHabit[id] ?? ""
    }
    
    func updateRecord(for habit: Habit, status: HabitStatus? = nil, note: String? = nil) {
        guard let id = habit.id else { return }
        let currentStatus = recordStatusByHabit[id] ?? .none
        let statusToSave = status ?? currentStatus
        
        let statusValue: Int16
        switch statusToSave {
        case .none: statusValue = 0
        case .completed: statusValue = 1
        case .skipped: statusValue = 2
        }
        
        let trimmedNote = note?.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalNote = (trimmedNote?.isEmpty ?? true) ? nil : trimmedNote
        
        coreDataManager.createOrUpdateDailyRecord(
            for: habit,
            date: selectedDate,
            status: statusValue,
            note: finalNote
        )
        load(for: selectedDate)
        DailyViewModel.clearWeeklySummaryCache()
    }
    
    // MARK: - Private
    private func loadRecords(for date: Date) {
        let records = coreDataManager.fetchDailyRecords(on: date)
        var statusMap: [UUID: HabitStatus] = [:]
        var noteMap: [UUID: String] = [:]
        
        records.forEach { record in
            guard let habitId = record.habit?.id else { return }
            switch record.status {
            case 1: statusMap[habitId] = .completed
            case 2: statusMap[habitId] = .skipped
            default: statusMap[habitId] = .none
            }
            if let note = record.note, !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                noteMap[habitId] = note
            }
        }
        
        recordStatusByHabit = statusMap
        noteByHabit = noteMap
    }
    
    private func loadReview(for date: Date) {
        let review = coreDataManager.getReview(for: date)
        reviewText = review?.text ?? ""
        aiSuggestion = review?.aiSuggestion ?? ""
    }
}
