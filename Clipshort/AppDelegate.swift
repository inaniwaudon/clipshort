//
//  AppDelegate.swift
//  Shortcut
//
//  Created by inaniwaudon on 2025/03/03.
//

import Cocoa
import Foundation
import ServiceManagement
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var clipboardState: ClipboardState?
    var statusItem: NSStatusItem?
    private var window: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        // 既存のウィンドウを破棄
        NSApp.windows.forEach{ $0.close() }
        
        // ログイン時に起動
        do {
            if SMAppService.mainApp.status != .enabled {
                try SMAppService.mainApp.register()
            }
        } catch {
            let alert = NSAlert()
            alert.messageText = "エラー"
            alert.informativeText = "ログイン項目への追加に失敗しました。権限を確認してください。"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "再試行")
            alert.buttons[0].tag = NSApplication.ModalResponse.OK.rawValue
            alert.addButton(withTitle: "終了")
            alert.buttons[1].tag = NSApplication.ModalResponse.stop.rawValue
            let result = alert.runModal()
            if result == .OK {
                checkAccessibilityPermission()
            } else {
                NSApplication.shared.terminate(self)
            }
        }
        
        // ステータスバーに表示
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "rectangle.and.paperclip", accessibilityDescription: "App Icon")
            button.action = #selector(openWindow)
        }
        
        checkAccessibilityPermission()
    }
    
    func checkAccessibilityPermission() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue(): true]
        if AXIsProcessTrustedWithOptions(options) {
            setup()
        } else {
            let alert = NSAlert()
            alert.messageText = "Accessibility API の権限が必要です"
            alert.informativeText = "本アプリケーションを実行するには Accessibility API の権限が必要です。システム設定の「プライバシーとセキュリティ」→「アクセシビリティ」から権限を付与してください。"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "再試行")
            alert.buttons[0].tag = NSApplication.ModalResponse.OK.rawValue
            alert.addButton(withTitle: "終了")
            alert.buttons[1].tag = NSApplication.ModalResponse.stop.rawValue
            let result = alert.runModal()
            if result == .OK {
                checkAccessibilityPermission()
            } else {
                NSApplication.shared.terminate(self)
            }
        }
    }
    
    func setup() {
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            if event.modifierFlags.rawValue == 262401  {
                // Control + [ で呼び出し
                if event.characters == "\u{1B}" {
                    // Command + C を実行
                    let source = CGEventSource(stateID: .hidSystemState)
                    let ctrlDown = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: true)
                    ctrlDown?.flags = CGEventFlags.maskCommand
                    ctrlDown?.post(tap: .cghidEventTap)
                    
                    let ctrlUp = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: false)
                    ctrlUp?.flags = CGEventFlags.maskCommand
                    ctrlUp?.post(tap: .cghidEventTap)
                    
                    DispatchQueue.main.async {
                        self.openWindow()
                    }
                }
            }
        }
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            // Command + Q, Esc: アプリケーション終了を無効化して、ウィンドウのみを閉じる
            if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "q" ||
                event.charactersIgnoringModifiers == "\u{1B}" {
                self.clipboardState!.copy()
                self.closeWindow()
                return nil
            }
            return event
        }
    }
    
    @objc private func openWindow() {
        // 既にあるウィンドウを破棄
        window?.close()
        
        // ウィンドウを作成
        let contentView = NSHostingView(rootView: ContentView().environmentObject(clipboardState!))
        let mouseLocation = NSEvent.mouseLocation
        window = CustomWindow(
            contentRect: NSRect(x: mouseLocation.x, y: mouseLocation.y, width: 400, height: 300),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window!.isReleasedWhenClosed = false
        window!.contentView = contentView
        window!.isOpaque = false
        window!.backgroundColor = NSColor.init(white: 0, alpha: 0)

        // ウィンドウを最前面に設定
        window!.level = .floating
        window!.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        clipboardState!.startMonitoring()
    }
    
    private func closeWindow() {
        window?.close()
        window = nil
        clipboardState!.stopMonitoring()
        clipboardState!.response = ""
    }
}

class CustomWindow: NSWindow {
    override var canBecomeKey: Bool {
        return true
    }
}
