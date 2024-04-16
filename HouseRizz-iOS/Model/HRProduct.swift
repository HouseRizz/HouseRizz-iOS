//
//  HRProduct.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 11/04/24.
//

import Foundation

struct HRProduct: Identifiable {
    var id = UUID()
    var category: Category
    var name: String
    var image: String
    var description: String
    var supplier: String
    var price: Int
    var width: String
    var height: String
    var diameter: String
    
}

enum Category: CaseIterable {
    case sofa
    case bed
    case chair
    case tv
    
    var title: String {
        switch self {
        case .sofa:
            return "Sofa"
        case .bed:
            return "Bed"
        case .chair:
            return "Chair"
        case .tv:
            return "TV"
        }
    }
    
    var image: String {
        switch self {
        case .sofa:
            return "bluesofa"
        case .bed:
            return "whitebed"
        case .chair:
            return "redchair"
        case .tv:
            return "retrotv"
        }
    }
}

var productList = [
    HRProduct(category: Category.sofa , name: "Blue Sofa", image: "bluesofa", description: "A comfortable blue sofa for your living room. This sofa features plush cushions and sturdy construction. Its vibrant blue color adds a touch of elegance to any space. Elevate your relaxation with this stylish piece of furniture. Available in various sizes to suit your needs.", supplier: "XYZ", price: 200, width: "80 inches", height: "40 inches", diameter: ""),
    HRProduct(category: Category.bed, name: "White Bed", image: "whitebed", description: "A stylish white bed for a good night's sleep. This bed combines modern design with exceptional comfort. Its sleek frame and clean lines create a contemporary look. Experience luxury and tranquility every night. Available in queen and king sizes.", supplier: "ABC", price: 400, width: "Queen", height: "60 inches", diameter: ""),
    HRProduct(category: Category.sofa, name: "Leather Sofa", image: "leathersofa", description: "Luxurious leather sofa for your home. Crafted with premium materials, this sofa exudes sophistication and refinement. Its supple leather upholstery provides unmatched comfort. Transform your living space with this timeless piece of furniture. Available in multiple colors to complement any decor.", supplier: "XYZ", price: 250, width: "75 inches", height: "38 inches", diameter: "40 inches"),
    HRProduct(category: Category.sofa, name: "Gray Sofa", image: "graysofa", description: "Modern gray sofa to enhance your decor. This sofa combines contemporary design with unbeatable comfort. Its neutral gray color blends seamlessly with any interior style. Upgrade your living room with this versatile and chic piece of furniture. Available in various sizes to fit your space perfectly.", supplier: "ABC", price: 430, width: "82 inches", height: "36 inches", diameter: ""),
    HRProduct(category: Category.chair, name: "Red Chair", image: "redchair", description: "Vibrant red chair for a pop of color. Add a bold statement to your room with this eye-catching chair. Its ergonomic design ensures maximum comfort and support. Whether used as an accent piece or a functional seat, this chair will enhance any space. Available in different upholstery options to suit your preference.", supplier: "Apple", price: 320, width: "26 inches", height: "32 inches", diameter: "40 inches"),
    HRProduct(category: Category.tv, name: "Retro TV", image: "retrotv", description: "Vintage-style retro TV for nostalgic moments. Transport yourself back in time with this charming retro TV. Its classic design evokes memories of simpler days. Enjoy your favorite movies and shows with modern technology in a nostalgic package. Available in compact sizes for easy placement in any room.", supplier: "Apple", price: 150, width: "32 inches", height: "24 inches", diameter: "40 inches")
]


