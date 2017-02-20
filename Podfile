# Uncomment this line to define a global platform for your project
# platform :ios, '10.0'

target 'SCAM' do
  use_frameworks!

  pod 'Parse'
  pod 'SCLAlertView'

  target 'SCAMTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'SCAMUITests' do
    inherit! :search_paths
    # Pods for testing
  end

  post_install do |installer|
      installer.pods_project.targets.each do |target|
          target.build_configurations.each do |config|
              config.build_settings['SWIFT_VERSION'] = '3.0'
          end
      end
  end

end
