import SwiftUI
import UserNotifications
import UIKit

struct ProfileView: View {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var apiKeyInput: String = AIConfig.apiKey
    @State private var apiKeyStatusMessage: String = ""
    @State private var reminderEnabled: Bool = UserDefaults.standard.bool(forKey: Constants.UserDefaults.reminderEnabled)
    @State private var reminderTime: Date = {
        if let stored = UserDefaults.standard.object(forKey: Constants.UserDefaults.reminderTime) as? Date {
            return stored
        }
        var comps = DateComponents()
        comps.hour = 20
        comps.minute = 0
        return Calendar.current.date(from: comps) ?? Date()
    }()
    @State private var reminderStatus: String = ""
    @State private var streakCount: Int = 0
    @State private var notificationPermission: String = ""
    
    var body: some View {
        NavigationView {
            List {
                // 用户信息区域
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("习惯追踪者")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("已坚持 \(streakCount) 天")
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                // 订阅状态
                Section {
                    HStack {
                        Image(systemName: subscriptionManager.isSubscribed ? "crown.fill" : "crown")
                            .foregroundColor(subscriptionManager.isSubscribed ? .yellow : .gray)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(subscriptionManager.isSubscribed ? "高级会员" : "免费用户")
                                .fontWeight(.medium)
                            Text(subscriptionManager.isSubscribed ? "周总结 / 无限习惯 / 备份" : "升级解锁更多功能")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        if subscriptionManager.isProcessing {
                            ProgressView()
                                .progressViewStyle(.circular)
                        } else {
                            Button(subscriptionManager.isSubscribed ? "已订阅" : "立即订阅") {
                                Task {
                                    await subscriptionManager.subscribe()
                                }
                            }
                            .disabled(subscriptionManager.isSubscribed)
                            .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    HStack {
                        Button("恢复购买") {
                            Task {
                                await subscriptionManager.restore()
                            }
                        }
                        .disabled(subscriptionManager.isProcessing)
                        
                        if let error = subscriptionManager.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // 功能列表
                Section("功能") {
                    NavigationLink(destination: Text("习惯管理")) {
                        Label("管理习惯", systemImage: "list.bullet")
                    }
                    
                    NavigationLink(destination: Text("数据统计")) {
                        Label("数据统计", systemImage: "chart.bar")
                    }
                    
                    NavigationLink(destination: Text("设置")) {
                        Label("设置", systemImage: "gear")
                    }
                }
                
                // 关于
                Section("关于") {
                    NavigationLink(destination: Text("关于应用")) {
                        Label("关于", systemImage: "info.circle")
                    }
                    
                    NavigationLink(destination: Text("隐私政策")) {
                        Label("隐私政策", systemImage: "hand.raised")
                    }
                    
                    NavigationLink(destination: Text("用户协议")) {
                        Label("用户协议", systemImage: "doc.text")
                    }
                }
                
                // AI Key 配置
                Section("AI 配置") {
                    VStack(alignment: .leading, spacing: 8) {
                        SecureField("OpenAI API Key", text: $apiKeyInput)
                            .textContentType(.password)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        
                        HStack(spacing: 12) {
                            Button("保存 Key") {
                                saveApiKey()
                            }
                            .disabled(apiKeyInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            
                            Button("清除 Key") {
                                apiKeyInput = ""
                                saveApiKey()
                            }
                        }
                        .foregroundColor(.blue)
                        
                        if !apiKeyStatusMessage.isEmpty {
                            Text(apiKeyStatusMessage)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Text(AIConfig.hasUserOverride ? "已使用自定义 Key" : "使用构建配置中的 Key")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // 提醒设置
                Section("提醒") {
                    Toggle(isOn: $reminderEnabled) {
                        Label("每日提醒", systemImage: "bell")
                    }
                    .onChange(of: reminderEnabled) { newValue in
                        UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.reminderEnabled)
                        handleReminderChange()
                    }
                    
                    DatePicker(
                        "提醒时间",
                        selection: $reminderTime,
                        displayedComponents: .hourAndMinute
                    )
                    .disabled(!reminderEnabled)
                    .onChange(of: reminderTime) { newValue in
                        UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.reminderTime)
                        handleReminderChange()
                    }
                    
                    if !reminderStatus.isEmpty {
                        Text(reminderStatus)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if !notificationPermission.isEmpty {
                        Text("通知权限：\(notificationPermission)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        if notificationPermission == "已拒绝" {
                            Button("前往系统设置开启") {
                                openSystemSettings()
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("我的")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                apiKeyInput = AIConfig.apiKey
                reminderEnabled = UserDefaults.standard.bool(forKey: Constants.UserDefaults.reminderEnabled)
                if let stored = UserDefaults.standard.object(forKey: Constants.UserDefaults.reminderTime) as? Date {
                    reminderTime = stored
                }
                updateStreak()
                refreshNotificationStatus()
            }
            .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)) { _ in
                updateStreak()
            }
        }
    }
    
    private func saveApiKey() {
        let trimmed = apiKeyInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty || AIConfig.isLikelyValid(key: trimmed) else {
            apiKeyStatusMessage = "Key 格式看起来不正确（需以 sk- 开头）"
            return
        }
        AIConfig.saveOverride(trimmed)
        apiKeyStatusMessage = trimmed.isEmpty ? "已清除自定义 Key" : "已保存自定义 Key（已加密存储）"
    }
    
    private func handleReminderChange() {
        guard reminderEnabled else {
            NotificationManager.shared.cancelDailyReminder()
            reminderStatus = "已关闭提醒"
            return
        }
        let comps = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        NotificationManager.shared.requestPermission { granted in
            if granted {
                NotificationManager.shared.scheduleDailyReminder(at: comps.hour ?? 20, minute: comps.minute ?? 0)
                reminderStatus = "已设置每日提醒"
                refreshNotificationStatus()
            } else {
                reminderEnabled = false
                reminderStatus = "未获得通知权限，无法开启提醒"
                UserDefaults.standard.set(false, forKey: Constants.UserDefaults.reminderEnabled)
                refreshNotificationStatus()
            }
        }
    }
    
    private func updateStreak() {
        streakCount = CoreDataManager.shared.currentStreak()
    }
    
    private func refreshNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let status: String
            switch settings.authorizationStatus {
            case .authorized, .provisional:
                status = "已授权"
            case .denied:
                status = "已拒绝"
            case .notDetermined:
                status = "未请求"
            @unknown default:
                status = "未知"
            }
            DispatchQueue.main.async {
                notificationPermission = status
            }
        }
    }
    
    private func openSystemSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    ProfileView()
}
