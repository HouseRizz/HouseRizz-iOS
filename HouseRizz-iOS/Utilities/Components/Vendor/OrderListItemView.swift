//
//  OrderListItemView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 08/06/24.
//

import SwiftUI

struct OrderListItemView: View {
    
    let order: HROrder
    
    var body: some View {
        HStack {
            Text("\(order.buyerName)")
            Text("\(order.name)")
            Text("\((order.price ?? 0).formattedCurrency())")
            Text("\(order.orderStatus ?? "To be Confirmed")")
        }
    }
}

#Preview {
    OrderListItemView(order: HROrder(id: UUID(), name: "Red Bed", price: 123.0, quantity: 2, supplier: "Krish", buyerName: "Krish Mittal", buyerEmail: "contact@krishmittal.com", buyerPhoneNumber: "9999670308", buyerAddress: "Rohini, Delhi", dateOfOrder: Date().timeIntervalSince1970, orderStatus: "Confirmed")!)
}
