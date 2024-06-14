//
//  UPIAppListViewDataModel.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 14/06/24.
//

import SwiftUI

struct UPIAppListViewDataModel: Decodable, Hashable {
    var imageURL: UIImage? {
        return UIImage(named: appname)
    }
    var appname: String
    var appScheme: String {
        get {
            return "\(appname)://app"
        }
    }
}
