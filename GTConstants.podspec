Pod::Spec.new do |s|
  s.name                  = "GTConstants"
  s.version               = "0.2.8"
  s.summary               = "Easy to use framework for managing Constants and String localization all while being changeable from your server."
  s.description           = %{ Easy to use framework for managing Constants and String localization all while being changeable from your server. Simply configure your server with an interceptions file and all constants will be changed }
  s.homepage              = "https://github.com/gametimesf/GTConstants"
  s.license               = 'MIT'
  s.author                = { "GT Engineering" => "engineering@gametime.co" }
  s.source_files          = 'Source/*.swift'
  s.exclude_files         = "Classes/Exclude"
  s.ios.frameworks        = 'Foundation', 'UIKit'
  s.ios.deployment_target = '11.0'
  s.requires_arc          = true
  s.swift_version         = '5.0'
  s.source                = { :git => 'https://github.com/gametimesf/GTConstants.git', :tag => "#{s.version}" }
end
