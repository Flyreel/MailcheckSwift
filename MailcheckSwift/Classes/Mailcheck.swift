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
    
    private static let defaultDomains = ["yahoo.com", "google.com", "hotmail.com", "gmail.com", "me.com", "aol.com", "mac.com", "live.com", "comcast.net", "googlemail.com", "msn.com", "hotmail.co.uk", "yahoo.co.uk", "facebook.com", "verizon.net", "sbcglobal.net", "att.net", "gmx.com", "mail.com"]
    
    private static let defaultTopLevelDomains = ["co.uk", "com", "net", "org", "info", "edu", "gov", "mil"]
    
    public static var threshold = 3
    
    public class func check(email: String, extraDomains: [String], extraTopLevelDomains: [String]) -> MailcheckResult {
        return self.check(email, domains: defaultDomains + [], topLevelDomains: defaultTopLevelDomains + [])
    }
    
    public class func check(email: String, domains: [String] = defaultDomains, topLevelDomains: [String] = defaultTopLevelDomains) -> MailcheckResult {
        if let suggestion = self.suggest(email, domains: domains, topLevelDomains: topLevelDomains) {
            return MailcheckResult(valid: email.isEmail, suggestion: suggestion)
        } else {
            return MailcheckResult(valid: email.isEmail)
        }
    }
    
    public class func suggest(email: String, extraDomains: [String], extraTopLevelDomains: [String]) -> MailcheckSuggestion? {
        return self.suggest(email, domains: defaultDomains + extraDomains, topLevelDomains: defaultTopLevelDomains + extraTopLevelDomains)
    }
    
    public class func suggest(email: String, domains: [String] = defaultDomains, topLevelDomains: [String] = defaultTopLevelDomains) -> MailcheckSuggestion? {
        
        if let emailComponents = self.splitEmail(email.lowercaseString) {
            if let closestDomain = self.findClosestDomain(emailComponents.domain, domains: domains) where closestDomain != emailComponents.domain {
                return MailcheckSuggestion(address: emailComponents.address, domain: closestDomain, full: "\(emailComponents.address)@\(closestDomain)")
            } else if let closestTopLevelDomain = self.findClosestDomain(emailComponents.topLevelDomain, domains: topLevelDomains) {
                if emailComponents.domain.length > 0 && closestTopLevelDomain != emailComponents.topLevelDomain {
                    let domain = emailComponents.domain
                    var domainParts = domain.componentsSeparatedByString(".")
                    domainParts.removeLast()
                    domainParts.append(closestTopLevelDomain)
                    let suggestedDomain = domainParts.joinWithSeparator(".")
                    return MailcheckSuggestion(address: emailComponents.address, domain: suggestedDomain, full: "\(emailComponents.address)@\(suggestedDomain)")
                }
            }
        }
        
        return nil
    }
    
    private class func findClosestDomain(domain: String, domains: [String]) -> String? {
        
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
        
        if let foundDomain = closestDomain where minDistance <= self.threshold {
            return foundDomain
        }
        
        return nil
    }
    
    private class func sift3Distance(firstString firstString: String, secondString: String) -> Int {
        // sift3: http://siderite.blogspot.com/2007/04/super-fast-and-accurate-string-distance.html
        
        if firstString.length == 0 {
            if secondString.length == 0 {
                return 0
            } else {
                return secondString.length
            }
        }
        
        if secondString.length == 0 {
            return firstString.length
        }
        
        var characterIndex = 0
        var offset1 = 0
        var offset2 = 0
        var lcs = 0
        let maxOffset = 5
        
        while((characterIndex + offset1 < firstString.length) && (characterIndex + offset2 < secondString.length)) {
            
            let stringOneCurrentCharacter = firstString[firstString.startIndex.advancedBy(characterIndex + offset1)]
            let stringTwoCurrentCharacter = secondString[secondString.startIndex.advancedBy(characterIndex + offset2)]
            if stringOneCurrentCharacter == stringTwoCurrentCharacter {
                lcs += 1
            } else {
                offset1 = 0
                offset2 = 0
                for offset in 0..<maxOffset {
                    let currentOffset = characterIndex + offset
                    if (currentOffset < firstString.length) &&
                        (firstString[firstString.startIndex.advancedBy(currentOffset)] == secondString[secondString.startIndex.advancedBy(characterIndex)]) {
                        offset1 = offset
                        break
                    }
                    
                    if (currentOffset < secondString.length) &&
                        (secondString[secondString.startIndex.advancedBy(currentOffset)] == firstString[firstString.startIndex.advancedBy(characterIndex)]) {
                        offset2 = offset
                        break
                    }
                }
            }
            characterIndex += 1
        }
        
        return (firstString.length + secondString.length) / 2 - lcs
    }
    
    private class func splitEmail(email: String) -> EmailComponents? {
        
        var parts = email.componentsSeparatedByString("@")
        
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
        let domainParts = domain.componentsSeparatedByString(".")
        var tld = ""
        
        if domainParts.count == 0 {
            // the address does not have a top-level domain
            return nil
        } else if domainParts.count == 1 {
            // the address has only a top-level domain (valid under RFC)
            tld = domainParts.first!
        } else {
            // the address has a domain and a top-level domain
            tld = domainParts[1..<domainParts.endIndex].joinWithSeparator(".")
        }
        
        return EmailComponents(topLevelDomain: tld, domain: domain, address: parts.joinWithSeparator("@"))
    }
    
}

private struct EmailComponents {
    let topLevelDomain: String
    let domain: String
    let address: String
    
    init(topLevelDomain: String, domain: String, address: String) {
        self.topLevelDomain = topLevelDomain
        self.domain = domain
        self.address = address
    }
}

private extension String {
    var length: Int {
        return self.characters.count
    }
    
    var isEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,20}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluateWithObject(self)
        return result
    }
}
