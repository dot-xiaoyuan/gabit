import Foundation
import StoreKit

final class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    @Published private(set) var isSubscribed: Bool
    @Published private(set) var isProcessing = false
    @Published var errorMessage: String?
    
    private let storeKitManager = StoreKitManager.shared
    
    private init() {
        isSubscribed = UserDefaults.standard.bool(forKey: Constants.UserDefaults.isSubscribed)
        Task {
            await refreshEntitlements()
        }
    }
    
    @MainActor
    func subscribe() async {
        guard !isProcessing else { return }
        isProcessing = true
        errorMessage = nil
        do {
            let success = try await storeKitManager.purchaseSubscription()
            if success {
                updateSubscriptionState(true)
            }
        } catch {
            errorMessage = "购买失败：\(error.localizedDescription)"
        }
        isProcessing = false
    }
    
    @MainActor
    func restore() async {
        guard !isProcessing else { return }
        isProcessing = true
        errorMessage = nil
        do {
            let restored = try await storeKitManager.restorePurchases()
            updateSubscriptionState(restored)
            if !restored {
                errorMessage = "未找到可恢复的购买"
            }
        } catch {
            errorMessage = "恢复失败：\(error.localizedDescription)"
        }
        isProcessing = false
    }
    
    private func updateSubscriptionState(_ newValue: Bool) {
        guard newValue != isSubscribed else { return }
        isSubscribed = newValue
        UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.isSubscribed)
    }
    
    private func refreshEntitlements() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == Constants.Product.subscription {
                await MainActor.run {
                    self.updateSubscriptionState(true)
                }
                return
            }
        }
    }
}
