import Foundation
import StoreKit

/// 轻量封装 StoreKit2 购买与恢复流程
@MainActor
final class StoreKitManager: ObservableObject {
    static let shared = StoreKitManager()
    private init() {}
    
    // 产品 ID，可根据实际上架时调整
    private let productIdentifiers: Set<String> = [Constants.Product.subscription]
    @Published private(set) var products: [Product] = []
    @Published private(set) var isLoading = false
    
    func loadProducts() async {
        guard products.isEmpty else { return }
        isLoading = true
        do {
            products = try await Product.products(for: Array(productIdentifiers))
        } catch {
            print("Load products error: \(error)")
        }
        isLoading = false
    }
    
    func purchaseSubscription() async throws -> Bool {
        if products.isEmpty {
            await loadProducts()
        }
        guard let product = products.first(where: { $0.id == Constants.Product.subscription }) else {
            throw StoreKitError.productUnavailable
        }
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            return true
        case .userCancelled:
            return false
        default:
            return false
        }
    }
    
    func restorePurchases() async throws -> Bool {
        var restored = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == Constants.Product.subscription {
                restored = true
            }
        }
        return restored
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreKitError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}
