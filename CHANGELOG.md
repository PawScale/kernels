# Changelog

## 1.0.0 (2026-05-03)

### Features

* Restructured package as library (`Kernels`) + demo (`KernelsDemo`) targets
* Added CI/CD workflows for build, test, and lint
* Added comprehensive documentation (Getting Started, API Reference)
* Added performance benchmarking suite
* Added examples (vector addition, matrix multiplication)
* Added website submodule at `website/`
* Added test suite for kernel operations
* Kernels.metal moved to dedicated resource file

### Bug Fixes

* Fix CI build by targeting library only (no GPU on runner)
* Fix yamllint errors (document start, bracket spacing, indentation)
* Fix Metal compilation errors in softmax kernel
* Fix tiled matrix multiplication kernel
* Fix stale repo URLs across all files

### Performance

* Eliminated redundant exp() calls in softmax kernel
* Optimized Metal kernel robustness and efficiency
* Moved Metal kernel code to separate `.metal` file for compilation caching

### Documentation

* Updated CONTRIBUTING.md with current project structure and commands
* Updated CHANGELOG.md with correct repo URLs
* Updated LICENSE copyright to PawScale

---

## 0.0.0-beta (2026-01-21)

Initial beta release of Metal Compute Kernels for Swift.
