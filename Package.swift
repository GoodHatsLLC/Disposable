// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Disposable",
  platforms: [.macOS(.v10_15), .iOS(.v14)],
  products: [
    .library(
      name: "Disposable",
      targets: [
        "Disposable",
        "DisposableInterface",
      ]
    ),
    .library(
      name: "DisposableAsync",
      targets: [
        "DisposableAsync",
        "DisposableAsyncInterface",
      ]
    ),
  ],
  dependencies: [
  ],
  targets: [
    .target(
      name: "Disposable",
      dependencies: ["DisposableInterface"]
    ),
    .target(
      name: "DisposableAsync",
      dependencies: ["DisposableAsyncInterface"]
    ),
    .target(
      name: "DisposableInterface",
      dependencies: []
    ),
    .target(
      name: "DisposableAsyncInterface",
      dependencies: []
    ),
    .testTarget(
      name: "DisposableTests",
      dependencies: ["Disposable"]
    ),
  ]
)
