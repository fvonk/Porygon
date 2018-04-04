Pod::Spec.new do |s|
  s.name         = "Porygon"
  s.version      = "0.0.3"
  s.summary      = "Generate low-poly style images."
  s.description  = <<-DESC
                   Porygon is a library for generate low-poly style images.
                   DESC

  s.homepage     = "https://github.com/fvonk/Porygon.git"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "PavelKozlov" => "pavelcauselov@gmail.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/fvonk/Porygon.git", :tag => s.version }
  s.source_files  = "Sources/*.{h,m,c}"
  s.public_header_files = "Sources/*.h"
  s.framework  = "UIKit"
  s.requires_arc = true
end
