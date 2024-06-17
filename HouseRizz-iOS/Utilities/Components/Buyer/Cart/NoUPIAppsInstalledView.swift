//
//  NoUPIAppsInstalledView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 14/06/24.
//

import SwiftUI

struct NoUPIAppsInstalledView: View {
    let appSchemes: [String: String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("No UPI Apps Installed")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("To proceed with UPI payments, please install any of the following apps:")
                .font(.body)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(appSchemes.sorted(by: <), id: \.key) { scheme, appName in
                    Text("• \(appName)")
                        .font(.body)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
}
