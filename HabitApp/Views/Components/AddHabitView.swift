import SwiftUI

struct AddHabitView: View {
    @ObservedObject var habitViewModel: HabitViewModel
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var habitTitle = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("习惯名称")
                        .font(.headline)
                    
                    TextField("例如：每日阅读30分钟", text: $habitTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            addHabit()
                        }
                }
                
                // 订阅提示
                if !subscriptionManager.isSubscribed && habitViewModel.habits.count >= Constants.freeUserHabitLimit - 1 {
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.yellow)
                            Text("免费用户最多创建\(Constants.freeUserHabitLimit)个习惯")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        
                        Button("升级到高级版") {
                            subscriptionManager.subscribe()
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("添加习惯")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("添加") {
                        addHabit()
                    }
                    .disabled(habitTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear {
        }
    }
    
    private func addHabit() {
        let success = habitViewModel.createHabit(title: habitTitle)
        if success {
            dismiss()
        }
    }
}

#Preview {
    AddHabitView(habitViewModel: HabitViewModel())
}
