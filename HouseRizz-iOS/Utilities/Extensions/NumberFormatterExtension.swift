//
//  NumberFormatterExtension.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 02/06/24.
//

import Foundation

extension NumberFormatter {
    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        let userLocale = Locale.current
        let isIndianUser = userLocale.region?.identifier == "IN"
        
        formatter.locale = isIndianUser ? Locale(identifier: "en_IN") : Locale(identifier: "en_US")
        
        return formatter
    }()
    
    static func formatCurrency(_ amount: Double, isINR: Bool = true) -> String {
        let userLocale = Locale.current
        let isIndianUser = userLocale.region?.identifier == "IN"
        
        if isIndianUser {
            return currencyFormatter.string(from: NSNumber(value: amount)) ?? ""
        } else {
            let convertedAmount = isINR ? amount / 85 : amount // Convert INR to USD if necessary
            return currencyFormatter.string(from: NSNumber(value: convertedAmount)) ?? ""
        }
    }
}
