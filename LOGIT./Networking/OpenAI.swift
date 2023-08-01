//
//  OpenAI.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 01.08.23.
//

import Combine
import Foundation
import OSLog

struct OpenAI {
    
    static func makeGptRequest(prompt: String, maxTokens: Int = 1024) -> AnyPublisher<String, Error> {
        let url = URL(string: "https://api.openai.com/v1/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(OPENAI_API_KEY)", forHTTPHeaderField: "Authorization")

        let requestBody = ["model": "text-davinci-003",
                            "prompt": "\(prompt)",
                            "max_tokens": maxTokens] as [String: Any]
        let requestBodyData = try! JSONSerialization.data(withJSONObject: requestBody, options: [])
        request.httpBody = requestBodyData

        Logger().log("GPT Request with prompt: \n\(prompt)")

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    let responseStatus = (response as? HTTPURLResponse)?.statusCode ?? -1
                    Logger().error("GPT request failed with status \(responseStatus)")
                    throw NSError(domain: "GPT request failed with status \(responseStatus)", code: responseStatus, userInfo: nil)
                }
                return data
            }
            .tryMap { data -> [String: Any] in
                if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    return jsonResponse
                } else {
                    throw NSError(domain: "Error: JSON decoding failed", code: -1, userInfo: nil)
                }
            }
            .mapError { error -> Error in
                Logger().error("Error: \(error.localizedDescription)")
                return error
            }
            .tryMap { jsonResponse -> String in
                if let text = (jsonResponse["choices"] as? [[String: Any]])?.first?["text"] as? String {
                    Logger().log("Received GPT response text: \(text)")
                    return text
                } else {
                    throw NSError(domain: "Error: GPT response parsing failed", code: -1, userInfo: nil)
                }
            }
            .eraseToAnyPublisher()
    }

}
