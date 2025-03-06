//
//  ShortcutApp.swift
//  Shortcut
//
//  Created by inaniwaudon on 2025/03/03.
//

import SwiftUI

@main
struct ShortcutApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @ObservedObject var clipboardState = ClipboardState()
    
    init() {
        appDelegate.clipboardState = clipboardState
    }
    
    var body: some Scene {
        WindowGroup {}
    }
}
