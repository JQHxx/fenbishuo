Pod::Spec.new do |s|
  s.name          = "DKImagePickerController"
  s.version       = "5.1.0"
  s.summary       = "DKImagePickerController is a highly customizable, pure-Swift library."
  s.homepage      = "https://github.com/vvlee/DKImagePickerController"
  s.license       = { :type => "MIT", :file => "LICENSE" }
  s.author        = { "Bannings" => "zhangao0086@gmail.com" }
  s.platform      = :ios, "10.0"
  s.source        = {:git => "https://github.com/vvlee/DKImagePickerController.git",
                     :tag => s.version.to_s }
  
  s.requires_arc  = true
  s.swift_version = ['4.2', '5']

  s.subspec 'Core' do |core|
    core.dependency 'SnapKit'
    core.dependency 'RxSwift'
    core.dependency 'RxCocoa'
    core.dependency 'lottie-ios'
    
    core.dependency 'MBProgressHUD'
    core.dependency 'PLShortVideoKit', '3.1.0'
    core.dependency 'Qiniu'
    
    core.dependency 'DKImagePickerController/ImageDataManager'
    core.dependency 'DKImagePickerController/Resource'

    core.frameworks    = "Foundation", "UIKit", "Photos"

    core.source_files = "Sources/DKImagePickerController/*.{h,swift}", "Sources/DKImagePickerController/View/**/*.swift"
  end

  s.subspec 'ImageDataManager' do |image|
    image.source_files = "Sources/DKImageDataManager/**/*.swift"
  end

  s.subspec 'Resource' do |resource|
    resource.resource_bundle = { "DKImagePickerController" => "Sources/DKImagePickerController/Resource/Resources/*" }

    resource.source_files = "Sources/DKImagePickerController/Resource/DKImagePickerControllerResource.swift"
  end

  s.subspec 'PhotoGallery' do |gallery|
    gallery.dependency 'DKImagePickerController/Core'
    gallery.dependency 'DKPhotoGallery'

    gallery.source_files = "Sources/Extensions/DKImageExtensionGallery.swift"
  end

  s.subspec 'Camera' do |camera|
    camera.dependency 'DKImagePickerController/Core'
    camera.dependency 'DKCamera'

    camera.source_files = "Sources/Extensions/DKImageExtensionCamera.swift"
  end

  s.subspec 'VideoCapture' do |video|
    video.dependency 'DKImagePickerController/Core'

    video.source_files = "Sources/VideoCapture/*.swift"
  end

  s.subspec 'Video' do |video|
    video.dependency 'DKImagePickerController/Core'
    video.dependency 'DKImagePickerController/VideoCapture'

    video.source_files = "Sources/Extensions/DKImageExtensionVideo.swift"
  end
  
  s.subspec 'PhotoWithAudio' do |pwa|
    pwa.dependency 'DKImagePickerController/Core'
    
    pwa.source_files = "Sources/PhotoWithAudio/*.swift"
  end

  s.subspec 'InlineCamera' do |inlineCamera|
    inlineCamera.dependency 'DKImagePickerController/Core'
    inlineCamera.dependency 'DKCamera'

    inlineCamera.source_files = "Sources/Extensions/DKImageExtensionInlineCamera.swift"
  end

  s.subspec 'PhotoEditor' do |photoEditor|
    photoEditor.dependency 'DKImagePickerController/Core'
    photoEditor.dependency 'CropViewController', '~> 2.5'

    photoEditor.source_files = "Sources/Extensions/DKImageExtensionPhotoCropper.swift"
  end

end
