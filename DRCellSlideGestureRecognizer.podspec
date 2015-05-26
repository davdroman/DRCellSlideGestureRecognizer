Pod::Spec.new do |s|
  s.name                  = "DRCellSlideGestureRecognizer"
  s.version               = "1.0.0"
  s.summary               = "Make your cells actionable through swipes"
  s.homepage              = "http://github.com/Dromaguirre/DRCellSlideGestureRecognizer"
  s.author                = { "David Roman" => "dromaguirre@gmail.com" }
  s.license               = { :type => 'MIT', :file => 'LICENSE' }

  s.platform              = :ios, '8.0'
  s.ios.deployment_target = '8.0'

  s.source                = { :git => "https://github.com/Dromaguirre/DRCellSlideGestureRecognizer.git", :tag => s.version.to_s }
  s.source_files          = 'DRCellSlideGestureRecognizer/*.{h,m}'
  s.frameworks            = 'Foundation', 'UIKit'
  s.requires_arc          = true
end
