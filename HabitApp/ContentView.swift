import SwiftUI

struct ContentView: View {
    @StateObject private var habitViewModel = HabitViewModel()
    @StateObject private var dailyViewModel = DailyViewModel()
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView(onShowProfile: { selectedTab = 2 })
                .tabItem {
                    Image(systemName: "calendar.day.timeline.left")
                    Text("今日")
                }
                .tag(0)
            
            HistoryView(onShowProfile: { selectedTab = 2 })
                .tabItem {
                    Image(systemName: "calendar")
                    Text("历史")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("我的")
                }
                .tag(2)
        }
        .accentColor(.blue)
        .environmentObject(habitViewModel)
        .environmentObject(dailyViewModel)
        .environmentObject(subscriptionManager)
    }
}

#Preview {
    ContentView()
}
