//
//  SideMenu.swift
//  HouseRizz
//
//  Created by Krish Mittal on 01/04/24.
//

import SwiftUI

struct SideMenu<Content: View, MenuView: View>: View {
    @Binding var showMenu: Bool
    var sideMenuWidth: CGFloat = 330
    var cornerRadius: CGFloat = 50
    var contentOpacity: Double = 0.5
    @ViewBuilder var content: (UIEdgeInsets) -> Content
    @ViewBuilder var menuView: (UIEdgeInsets) -> MenuView
    @GestureState private var isDragging: Bool = false
    @State private var offsetX: CGFloat = 0
    @State private var lastOffsetX: CGFloat = 0
    @State private var progress: CGFloat = 0
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let safeArea = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow?.safeAreaInsets ?? .zero
            ZStack {
                Color.gray.opacity(showMenu ? 0.5 : 0.0)
                    .ignoresSafeArea()
                HStack(spacing: 0) {
                    GeometryReader { _ in
                        menuView(safeArea)
                            .background(Color.white)
                    }
                    .frame(width: sideMenuWidth)
                    .contentShape(.rect)
                    GeometryReader { _ in
                        content(safeArea)
                            .opacity(showMenu ? contentOpacity : 1.0)
                    }
                    .frame(width: size.width)
                }
                .frame(width: size.width + sideMenuWidth, height: size.height)
                .offset(x: -sideMenuWidth)
                .offset(x: offsetX)
                .contentShape(.rect)
                .gesture(drageGesture)
            }
        }
        .ignoresSafeArea()
        .onChange(of: showMenu, initial: true) { _, newValue in
            withAnimation(.snappy(duration: 0.3, extraBounce: 0)) {
                if newValue {
                    showSideBar()
                } else {
                    reset()
                }
            }
        }
    }
    var drageGesture: some Gesture {
        DragGesture()
            .updating($isDragging) { _, out, _ in
                out = true
            }.onChanged { value in
                let translationX = isDragging ? max(min(value.translation.width + lastOffsetX, sideMenuWidth),0) : 0
                offsetX = translationX
            }.onEnded { value in
                withAnimation(.snappy(duration: 0.3,extraBounce: 0)){
                    let velocityX = value.velocity.width / 8
                    let total = velocityX + offsetX
                    if total > (sideMenuWidth + 0.6) {
                        showSideBar()
                    } else {
                        reset()
                    }
                    offsetX = 0
                }
            }
    }
    func showSideBar() {
        offsetX = sideMenuWidth
        lastOffsetX = offsetX
        showMenu = true
    }
    func reset() {
        offsetX = 0
        lastOffsetX = 0
        showMenu = false
    }
}
