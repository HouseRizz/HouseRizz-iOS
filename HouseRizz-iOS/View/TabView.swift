//
//  TabView.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 13/04/24.
//

import SwiftUI

struct TabbedView: View {
    @State var selectedTab = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(0)
                AIView()
                    .tag(1)
                CameraView()
                    .tag(2)
                ProductView()
                    .tag(3)
               
            }

            ZStack {
                HStack {
                    ForEach(HRTabItems.allCases, id: \.self) { item in
                        Button {
                            selectedTab = item.rawValue
                        } label: {
                            CustomTabItem(imageName: item.iconName, title: item.title, isActive: (selectedTab == item.rawValue))
                        }
                    }
                }
                .padding(6)
            }
            .frame(height: 70)
            .background(.purple.opacity(0.2))
            .cornerRadius(35)
            .padding(.horizontal, 26)
        }
    }
}

extension TabbedView {
    func CustomTabItem(imageName: String, title: String, isActive: Bool) -> some View {
        HStack(spacing: 10) {
            Spacer()
            Image(imageName)
                .resizable()
                .frame(width: 25, height: 25)
            if isActive {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(isActive ? .black : .purple)
            }
            Spacer()
        }
        .frame(width: isActive ? .none : 60, height: 60)
        .background(isActive ? .purple.opacity(0.4) : .clear)
        .cornerRadius(30)
    }
}



