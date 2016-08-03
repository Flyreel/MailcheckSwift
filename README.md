Mailcheck - Swift
====================

The Swift library that suggests a right domain when your users misspell it in an email address. See the original at https://github.com/mailcheck/mailcheck.

When your user types in "user@hotnail.con", Mailcheck will suggest "user@hotmail.com".

Mailcheck will offer up suggestions for top level domains too, and suggest ".com" when a user types in "user@hotmail.cmo".

Usage
-----

```Swift
import MailcheckSwift
let result: MailcheckSuggestion? = Mailcheck.suggest("test@hotnail.com")
```

Result will contain nil if the domain appears to be valid.
Otherwise the suggestion will be a MailcheckSuggestion struct that will contain the following fields:
```Swift
address: String //e.g. "test"
domain: String  //e.g. "hotmail.com",
full: String    //e.g "test@hotmail.com"
```

Customize maximum edit distance
----------

You can customize the maximum edit distance. For instance with a threshold of 2:

```Swift
Mailcheck.threshold = 2
Mailcheck.check("bhammond@gmailll.com")
````

will return a suggestion of "bhammond@gmail.com". With a threshold of 1 no suggestion would be returned for this case. The default value is 3.

Checking if an e-mail is valid
----------

Checks to see if an e-mail is valid format while also returning a suggestion

```Swift
import MailcheckSwift
let result = Mailcheck.check("test@hotnail.com")
```

Result will be a MailcheckResult struct with the following fields
```Swift
valid: Bool //true or false
suggestion: MailcheckSuggestion? // e.g. MailcheckSuggestion(address: "test", domain: "hotmail.com", full: "test@hotmail.com")
```

Checking against additional domains
----------

Supply your own domain lists:
```Swift
let result: MailcheckResult = Mailcheck.check("test@mydomain.co", domains: ["mydomain.co"], topLevelDomains: ["co"])
```

Or add to the default list:
```Swift
let result: MailcheckResult = Mailcheck.check:@"test@mydomain.co" extraDomains:["mydomain.co"] extraTopLevelDomains:["co"]];
```

Maintainers
-------

- Bryce Hammond, [@brycehammond](http://github.com/brycehammond). Author.

License
-------

Licensed under the MIT License.
Swift implementation of Mailcheck (http://getmailcheck.org/)

Thanks and References
-------

This project was heavily influenced by the Objective-C implementation of Mailcheck (https://github.com/mailcheck/mailcheck-objectivec)
