//
//  Operation.swift
//  Shortcut
//
//  Created by inaniwaudon on 2025/03/05.
//

import Combine
import Foundation
import SwiftUI

enum OperationType {
    case llm
    case shell
    case settings
    case exit
}

class OperationState: ObservableObject {
    @Published var input: String = ""
    
    private(set) var type: OperationType = .llm
    private(set) var content: String = ""
    private(set) var command: String?
    private var cancellables = Set<AnyCancellable>()
    
    var appliesClipboard: Bool {
        type == .llm && (content.last == "：" || content.last == ":")
    }
    
    init() {
        $input
            .sink { newValue in
                self.onInputChanged(value: newValue)
            }
        .store(in: &cancellables)
    }

    func onInputChanged(value: String) {
        let trimed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let isSettings = trimed == "/settings"
        if isSettings || trimed == "/exit" {
            type = isSettings ? .settings : .exit
            content = ""
            command = nil
            return
        }
        
        // /command
        if let match = trimed.firstMatch(of: /^\/([a-zA-Z]+)/)?.1,
           let value = Settings.shortcuts[String(match)] {
            // 定義された値に #1 が存在する場合は入力値に置換
            let start = trimed.index(trimed.startIndex, offsetBy: match.count + 1)
            let end = trimed.endIndex
            let extracted = trimed[start..<end].trimmingCharacters(in: .whitespacesAndNewlines)
            command = value.replacing("#1", with: extracted)
        } else {
            command = nil
        }
        let commandApplied = (command ?? trimed).trimmingCharacters(in: .whitespacesAndNewlines)

        // /llm
        if commandApplied.starts(with: "/llm ") {
            type = .llm
            content = commandApplied.replacing(/^\/llm\ /, with: "")
            return
        }
        // /sh
        if commandApplied.starts(with: "/sh ") {
            type = .shell
            content = commandApplied.replacing(/^\/sh\ /, with: "")
            return
        }
        if Settings.isDefaultLLM {
            type = .llm
            content = commandApplied
            return
        }
        type = .llm
        content = commandApplied
    }
    
    func run(clipboardState: ClipboardState, trimedClipboard: String) {
        switch type {
        case .settings:
            clipboardState.response = "Opening settings..."
            NSWorkspace.shared.open(Settings.url)
        case .exit:
            NSApp.terminate(self)
        case .llm:
            let withClipboard = "\(content)\n\(trimedClipboard)"
            clipboardState.response = "Inquiring with LLM..."
            Request.fetchOpenAIApi(content: withClipboard) { output in
                DispatchQueue.main.async {
                    clipboardState.response = output.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        case .shell:
            clipboardState.response = "Interacting with shell..."
            DispatchQueue.main.async {
                Shell.shared.inputToShell(command: self.content)
            }
        }
    }
}
