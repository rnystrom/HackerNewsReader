Pod::Spec.new do |s|
  s.name             = "HackerNewsNetworker"
  s.version          = "0.1.0"
  s.summary          = "Networking for Hacker News"

  s.description      = <<-DESC
                       DESC

  s.homepage         = "https://github.com/rnystrom/HackerNewsReader"
  s.license          = 'MIT'
  s.author           = { "Ryan Nystrom" => "rnystrom@whoisryannystrom.com" }
  s.source           = { :git => "https://github.com/rnystrom/HackerNewsReader.git", :tag => s.version.to_s }
  s.social_media_url = "https://twitter.com/_ryannystrom"

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  # s.library = 'xml2.2'
  s.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2' }

  s.source_files = 'Pod/Classes/**/*'
  s.ios.resource_bundle = { 'HackerNewsNetworker' => 'Pod/Assets/*.json' }

  s.public_header_files = 'Pod/Classes/**/*.h'

  s.dependency 'HackerNewsKit'
end
