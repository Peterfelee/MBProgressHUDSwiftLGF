Pod::Spec.new do |s|
s.name = 'MBProgressHUDSwiftLGF'
s.version = '1.0.1'
s.license = 'MIT'
s.summary = 'An MBProgressHUD With Swift4.2 on iOS.'
s.homepage = 'https://github.com/Peterfelee/MBProgressHUDSwiftLGF'
s.authors = { 'peterlee' => '925460675@qq.com' }
s.source = { :git => 'https://github.com/Peterfelee/MBProgressHUDSwiftLGF.git', :tag => s.version.to_s }
s.requires_arc = true
s.ios.deployment_target = '10.0'
s.source_files = 'MBProgressHUDSwiftLGF/MBProgressHudSwift.swift'
#s.resources = ''
end
