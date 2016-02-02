Pod::Spec.new do |s|
  s.name             = "HackerNewsKit"
  s.version          = "0.1.0"
  s.summary          = "Models for Hacker News."

  s.description      = <<-DESC
                       DESC

  s.homepage         = "https://github.com/rnystrom/HackerNewsReader"
  s.license          = 'MIT'
  s.author           = { "Ryan Nystrom" => "rnystrom@whoisryannystrom.com" }
  s.source           = { :git => "https://github.com/rnystrom/HackerNewsReader.git", :tag => s.version.to_s }
  s.social_media_url = "https://twitter.com/_ryannystrom"

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'

  s.public_header_files = 'Pod/Classes/**/*.h'
end
