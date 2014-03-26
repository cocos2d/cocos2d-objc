Pod::Spec.new do |spec|
  spec.name         = 'cocos2d-iphone'
  spec.version      = '3.0.0'
  spec.license      = { type: 'mit' }
  spec.homepage     = 'http://www.cocos2d-iphone.org/'
  spec.authors      = {
    'Lars Birkemose'       => 'http://thebackfiregames.wordpress.com',
    'Andy Korth'           => 'http://howlingmoonsoftware.com',
    'Apportable'           => 'http://www.apportable.com',
    'Christian Enevoldsen' => '',
    'Dominik Hadl'         => '',
    'John Twigg'           => '',
    'Martin Walsh'         => '',
    'Oleg Osin'            => '',
    'Scott Lembcke'        => 'http://chipmunk2d.net',
    'Viktor Lidholt'       => ''
  }
  spec.summary      = 'cocos2d-iphone is a framework for building 2D games,
  demos,and other graphical/interactive applications. It is based on the
  cocos2d design: It uses the same concepts, but instead of using Python,
  it uses Objective-C.'
  spec.source       =  {
    git: 'https://github.com/dylan/cocos2d-iphone.git',
    tag: 'release-3.0-rc4'
  }
  spec.header_mappings_dir = 'kazmath'
  spec.source_files = 'cocos2d/**/*.{h,m}',
                      'cocos2d-ui/**/*.{h,m}',
                      'external/libpng/*.{h,c}',
                      'external/kazmath/**/*.{h,c}',
                      'external/ObjectAL/**/*.{h,m}',
                      'external/Chipmunk/include/chipmunk/*.h',
                      'external/Chipmunk/src/*.c',
                      'external/Chipmunk/objectivec/include/ObjectiveChipmunk/*.h',
                      'external/Chipmunk/objectivec/src/*.m'
  spec.xcconfig = {
    'HEADER_SEARCH_PATHS' => '"${PODS_ROOT}/Headers/external/kazmath/include" "${PODS_ROOT}/Headers/external/Chipmunk/objectivec/include" "${PODS_ROOT}/Headers/external/Chipmunk/include"'
  }
  spec.frameworks   = 'CoreText', 'CoreMotion', 'CoreGraphics', 'Foundation', 'OpenGLES', 'QuartzCore', 'UIKit', 'AVFoundation', 'AudioToolbox', 'OpenAL', 'GameKit', 'XCTest'
  spec.library = 'z', 'sqlite3'
  # spec.requires_arc = true
end
