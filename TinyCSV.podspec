Pod::Spec.new do |s|
  s.name                 = "TinyCSV"
  s.version              = "1.1.0"
  s.summary              = "A tiny Swift CSV decoder/encoder library"
  s.description          = <<-DESC
    A tiny Swift CSV decoder/encoder library, conforming to RFC 4180 as closely as possible
  DESC
  s.homepage             = "https://github.com/dagronf"
  s.license              = { :type => "MIT", :file => "LICENSE" }
  s.author               = { "Darren Ford" => "dford_au-reg@yahoo.com" }
  s.source               = { :git => "https://github.com/dagronf/TinyCSV.git", :tag => s.version.to_s }
  s.platforms            = { :ios => "12.0", :tvos => "12.0", :osx => "10.13", :watchos => "4.0" }
  s.source_files         = 'Sources/TinyCSV/**/*.swift'
  s.swift_versions       = ['5.4', '5.5', '5.6', '5.7', '5.8', '5.9', '5.10']
  s.resource_bundles     = {
    'TinyCSV' => 'Sources/TinyCSV/PrivacyInfo.xcprivacy'
  }
end
