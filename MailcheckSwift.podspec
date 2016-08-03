Pod::Spec.new do |s|
  s.name = 'MailcheckSwift'
  s.version = '0.1'
  s.license = 'MIT'
  s.summary = 'Swift implementation of Mailcheck (http://getmailcheck.org/)'
  s.homepage = 'https://github.com/Flyreel/MailcheckSwift'
  s.authors = { 'Bryce Hammond' => 'bryce@flyreel.co' }
  s.source = { :git => 'https://github.com/Flyreel/MailcheckSwift.git', :tag => '0.1' }

  s.ios.deployment_target = '8.0'

  s.source_files = 'Source/*.swift'

  s.requires_arc = true
end