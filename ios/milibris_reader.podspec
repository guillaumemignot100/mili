Pod::Spec.new do |s|
  s.name             = 'milibris_reader'
  s.version          = '0.0.1'
  s.summary          = 'FFI bridge to MiLibris Reader SDK.'
  s.description      = <<-DESC
FFI bridge to MiLibris Reader SDK.
                       DESC
  s.homepage         = 'https://github.com/example/milibris_reader'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Liberation' => 'dev@liberation.fr' }

  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }
  s.swift_version = '5.0'
end
