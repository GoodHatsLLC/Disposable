# Disposable

A `Disposable` is an async oriented cancellation handler.  
Disposables can represent any handle to long running behaviors— like `Cancellables` and `Tasks`.

## Purpose

Disposable is intended to bridge different cancellable sources including:
* Combine's `Cancellable's` `cancel()`
* Swift's `Task's` `cancel()`
* RxSwift's `Disposable's` `dispose()`

It abstracts over their differences and provides an async-first API for handling them.

This package also provides a `DisposalStage` which allows for grouping `Disposables`
and handling them as a single entity — in the manner Combine uses `Set<AnyCancellable>`
and RxSwift uses `DisposeBag`.
