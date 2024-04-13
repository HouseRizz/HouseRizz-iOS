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
    case products
    case profile
    
    var title: String{
        switch self {
        case .home:
            return "Home"
        case .ai:
            return "AI"
        case .products:
            return "Products"
        case .profile:
            return "Profile"
        }
    }
    
    var iconName: String{
        switch self {
        case .home:
            return "Home"
        case .ai:
            return "Star"
        case .products:
            return "Box"
        case .profile:
            return "Person"
        }
    }
}
