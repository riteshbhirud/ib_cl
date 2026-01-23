//
//  MockData.swift
//  ib_clone
//
//  Created by rb on 1/17/26.
//

import Foundation

@MainActor
class MockData {
    static let shared = MockData()
    
    // MARK: - Sample User
    let sampleUser = User(
        id: UUID(),
        name: "Sarah Johnson",
        email: "sarah.johnson@example.com",
        balance: 24.50,
        totalEarned: 87.25,
        totalWithdrawn: 62.75,
        createdAt: Date().addingTimeInterval(-60 * 60 * 24 * 90) // 90 days ago
    )
    
    // MARK: - Sample Stores
    let stores: [Store] = [
        Store(
            name: "Walmart",
            logoUrl: "walmart_logo",
            description: "Save money. Live better.",
            isActive: true,
            offerCount: 12
        ),
        Store(
            name: "Target",
            logoUrl: "target_logo",
            description: "Expect More. Pay Less.",
            isActive: true,
            offerCount: 15
        ),
        Store(
            name: "CVS Pharmacy",
            logoUrl: "cvs_logo",
            description: "Health is everything",
            isActive: true,
            offerCount: 18
        ),
        Store(
            name: "Walgreens",
            logoUrl: "walgreens_logo",
            description: "Trusted since 1901",
            isActive: true,
            offerCount: 14
        ),
        Store(
            name: "Kroger",
            logoUrl: "kroger_logo",
            description: "Fresh for Everyone",
            isActive: true,
            offerCount: 20
        ),
        Store(
            name: "Costco",
            logoUrl: "costco_logo",
            description: "The Warehouse Wholesaler",
            isActive: true,
            offerCount: 10
        )
    ]
    
