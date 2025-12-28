import SwiftUI

struct StatsView: View {
    @EnvironmentObject private var habitViewModel: HabitViewModel
    
    private var average7DayRate: Double {
        guard !habitViewModel.habits.isEmpty else { return 0 }
        let total = habitViewModel.habits.reduce(0.0) { $0 + habitViewModel.getCompletionRate(for: $1, days: 7) }
        return total / Double(habitViewModel.habits.count)
    }
    
    private var streak: Int {
        CoreDataManager.shared.currentStreak()
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                statCard(title: "7 日平均完成率", value: String(format: "%.0f%%", average7DayRate * 100))
                statCard(title: "连续坚持天数", value: "\(streak) 天")
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("按习惯统计")
                        .font(.headline)
                    if habitViewModel.habits.isEmpty {
                        Text("暂无习惯，先去添加吧")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(habitViewModel.habits) { habit in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(habit.title ?? "")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text("7 日完成率 \(habitViewModel.getCompletionRateText(for: habit, days: 7))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 8)
                            if habit.id != habitViewModel.habits.last?.id {
                                Divider()
                            }
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            }
            .padding()
        }
        .navigationTitle("数据统计")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func statCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    StatsView()
        .environmentObject(HabitViewModel())
}
