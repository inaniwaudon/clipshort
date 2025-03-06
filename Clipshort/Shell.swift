//
//  Shell.swift
//  Shortcut
//
//  Created by inaniwaudon on 2025/03/05.
//

import Foundation

class Shell {
    static let shared = Shell()
    
    var delegate: ShellDelegate?
    private var process = Process()
    private var inputPipe = Pipe()
    private var outputPipe = Pipe()
    private var outputs = false
    
    init() {
        process = Process()
        inputPipe = Pipe()
        outputPipe = Pipe()

        process.launchPath = Settings.shellBin
        outputPipe.fileHandleForReading.readabilityHandler = { handle in
            if let output = String(data: handle.availableData, encoding: .utf8), !output.isEmpty {
                if self.outputs {
                    self.delegate?.completion(output: output)
                }
            }
        }
        process.standardInput = inputPipe
        process.standardOutput = outputPipe
        process.standardError = outputPipe
        
        do {
            try process.run()
        } catch {
            delegate?.completion(output: "Failed to start zsh: \(error)")
        }
        
        outputs = false
        inputToShell(command: Settings.shellInitial)
        outputs = true
    }
    
    func exit() {
        process.terminate()
    }
    
    func inputToShell(command: String) {
        let commandWithNewline = command + "\n"
        if let data = commandWithNewline.data(using: .utf8) {
            inputPipe.fileHandleForWriting.write(data)
        }
    }
}

protocol ShellDelegate {
    func completion(output: String)
}