    // MARK: - Sample Offers
    func generateOffers() -> [Offer] {
        var offers: [Offer] = []
        
        // Walmart Offers
        offers.append(contentsOf: [
            Offer(
                storeId: stores[0].id,
                offerId: "walmart_1",
                slug: "tide-pods",
                name: "Tide PODS Laundry Detergent, 81ct",
                imageUrl: "tide_pods",
                cashback: 3.50,
                details: "Get $3.50 back on Tide PODS",
                offerDetail: "Valid on any Tide PODS 81ct or larger. Limit 2 per receipt.",
                purchaseRequirement: "Must buy 1",
                redemptionLimit: 2,
                expiringSoon: false,
                hasBonus: false
            ),
            Offer(
                storeId: stores[0].id,
                offerId: "walmart_2",
                slug: "dove-soap",
                name: "Dove Beauty Bar Soap 4pk",
                imageUrl: "dove_soap",
                cashback: 1.00,
                details: "Get $1.00 back",
                offerDetail: "Valid on any Dove Beauty Bar 4pk or larger.",
                specialTag: "FREE AFTER OFFER",
                purchaseRequirement: nil,
                redemptionLimit: 5,
                expiringSoon: true,
                hasBonus: false
            ),
            Offer(
                storeId: stores[0].id,
                offerId: "walmart_3",
                slug: "pepsi-12pk",
                name: "Pepsi 12pk Cans",
                imageUrl: "pepsi",
                cashback: 2.00,
                details: "Get $2.00 back",
                offerDetail: "Valid on any Pepsi 12pk cans.",
                purchaseRequirement: "Must buy 2",
                redemptionLimit: 3,
                expiringSoon: false,
                hasBonus: true
            ),
            Offer(
                storeId: stores[0].id,
                offerId: "walmart_4",
                slug: "cheerios",
                name: "Cheerios Cereal, 18oz",
                imageUrl: "cheerios",
                cashback: 1.50,
                details: "Get $1.50 back",
                offerDetail: "Valid on any Cheerios 18oz or larger.",
                redemptionLimit: 4,
                expiringSoon: false
            ),
            Offer(
                storeId: stores[0].id,
                offerId: "walmart_5",
                slug: "charmin",
                name: "Charmin Ultra Soft Toilet Paper 12ct",
                imageUrl: "charmin",
                cashback: 2.50,
                details: "Get $2.50 back",
                offerDetail: "Valid on any Charmin 12ct or larger.",
                redemptionLimit: 2,
                expiringSoon: false
            )
        ])
        
        // Target Offers
        offers.append(contentsOf: [
            Offer(
                storeId: stores[1].id,
                offerId: "target_1",
                slug: "olay-regenerist",
                name: "Olay Regenerist Moisturizer",
                imageUrl: "olay",
                cashback: 5.00,
                details: "Get $5.00 back",
                offerDetail: "Valid on any Olay Regenerist product.",
                redemptionLimit: 3,
                expiringSoon: false,
                hasBonus: true
            ),
            Offer(
                storeId: stores[1].id,
                offerId: "target_2",
                slug: "nutella",
                name: "Nutella Hazelnut Spread 26.5oz",
                imageUrl: "nutella",
                cashback: 2.00,
                details: "Get $2.00 back",
                offerDetail: "Valid on any Nutella 26.5oz jar.",
                redemptionLimit: 5,
                expiringSoon: true
            ),
            Offer(
                storeId: stores[1].id,
                offerId: "target_3",
                slug: "lysol-spray",
                name: "Lysol Disinfectant Spray",
                imageUrl: "lysol",
                cashback: 1.50,
                details: "Get $1.50 back",
                offerDetail: "Valid on any Lysol spray product.",
                specialTag: "FREE AFTER OFFER",
                redemptionLimit: 4,
                expiringSoon: false
            ),
            Offer(
                storeId: stores[1].id,
                offerId: "target_4",
                slug: "bounty",
                name: "Bounty Paper Towels 6pk",
                imageUrl: "bounty",
                cashback: 3.00,
                details: "Get $3.00 back",
                offerDetail: "Valid on any Bounty 6pk or larger.",
                purchaseRequirement: "Must buy 2",
                redemptionLimit: 2,
                expiringSoon: false
            )
        ])
        
        // CVS Offers
        offers.append(contentsOf: [
            Offer(
                storeId: stores[2].id,
                offerId: "cvs_1",
                slug: "colgate-toothpaste",
                name: "Colgate Total Toothpaste",
                imageUrl: "colgate",
                cashback: 2.00,
                details: "Get $2.00 back",
                offerDetail: "Valid on any Colgate Total toothpaste.",
                specialTag: "FREE AFTER OFFER",
                redemptionLimit: 5,
                expiringSoon: true
            ),
            Offer(
                storeId: stores[2].id,
                offerId: "cvs_2",
                slug: "advil",
                name: "Advil Pain Reliever 50ct",
                imageUrl: "advil",
                cashback: 3.00,
                details: "Get $3.00 back",
                offerDetail: "Valid on any Advil 50ct or larger.",
                redemptionLimit: 3,
                expiringSoon: false
            ),
            Offer(
                storeId: stores[2].id,
                offerId: "cvs_3",
                slug: "loreal-shampoo",
                name: "L'Oréal Elvive Shampoo",
                imageUrl: "loreal",
                cashback: 2.50,
                details: "Get $2.50 back",
                offerDetail: "Valid on any L'Oréal Elvive shampoo or conditioner.",
                purchaseRequirement: "Must buy 2",
                redemptionLimit: 4,
                expiringSoon: false,
                hasBonus: true
            )
        ])
        
        // Walgreens Offers
        offers.append(contentsOf: [
            Offer(
                storeId: stores[3].id,
                offerId: "walgreens_1",
                slug: "gillette-razor",
                name: "Gillette Fusion5 Razor",
                imageUrl: "gillette",
                cashback: 4.00,
                details: "Get $4.00 back",
                offerDetail: "Valid on any Gillette Fusion5 razor.",
                redemptionLimit: 2,
                expiringSoon: false
            ),
            Offer(
                storeId: stores[3].id,
                offerId: "walgreens_2",
                slug: "nivea-lotion",
                name: "Nivea Body Lotion 16.9oz",
                imageUrl: "nivea",
                cashback: 1.50,
                details: "Get $1.50 back",
                offerDetail: "Valid on any Nivea body lotion.",
                redemptionLimit: 5,
                expiringSoon: true
            )
        ])
        
        // Kroger Offers
        offers.append(contentsOf: [
            Offer(
                storeId: stores[4].id,
                offerId: "kroger_1",
                slug: "ben-jerrys",
                name: "Ben & Jerry's Ice Cream Pint",
                imageUrl: "ben_jerrys",
                cashback: 1.50,
                details: "Get $1.50 back",
                offerDetail: "Valid on any Ben & Jerry's pint.",
                purchaseRequirement: "Must buy 2",
                redemptionLimit: 3,
                expiringSoon: false,
                hasBonus: true
            ),
            Offer(
                storeId: stores[4].id,
                offerId: "kroger_2",
                slug: "hellmanns-mayo",
                name: "Hellmann's Real Mayonnaise 30oz",
                imageUrl: "hellmanns",
                cashback: 2.00,
                details: "Get $2.00 back",
                offerDetail: "Valid on any Hellmann's 30oz jar.",
                redemptionLimit: 4,
                expiringSoon: false
            )
        ])
        
        // Costco Offers
        offers.append(contentsOf: [
            Offer(
                storeId: stores[5].id,
                offerId: "costco_1",
                slug: "kirkland-nuts",
                name: "Kirkland Mixed Nuts 2.5lb",
                imageUrl: "kirkland_nuts",
                cashback: 5.00,
                details: "Get $5.00 back",
                offerDetail: "Valid on any Kirkland mixed nuts.",
                redemptionLimit: 2,
                expiringSoon: false
            ),
            Offer(
                storeId: stores[5].id,
                offerId: "costco_2",
                slug: "kirkland-water",
                name: "Kirkland Water 40pk",
                imageUrl: "kirkland_water",
                cashback: 3.00,
                details: "Get $3.00 back",
                offerDetail: "Valid on any Kirkland water 40pk.",
                redemptionLimit: 3,
                expiringSoon: true
            )
        ])
        
        return offers
    }
    
