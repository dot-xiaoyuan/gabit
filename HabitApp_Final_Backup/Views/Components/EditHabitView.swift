import SwiftUI
import CoreData

struct EditHabitView: View {
    let habit: Habit
    @ObservedObject var habitViewModel: HabitViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var habitTitle: String
    
    init(habit: Habit, habitViewModel: HabitViewModel) {
        self.habit = habit
        self.habitViewModel = habitViewModel
        self._habitTitle = State(initialValue: habit.title ?? "")
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("习惯名称")
                        .font(.headline)
                    
                    TextField("习惯名称", text: $habitTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            saveChanges()
                        }
                }
                
                // 习惯统计信息
                VStack(alignment: .leading, spacing: 12) {
                    Text("统计信息")
                        .font(.headline)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("创建时间")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(habit.createdAt?.formatted(date: .abbreviated, time: .omitted) ?? "未知")
                                .font(.subheadline)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("本周完成率")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(habitViewModel.getCompletionRateText(for: habit, days: 7))
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                Spacer()
            }
            .padding()
            .navigationTitle("编辑习惯")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveChanges()
                    }
                    .disabled(habitTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func saveChanges() {
        let success = habitViewModel.updateHabit(habit, newTitle: habitTitle)
        if success {
            dismiss()
        }
    }
}

#Preview {
    let context = CoreDataManager.shared.context
    let habit = Habit(context: context)
    habit.title = "每日阅读"
    habit.goalType = "daily"
    habit.createdAt = Date()
    
    return EditHabitView(habit: habit, habitViewModel: HabitViewModel())
}
