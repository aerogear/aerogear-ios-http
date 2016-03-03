Pod::Spec.new do |s|
  s.name         = "AeroGearHttp"
  s.version      = "0.5.1"
  s.summary      = "Lightweight lib around NSURLSession to ease HTTP calls."
  s.homepage     = "https://github.com/aerogear/aerogear-ios-http"
  s.license      = 'Apache License, Version 2.0'
  s.author       = "Red Hat, Inc."
  s.source       = { :git => 'https://github.com/aerogear/aerogear-ios-http.git', :tag => s.version }
  s.platform     = :ios, 8.0
  s.source_files = 'AeroGearHttp/*.{swift}'
  s.requires_arc = true
end
