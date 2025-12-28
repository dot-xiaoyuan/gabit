import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var habitViewModel: HabitViewModel
    @EnvironmentObject private var dailyViewModel: DailyViewModel
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @State private var showingAddHabit = false
    @State private var newHabitTitle = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if !subscriptionManager.isSubscribed && habitViewModel.habits.count >= Constants.freeUserHabitLimit {
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("免费上限已满 \(Constants.freeUserHabitLimit) 个")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Text("升级后可创建更多习惯，并解锁周总结等功能")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Button("升级到高级版") {
                                    Task {
                                        await subscriptionManager.subscribe()
                                    }
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
                                .disabled(subscriptionManager.isProcessing)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // 今日习惯列表
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("今日习惯")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Spacer()
                            Button("添加") {
                                showingAddHabit = true
                            }
                            .foregroundColor(.blue)
                        }
                        
                        if habitViewModel.habits.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "plus.circle")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                Text("还没有习惯")
                                    .foregroundColor(.gray)
                                Text("点击右上角添加你的第一个习惯")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            ForEach(habitViewModel.habits) { habit in
                                HabitCardView(habit: habit, habitViewModel: habitViewModel)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // 复盘输入区域
                    VStack(alignment: .leading, spacing: 12) {
                        Text("今日复盘")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        TextField("今天有什么想说的...", text: $dailyViewModel.reviewText, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                        
                        Button("保存复盘") {
                            dailyViewModel.saveReview()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        
                        if dailyViewModel.showSaveSuccess {
                            Text("已保存")
                                .font(.caption)
                                .foregroundColor(.green)
                                .transition(.opacity)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // AI建议区域
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("AI建议")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Spacer()
                            Button("获取建议") {
                                dailyViewModel.generateAISuggestion(for: habitViewModel.habits)
                            }
                            .foregroundColor(.blue)
                            .disabled(dailyViewModel.isLoading)
                        }
                        
                        if dailyViewModel.isLoading {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("正在生成建议...")
                                    .foregroundColor(.gray)
                            }
                        } else if dailyViewModel.aiSuggestion.isEmpty {
                            Text("点击获取建议来获得今日的成长建议")
                                .foregroundColor(.gray)
                                .italic()
                        } else {
                            Text(dailyViewModel.aiSuggestion)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("今日")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingAddHabit) {
            AddHabitView()
                .environmentObject(habitViewModel)
                .environmentObject(subscriptionManager)
        }
        .alert("错误", isPresented: .constant(habitViewModel.errorMessage != nil)) {
            Button("确定") {
                habitViewModel.clearError()
            }
        } message: {
            Text(habitViewModel.errorMessage ?? "")
        }
        .alert("错误", isPresented: .constant(dailyViewModel.errorMessage != nil)) {
            Button("确定") {
                dailyViewModel.clearError()
            }
        } message: {
            Text(dailyViewModel.errorMessage ?? "")
        }
    }
}


#Preview {
    TodayView()
        .environmentObject(HabitViewModel())
        .environmentObject(DailyViewModel())
        .environmentObject(SubscriptionManager.shared)
}
