//
//  AppState.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import SwiftUI
import Auth

@MainActor
@Observable
class AppState {
    static let shared = AppState()
    
    // MARK: - Services
    private let authService = AuthService()
    private let storeService = StoreService()
    private let offerService = OfferService()
    private let userListService = UserListService()
    private let submissionService = SubmissionService()
    private let accountService = AccountService()
    var currentUser: User?
    var isAuthenticated: Bool = false
    
    // MARK: - Stores & Offers
    var stores: [Store] = []
    var offersByStore: [UUID: [Offer]] = [:]
    
    // MARK: - User's List
    var userListItems: [UserOfferListItem] = []
    
    // MARK: - Submissions
    var submissions: [Submission] = []
    
    // MARK: - Transactions
    var transactions: [Transaction] = []
    
    // MARK: - Loading States
    var isLoadingStores = false
    var isLoadingOffers = false
    
    // MARK: - Tab Selection
    var selectedTab: Tab = .home
    
    enum Tab {
        case home
        case myList
        case activity
        case account
    }
    
    private init() {
        // Start with NO authentication - user must log in
        isAuthenticated = false
        currentUser = nil
        
        // Load data from Supabase
        Task {
            await loadSupabaseData()
        }
    }
    
    // MARK: - Supabase Data Loading
    func loadSupabaseData() async {
        isLoadingStores = true
        
        print("🔄 Starting to load data from Supabase...")
        
        do {
            // Load stores from Supabase
            print("🔄 Fetching stores...")
            stores = try await storeService.fetchStoresWithOfferCounts()
            print("✅ Loaded \(stores.count) stores from Supabase:")
            for store in stores {
                print("  - \(store.name) (\(store.offerCount ?? 0) offers)")
            }
            
            // Load offers for each store
            for store in stores {
                print("🔄 Fetching offers for \(store.name)...")
                let offers = try await offerService.fetchOffers(storeId: store.id)
                offersByStore[store.id] = offers
                print("✅ Loaded \(offers.count) offers for \(store.name)")
            }
            
            print("✅ All data loaded successfully from Supabase!")
            
            // DO NOT auto-authenticate - user must log in
            // The stores/offers are loaded but user must sign in to use the app
            
        } catch {
            print("❌ Error loading Supabase data:")
            print("   Error: \(error)")
            print("   Description: \(error.localizedDescription)")
        }
        
        isLoadingStores = false
    }
    
    // MARK: - Authentication
    func login(email: String, password: String) async throws {
        print("🔐 Attempting login for: \(email)")
        
        do {
            try await authService.signIn(email: email, password: password)
            
            // Check if login was successful
            guard let user = authService.currentUser else {
                throw NSError(domain: "AppState", code: 1, userInfo: [NSLocalizedDescriptionKey: "Login failed"])
            }
            
            print("✅ Login successful for user: \(user.id)")
            
            // Create User object from Supabase profile
            if let profile = authService.userProfile {
                currentUser = User(
                    id: profile.id,
                    name: profile.fullName ?? profile.email ?? "User",
                    email: profile.email ?? "",
                    balance: profile.balance,
                    totalEarned: profile.totalEarned,
                    totalWithdrawn: profile.totalWithdrawn
                )
            } else {
                // Create a basic user if profile doesn't exist yet
                currentUser = User(
                    id: user.id,
                    name: user.email ?? "User",
                    email: user.email ?? ""
                )
            }
            
            isAuthenticated = true
            
            print("✅ User authenticated: \(currentUser?.name ?? "Unknown")")
            
            // Load user's list items from Supabase
            print("🔄 Loading user's saved offers...")
            userListItems = try await userListService.fetchUserLists(userId: user.id)
            print("✅ Loaded \(userListItems.count) items from list")
            
            // Load user's submissions
            print("🔄 Loading user's submissions...")
            submissions = try await submissionService.fetchSubmissions(userId: user.id)
            print("✅ Loaded \(submissions.count) submissions")
            
            // Load user's transactions
            print("🔄 Loading user's transactions...")
            transactions = try await accountService.fetchTransactions(userId: user.id)
            print("✅ Loaded \(transactions.count) transactions")
            
        } catch {
            print("❌ Login failed: \(error.localizedDescription)")
            throw error
        }
    }
    
