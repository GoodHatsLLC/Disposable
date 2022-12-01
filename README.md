# Disposable

A `Disposable` represents cancellation behavior in a source agnostic manner.

It is intended to bridge cancellable sources like:
* Combine's `Cancellable` `cancel()`
* Swift's `Task` `cancel()`
* RxSwift's `Disposable` `Dispose()`
* etc.

This package also provides a `DisposalStage` which allows for grouping `Disposables`
and handling them as a single entity.
