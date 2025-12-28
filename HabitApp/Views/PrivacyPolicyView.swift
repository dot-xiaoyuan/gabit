import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("隐私政策")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("""
本应用仅将您的习惯记录、复盘内容存储在本地设备的 Core Data，不会上传到服务器。只有在您填写 OpenAI API Key 时，请求内容会直接发送至 OpenAI；请确保您信任该服务商并了解其隐私政策。

我们不会收集、出售或共享您的个人信息。若您选择开启通知，仅会使用系统本地通知，不会将信息传至第三方。
""")
                    .font(.body)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
        }
        .navigationTitle("隐私政策")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    PrivacyPolicyView()
}
