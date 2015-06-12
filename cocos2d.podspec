Pod::Spec.new do |spec|
  spec.name         = 'cocos2d'
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
    git: 'https://github.com/cocos2d/cocos2d-iphone.git',
    tag: 'release-3.0.0-rc.5'
  }

  # Declare so we can exclude them
  objective_chipmunk = 'external/Chipmunk/include/**/*.h',
                       'external/Chipmunk/src/*.c',
                       'external/Chipmunk/objectivec/include/ObjectiveChipmunk/*.h',
                       'external/Chipmunk/objectivec/src/*.m'

  spec.header_mappings_dir = 'external'
  spec.source_files = 'cocos2d/**/*.{h,m,c}',
                      'cocos2d-ui/**/*.{h,m}',
                      'external/kazmath/**/*.{h,m,c}',
                      'external/libpng/**/*.{h,m,c}',
                      'external/ObjectAL/**/*.{h,m,c}'

  # Exclude them so we can make a subspec that doesn't use ARC
  spec.exclude_files = objective_chipmunk

  spec.frameworks   = 'CoreText',
                      'CoreMotion',
                      'CoreGraphics',
                      'Foundation',
                      'OpenGLES',
                      'QuartzCore',
                      'UIKit',
                      'AVFoundation',
                      'AudioToolbox',
                      'OpenAL',
                      'GameKit',
                      'XCTest'

  spec.library = 'z', 'sqlite3'
  spec.requires_arc = true

  spec.subspec 'ObjectiveChipmunk' do |objChipmunk|
    objChipmunk.requires_arc = false
    objChipmunk.source_files = objective_chipmunk
  end

  spec.xcconfig = {
    'HEADER_SEARCH_PATHS' => '"${PODS_ROOT}/Headers/cocos2d/kazmath/include" "${PODS_ROOT}/Headers/cocos2d/Chipmunk/objectivec/include/" "${PODS_ROOT}/Headers/cocos2d/Chipmunk/include/"'
  }

end