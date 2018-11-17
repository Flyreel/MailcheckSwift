Pod::Spec.new do |s|
  s.name = 'MailcheckSwift'
  s.version = '0.2.0'
  s.license = 'MIT'
  s.summary = 'Swift implementation of Mailcheck (http://getmailcheck.org/). Suggest corrections for misspelled email addresses.'
  s.homepage = 'https://github.com/Flyreel/MailcheckSwift'
  s.authors = { 'Bryce Hammond' => 'bryce@flyreel.co' }
  s.source = { :git => 'https://github.com/Flyreel/MailcheckSwift.git', :tag => "#{s.version}" }

  s.swift_version = '4.2'
  s.ios.deployment_target = '8.0'

  s.source_files = 'MailcheckSwift/Classes/**/*'
end
