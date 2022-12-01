# Disposable

A `Disposable` represents cancellation handlers in a source agnostic manner.

## Purpose

Disposable is intended to bridge different cancellable sources like:
* Combine's `Cancellable's` `cancel()`
* Swift's `Task's` `cancel()`
* RxSwift's `Disposable's` `dispose()`
* etc.

This package also provides a `DisposalStage` which allows for grouping `Disposables`
and handling them as a single entity — in the manner Combine uses `Set<AnyCancellable>`
and RxSwift uses `DisposeBag`.

## Limitations

* Disposables are `@MainActor` bound.
* Only `Task` and `Cancellable` bridging are implemented.

## Context

Disposable is used as the handle for subscription lifecycles in
[`Emitter`](https://github.com/GoodHatsLLC/Emitter), a basic Reactive Streams implementation.
