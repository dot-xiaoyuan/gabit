import Foundation

/// 供内部配置使用的 AI Key 读取工具
/// 建议在 Info.plist 中添加 `OPENAI_API_KEY` 字段，由发行方配置，用户不可见
enum AIConfig {
    static var apiKey: String {
        // 优先从 Info.plist 获取，未配置则返回空字符串
        Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String ?? ""
    }
}
