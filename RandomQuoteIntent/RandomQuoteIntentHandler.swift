//
//  RandomQuoteIntentHandler.swift
//  RandomQuoteIntent
//
//  Created by Nishant Taneja on 05/09/23.
//

import Foundation
import Intents

final class RandomQuoteIntentHandler: NSObject, RandomQuoteIntentHandling {
    func handle(intent: RandomQuoteIntent, completion: @escaping (RandomQuoteIntentResponse) -> Void) {
        NFCoreDataService.shared.fetchGroups { result in
            switch result {
            case .success(let groups):
                guard let quote = groups.filter({ $0.title == intent.group }).first?.items.randomElement()?.title else {
                    completion(.success(quote: "No Quotes Found."))
                    return
                }
                completion(.success(quote: quote))
            case .failure(let failure):
                completion(.success(quote: failure.localizedDescription))
            }
        }
    }
}
