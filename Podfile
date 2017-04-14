# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

  use_frameworks!

target 'Qv1' do

    pod 'Firebase/Core'
    pod 'Firebase/Auth'
    pod 'Firebase/Database'
    pod 'Firebase/Storage'
    pod 'Firebase/Messaging'
    pod 'Firebase/Analytics'
    pod 'SDWebImage'
    pod 'SDWebImage/GIF'
    pod 'SwiftLinkPreview', '~> 1.0.1'
    pod 'Navajo-Swift'
    pod 'JTAppleCalendar'
    pod 'paper-onboarding', '~> 2.0.1'
    pod 'Gifu'
    
    
    target 'pollNotificationExtension' do
        inherit! :search_paths
    end

    
    post_install do |installer|
        installer.pods_project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '3.0'
            end
        end
        
    end
  
end


