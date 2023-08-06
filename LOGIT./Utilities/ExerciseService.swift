//
//  ExerciseCreator.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 04.08.23.
//

import Combine
import OpenAIKit
import OSLog
import Foundation

class ExerciseService {
    
    enum Error: Swift.Error {
        case emptyResponse, jsonParsingError, keysNotMatching
    }
    
    let database: Database
    
    init(database: Database) {
        self.database = database
    }
    
    // MARK: - Prompts
    
    let createExercisePrompt = """
        For the following exercise name, return a JSON object that includes the primary muscle Group for that exercise.
        enum MuscleGroup {
        case \((MuscleGroup.allCases.map { $0.rawValue }).joined(separator: ", "))
        }
        Return JSON of form:
        exercise = {
        name: string,
        muscleGroup: MuscleGroup
        }
    """
    
    lazy var getMatchingExercisePrompt = """
        For the following exercise names, decide if they are already in this list of exercises:
        \(database.getExercises().compactMap({ $0.name }).joined(separator: ", "))
        The names don't have to match, they should just mean the same exercise.
        Also match the exercises, if the name is in a different language than the existing exercises name.
        Return the following JSON: { matches: [{ name: String, existingExerciseName: String | None }] }
    """
    
    // MARK: - Public Methods
    
    func matchExercisesToExisting(_ exerciseNames: [String]) -> AnyPublisher<[String:Exercise?], Swift.Error> {
        let systemMessage = AIMessage(role: .system, content: getMatchingExercisePrompt)
        let userMessage = AIMessage(role: .user, content: exerciseNames.joined(separator: ", "))
        let publisher = Future<String, Swift.Error> { promise in
            OpenAIKit(apiToken: OPENAI_API_KEY).sendChatCompletion(
                newMessage: userMessage,
                previousMessages: [systemMessage],
                model: .gptV3_5(.gptTurbo),
                maxTokens: nil,
                temperature: 0
            ) { result in
                switch result {
                case .success(let aiResult):
                    if let text = aiResult.choices.first?.message?.content {
                        promise(.success(text))
                    } else {
                        promise(.failure(Error.emptyResponse))
                    }
                case .failure(let error):
                    promise(.failure(error))
                }
                
            }
        }
        .flatMap { text -> AnyPublisher<Data, Swift.Error> in
            return TextProcessing.extractJsonDataFromString(text)
        }
        .flatMap { jsonData -> AnyPublisher<[String:Exercise?], Swift.Error> in
            return Future<[String:Exercise?], Swift.Error> { [unowned self] promise in
                guard let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
                    return promise(.failure(Error.jsonParsingError))
                }
                
                guard let matchesKey = findKey("matches", in: json)
                else {
                    return promise(.failure(Error.keysNotMatching))
                }
                
                let matches = json[matchesKey] as? [[String:Any]]
                
                var result = [String:Exercise?]()
                matches?.forEach { match in
                    guard let exerciseNameKey = findKey("name", in: match),
                          let existingExerciseNameKey = findKey("existingExerciseName", in: match)
                    else {
                        return promise(.failure(Error.keysNotMatching))
                    }
                    
                    guard let exerciseName = match[exerciseNameKey] as? String else { return }
                    guard let existingExerciseName = match[existingExerciseNameKey] as? String else { return }
                    
                    let existingExercise = database.getExercises(withNameIncluding: existingExerciseName).first
                    result[exerciseName] = existingExercise
                }
                
                promise(.success(result))
            }
            .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
        
        return publisher
    }
    
    func createExercise(for name: String) -> AnyPublisher<Exercise, Swift.Error> {
        let systemMessage = AIMessage(role: .system, content: createExercisePrompt)
        let userMessage = AIMessage(role: .user, content: name)
        
        let publisher = Future<String, Swift.Error> { promise in
            OpenAIKit(apiToken: OPENAI_API_KEY).sendChatCompletion(
                newMessage: userMessage,
                previousMessages: [systemMessage],
                model: .gptV3_5(.gptTurbo),
                maxTokens: nil,
                temperature: 0
            ) { result in
                    switch result {
                    case .success(let aiResult):
                        if let text = aiResult.choices.first?.message?.content {
                            promise(.success(text))
                        } else {
                            promise(.failure(Error.emptyResponse))
                        }
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
        }
        .flatMap { text -> AnyPublisher<Data, Swift.Error> in
            return TextProcessing.extractJsonDataFromString(text)
        }
        .flatMap { [unowned self] jsonData -> AnyPublisher<Exercise, Swift.Error> in
            return createExercise(from: jsonData)
        }
        .eraseToAnyPublisher()
        
        return publisher
    }
    
    // MARK: - Private Helper Methods
    
    // Helper function to find a matching key, checking if the key contains the property name
    private func findKey(_ propertyName: String, in dictionary: [String: Any]) -> String? {
        return dictionary.keys.first(where: { $0.lowercased().contains(propertyName.lowercased()) })
    }
    
    private func createExercise(from jsonData: Data) -> AnyPublisher<Exercise, Swift.Error> {
        let publisher = Future<Exercise, Swift.Error> { [unowned self] promise in
            guard let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
                promise(.failure(Error.jsonParsingError))
                return
            }
            
            guard let nameKey = findKey("name", in: json),
                  let muscleGroupKey = findKey("muscleGroup", in: json)
            else {
                promise(.failure(Error.keysNotMatching))
                return
            }
            
            let name = json[nameKey] as? String ?? ""
            let muscleGroup = MuscleGroup(rawValue: json[muscleGroupKey] as? String ?? "") ?? .chest
            
            let exercise = database.newExercise(name: name, muscleGroup: muscleGroup)
            
            promise(.success(exercise))
        }
        
        return AnyPublisher(publisher)
    }
    
}
