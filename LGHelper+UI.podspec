Pod::Spec.new do |s|

    s.name = 'LGHelper+UI'
    s.version = '1.0.0'
    s.platform = :ios, '6.0'
    s.license = 'MIT'
    s.homepage = 'https://github.com/Friend-LGA/LGHelper-UI'
    s.author = { 'Grigory Lutkov' => 'Friend.LGA@gmail.com' }
    s.source = { :git => 'https://github.com/Friend-LGA/LGHelper-UI.git', :tag => s.version }
    s.summary = 'iOS helper extends UIColor, UIImage, UILabel, and other UI* classes'

    s.requires_arc = true

    s.source_files = 'LGHelper+UI/*.{h,m}'

end
