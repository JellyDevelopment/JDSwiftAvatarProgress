# JDSwiftAvatarProgress

[![Version](https://img.shields.io/cocoapods/v/JDSwiftAvatarProgress.svg?style=flat)](http://cocoapods.org/pods/JDSwiftAvatarProgress)
[![License](https://img.shields.io/cocoapods/l/JDSwiftAvatarProgress.svg?style=flat)](http://cocoapods.org/pods/JDSwiftAvatarProgress)
[![Platform](https://img.shields.io/cocoapods/p/JDSwiftAvatarProgress.svg?style=flat)](http://cocoapods.org/pods/JDSwiftAvatarProgress)

<img src="https://raw.githubusercontent.com/JellyDevelopment/JDAvatarProgress/master/JDAvatarProgressDemo.gif" width=320>

##Objective-C

JDAvatarProgress is available in Objective-C also,

[JDAvatarProgress](https://github.com/JellyDevelopment/JDAvatarProgress)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

JDSwiftAvatarProgress is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "JDSwiftAvatarProgress"
```

### Manual

Clone the repository:

```bash
$ git clone https://github.com/JellyDevelopment/JDSwiftAvatarProgress.git
```

Drag and drop `JDAvatarProgress.swift` file into your project. Add `import JDSwiftAvatarProgress` to all view controllers that need to use it.

### Requirements
`QuartzCore.framework`

## Sample Usage

```swift

self.avatarImgView.setImageWithURL(NSURL(string: "http://3.bp.blogspot.com/-k-0O0FocJ2I/TyWbextRGlI/AAAAAAAACqo/GuPx0RH7PcY/s1600/Fondo+Pantalla.jpg")!)

```

## Advanced Usage

```swift
self.avatarImgView.setImageWithURL(NSURL(string: "http://3.bp.blogspot.com/-k-0O0FocJ2I/TyWbextRGlI/AAAAAAAACqo/GuPx0RH7PcY/s1600/Fondo+Pantalla.jpg")!,
    placeholder: nil,
    progressBarColor: UIColor.orangeColor(),
    progressBarLineWidth: JDAvatarDefaultProgressBarLineWidth,
    borderColor:nil,
    borderWidth: JDAvatarDefaultBorderWidth,
    completion: { (image, error) -> Void in

    print("image => \(image)")
    print("error => \(error)")
    print("------------------")
})
```


## Author

* [Jelly Development](https://github.com/JellyDevelopment)
    * Juanpe Catalán, juanpecm@gmail.com
    * David Carrascal, davidlcarrascal@gmail.com

## License

JDSwiftAvatarProgress is available under the MIT license. See the LICENSE file for more info.
