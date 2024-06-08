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
