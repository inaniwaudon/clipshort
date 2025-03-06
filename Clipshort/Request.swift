//
//  Request.swift
//  Shortcut
//
//  Created by inaniwaudon on 2025/03/04.
//

import Foundation

struct Request {
    static func fetchOpenAIApi(content: String, completion: @escaping (String) -> Void) {
        // リクエストを準備
        let endpoint = "https://api.openai.com/v1/chat/completions"
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(Settings.llmApiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "messages": [
                [
                    "role": "system",
                    "content": Settings.systemPrompt,
                ],
                [
                    "role": "user",
                    "content": content,
                ],
            ],
            "model": Settings.llmModel,
        ]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
            request.httpBody = jsonData
        } catch {
            completion("Failed to Serialize JSON")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                completion("Failed to fetch API")
                return
            }
            guard let data = data else {
                completion("Failed to fetch API")
                return
            }
            do {
                // レスポンスデータをJSONとして解析
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let choices = jsonResponse?["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    completion(content)
                } else {
                    completion("Invalid request. Please check llm.apiKey or llm.model.")
                }
            } catch {
                completion("Failed to fetch API")
            }
        }
        task.resume()
    }
}
