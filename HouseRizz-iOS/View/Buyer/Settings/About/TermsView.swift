//
//  TermsView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 15/06/24.
//

import SwiftUI

struct TermsView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Group {
                        Text("Introduction")
                            .font(.headline)
                        Text("""
                            Welcome to HouseRizz, a home interior marketplace where vendors can sell their products and customers can purchase them. By using our platform, you agree to comply with and be bound by the following terms and conditions. Please read them carefully. If you do not agree with any part of these terms, you must not use our website.
                            """)
                        
                        Text("Definitions")
                            .font(.headline)
                        Text("""
                            - "Platform" refers to the HouseRizz website and any associated services.
                            - "Vendor" refers to individuals or businesses that sell products through HouseRizz.
                            - "Customer" refers to individuals who purchase products through HouseRizz.
                            - "Products" refer to home interior items sold on the platform.
                            """)
                        
                        Text("General Terms")
                            .font(.headline)
                        Text("""
                            1. Acceptance of Terms
                            By accessing or using our platform, you agree to be bound by these terms and conditions, our privacy policy, and all other policies and guidelines applicable to your use of the platform.

                            2. Eligibility
                            You must be at least 18 years old to use our platform. By using HouseRizz, you represent and warrant that you are at least 18 years old and that you have the right, authority, and capacity to enter into these terms and conditions.
                            """)
                        
                        Text("Vendor Terms")
                            .font(.headline)
                        Text("""
                            1. Vendor Registration
                            Vendors must complete the registration process to sell products on HouseRizz. Vendors must provide accurate and complete information during registration and maintain the accuracy of such information.

                            2. Product Listings
                            Vendors are responsible for creating accurate and detailed product listings. HouseRizz reserves the right to remove any listings that violate our policies or are deemed inappropriate.

                            3. Fees and Payments
                            Vendors agree to pay any applicable fees for listing and selling products on HouseRizz. Payment terms and conditions will be communicated separately to vendors.

                            4. Order Fulfillment
                            Vendors are responsible for fulfilling orders promptly and accurately. Any disputes or issues regarding order fulfillment are the responsibility of the vendor.

                            5. Compliance with Laws
                            Vendors must comply with all applicable laws and regulations related to the sale of their products, including but not limited to consumer protection laws, intellectual property laws, and tax regulations.
                            """)
                        
                        Text("Customer Terms")
                            .font(.headline)
                        Text("""
                            1. Account Registration
                            Customers may need to create an account to purchase products on HouseRizz. Customers agree to provide accurate and complete information and to keep this information up to date.

                            2. Purchasing Products
                            When purchasing products, customers agree to provide accurate payment information and authorize HouseRizz to charge the applicable fees.

                            3. Returns and Refunds
                            HouseRizz's return and refund policies will apply to all purchases. Customers should review these policies before making a purchase.

                            4. Product Availability
                            HouseRizz does not guarantee the availability of any products listed on the platform. All orders are subject to availability.
                            """)
                        
                        Text("Intellectual Property")
                            .font(.headline)
                        Text("""
                            1. Platform Content
                            All content on the HouseRizz platform, including but not limited to text, graphics, logos, and images, is the property of HouseRizz or its licensors and is protected by intellectual property laws.

                            2. User Content
                            Users retain ownership of the content they submit, post, or display on the platform. By submitting content, users grant HouseRizz a non-exclusive, worldwide, royalty-free license to use, modify, and display such content.
                            """)
                        
                        Text("Limitation of Liability")
                            .font(.headline)
                        Text("""
                            HouseRizz is not liable for any indirect, incidental, special, consequential, or punitive damages arising out of or related to the use of the platform or the purchase or sale of products through the platform.
                            """)
                        
                        Text("Indemnification")
                            .font(.headline)
                        Text("""
                            Users agree to indemnify and hold HouseRizz harmless from any claims, damages, losses, liabilities, and expenses arising out of or related to their use of the platform or violation of these terms and conditions.
                            """)
                        
                        Text("Changes to Terms")
                            .font(.headline)
                        Text("""
                            HouseRizz reserves the right to modify these terms and conditions at any time. Any changes will be effective immediately upon posting on the platform. Users are responsible for reviewing these terms regularly.
                            """)
                        
                        Text("Governing Law")
                            .font(.headline)
                        Text("""
                            These terms and conditions are governed by and construed in accordance with the laws of Delhi, without regard to its conflict of law principles.
                            """)
                        
                        Text("Contact Information")
                            .font(.headline)
                        Text("""
                            For any questions or concerns regarding these terms and conditions, please contact us at:

                            HouseRizz Support Team
                            Email: contact.houserizz@gmail.com.com
                            """)
                    }
                }
                .padding()
            }
            .navigationTitle("Terms and Conditions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.red)
                    }
                }
        }
        }
    }
}

#Preview {
    TermsView()
}
