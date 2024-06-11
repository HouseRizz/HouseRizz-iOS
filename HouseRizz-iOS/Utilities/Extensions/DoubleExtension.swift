//
//  DoubleExtension.swift
//  InventoryManagement
//
//  Created by Krish Mittal on 24/05/24.
//

import Foundation

extension Double {
    func formattedCurrency() -> String {
        let formatter = NumberFormatter.currencyFormatter
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }
}

extension Int {
    func formattedCurrency() -> String {
        let formatter = NumberFormatter.currencyFormatter
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }
}

