//
//  Suggestion.swift
//
//
//  Created by Anton Atanasov on 16.05.24.
//

import Foundation

public struct Suggestion: Codable, Identifiable, Hashable {
    
    public var id: String
    public let label: String
    public let value: String
    
    public init(id: String, label: String, value: String) {
        self.id = id
        self.label = label
        self.value = value
    }
    
    public init(id: String, label: String) {
        self.init(id: id, label: label, value: label)
    }
}


