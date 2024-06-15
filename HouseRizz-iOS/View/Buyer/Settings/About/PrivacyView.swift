//
//  PrivacyPolicyView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 15/06/24.
//

import SwiftUI

struct PrivacyView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Group {
                        Text("Introduction")
                            .font(.headline)
                        Text("""
                            At HouseRizz, we value your privacy and are committed to protecting your personal information. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our platform. By using HouseRizz, you consent to the practices described in this policy.
                            """)
                        
                        Text("Information We Collect")
                            .font(.headline)
                        Text("""
                            1. Personal Information
                            We collect personal information that you provide to us when you register on our platform, make a purchase, or communicate with us. This information may include your name, email address, phone number, billing and shipping addresses, and payment information.

                            2. Usage Data
                            We collect information about your interactions with our platform, such as the pages you visit, the products you view, and your search queries. We also collect information about the device and browser you use to access our platform.
                            """)
                        
                        Text("How We Use Your Information")
                            .font(.headline)
                        Text("""
                            1. To Provide and Improve Our Services
                            We use your information to process your orders, manage your account, and provide customer support. We also use your information to improve our platform, personalize your experience, and develop new features and services.

                            2. To Communicate with You
                            We use your contact information to send you updates about your orders, respond to your inquiries, and provide information about our products and promotions. You can opt out of promotional communications at any time.

                            3. To Comply with Legal Obligations
                            We may use your information to comply with legal and regulatory requirements, prevent fraud, and enforce our terms and conditions.
                            """)
                        
                        Text("How We Share Your Information")
                            .font(.headline)
                        Text("""
                            1. With Service Providers
                            We Donot share your information with third-party service providers who perform services on our behalf, such as payment processing, shipping, and data analysis. =

                            2. With Vendors
                            When you purchase a product from a vendor on our platform, we share your information with the vendor to facilitate order fulfillment. Vendors are required to protect your information and use it only for purposes related to your order.

                            3. For Legal Reasons
                            We may disclose your information if required to do so by law or in response to a valid request by a governmental authority, such as a court or regulatory agency.

                            4. No Sale or Provision to Third Parties
                            We do not sell, trade, or otherwise provide your personal information to any third parties for their marketing or advertising purposes.
                            """)
                        
                        Text("Your Rights and Choices")
                            .font(.headline)
                        Text("""
                            1. Access and Update Your Information
                            You can access and update your personal information by logging into your account on HouseRizz. If you need assistance, please contact our support team.

                            2. Opt Out of Marketing Communications
                            You can opt out of receiving promotional emails from us by following the unsubscribe instructions in the email or by contacting us directly. Please note that you may still receive transactional emails related to your orders.

                            3. Delete Your Account
                            You can request to delete your account by contacting our support team. We will delete your account and personal information, except for information that we are required to retain by law or for legitimate business purposes.
                            """)
                        
                        Text("Security of Your Information")
                            .font(.headline)
                        Text("""
                            We take reasonable measures to protect your information from unauthorized access, use, or disclosure. However, no method of transmission over the internet or electronic storage is completely secure, and we cannot guarantee the absolute security of your information.
                            """)
                        
                        Text("Changes to This Privacy Policy")
                            .font(.headline)
                        Text("""
                            We may update this Privacy Policy from time to time to reflect changes in our practices or legal requirements. We will notify you of any significant changes by posting the updated policy on our platform and indicating the date of the latest revision. Your continued use of HouseRizz after any changes constitutes your acceptance of the updated policy.
                            """)
                        
                        Text("Contact Us")
                            .font(.headline)
                        Text("""
                            If you have any questions or concerns about this Privacy Policy or our data practices, please contact us at:

                            HouseRizz Support Team
                            Email: contact.houserizz@gmail.com
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
    PrivacyView()
}
