import SwiftUI
import CoreData

struct HistoryView: View {
    @EnvironmentObject private var habitViewModel: HabitViewModel
    @EnvironmentObject private var dailyViewModel: DailyViewModel
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @StateObject private var historyViewModel = HistoryViewModel()
    @State private var noteDrafts: [UUID: String] = [:]
    @State private var saveMessage: String = ""
    @State private var showSaveToast = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 周总结
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("周总结")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Spacer()
                            Text(dailyViewModel.getWeeklyCompletionText(for: habitViewModel.habits))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                            if subscriptionManager.isSubscribed {
                                if dailyViewModel.isWeeklyLoading {
                                    HStack {
                                        ProgressView()
                                        Text("正在生成周总结…")
                                            .foregroundColor(.gray)
                                }
                                } else {
                                    if dailyViewModel.weeklySummary.isEmpty {
                                        Text("点击生成 AI 周总结，获得针对本周的建议")
                                            .foregroundColor(.gray)
                                    } else {
                                        Text(dailyViewModel.weeklySummary)
                                            .multilineTextAlignment(.leading)
                                        if dailyViewModel.usingMockWeeklySummary {
                                            Text("当前使用模拟周总结，需提供有效 API Key")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            
                            Button("生成 AI 周总结") {
                                dailyViewModel.generateWeeklySummary(for: habitViewModel.habits)
                            }
                            .disabled(dailyViewModel.isWeeklyLoading || habitViewModel.habits.isEmpty)
                        } else {
                            Text("免费用户仅显示完成率，订阅后可生成 AI 周总结。")
                                .foregroundColor(.gray)
                            Button("升级到高级版") {
                                subscriptionManager.subscribe()
                            }
                            .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    
                    // 日期选择
                    VStack(alignment: .leading, spacing: 12) {
                        Text("选择日期")
                            .font(.title2)
                            .fontWeight(.semibold)
                        DatePicker(
                            "",
                            selection: $historyViewModel.selectedDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    
                    // 习惯状态列表
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(historyViewModel.selectedDate.chineseDateString)
                                    .font(.headline)
                                Text(historyViewModel.selectedDate.weekdayString)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        if habitViewModel.habits.isEmpty {
                            VStack(spacing: 8) {
                                Text("暂无习惯")
                                    .foregroundColor(.gray)
                                Text("先在「今日」页添加习惯，历史会自动记录")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.leading)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 24)
                        } else {
                            ForEach(habitViewModel.habits) { habit in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(habit.title ?? "")
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                            Text(historyViewModel.status(for: habit).text)
                                                .font(.caption)
                                                .foregroundColor(historyViewModel.status(for: habit).color)
                                        }
                                        Spacer()
                                        HStack(spacing: 10) {
                                            Button {
                                                guard let id = habit.id else { return }
                                                historyViewModel.updateRecord(for: habit, status: .completed, note: noteDrafts[id])
                                                Task { @MainActor in dailyViewModel.resetWeeklySummaryMemory() }
                                                showToast("已保存状态为完成")
                                            } label: {
                                                Image(systemName: "checkmark.circle")
                                                    .foregroundColor(historyViewModel.status(for: habit) == .completed ? .green : .gray)
                                            }
                                            
                                            Button {
                                                guard let id = habit.id else { return }
                                                historyViewModel.updateRecord(for: habit, status: .skipped, note: noteDrafts[id])
                                                Task { @MainActor in dailyViewModel.resetWeeklySummaryMemory() }
                                                showToast("已保存状态为跳过")
                                            } label: {
                                                Image(systemName: "minus.circle")
                                                    .foregroundColor(historyViewModel.status(for: habit) == .skipped ? .orange : .gray)
                                            }
                                            
                                            Button {
                                                guard let id = habit.id else { return }
                                                historyViewModel.updateRecord(for: habit, status: .none, note: noteDrafts[id])
                                                Task { @MainActor in dailyViewModel.resetWeeklySummaryMemory() }
                                                showToast("已重置状态")
                                            } label: {
                                                Image(systemName: "circle")
                                                    .foregroundColor(historyViewModel.status(for: habit) == .none ? .blue : .gray)
                                            }
                                        }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        TextField(
                                            "备注（选填）",
                                            text: Binding(
                                                get: {
                                                    guard let id = habit.id else { return "" }
                                                    return noteDrafts[id] ?? ""
                                                },
                                                set: { newValue in
                                                    guard let id = habit.id else { return }
                                                    noteDrafts[id] = newValue
                                                }
                                            ),
                                            axis: .vertical
                                        )
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .onSubmit {
                                            guard let id = habit.id else { return }
                                            historyViewModel.updateRecord(for: habit, note: noteDrafts[id])
                                            Task { @MainActor in dailyViewModel.resetWeeklySummaryMemory() }
                                            showToast("备注已保存")
                                        }
                                        .lineLimit(1...2)
                                        
                                        Button {
                                            guard let id = habit.id else { return }
                                            historyViewModel.updateRecord(for: habit, note: noteDrafts[id])
                                            Task { @MainActor in dailyViewModel.resetWeeklySummaryMemory() }
                                            showToast("备注已保存")
                                        } label: {
                                            Text("保存备注")
                                                .font(.caption)
                                        }
                                        .foregroundColor(.blue)
                                    }
                                }
                                .padding(.vertical, 6)
                                
                                if habit.id != habitViewModel.habits.last?.id {
                                    Divider()
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    
                    // 复盘与 AI 建议
                    VStack(alignment: .leading, spacing: 12) {
                    Text("复盘 & 建议")
                        .font(.title2)
                        .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "text.bubble")
                                Text("复盘")
                                    .font(.headline)
                            }
                            if historyViewModel.reviewText.isEmpty {
                                Text("暂无复盘")
                                    .foregroundColor(.gray)
                            } else {
                                Text(historyViewModel.reviewText)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "sparkles")
                                Text("AI 建议")
                                    .font(.headline)
                            }
                            if historyViewModel.aiSuggestion.isEmpty {
                                Text("暂无建议")
                                    .foregroundColor(.gray)
                            } else {
                                Text(historyViewModel.aiSuggestion)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                }
                .padding()
            }
            .navigationTitle("历史")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                historyViewModel.load(for: historyViewModel.selectedDate)
                habitViewModel.loadHabits()
                dailyViewModel.loadWeeklySummaryFromCache(for: habitViewModel.habits)
                syncNoteDrafts()
            }
            .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)) { _ in
                historyViewModel.load(for: historyViewModel.selectedDate)
            }
            .onChange(of: historyViewModel.selectedDate) { _ in
                syncNoteDrafts()
            }
            .onChange(of: habitViewModel.habits.count) { _ in
                syncNoteDrafts()
            }
            .overlay(alignment: .top) {
                if showSaveToast {
                    Text(saveMessage)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.75))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.top, 12)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
    }
    
    private func syncNoteDrafts() {
        var drafts: [UUID: String] = [:]
        for habit in habitViewModel.habits {
            if let id = habit.id {
                drafts[id] = historyViewModel.note(for: habit)
            }
        }
        noteDrafts = drafts
    }
    
    private func showToast(_ message: String) {
        withAnimation {
            saveMessage = message
            showSaveToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation {
                showSaveToast = false
            }
        }
    }
}

#Preview {
    HistoryView()
        .environmentObject(HabitViewModel())
        .environmentObject(DailyViewModel())
        .environmentObject(SubscriptionManager.shared)
}
