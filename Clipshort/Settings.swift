//
//  Settings.swift
//  Shortcut
//
//  Created by inaniwaudon on 2025/03/04.
//

import Cocoa
import Foundation

struct Settings {
    static let url = URL(fileURLWithPath: path)
    
    private static let path = NSString(string: "~/.clipshortrc.json").expandingTildeInPath
    private static var config: Config?
    
    private static let defaultDefault = "llm"
    private static let defaultLlmProvider = "openai"
    private static let defaultLlmModel = "openai/gpt-4o-mini"
    private static let defaultSystemPrompt = "以下の質問に簡潔に回答してください"
    private static let defaultShellBin = "/bin/zsh"
    private static let defaultShellInitial = "source ~/.zshrc"
    private static let defaultWidth: Float = 250
    
    static var isDefaultLLM: Bool {
        return (config?.defaultMode ?? defaultDefault) == "llm"
    }
    static var llmProvider: String {
        return config?.llm.provider ?? defaultLlmProvider
    }
    static var llmApiKey: String {
        return config?.llm.apiKey ?? ""
    }
    static var llmModel: String {
        return config?.llm.model ?? defaultLlmModel
    }
    static var formattedModelName: String {
        let model = llmModel
        // OpenAIプロバイダーの場合、"openai/gpt-4o" から "gpt-4o" のようにプロバイダー部分を削除
        if llmProvider == "openai" && model.contains("/") {
            if let index = model.firstIndex(of: "/") {
                return String(model[model.index(after: index)...])
            }
        }
        return model
    }
    static var systemPrompt: String {
        return config?.llm.systemPrompt ?? defaultSystemPrompt
    }
    static var shellBin: String {
        return config?.shell.bin ?? defaultShellBin
    }
    static var shellInitial: String {
        return config?.shell.initial ?? defaultShellInitial
    }
    static var shortcuts: [String: String] {
        return config?.shortcut ?? [:]
    }
    static var width: Float {
        return config?.width ?? defaultWidth
    }

    static func initialize() {
        if !FileManager.default.fileExists(atPath: path) {
            newFile()
        }
        read()
    }
    
    private static func newFile() {
        let config = Config(
            defaultMode: "llm",
            llm: ConfigLLM(apiKey: "YOUR_API_KEY", model: defaultLlmModel, systemPrompt: defaultSystemPrompt, provider: defaultLlmProvider),
            shell: ConfigShell(bin: defaultShellBin, initial: defaultShellInitial),
            shortcut: [:],
            width: defaultWidth)
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            try encoder.encode(config).write(to: url, options: .atomic)
        } catch {
            let alert = NSAlert()
            alert.messageText = "エラー"
            alert.informativeText = "設定ファイルの作成に失敗しました。権限を確認してください。"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "再試行")
            alert.buttons[0].tag = NSApplication.ModalResponse.OK.rawValue
            alert.addButton(withTitle: "終了")
            alert.buttons[1].tag = NSApplication.ModalResponse.stop.rawValue
            let result = alert.runModal()
            if result == .OK {
                initialize()
            } else {
                NSApplication.shared.terminate(self)
            }
        }
    }
    
    private static func read() {
        do {
            let data = try Data(contentsOf: url)
            config = try JSONDecoder().decode(Config.self, from: data)
        } catch {
            let alert = NSAlert()
            alert.messageText = "エラー"
            alert.informativeText = "設定ファイルの読込に失敗しました。~/.clipshortrc.json を確認するか、一度削除してください。"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "再試行")
            alert.buttons[0].tag = NSApplication.ModalResponse.OK.rawValue
            alert.addButton(withTitle: "終了")
            alert.buttons[1].tag = NSApplication.ModalResponse.stop.rawValue
            let result = alert.runModal()
            if result == .OK {
                initialize()
            } else {
                NSApplication.shared.terminate(self)
            }
        }
    }
}

struct Config: Codable {
    let defaultMode: String
    let llm: ConfigLLM
    let shell: ConfigShell
    let shortcut: [String: String]
    let width: Float
}

struct ConfigLLM: Codable {
    let apiKey: String
    let model: String
    let systemPrompt: String
    let provider: String? // "openai" or "openrouter"
}

struct ConfigShell: Codable {
    let bin: String
    let initial: String
}
