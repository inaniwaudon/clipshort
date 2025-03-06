//
//  ContentView.swift
//  Shortcut
//
//  Created by inaniwaudon on 2025/03/03.
//

import Foundation
import SwiftUI

struct ContentView: View, ShellDelegate {
    static let baseFontSize: CGFloat = 15
    
    @EnvironmentObject var clipboardState: ClipboardState
    
    var body: some View {
        ZStack {
            VStack(spacing: 4) {
                TopView()
                if clipboardState.response.count > 0 {
                    ResponseView()
                }
            }
            .padding([.horizontal], 14)
            .padding(.vertical, 10)
            .background(.black.opacity(0.8))
            .cornerRadius(10)
            .animation(.easeOut, value: clipboardState.response)
            .onAppear {
                Settings.initialize()
                clipboardState.startMonitoring()
                Shell.shared.delegate = self
            }
            .onDisappear {
                clipboardState.stopMonitoring()
                //Shell.shared.exit()
            }
        }.frame(width: CGFloat(Settings.width))
    }
    
    func completion(output: String) {
        DispatchQueue.main.async {
            clipboardState.response = output.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}
