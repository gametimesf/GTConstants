Pod::Spec.new do |s|
  s.name                  = "GAMConstants"
  s.version               = "0.1.10"
  s.summary               = "Easy to use framework for managing Constants and String localization all while being changeable from your server."
  s.description           = %{ Easy to use framework for managing Constants and String localization all while being changeable from your server. Simply configure your server with an interceptions file and all constants will be changed }
  s.homepage              = "https://github.com/gametimesf/GAMConstants"
  s.license               = 'MIT'
  s.author                = { "Mike Silvis" => "mike@gametime.co" }
  s.source_files          = 'Source/*.swift'
  s.exclude_files         = "Classes/Exclude"
  s.ios.frameworks        = 'Foundation', 'UIKit'
  s.ios.deployment_target = '9.0'
  s.requires_arc          = true
  s.source                = { :git => 'https://github.com/gametimesf/GAMConstants.git', :tag => "#{s.version}" }
end
