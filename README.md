![TVButton - Apple TV Parallax icons on iOS](https://cloud.githubusercontent.com/assets/889949/11056798/b0b54632-8785-11e5-8ef2-af9c579815f9.png)

[![Build Status](https://travis-ci.org/marmelroy/TVButton.svg?branch=master)](https://travis-ci.org/marmelroy/TVButton) [![Version](http://img.shields.io/cocoapods/v/TVButton.svg)](http://cocoapods.org/?q=TVButton)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

# TVButton
Recreating the cool parallax icons from Apple TV as iOS UIButtons (in Swift). The effect is triggered by long pressing or dragging.

![Star Wars TVButton](http://i.giphy.com/xTiTnCqL5arYHW92Lu.gif)

## Usage

Import TVButton at the top of your Swift ViewController.

```swift
import TVButton
```

Create and position your TVButton in interface builder or in code.

For the parallax TVButton you will need at least two layers of images (three recommended). For best results, the button and the images should all have the same dimensions. Assign the relevant UIImages to TVButtonLayers and provide them as a layers array to the TVButton.
```swift
let background = TVButtonLayer(image: UIImage(named: "TVButtonBackground.png")!)
let pattern = TVButtonLayer(image: UIImage(named: "TVButtonPattern.png")!)
let top = TVButtonLayer(image: UIImage(named: "TVButtonTop.png")!)
tvButton.layers = [background, pattern, top]
```

You can customize the parallax intensity of your TVButton. Default value is 1.0 and it's very subtle. Maximum recommended value is 2.0.
```swift
tvButton.parallaxIntensity = 1.3
```

![TVButton in action](http://i.giphy.com/l0O9zc8b49oDi209y.gif)

Enjoy!

### Setting up with [CocoaPods](http://cocoapods.org/?q=TVButton)
```ruby
source 'https://github.com/CocoaPods/Specs.git'
pod 'TVButton', '~> 1.0'
```

### Setting up with Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that automates the process of adding frameworks to your Cocoa application.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate TVButton into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "marmelroy/TVButton"
```
