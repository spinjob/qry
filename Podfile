# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Qv1' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Qv1

pod 'Firebase/Core'
pod 'Firebase/Auth'
pod 'Firebase/Database'
pod 'Firebase/Storage'
pod 'Firebase/Messaging'
pod 'Firebase/Analytics'
pod 'SDWebImage'
pod 'SwiftLinkPreview', '~> 1.0.1'
pod 'Navajo-Swift'
pod 'JTAppleCalendar'


post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
    
end


end
