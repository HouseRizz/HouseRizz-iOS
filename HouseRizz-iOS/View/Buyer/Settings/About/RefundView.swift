//
//  RefundPolicyView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 15/06/24.
//

import SwiftUI

struct RefundView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Group {
                        Text("Introduction")
                            .font(.headline)
                        Text("""
                            At HouseRizz, we strive to ensure that you are satisfied with your purchase. If you are not completely satisfied with a product, our refund policy outlines the conditions and processes for obtaining a refund. Please read this policy carefully.
                            """)
                        
                        Text("Eligibility for Refunds")
                            .font(.headline)
                        Text("""
                            1. **Damaged or Defective Products**
                            If you receive a damaged or defective product, you are eligible for a full refund or replacement. Please contact us within 7 days of receiving the product to initiate the refund process.

                            2. **Incorrect Products**
                            If you receive a product that is not what you ordered, you are eligible for a full refund or replacement. Please contact us within 7 days of receiving the product to initiate the refund process.

                            3. **Change of Mind**
                            If you change your mind about a purchase, you may return the product for a refund within 14 days of receiving it. The product must be unused, in its original packaging, and in the same condition as when you received it. Shipping costs for returning the product will be your responsibility.
                            """)
                        
                        Text("Non-Refundable Items")
                            .font(.headline)
                        Text("""
                            The following items are not eligible for refunds:
                            - Products that have been used, damaged, or altered by the customer.
                            - Custom or personalized items.
                            - Items purchased on clearance or sale.
                            """)
                        
                        Text("Refund Process")
                            .font(.headline)
                        Text("""
                            1. **Initiating a Refund**
                            To initiate a refund, please contact our support team at support@houserizz.com with your order details, reason for the refund request, and any supporting photos or documentation if applicable.

                            2. **Return Instructions**
                            Our support team will provide you with return instructions and a return shipping address. Please ensure that the product is securely packaged to prevent damage during return shipping.

                            3. **Inspection and Approval**
                            Once we receive the returned product, we will inspect it to ensure it meets the eligibility criteria for a refund. We will notify you of the approval or rejection of your refund request.

                            4. **Processing the Refund**
                            If your refund request is approved, we will process the refund to your original method of payment within 7-10 business days. Please note that it may take additional time for the refund to appear on your account, depending on your payment provider.
                            """)
                        
                        Text("Exchanges")
                            .font(.headline)
                        Text("""
                            If you wish to exchange a product for a different size, color, or item, please follow the refund process to return the original product and place a new order for the desired item.
                            """)
                        
                        Text("Contact Us")
                            .font(.headline)
                        Text("""
                            If you have any questions or concerns about our refund policy or need assistance with a refund request, please contact us at:

                            HouseRizz Support Team
                            Email: contact.houserizz@gmail.com
                            """)
                    }
                }
                .padding()
            }
            .navigationTitle("Refund Policy")
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
    RefundView()
}
