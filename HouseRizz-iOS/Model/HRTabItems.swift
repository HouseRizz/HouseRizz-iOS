//
//  HRTabItems.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 13/04/24.
//

import Foundation

enum HRTabItems: Int, CaseIterable {
    
    case home = 0
    case ai
    case ar
    case products
    
    var title: String{
        switch self {
        case .home:
            return "Home"
        case .ai:
            return "AI"
        case .ar:
            return "3D"
        case .products:
            return "Product"
      
        }
    }
    
    var iconName: String{
        switch self {
        case .home:
            return "Home"
        case .ai:
            return "Star"
        case .ar:
            return "Earth"
        case .products:
            return "Box"
  
        }
    }
}
