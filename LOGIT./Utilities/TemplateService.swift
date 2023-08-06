//
//  TemplateService.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 01.08.23.
//

import Combine
import OpenAIKit
import OSLog
import SwiftUI

class TemplateService: ObservableObject {
    
    enum Error: Swift.Error {
        case emptyResponse, invalidData, invalidImage, jsonParsingError, keysNotMatching, noRecognizedText
    }
    
    private let database = Database.shared
    private lazy var exerciseCreator = ExerciseService(database: database)
    
    private var cancellables = [AnyCancellable]()
    
    // MARK: - Prompts
    
    private let systemPrompt = """
        You should extract the workout from the following text. You only extract exercises that are actual exercises. If an entry is not specifically mentioned, you use the default.
        Repetitions and sets might not be exactly called that so you will have to infer if possible.
        Also make sure the the workout name makes sense, otherwise change it accordingly.
        The result should be a JSON looking like this:
        Workout = {
            name: string = "",
            exercises: [{
                name: string = "",
                sets: [{
                    repetitions: integer = 0,
                    weight: integer = 0
                }]
            }]
        }
    """
    
    // MARK: - Public Methods
    
    func createTemplate(from uiImage: UIImage) -> AnyPublisher<Template, Swift.Error> {
        return TextProcessing.readText(from: uiImage)
            .flatMap { recognizedText -> AnyPublisher<String, Swift.Error> in
                guard let text = recognizedText else {
                    return Fail(error: Error.noRecognizedText).eraseToAnyPublisher()
                }
                return Just(text).setFailureType(to: Swift.Error.self).eraseToAnyPublisher()
            }
            .flatMap { [unowned self] text -> AnyPublisher<String, Swift.Error> in
                return generateTemplateJSONText(from: text)
            }
            .flatMap { text -> AnyPublisher<Data, Swift.Error> in
                return TextProcessing.extractJsonDataFromString(text)
            }
            .flatMap { [unowned self] jsonData -> AnyPublisher<Template, Swift.Error> in
                return createTemplate(from: jsonData)
            }
                .eraseToAnyPublisher()
    }
    
    // MARK: - Private Helper Methods
    
    private func generateTemplateJSONText(from text: String) -> AnyPublisher<String, Swift.Error> {
        let systemMessage = AIMessage(role: .system, content: systemPrompt)
        let userMessage = AIMessage(role: .user, content: text)
        
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
        
        return AnyPublisher(publisher)
    }
    
    private func createTemplate(from jsonData: Data) -> AnyPublisher<Template, Swift.Error> {
        // Helper function to find a matching key, checking if the key contains the property name
        func findKey(_ propertyName: String, in dictionary: [String: Any]) -> String? {
            return dictionary.keys.first(where: { $0.lowercased().contains(propertyName.lowercased()) })
        }
        
        return Future<Template, Swift.Error> { [unowned self] promise in
            guard let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
                promise(.failure(Error.jsonParsingError))
                return
            }
            
            guard let nameKey = findKey("name", in: json) ?? findKey("title", in: json),
                  let setGroupsKey = findKey("exercises", in: json)
            else {
                promise(.failure(Error.keysNotMatching))
                return
            }
            
            let name = json[nameKey] as? String ?? ""
            let template = database.newTemplate(name: name)
            database.flagAsTemporary(template)
            
            let setGroupsJSON = json[setGroupsKey] as? [[String:Any]]
            
            let setGroupPublishers = setGroupsJSON?.map { setGroupJSON -> AnyPublisher<(), Swift.Error> in
                guard let exerciseNameKey = findKey("name", in: setGroupJSON),
                      let setsKey = findKey("sets", in: setGroupJSON)
                else {
                    return Fail(error: Error.keysNotMatching).eraseToAnyPublisher()
                }
                
                guard let exerciseName = setGroupJSON[exerciseNameKey] as? String else {
                    return Fail(error: Error.keysNotMatching).eraseToAnyPublisher()
                }

                return createOrGetExistingExercise(for: exerciseName)
                    .flatMap { [unowned self] exercise -> AnyPublisher<(), Swift.Error> in
                        let setGroup = database.newTemplateSetGroup(createFirstSetAutomatically: false, exercise: exercise, template: template)
                        
                        let setsJSON = setGroupJSON[setsKey] as? [[String:Any]]
                        setsJSON?.forEach { setJSON in
                            guard let repetitionsKey = findKey("repetitions", in: setJSON),
                                  let weightKey = findKey("weight", in: setJSON)
                            else {
                                return
                            }
                            
                            let repetitions = setJSON[repetitionsKey] as? Int ?? 0
                            let weight = setJSON[weightKey] as? Int ?? 0
                            
                            database.newTemplateStandardSet(repetitions: repetitions, weight: weight, setGroup: setGroup)
                        }
                        
                        return Just(())
                            .setFailureType(to: Swift.Error.self)
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            } ?? []

            // Wait until all exercises have been created or gotten, then complete the promise.
            Publishers.MergeMany(setGroupPublishers)
                .collect()
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        promise(.success(template))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }, receiveValue: { _ in })
                .store(in: &cancellables)
        }
        .eraseToAnyPublisher()
    }
    
    private func createOrGetExistingExercise(for name: String) -> AnyPublisher<Exercise, Swift.Error> {
        if let existingExercise = database.getExercises(withNameIncluding: name).first {
            return Just(existingExercise)
                .setFailureType(to: Swift.Error.self)
                .eraseToAnyPublisher()
        } else {
            return exerciseCreator.createExercise(for: name)
                .handleEvents(receiveOutput: { [unowned self] newExercise in
                    database.flagAsTemporary(newExercise)
                })
                .eraseToAnyPublisher()
        }
    }

    
}