    func signUp(name: String, email: String, password: String) async throws {
        print("🔐 Attempting signup for: \(email)")
        
        do {
            try await authService.signUp(email: email, password: password, fullName: name)
            
            // Check if signup was successful
            guard let user = authService.currentUser else {
                throw NSError(domain: "AppState", code: 1, userInfo: [NSLocalizedDescriptionKey: "Signup failed"])
            }
            
            print("✅ Signup successful for user: \(user.id)")
            
            // Wait a bit for the profile to be created by the trigger
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            // Fetch the profile
            await authService.fetchUserProfile()
            
            // Create User object
            if let profile = authService.userProfile {
                currentUser = User(
                    id: profile.id,
                    name: profile.fullName ?? name,
                    email: profile.email ?? email,
                    balance: profile.balance,
                    totalEarned: profile.totalEarned,
                    totalWithdrawn: profile.totalWithdrawn
                )
            } else {
                // Create a basic user if profile doesn't exist yet
                currentUser = User(
                    id: user.id,
                    name: name,
                    email: email
                )
            }
            
            isAuthenticated = true
            
            print("✅ User registered and authenticated: \(currentUser?.name ?? "Unknown")")
            
            // New user won't have any list items yet, but initialize empty
            userListItems = []
            submissions = []
            transactions = []
            
        } catch {
            print("❌ Signup failed: \(error.localizedDescription)")
            throw error
        }
    }
    
    func logout() {
        print("🔐 Logging out user...")
        
        Task {
            try? await authService.signOut()
        }
        
        isAuthenticated = false
        currentUser = nil
        userListItems = []
        submissions = []
        transactions = []
        
        print("✅ User logged out")
    }
    
    // MARK: - List Management
    func isOfferInList(_ offerId: UUID) -> Bool {
        userListItems.contains { $0.offerId == offerId }
    }
    
    func addToList(offer: Offer, quantity: Int = 1) {
        guard let userId = authService.currentUser?.id else {
            print("⚠️ Cannot add to list: User not authenticated")
            return
        }
        
        print("➕ Adding offer '\(offer.name)' to list (quantity: \(quantity))")
        
        Task {
            do {
                // Check if already in list locally
                if let existingIndex = userListItems.firstIndex(where: { $0.offerId == offer.id }) {
                    // Update quantity
                    let newQuantity = min(
                        userListItems[existingIndex].quantity + quantity,
                        offer.redemptionLimit
                    )
                    
                    print("🔄 Updating quantity for '\(offer.name)' to \(newQuantity)")
                    
                    // Update in Supabase
                    try await userListService.updateQuantity(
                        listItemId: userListItems[existingIndex].id,
                        quantity: newQuantity
                    )
                    
                    // Update local state
                    userListItems[existingIndex].quantity = newQuantity
                } else {
                    // Add new item to Supabase
                    try await userListService.addToList(
                        userId: userId,
                        offerId: offer.id,
                        storeId: offer.storeId,
                        quantity: quantity
                    )
                    
                    print("✅ Added '\(offer.name)' to Supabase")
                    
                    // Refresh the list from Supabase to get the new item with ID
                    userListItems = try await userListService.fetchUserLists(userId: userId)
                    
                    print("✅ List refreshed. Total items: \(userListItems.count)")
                }
                
                // Haptic feedback
                await MainActor.run {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }
                
            } catch {
                print("❌ Error adding to list: \(error)")
                print("   Error details: \(error.localizedDescription)")
            }
        }
    }
    
    func removeFromList(_ itemId: UUID) {
        print("🗑️ Removing item from list: \(itemId)")
        
        Task {
            do {
                try await userListService.removeFromList(listItemId: itemId)
                
                // Update local state
                userListItems.removeAll { $0.id == itemId }
                
                print("✅ Item removed from list")
                
            } catch {
                print("❌ Error removing from list: \(error)")
            }
        }
    }
    
