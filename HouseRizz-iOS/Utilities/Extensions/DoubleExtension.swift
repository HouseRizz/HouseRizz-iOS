//
//  DoubleExtension.swift
//  InventoryManagement
//
//  Created by Krish Mittal on 24/05/24.
//

import Foundation

extension Double {
    func formattedCurrency(isINR: Bool = true) -> String {
        return NumberFormatter.formatCurrency(self, isINR: isINR)
    }
}

extension Int {
    func formattedCurrency(isINR: Bool = true) -> String {
        return NumberFormatter.formatCurrency(Double(self), isINR: isINR)
    }
}
