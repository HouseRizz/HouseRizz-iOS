//
//  HRProduct.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 11/04/24.
//

import Foundation

struct HRProduct: Identifiable {
    var id = UUID()
    var name: String
    var image: String
    var description: String
    var supplier: String
    var price: Int
    
}

var productList = [
    HRProduct(name: "Blue Sofa", image: "bluesofa", description: "", supplier: "XYZ", price: 200),
    HRProduct(name: "White Bed", image: "whitebed", description: "", supplier: "ABC", price: 400),
    HRProduct(name: "Leather Sofa", image: "leathersofa", description: "", supplier: "XYZ", price: 250),
    HRProduct(name: "Gray Sofa", image: "graysofa", description: "", supplier: "ABC", price: 430),
    HRProduct(name: "Red Chair", image: "redchair", description: "", supplier: "Apple", price: 320),
    HRProduct(name: "Retro TV", image: "retrotv", description: "", supplier: "Apple", price: 150)
]
