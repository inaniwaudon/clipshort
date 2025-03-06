//
//  Top.swift
//  Shortcut
//
//  Created by inaniwaudon on 2025/03/06.
//

import Foundation
import SwiftUI

struct TopView: View {
    private static let smallFontSize: CGFloat = 13

    @EnvironmentObject var clipboardState: ClipboardState
    @StateObject var operationState = OperationState()
    
    @State var inputTextHeight: CGFloat = ContentView.baseFontSize
    @State var commandTextHeight: CGFloat = smallFontSize
    @State var clipboardTextHeight: CGFloat = smallFontSize
    @FocusState var isFocused: Bool
    
    private var trimedClipboard: String {
        operationState.appliesClipboard ? clipboardState.text.trimmingCharacters(in: .whitespacesAndNewlines) : ""
    }
    private var commandHeight: CGFloat {
        operationState.command != nil ? commandTextHeight : 0
    }
    private var clipboardHeight: CGFloat {
        operationState.appliesClipboard ? clipboardTextHeight : 0
    }
    private var totalHeight: CGFloat {
        inputTextHeight + commandHeight + clipboardHeight
    }
        
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                // プロンプト
                TextField("", text: $operationState.input, axis: .vertical)
                    .font(.system(size: ContentView.baseFontSize, weight: .semibold))
                    .textFieldStyle(.plain)
                    .foregroundColor(.white)
                    .background(.clear)
                    .lineLimit(1...10)
                    .focused($isFocused)
                    .onSubmit {
                        // Enter での改行を可能にする
                        operationState.input.append("\n")
                        isFocused = true
                    }
                    .onKeyPress(keys: [.return]) { keyPress in
                        // Command + Enter で送信処理
                        if keyPress.modifiers.contains(.command) {
                            operationState.run(
                                clipboardState: clipboardState,
                                trimedClipboard: trimedClipboard)
                            return .handled
                        }
                        return .ignored
                    }
                    .overlay(GeometryReader { geometry in
                        // サイズを取得
                        Color.clear
                            .allowsHitTesting(false)
                            .onAppear {
                                inputTextHeight = geometry.size.height
                            }
                            .onChange(of: geometry.size.height) {
                                inputTextHeight = geometry.size.height
                            }
                    })
                    .onAppear {
                        isFocused = true
                    }
                
                // コマンド
                Text(operationState.command ?? "")
                    .font(.system(size: TopView.smallFontSize))
                    .foregroundColor(.white.opacity(0.5))
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: operationState.command == nil ? 0 : nil,
                        alignment: .leading)
                    .lineLimit(0...3)
                    .animation(.easeOut, value: operationState.command)
                    .overlay(GeometryReader { geometry in
                        // サイズを取得
                        Color.clear
                            .allowsHitTesting(false)
                            .onAppear {
                                commandTextHeight = geometry.size.height
                            }
                            .onChange(of: geometry.size.height) {
                                commandTextHeight = geometry.size.height
                            }
                    })
                
                // クリップボード
                Text(trimedClipboard)
                    .font(.system(size: TopView.smallFontSize))
                    .foregroundColor(.white.opacity(0.5))
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: operationState.appliesClipboard ? nil : 0,
                        alignment: .leading)
                    .lineLimit(0...3)
                    .animation(.easeOut, value: [clipboardHeight])
                    .overlay(GeometryReader { geometry in
                        // サイズを取得
                        Color.clear
                            .allowsHitTesting(false)
                            .onAppear {
                                clipboardTextHeight = geometry.size.height
                            }
                            .onChange(of: geometry.size.height) {
                                clipboardTextHeight = geometry.size.height
                            }
                    })
            }.frame(height: 400)
        }.frame(height: totalHeight)
    }
}
