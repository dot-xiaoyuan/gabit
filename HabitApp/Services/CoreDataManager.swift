import CoreData
import Foundation

class CoreDataManager: ObservableObject {
    static let shared = CoreDataManager()
    
    // Core Data Stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "HabitApp")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data error: \(error)")
            }
        }
        
        // 合并策略：以内存中的修改为主，避免冲突导致崩溃
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.shouldDeleteInaccessibleFaults = true
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    private init() {}
    
    // MARK: - Save Context
    func save() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            // 轻量日志，便于调试
            print("Save error: \(error)")
        }
    }
    
    // MARK: - Background Write
    /// 在后台上下文执行写操作，写完自动保存
    func performBackgroundWrite(_ work: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask { bgContext in
            bgContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            bgContext.automaticallyMergesChangesFromParent = true
            bgContext.undoManager = nil
            
            work(bgContext)
            
            guard bgContext.hasChanges else { return }
            do {
                try bgContext.save()
            } catch {
                print("Background save error: \(error)")
            }
        }
    }
    
    // MARK: - Habit Operations
    /// 创建习惯并立即持久化
    func createHabit(title: String) -> Habit {
        let habit = Habit(context: context)
        habit.id = UUID()
        habit.title = title
        habit.goalType = "daily"
        habit.createdAt = Date()
        save()
        return habit
    }
    
    /// 获取全部习惯（创建时间排序）
    func fetchHabits() -> [Habit] {
        let request: NSFetchRequest<Habit> = Habit.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Habit.createdAt, ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Fetch habits error: \(error)")
            return []
        }
    }
    
    /// 删除指定习惯
    func deleteHabit(_ habit: Habit) {
        context.delete(habit)
        save()
    }
    
    // MARK: - Daily Record Operations
    /// 当天打卡记录：有则更新，无则创建
    func createOrUpdateDailyRecord(for habit: Habit, date: Date, status: Int16, note: String? = nil) {
        let request: NSFetchRequest<DailyRecord> = DailyRecord.fetchRequest()
        request.predicate = NSPredicate(format: "habit == %@ AND date >= %@ AND date < %@", 
                                      habit, 
                                      Calendar.current.startOfDay(for: date) as NSDate,
                                      Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: date))! as NSDate)
        
        do {
            let records = try context.fetch(request)
            let record = records.first ?? DailyRecord(context: context)
            
            if records.isEmpty {
                record.id = UUID()
                record.habit = habit
                record.date = Calendar.current.startOfDay(for: date)
            }
            
            record.status = status
            record.note = note
            save()
        } catch {
            print("Create/update daily record error: \(error)")
        }
    }
    
    /// 指定时间范围内的打卡记录
    func fetchDailyRecords(for habit: Habit, from startDate: Date, to endDate: Date) -> [DailyRecord] {
        let request: NSFetchRequest<DailyRecord> = DailyRecord.fetchRequest()
        request.predicate = NSPredicate(format: "habit == %@ AND date >= %@ AND date <= %@", 
                                      habit, 
                                      startDate as NSDate, 
                                      endDate as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \DailyRecord.date, ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Fetch daily records error: \(error)")
            return []
        }
    }
    
    /// 获取某天所有习惯的打卡记录
    func fetchDailyRecords(on date: Date) -> [DailyRecord] {
        let dayStart = Calendar.current.startOfDay(for: date)
        let dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: dayStart)!
        
        let request: NSFetchRequest<DailyRecord> = DailyRecord.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", dayStart as NSDate, dayEnd as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \DailyRecord.date, ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Fetch daily records by date error: \(error)")
            return []
        }
    }
    
    /// 获取当天的打卡记录
    func getTodayRecord(for habit: Habit) -> DailyRecord? {
        let today = Calendar.current.startOfDay(for: Date())
        let request: NSFetchRequest<DailyRecord> = DailyRecord.fetchRequest()
        request.predicate = NSPredicate(format: "habit == %@ AND date >= %@ AND date < %@", 
                                      habit, 
                                      today as NSDate,
                                      Calendar.current.date(byAdding: .day, value: 1, to: today)! as NSDate)
        
        do {
            return try context.fetch(request).first
        } catch {
            print("Get today record error: \(error)")
            return nil
        }
    }
    
    // MARK: - Review Operations
    /// 保存/更新当天复盘和 AI 建议
    func createOrUpdateReview(date: Date, text: String?, aiSuggestion: String? = nil) {
        let request: NSFetchRequest<Review> = Review.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", 
                                      Calendar.current.startOfDay(for: date) as NSDate,
                                      Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: date))! as NSDate)
        
        do {
            let reviews = try context.fetch(request)
            let review = reviews.first ?? Review(context: context)
            
            if reviews.isEmpty {
                review.date = Calendar.current.startOfDay(for: date)
            }
            
            review.text = text
            if let aiSuggestion = aiSuggestion {
                review.aiSuggestion = aiSuggestion
            }
            save()
        } catch {
            print("Create/update review error: \(error)")
        }
    }
    
    /// 获取当天的复盘
    func getTodayReview() -> Review? {
        let today = Calendar.current.startOfDay(for: Date())
        let request: NSFetchRequest<Review> = Review.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", 
                                      today as NSDate,
                                      Calendar.current.date(byAdding: .day, value: 1, to: today)! as NSDate)
        
        do {
            return try context.fetch(request).first
        } catch {
            print("Get today review error: \(error)")
            return nil
        }
    }
    
    /// 获取指定日期的复盘
    func getReview(for date: Date) -> Review? {
        let dayStart = Calendar.current.startOfDay(for: date)
        let request: NSFetchRequest<Review> = Review.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", 
                                        dayStart as NSDate,
                                        Calendar.current.date(byAdding: .day, value: 1, to: dayStart)! as NSDate)
        
        do {
            return try context.fetch(request).first
        } catch {
            print("Get review error: \(error)")
            return nil
        }
    }
    
    // MARK: - Statistics
    func getCompletionRate(for habit: Habit, days: Int = 7) -> Double {
        // 近7天完成率：以“天”为单位计算，没有记录的天数视为未完成
        let calendar = Calendar.current
        let endDate = calendar.startOfDay(for: Date())
        guard let startDate = calendar.date(byAdding: .day, value: -(days - 1), to: endDate) else {
            return 0.0
        }
        
        // 将记录按日期聚合
        let records = fetchDailyRecords(for: habit, from: startDate, to: endDate)
        var recordByDay: [Date: DailyRecord] = [:]
        records.forEach { record in
            if let date = record.date {
                recordByDay[calendar.startOfDay(for: date)] = record
            }
        }
        
        var completedDays = 0
        for offset in 0..<days {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: endDate) else { continue }
            let key = calendar.startOfDay(for: day)
            if let record = recordByDay[key], record.status == 1 {
                completedDays += 1
            }
        }
        
        return days > 0 ? Double(completedDays) / Double(days) : 0.0
    }
    
    /// 连续打卡天数（至少有一条完成记录算打卡，遇到未完成当天终止）
    func currentStreak() -> Int {
        let calendar = Calendar.current
        var date = calendar.startOfDay(for: Date())
        var streak = 0
        
        while true {
            let dayStart = date
            guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else { break }
            
            let request: NSFetchRequest<DailyRecord> = DailyRecord.fetchRequest()
            request.predicate = NSPredicate(format: "date >= %@ AND date < %@ AND status == %d", dayStart as NSDate, dayEnd as NSDate, 1)
            
            do {
                let count = try context.count(for: request)
                if count > 0 {
                    streak += 1
                    guard let previousDay = calendar.date(byAdding: .day, value: -1, to: dayStart) else { break }
                    date = previousDay
                } else {
                    break
                }
            } catch {
                print("Streak fetch error: \(error)")
                break
            }
        }
        
        return streak
    }
}
