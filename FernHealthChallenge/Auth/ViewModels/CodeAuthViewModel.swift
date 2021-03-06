//
//  AuthViewModel.swift
//  FernHealthChallenge
//
//  Created by Arturo Reyes on 6/20/20.
//  Copyright © 2020 Arturo Reyes. All rights reserved.
//

import Foundation
import Combine

/// An enum for the possible outputs from different codes where the HTTURLResponse.statusCode == rawValue
enum CodeValue: Int {
    // Code is valid
    case valid = 200
    // Code is not recognized
    case notRecognized = 404
    // Code for when the program is full
    case full = 400
    
    // The localized string key of the error description to be shown to the user for each code value
    var descriptionKey: String {
        switch self {
        case .notRecognized  : return "invalid_code_message"
        case .full           : return "full_program_message"
        default: return ""
        }
    }
}

/// The ViewModel for the CodeValidatorViewController
final class CodeAuthViewModel {
    
    // The code string input by the user
    @Published var code: String = ""
    // The code value generated by the code string
    @Published private(set) var codeValue: CodeValue?
    
    // The network request subscriber completion closure
    var didCompleteRequest: ((Subscribers.Completion<Error>) -> Void)?
    
    // Link the publisher life span to the viewModel's
    private var token: AnyCancellable?
    
    // The code validator service that converts the code string into a code value
    let codeAuthenticator: CodeAuthenticator
    
    
    init(codeValidator: CodeAuthenticator) {
        self.codeAuthenticator = codeValidator
    }
    
    /// Athenticate the code with the injected code authenticator
    func authenticate() {
        guard let completion = didCompleteRequest else { return }
        
        token = codeAuthenticator.authenticate(code).sink(
            receiveCompletion: completion,
            receiveValue: { [weak self] value in
                guard let self = self else { return }
                guard let value = value else { return }
                self.codeValue = value
            })
        
    }
}
