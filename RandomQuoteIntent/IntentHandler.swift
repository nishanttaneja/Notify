//
//  IntentHandler.swift
//  RandomQuoteIntent
//
//  Created by Nishant Taneja on 05/09/23.
//

import Intents

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        switch intent {
        case is RandomQuoteIntent:
            return RandomQuoteIntentHandler()
        default:
            return self
        }
    }
    
}
