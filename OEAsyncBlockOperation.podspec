Pod::Spec.new do |s|
  s.name              = "OEAsyncBlockOperation"
  s.version           = "1.0"
  s.summary           = "A simple NSOperation subclass to perform asynchronous operations on NSOperationQueue"
  s.homepage          = "https://github.com/orxelm/OEAsyncBlockOperation"
  s.license           = { :type => "MIT", :file => "LICENSE" }
  s.author            = { "Or Elmaliah" => "orxelm@gmail.com" }
  s.social_media_url  = "https://twitter.com/OrElm"
  s.platform          = :ios, "8.0"
  s.source            = { :git => "https://github.com/orxelm/OEAsyncBlockOperation.git", :tag => s.version }
  s.source_files      = "AsyncBlockOperation/*.swift"
  s.requires_arc      = true
  s.framework         = "Foundation"
end
