import SwiftUI

struct HistoryView: View {
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 日历视图占位
                VStack {
                    Text("📅")
                        .font(.system(size: 60))
                    Text("日历视图")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("这里将显示日历，点击日期查看历史记录")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // 历史记录列表占位
                VStack(alignment: .leading, spacing: 12) {
                    Text("最近记录")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 8) {
                        Text("📝")
                            .font(.system(size: 40))
                        Text("暂无历史记录")
                            .foregroundColor(.gray)
                        Text("开始记录你的习惯，这里会显示历史数据")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
            .navigationTitle("历史")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    HistoryView()
}
