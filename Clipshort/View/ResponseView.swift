//
//  Response.swift
//  Shortcut
//
//  Created by inaniwaudon on 2025/03/06.
//

import Foundation
import SwiftUI

struct ResponseView: View {
    @EnvironmentObject var clipboardState: ClipboardState
    @State private var responseHeight: CGFloat = ContentView.baseFontSize
    
    var body: some View {
        ScrollView {
            TextField("",text: $clipboardState.response, axis: .vertical)
                .font(.system(size: ContentView.baseFontSize))
                .textFieldStyle(.plain)
                .foregroundColor(.white)
                .background(.clear)
                .animation(.easeOut, value: clipboardState.response)
                .overlay(GeometryReader { geometry in
                    // サイズを取得
                    Color.clear
                        .allowsHitTesting(false)
                        .onAppear {
                            responseHeight = geometry.size.height
                        }
                        .onChange(of: geometry.size.height) {
                            responseHeight = geometry.size.height
                        }
                })
        }.frame(height: min(responseHeight, 150))
    }
}
