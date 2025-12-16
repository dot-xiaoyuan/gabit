import SwiftUI

struct ProfileView: View {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
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
                            Text("已坚持 0 天")
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
                        
                        Button(subscriptionManager.isSubscribed ? "取消" : "订阅") {
                            subscriptionManager.toggle()
                        }
                        .foregroundColor(.blue)
                    }
                    .padding(.vertical, 4)
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
            }
            .navigationTitle("我的")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    ProfileView()
}