    // MARK: - Sample Submissions
    func generateSubmissions(userId: UUID) -> [Submission] {
        [
            Submission(
                userId: userId,
                storeId: stores[0].id,
                receiptImageUrl: "receipt_1",
                totalCashback: 7.00,
                status: .approved,
                submittedAt: Date().addingTimeInterval(-60 * 60 * 24 * 5),
                reviewedAt: Date().addingTimeInterval(-60 * 60 * 24 * 4),
                items: [
                    SubmissionItem(
                        submissionId: UUID(),
                        offerId: UUID(),
                        offerName: "Tide PODS 81ct",
                        quantity: 2,
                        cashbackPerItem: 3.50
                    )
                ],
                store: stores[0]
            ),
            Submission(
                userId: userId,
                storeId: stores[1].id,
                receiptImageUrl: "receipt_2",
                totalCashback: 12.50,
                status: .pending,
                submittedAt: Date().addingTimeInterval(-60 * 60 * 24),
                items: [
                    SubmissionItem(
                        submissionId: UUID(),
                        offerId: UUID(),
                        offerName: "Olay Regenerist",
                        quantity: 1,
                        cashbackPerItem: 5.00
                    ),
                    SubmissionItem(
                        submissionId: UUID(),
                        offerId: UUID(),
                        offerName: "Bounty 6pk",
                        quantity: 2,
                        cashbackPerItem: 3.00
                    ),
                    SubmissionItem(
                        submissionId: UUID(),
                        offerId: UUID(),
                        offerName: "Lysol Spray",
                        quantity: 1,
                        cashbackPerItem: 1.50
                    )
                ],
                store: stores[1]
            ),
            Submission(
                userId: userId,
                storeId: stores[2].id,
                receiptImageUrl: "receipt_3",
                totalCashback: 5.00,
                status: .rejected,
                rejectionReason: "Receipt image was not clear enough. Please resubmit with a clearer photo.",
                submittedAt: Date().addingTimeInterval(-60 * 60 * 24 * 10),
                reviewedAt: Date().addingTimeInterval(-60 * 60 * 24 * 9),
                items: [
                    SubmissionItem(
                        submissionId: UUID(),
                        offerId: UUID(),
                        offerName: "Colgate Total",
                        quantity: 2,
                        cashbackPerItem: 2.00
                    )
                ],
                store: stores[2]
            )
        ]
    }
    
    // MARK: - Sample Transactions
    func generateTransactions(userId: UUID) -> [Transaction] {
        [
            Transaction(
                userId: userId,
                type: .earning,
                amount: 7.00,
                description: "Walmart receipt approved",
                date: Date().addingTimeInterval(-60 * 60 * 24 * 4)
            ),
            Transaction(
                userId: userId,
                type: .earning,
                amount: 15.50,
                description: "Target receipt approved",
                date: Date().addingTimeInterval(-60 * 60 * 24 * 15)
            ),
            Transaction(
                userId: userId,
                type: .bonus,
                amount: 2.00,
                description: "New user bonus",
                date: Date().addingTimeInterval(-60 * 60 * 24 * 90)
            ),
            Transaction(
                userId: userId,
                type: .withdrawal,
                amount: 25.00,
                description: "PayPal withdrawal",
                date: Date().addingTimeInterval(-60 * 60 * 24 * 30)
            ),
            Transaction(
                userId: userId,
                type: .earning,
                amount: 8.75,
                description: "CVS receipt approved",
                date: Date().addingTimeInterval(-60 * 60 * 24 * 45)
            )
        ]
    }
}