    func updateQuantity(itemId: UUID, quantity: Int) {
        print("🔄 Updating quantity for item \(itemId) to \(quantity)")
        
        Task {
            do {
                try await userListService.updateQuantity(listItemId: itemId, quantity: quantity)
                
                // Update local state
                if let index = userListItems.firstIndex(where: { $0.id == itemId }) {
                    userListItems[index].quantity = quantity
                }
                
                print("✅ Quantity updated")
                
            } catch {
                print("❌ Error updating quantity: \(error)")
            }
        }
    }
    
    func getListItems(for storeId: UUID) -> [UserOfferListItem] {
        userListItems.filter { $0.storeId == storeId }
    }
    
    var listItemsByStore: [UUID: [UserOfferListItem]] {
        Dictionary(grouping: userListItems, by: { $0.storeId })
    }
    
    var totalPotentialCashback: Double {
        userListItems.reduce(0) { $0 + $1.totalCashback }
    }
    
    // MARK: - Submission Management
    func submitReceipt(
        storeId: UUID, 
        items: [UserOfferListItem], 
        receiptImageUrls: [String]
    ) async throws {
        guard let userId = currentUser?.id else { 
            throw NSError(domain: "AppState", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        guard !receiptImageUrls.isEmpty else {
            throw NSError(domain: "AppState", code: 400, userInfo: [NSLocalizedDescriptionKey: "At least one receipt image is required"])
        }
        
        let totalCashback = items.reduce(0) { $0 + $1.totalCashback }
        
        // Prepare submission items for the service
        let submissionItemsInput = items.map { item in
            SubmissionItemInput(
                offerId: item.offerId,
                offerName: item.offer?.name ?? "Unknown",
                quantity: item.quantity,
                cashbackPerItem: item.offer?.cashback ?? 0,
                totalCashback: (item.offer?.cashback ?? 0) * Double(item.quantity)
            )
        }
        
        // Call the SubmissionService to save to database
        let submittedSubmission = try await SubmissionService().createSubmission(
            userId: userId,
            storeId: storeId,
            receiptUrls: receiptImageUrls,
            items: submissionItemsInput,
            totalCashback: totalCashback
        )
        
        // Add store information to the submission
        var submissionWithStore = submittedSubmission
        submissionWithStore.store = stores.first { $0.id == storeId }
        
        // Fetch and attach submission items to the submission
        let submissionItems = items.map { item in
            SubmissionItem(
                submissionId: submittedSubmission.id,
                offerId: item.offerId,
                offerName: item.offer?.name ?? "Unknown",
                quantity: item.quantity,
                cashbackPerItem: item.offer?.cashback ?? 0
            )
        }
        submissionWithStore.items = submissionItems
        
        // Add to local state
        submissions.insert(submissionWithStore, at: 0)
        
        // Remove submitted items from local list (already removed in SubmissionService)
        for item in items {
            if let index = userListItems.firstIndex(where: { $0.id == item.id }) {
                userListItems.remove(at: index)
            }
        }
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        print("✅ Receipt submitted successfully to database: \(submittedSubmission.id)")
    }
    
    func getSubmissions(status: Submission.SubmissionStatus? = nil) -> [Submission] {
        if let status = status {
            return submissions.filter { $0.status == status }
        }
        return submissions
    }
    
    // MARK: - Balance Management
    func requestWithdrawal(amount: Double) async throws {
        guard let userId = currentUser?.id,
              var user = currentUser,
              user.balance >= amount,
              amount >= 15.0 else {
            throw NSError(domain: "AppState", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid withdrawal amount"])
        }
        
        print("💳 Processing gift card withdrawal of \(amount.asCurrency)")
        
        // Simulate API call to process withdrawal
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        
        // Update user balance
        user.balance -= amount
        user.totalWithdrawn += amount
        currentUser = user
        
        // Create transaction record
        let transaction = Transaction(
            userId: userId,
            type: .withdrawal,
            amount: amount,
            description: "Visa Gift Card - Link sent to email"
        )
        transactions.insert(transaction, at: 0)
        
        print("✅ Withdrawal processed successfully")
        print("   New balance: \(user.balance.asCurrency)")
        print("   Total withdrawn: \(user.totalWithdrawn.asCurrency)")
        
        // In production, this would:
        // 1. Call backend API to create withdrawal request
        // 2. Backend would send email with gift card selection link
        // 3. User would receive email within 24 hours
        
        // Haptic feedback
        await MainActor.run {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
}
