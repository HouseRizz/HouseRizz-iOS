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
                AIImageGenerationView()
                    .tag(1)
//                CameraView()
//                    .tag(2)
                CategoryView()
                    .tag(2)
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
            .background(Color.primaryColor.opacity(0.4))
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
                    .bold()
                    .font(.system(size: 14))
                    .foregroundColor(isActive ? .black : .orange)
            }
            Spacer()
        }
        .frame(width: isActive ? .none : 60, height: 60)
        .background(isActive ? Color.primaryColor.opacity(0.6) : .clear)
        .cornerRadius(30)
    }
}



