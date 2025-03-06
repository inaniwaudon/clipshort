//
//  ClipboardMonitor.swift
//  Shortcut
//
//  Created by inaniwaudon on 2025/03/04.
//

import Foundation
import SwiftUI

class ClipboardState: ObservableObject {
    @Published var text = ""
    @Published var response = ""
    private var timer: Timer?
    
    func startMonitoring() {
        timer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(checkClipboard),
            userInfo: nil,
            repeats: true)
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    func copy() {
        // 存在する場合は選択中のテキストを、なければ response 全文を選択
        var selectedText: String? = nil
        if let editor = NSApp.keyWindow?.firstResponder as? NSTextView {
            if let selectedRange = editor.selectedRanges.first as? NSRange {
                if selectedRange.length > 0 {
                    selectedText = (editor.string as NSString).substring(with: selectedRange)
                }
            }
        }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(selectedText ?? response, forType: .string)
    }

    @objc private func checkClipboard() {
        if let str = NSPasteboard.general.string(forType: .string) {
            DispatchQueue.main.async {
                self.text = str
            }
        }
    }
}
