# BaseKit
![Tests](https://github.com/andyfinnell/BaseKit/workflows/Tests/badge.svg) [![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)

BaseKit is a Swift package with a random collection of Foundation extensions and Foundation-level types. It's an extraction of my personal set of utils so I don't have to copy-pasta them across projects.

## Requirements

- Swift 5.3 or greater
- iOS/tvOS 13 or greater OR macOS 10.15 or greater

## Installation

Currently, BaseKit is only available as a Swift Package.

### ...using a Package.swift file

Open the Package.swift file and edit it:

1. Add BaseKit repo to the `dependencies` array.
1. Add BaseKit as a dependency of the target that will use it

```Swift
// swift-tools-version:5.3

import PackageDescription

let package = Package(
  // ...snip...
  dependencies: [
    .package(url: "https://github.com/andyfinnell/BaseKit.git", from: "0.0.1")
  ],
  targets: [
    .target(name: "MyTarget", dependencies: ["BaseKit"])
  ]
)
```

Then build to pull down the dependencies:

```Bash
$ swift build
```

### ...using Xcode

Use the Swift Packages tab on the project to add BaseKit:

1. Open the Xcode workspace or project that you want to add BaseKit to
1. In the file browser, select the project to show the list of projects/targets on the right
1. In the list of projects/targets on the right, select the project
1. Select the "Swift Packages" tab
1. Click on the "+" button to add a package
1. In the "Choose Package Repository" sheet, search for  "https://github.com/andyfinnell/BaseKit.git"
1. Click "Next"
1. Choose the version rule you want
1. Click "Next"
1. Choose the target you want to add BaseKit to
1. Click "Finish"
