Pod::Spec.new do |s|
  s.name         = "SLUtil"
  s.version      = "0.0.1"
  s.summary      = "Some common utilities"
  s.homepage     = "https://github.com/shuoli84/SLUtil"

  s.license      = 'MIT (example)'
  s.author       = { "shuo li" => "shuoli84@gmail.com" }
  s.source       = { :git => "https://github.com/shuoli84/SLUtil.git" }
  s.source_files = 'SLUtilClasses/*.{h,m}'

  s.requires_arc = true
  s.dependency 'BlocksKit'
end
