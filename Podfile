xcodeproj './App.xcodeproj'

platform :ios, '7.0'

# public pods
pod 'AFNetworking', '2.3.1'
#pod 'pop', '1.0.6'
#pod 'HPGrowingTextView', '1.1'
#pod 'DAKeyboardControl', '2.3.1'
#pod 'FastImageCache', '1.3'
pod 'PBJActivityIndicator', '0.2.1'
#pod 'PBJNetworkObserver', '0.1.3'
pod 'EDColor', '0.4.0'
pod 'CRGradientNavigationBar'
pod 'CCHLinkTextView'

# SDKs
#pod 'Facebook-iOS-SDK', '3.15.0'
#pod 'PayPal-iOS-SDK', '2.1.0'

# analytics
#pod 'Quantcast-Measure', '1.4.5'

# debug
#pod 'PLCrashReporter', '1.2-rc5'

# sqlite
pod 'FMDB', '2.3'

post_install do |installer|
    installer.project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ARCHS'] = "$(ARCHS_STANDARD_INCLUDING_64_BIT)"
        end
    end
end