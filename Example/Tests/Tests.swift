import Quick
import Nimble
@testable import MailcheckSwift

class MailcheckSpec: QuickSpec {
    override func spec() {
        describe("suggest") {
            
            let defaultDomains = ["yahoo.com", "google.com", "hotmail.com", "gmail.com", "me.com", "aol.com", "mac.com", "live.com", "comcast.net", "googlemail.com", "msn.com", "hotmail.co.uk", "yahoo.co.uk", "facebook.com", "verizon.net", "sbcglobal.net", "att.net", "gmx.com", "mail.com", "yahoo.com.tw"];
            let defaultTopLevelDomains = ["co.uk", "com", "net", "org", "info", "edu", "gov", "mil", "com.tw"];

            it("should return nil for a valid likely e-mail") {
                expect(Mailcheck.suggest("randomuser@gmail.com")).to(beNil())
            }
            
            it("should return nil for an invalid e-mail") {
                expect(Mailcheck.suggest("", domains: defaultDomains, topLevelDomains: defaultTopLevelDomains)).to(beNil())
                expect(Mailcheck.suggest("test@yahoo.com.tw", domains: defaultDomains, topLevelDomains: defaultTopLevelDomains)).to(beNil())
                expect(Mailcheck.suggest("test@", domains: defaultDomains, topLevelDomains: defaultTopLevelDomains)).to(beNil())
                expect(Mailcheck.suggest("test", domains: defaultDomains, topLevelDomains: defaultTopLevelDomains)).to(beNil())
            }
            
            it("should have a suggestion for possible mistyping") {
                expect(Mailcheck.suggest("test@emaildomain.co", domains: defaultDomains, topLevelDomains: defaultTopLevelDomains)?.domain) == "emaildomain.com"
                expect(Mailcheck.suggest("test@gmail.con", domains: defaultDomains, topLevelDomains: defaultTopLevelDomains)?.domain) == "gmail.com"
                expect(Mailcheck.suggest("test@gnail.con", domains: defaultDomains, topLevelDomains: defaultTopLevelDomains)?.domain) == "gmail.com"
                expect(Mailcheck.suggest("test@GNAIL.con", domains: defaultDomains, topLevelDomains: defaultTopLevelDomains)?.domain) == "gmail.com"
                expect(Mailcheck.suggest("test@#gmail.com", domains: defaultDomains, topLevelDomains: defaultTopLevelDomains)?.domain) == "gmail.com"
                expect(Mailcheck.suggest("test@comcast.com", domains: defaultDomains, topLevelDomains: defaultTopLevelDomains)?.domain) == "comcast.net"
                expect(Mailcheck.suggest("test@hotmail.con", domains: defaultDomains, topLevelDomains: defaultTopLevelDomains)?.domain) == "hotmail.com"
                expect(Mailcheck.suggest("test@hotmail.co", domains: defaultDomains, topLevelDomains: defaultTopLevelDomains)?.domain) == "hotmail.com"
                expect(Mailcheck.suggest("test@fabecook.com", domains: defaultDomains, topLevelDomains: defaultTopLevelDomains)?.domain) == "facebook.com"
                expect(Mailcheck.suggest("test@yajoo.com", domains: defaultDomains, topLevelDomains: defaultTopLevelDomains)?.domain) == "yahoo.com"
                expect(Mailcheck.suggest("test@randomsmallcompany.cmo", domains: defaultDomains, topLevelDomains: defaultTopLevelDomains)?.domain) == "randomsmallcompany.com"
                
            }
        }
    }
}
