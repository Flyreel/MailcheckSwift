//
//  Mailcheck.swift
//  Flyreel
//
//  Created by Bryce Hammond on 8/3/16.
//  Licensed under the MIT License.
//

import Foundation

//Returned form check functions
public struct MailcheckResult {
    public var valid: Bool //True if the e-mail is a valid format
    public var suggestion: MailcheckSuggestion?
    
    public init(valid: Bool, suggestion: MailcheckSuggestion) {
        self.valid = valid
        self.suggestion = suggestion
    }
    
    public init(valid: Bool) {
        self.valid = valid
    }
}

//Returned from suggest functions
public struct MailcheckSuggestion {
    public var address: String //the name address of the e-mail (e.g. frank in frank@whitehouse.gov)
    public var domain: String //the suggested correction of domain (e.g. whitehouse.gov if whitehouse.gv is entered)
    public var full: String //the full address that is being suggested (e.g. frank@whitehouse.gov)
    
    public init(address: String, domain: String, full: String) {
        self.address = address
        self.domain = domain
        self.full = full
    }
}

public class Mailcheck {
    
    public static let defaultDomains = ["yahoo.com", "google.com", "hotmail.com", "gmail.com", "me.com", "aol.com", "mac.com", "live.com", "comcast.net", "googlemail.com", "msn.com", "hotmail.co.uk", "yahoo.co.uk", "facebook.com", "verizon.net", "sbcglobal.net", "att.net", "gmx.com", "mail.com"]
    
    public static let defaultTopLevelDomains = ["co.uk", "com", "net", "org", "info", "edu", "gov", "mil"]
    
    public static var threshold = 3
    
    public class func check(_ email: String, extraDomains: [String], extraTopLevelDomains: [String]) -> MailcheckResult {
        return self.check(email, domains: defaultDomains + [], topLevelDomains: defaultTopLevelDomains + [])
    }
    
    public class func check(_ email: String, domains: [String] = defaultDomains, topLevelDomains: [String] = defaultTopLevelDomains) -> MailcheckResult {
        let isValidEmail = self.isEmail(string: email)
        if let suggestion = self.suggest(email, domains: domains, topLevelDomains: topLevelDomains) {
            return MailcheckResult(valid: isValidEmail, suggestion: suggestion)
        } else {
            return MailcheckResult(valid: isValidEmail)
        }
    }
    
    public class func suggest(_ email: String, extraDomains: [String], extraTopLevelDomains: [String]) -> MailcheckSuggestion? {
        return self.suggest(email, domains: defaultDomains + extraDomains, topLevelDomains: defaultTopLevelDomains + extraTopLevelDomains)
    }
    
    public class func suggest(_ email: String, domains: [String] = defaultDomains, topLevelDomains: [String] = defaultTopLevelDomains) -> MailcheckSuggestion? {
        
        if let emailComponents = self.splitEmail(email.lowercased()) {
            if let closestDomain = self.findClosestDomain(emailComponents.domain, domains: domains), closestDomain != emailComponents.domain {
                return MailcheckSuggestion(address: emailComponents.address, domain: closestDomain, full: "\(emailComponents.address)@\(closestDomain)")
            } else if let closestTopLevelDomain = self.findClosestDomain(emailComponents.topLevelDomain, domains: topLevelDomains) {
                if emailComponents.domain.count > 0 && closestTopLevelDomain != emailComponents.topLevelDomain {
                    let domain = emailComponents.domain
                    var domainParts = domain.components(separatedBy: ".")
                    domainParts.removeLast()
                    domainParts.append(closestTopLevelDomain)
                    let suggestedDomain = domainParts.joined(separator: ".")
                    return MailcheckSuggestion(address: emailComponents.address, domain: suggestedDomain, full: "\(emailComponents.address)@\(suggestedDomain)")
                }
            }
        }
        
        return nil
    }
    
    internal class func findClosestDomain(_ domain: String, domains: [String]) -> String? {
        
        var distance = 0
        var minDistance = 99
        var closestDomain: String?
        
