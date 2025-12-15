import SwiftUI

struct HabitCard: View {
    let habit: Habit
    @State private var status: HabitStatus = .none
    
    enum HabitStatus {
        case none, completed, skipped
        
        var color: Color {
            switch self {
            case .none: return .gray
            case .completed: return .green
            case .skipped: return .orange
            }
        }
        
        var icon: String {
            switch self {
            case .none: return "circle"
            case .completed: return "checkmark.circle.fill"
            case .skipped: return "minus.circle.fill"
            }
        }
        
        var text: String {
            switch self {
            case .none: return "未完成"
            case .completed: return "已完成"
            case .skipped: return "跳过"
            }
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(status.text)
                    .font(.caption)
                    .foregroundColor(status.color)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                // 完成按钮
                Button(action: {
                    status = .completed
                }) {
                    Image(systemName: "checkmark.circle")
                        .font(.title2)
                        .foregroundColor(status == .completed ? .green : .gray)
                }
                
                // 跳过按钮
                Button(action: {
                    status = .skipped
                }) {
                    Image(systemName: "minus.circle")
                        .font(.title2)
                        .foregroundColor(status == .skipped ? .orange : .gray)
                }
                
                // 重置按钮
                Button(action: {
                    status = .none
                }) {
                    Image(systemName: "circle")
                        .font(.title2)
                        .foregroundColor(status == .none ? .blue : .gray)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    VStack(spacing: 12) {
        HabitCard(habit: Habit(title: "每日阅读"))
        HabitCard(habit: Habit(title: "运动30分钟"))
        HabitCard(habit: Habit(title: "早睡早起"))
    }
    .padding()
}
