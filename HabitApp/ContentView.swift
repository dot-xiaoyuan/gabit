import SwiftUI

struct ContentView: View {
    @StateObject private var habitViewModel = HabitViewModel()
    @StateObject private var dailyViewModel = DailyViewModel()
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Image(systemName: "calendar.day.timeline.left")
                    Text("今日")
                }
            
            HistoryView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("历史")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("我的")
                }
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