        for targetDomain in domains {
            if domain == targetDomain {
                return domain
            }
            
            distance = self.sift3Distance(firstString: domain, secondString: targetDomain)
            if distance < minDistance {
                minDistance = distance
                closestDomain = targetDomain
            }
        }
        
        if let foundDomain = closestDomain, minDistance <= self.threshold {
            return foundDomain
        }
        
        return nil
    }
    
    private class func sift3Distance(firstString: String, secondString: String) -> Int {
        // sift3: http://siderite.blogspot.com/2007/04/super-fast-and-accurate-string-distance.html
        
        if firstString.count == 0 {
            if secondString.count == 0 {
                return 0
            } else {
                return secondString.count
            }
        }
        
        if secondString.count == 0 {
            return firstString.count
        }
        
        var characterIndex = 0
        var offset1 = 0
        var offset2 = 0
        var lcs = 0
        let maxOffset = 5
        
        while((characterIndex + offset1 < firstString.count) && (characterIndex + offset2 < secondString.count)) {
            
            let stringOneCurrentCharacter = firstString[characterIndex + offset1]
            let stringTwoCurrentCharacter = secondString[characterIndex + offset2]
            if stringOneCurrentCharacter == stringTwoCurrentCharacter {
                lcs += 1
            } else {
                offset1 = 0
                offset2 = 0
                for offset in 0..<maxOffset {
                    let currentOffset = characterIndex + offset
                    if (currentOffset < firstString.count) &&
                        (firstString[currentOffset] == secondString[characterIndex]) {
                        offset1 = offset
                        break
                    }
                    
                    if (currentOffset < secondString.count) &&
                        (secondString[currentOffset] == firstString[characterIndex]) {
                        offset2 = offset
                        break
                    }
                }
            }
            characterIndex += 1
        }
        
        return (firstString.count + secondString.count) / 2 - lcs
    }
    
    private class func splitEmail(_ email: String) -> EmailComponents? {
        
        var parts = email.components(separatedBy: "@")
        
        if parts.count < 2 {
            return nil
        }
        
        for part in parts {
            if part == "" {
                return nil
            }
        }
        
        let domain = parts.last!
        parts.removeLast()
        let domainParts = domain.components(separatedBy: ".")
        var tld = ""
        
        if domainParts.count == 0 {
            // the address does not have a top-level domain
            return nil
        } else if domainParts.count == 1 {
            // the address has only a top-level domain (valid under RFC)
            tld = domainParts.first!
        } else {
            // the address has a domain and a top-level domain
            tld = domainParts[1..<domainParts.endIndex].joined(separator: ".")
        }
        
        return EmailComponents(topLevelDomain: tld, domain: domain, address: parts.joined(separator: "@"))
    }
    
    private class func isEmail(string: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,20}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: string)
        return result
    }
    
}

internal struct EmailComponents {
    let topLevelDomain: String
    let domain: String
    let address: String
    
    init(topLevelDomain: String, domain: String, address: String) {
        self.topLevelDomain = topLevelDomain
        self.domain = domain
        self.address = address
    }
}

//MARK: Extensions for string subscripting
private extension StringProtocol {
    
    var string: String { return String(self) }
    
    subscript(offset: Int) -> Element {
        return self[index(startIndex, offsetBy: offset)]
    }
    
    subscript(_ range: CountableRange<Int>) -> SubSequence {
        return prefix(range.lowerBound + range.count)
            .suffix(range.count)
    }
    subscript(range: CountableClosedRange<Int>) -> SubSequence {
        return prefix(range.lowerBound + range.count)
            .suffix(range.count)
    }
    
    subscript(range: PartialRangeThrough<Int>) -> SubSequence {
        return prefix(range.upperBound.advanced(by: 1))
    }
    subscript(range: PartialRangeUpTo<Int>) -> SubSequence {
        return prefix(range.upperBound)
    }
    subscript(range: PartialRangeFrom<Int>) -> SubSequence {
        return suffix(Swift.max(0, count - range.lowerBound))
    }
}

private extension Substring {
    var string: String { return String(self) }
}

