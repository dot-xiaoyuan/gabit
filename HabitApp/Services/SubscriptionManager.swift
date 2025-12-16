import Foundation

final class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    @Published private(set) var isSubscribed: Bool
    
    private init() {
        isSubscribed = UserDefaults.standard.bool(forKey: Constants.UserDefaults.isSubscribed)
    }
    
    func subscribe() {
        updateSubscriptionState(true)
    }
    
    func cancelSubscription() {
        updateSubscriptionState(false)
    }
    
    func toggle() {
        updateSubscriptionState(!isSubscribed)
    }
    
    private func updateSubscriptionState(_ newValue: Bool) {
        guard newValue != isSubscribed else { return }
        isSubscribed = newValue
        UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.isSubscribed)
    }
}
