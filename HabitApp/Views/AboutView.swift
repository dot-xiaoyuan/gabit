import SwiftUI

struct AboutView: View {
    var body: some View {
        List {
            Section {
                HStack {
                    Image(systemName: "leaf.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.blue)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(Constants.appName)
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text("版本 \(Constants.appVersion)")
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
            
            Section("说明") {
                Text("这是一个帮助你建立习惯、复盘并获得 AI 建议的工具。数据默认仅存储在本地。")
            }
            
            Section("联系方式") {
                Text("如有建议或问题，请在应用商店评论区反馈。")
            }
        }
        .navigationTitle("关于")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    AboutView()
}
