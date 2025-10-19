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
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    private init() {}
    
    // MARK: - Save Context
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Save error: \(error)")
            }
        }
    }
    
    // MARK: - Habit Operations
    func createHabit(title: String) -> Habit {
        let habit = Habit(context: context)
        habit.id = UUID()
        habit.title = title
        habit.goalType = "daily"
        habit.createdAt = Date()
        save()
        return habit
    }
    
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
    
    func deleteHabit(_ habit: Habit) {
        context.delete(habit)
        save()
    }
    
    // MARK: - Daily Record Operations
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
    
    // MARK: - Statistics
    func getCompletionRate(for habit: Habit, days: Int = 7) -> Double {
        let endDate = Calendar.current.startOfDay(for: Date())
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: endDate)!
        
        let records = fetchDailyRecords(for: habit, from: startDate, to: endDate)
        let completedCount = records.filter { $0.status == 1 }.count
        let totalDays = min(days, records.count + (records.isEmpty ? 0 : 1))
        
        return totalDays > 0 ? Double(completedCount) / Double(totalDays) : 0.0
    }
}
