import SwiftUI

struct TermsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("用户协议")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("""
1. 您在本应用中创建的习惯和复盘内容仅供个人使用，请自行备份。
2. 订阅购买通过 App Store 处理，具体价格与权益以 App Store 展示为准；如需取消，请在到期前在系统订阅管理中关闭自动续订。
3. 本应用不对因使用第三方服务（如 OpenAI）产生的结果与费用负责，请自行确保 Key 的安全与合法性。
4. 如有问题或反馈，欢迎通过应用商店评论或邮件与我们联系。
""")
                    .font(.body)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
        }
        .navigationTitle("用户协议")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    TermsView()
}
