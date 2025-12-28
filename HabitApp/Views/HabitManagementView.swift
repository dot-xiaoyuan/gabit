import SwiftUI

struct HabitManagementView: View {
    @EnvironmentObject private var habitViewModel: HabitViewModel
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @State private var editingHabit: Habit?
    @State private var showingDelete: Habit?
    @State private var showingAdd = false
    
    var body: some View {
        List {
            Section {
                if habitViewModel.habits.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("还没有习惯，先去添加一个吧")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                } else {
                    ForEach(habitViewModel.habits) { habit in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(habit.title ?? "")
                                    .font(.headline)
                                Text("7日完成率 \(habitViewModel.getCompletionRateText(for: habit, days: 7))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                if let createdAt = habit.createdAt {
                                    Text("创建于 \(createdAt.formatted(date: .abbreviated, time: .omitted))")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                            Button {
                                editingHabit = habit
                            } label: {
                                Image(systemName: "pencil")
                            }
                            .buttonStyle(.borderless)
                            
                            Button(role: .destructive) {
                                showingDelete = habit
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }
        }
        .navigationTitle("习惯管理")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAdd = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(item: $editingHabit) { habit in
            EditHabitView(habit: habit, habitViewModel: habitViewModel)
        }
        .sheet(isPresented: $showingAdd) {
            AddHabitView()
                .environmentObject(habitViewModel)
                .environmentObject(subscriptionManager)
        }
        .alert("删除习惯", isPresented: Binding(
            get: { showingDelete != nil },
            set: { _ in showingDelete = nil }
        )) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                if let target = showingDelete {
                    habitViewModel.deleteHabit(target)
                }
            }
        } message: {
            Text("删除后无法恢复，确认删除吗？")
        }
    }
}

#Preview {
    HabitManagementView()
        .environmentObject(HabitViewModel())
        .environmentObject(SubscriptionManager.shared)
}
