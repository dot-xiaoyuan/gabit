import SwiftUI
import CoreData

struct HabitCardView: View {
    let habit: Habit
    @ObservedObject var habitViewModel: HabitViewModel
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.title ?? "")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack {
                    Text(statusText)
                        .font(.caption)
                        .foregroundColor(statusColor)
                    
                    Spacer()
                    
                    Text(completionRateText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                // 完成按钮
                Button(action: {
                    updateStatus(.completed)
                }) {
                    Image(systemName: "checkmark.circle")
                        .font(.title2)
                        .foregroundColor(currentStatus == .completed ? .green : .gray)
                }
                
                // 跳过按钮
                Button(action: {
                    updateStatus(.skipped)
                }) {
                    Image(systemName: "minus.circle")
                        .font(.title2)
                        .foregroundColor(currentStatus == .skipped ? .orange : .gray)
                }
                
                // 重置按钮
                Button(action: {
                    updateStatus(.none)
                }) {
                    Image(systemName: "circle")
                        .font(.title2)
                        .foregroundColor(currentStatus == .none ? .blue : .gray)
                }
                
                // 更多操作按钮
                Menu {
                    Button("编辑") {
                        showingEditSheet = true
                    }
                    
                    Button("删除", role: .destructive) {
                        showingDeleteAlert = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .sheet(isPresented: $showingEditSheet) {
            EditHabitView(habit: habit, habitViewModel: habitViewModel)
        }
        .alert("删除习惯", isPresented: $showingDeleteAlert) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                habitViewModel.deleteHabit(habit)
            }
        } message: {
            Text("确定要删除习惯"\(habit.title ?? "")"吗？此操作无法撤销。")
        }
    }
    
    // MARK: - Computed Properties
    private var currentStatus: HabitStatus {
        habitViewModel.getTodayStatus(for: habit)
    }
    
    private var statusText: String {
        currentStatus.text
    }
    
    private var statusColor: Color {
        currentStatus.color
    }
    
    private var completionRateText: String {
        habitViewModel.getCompletionRateText(for: habit, days: 7)
    }
    
    // MARK: - Actions
    private func updateStatus(_ status: HabitStatus) {
        habitViewModel.updateTodayRecord(for: habit, status: status)
    }
}

#Preview {
    let context = CoreDataManager.shared.context
    let habit = Habit(context: context)
    habit.title = "每日阅读"
    habit.goalType = "daily"
    habit.createdAt = Date()
    
    return HabitCardView(habit: habit, habitViewModel: HabitViewModel())
        .padding()
}
