import Foundation

/// 供内部配置使用的 AI Key 读取工具
/// 建议在 Info.plist 中添加 `OPENAI_API_KEY` 字段，由发行方配置，用户不可见
enum AIConfig {
    /// 优先使用用户在设置中保存的 Key，其次 Info.plist
    static var apiKey: String {
        if let userKey = KeychainHelper.read(key: Constants.UserDefaults.openAIKeyOverride)?
            .trimmingCharacters(in: .whitespacesAndNewlines),
           !userKey.isEmpty {
            return userKey
        }
        return Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String ?? ""
    }
    
    /// 保存或清理用户自定义 Key
    static func saveOverride(_ key: String?) {
        let trimmed = key?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if trimmed.isEmpty {
            KeychainHelper.delete(key: Constants.UserDefaults.openAIKeyOverride)
        } else {
            _ = KeychainHelper.save(key: Constants.UserDefaults.openAIKeyOverride, value: trimmed)
        }
    }
    
    /// 当前是否存在用户自定义 Key
    static var hasUserOverride: Bool {
        guard let value = KeychainHelper.read(key: Constants.UserDefaults.openAIKeyOverride) else { return false }
        return !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// 粗略校验 Key 长度与前缀（sk- 开头且长度≥20）
    static func isLikelyValid(key: String) -> Bool {
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.hasPrefix("sk-") && trimmed.count >= 20
    }
}
