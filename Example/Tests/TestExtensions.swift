//
//  TestExtensions.swift
//  MailcheckSwift_Tests
//
//  Created by Bryce Hammond on 11/17/18.
//

import Foundation
@testable import MailcheckSwift

extension EmailComponents : Equatable {
    public static func == (lhs: EmailComponents, rhs: EmailComponents) -> Bool {
        return lhs.topLevelDomain == rhs.topLevelDomain &&
            lhs.domain == rhs.domain &&
            lhs.address == rhs.address
    }
}

extension  MailcheckSuggestion : Equatable {
    public static func == (lhs: MailcheckSuggestion, rhs: MailcheckSuggestion) -> Bool {
        return lhs.address == rhs.address &&
                lhs.domain == rhs.domain &&
                lhs.full == rhs.full
    }
}

