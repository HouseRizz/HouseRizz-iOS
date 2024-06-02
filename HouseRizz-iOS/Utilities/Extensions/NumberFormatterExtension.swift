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
        return formatter
    }()
}
