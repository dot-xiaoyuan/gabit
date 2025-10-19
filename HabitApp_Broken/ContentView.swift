import SwiftUI

struct ContentView: View {
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
    }
}

#Preview {
    ContentView()
}
