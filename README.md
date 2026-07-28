[![CI](https://github.com/tomwaits/urweb/actions/workflows/ci.yml/badge.svg?branch=pidmint%2Fmain)](https://github.com/tomwaits/urweb/actions/workflows/ci.yml)

# The Ur/Web Programming Language

> **About this fork:** this is a maintained fork of
> [urweb/urweb](https://github.com/urweb/urweb). The `master` branch mirrors
> upstream (currently `55a881f`, 2024-03); the default `pidmint/main` branch
> additionally carries build fixes and correctness patches, many harvested from
> long-open upstream pull requests (each merge commit names its source PR).
> Fixes authored here are also offered upstream. License and copyright are
> unchanged (BSD-3-Clause, see `LICENSE`).

Implementation of a domain-specific functional programming language for web applications.  Please see [the Ur/Web project web site](http://www.impredicative.com/ur/) for much more information!  Here's a summary:

Ur is a programming language in the tradition of ML and Haskell, but featuring a significantly richer type system. Ur is functional, pure, statically typed, and strict. Ur supports a powerful kind of metaprogramming based on row types.

Ur/Web is Ur plus a special standard library and associated rules for parsing and optimization. Ur/Web supports construction of dynamic web applications backed by SQL databases. The signature of the standard library is such that well-typed Ur/Web programs "don't go wrong" in a very broad sense. Not only do they not crash during particular page generations, but they also may not:

* Suffer from any kinds of code-injection attacks
* Return invalid HTML
* Contain dead intra-application links
* Have mismatches between HTML forms and the fields expected by their handlers
* Include client-side code that makes incorrect assumptions about the "AJAX"-style services that the remote web server provides
* Attempt invalid SQL queries
* Use improper marshaling or unmarshaling in communication with SQL databases or between browsers and web servers

This type safety is just the foundation of the Ur/Web methodology. It is also possible to use metaprogramming to build significant application pieces by analysis of type structure. For instance, the demo includes an ML-style functor for building an admin interface for an arbitrary SQL table. The type system guarantees that the admin interface sub-application that comes out will always be free of the above-listed bugs, no matter which well-typed table description is given as input.

The Ur/Web compiler also produces very efficient object code that does not use garbage collection. These compiled programs will often be even more efficient than what most programmers would bother to write in C. For example, the standalone web server generated for the demo uses less RAM than the bash shell. The compiler also generates JavaScript versions of client-side code, with no need to write those parts of applications in a different language.

# Simple Invocation

Here's a simple example of compiling, running, and accessing an application included with the Ur/Web distribution.

```sh
urweb demo/hello
demo/hello.exe &
wget http://localhost:8080/Hello/main -O -
```

# Simple Installation

## With Nix (recommended)

From a checkout of this repository:

```sh
nix-build          # builds the compiler and runs the test suite
result/bin/urweb
```

(`nixpkgs` also ships a `urweb` package, but it is the 20200209 release, which
predates several build and correctness fixes carried on this branch.)

## From Source

The normal UNIX-style build and installation procedure works (where the `make` program needs to be GNU Make, and where `./autogen.sh` must be run first only if starting from a Git checkout rather than a release tarball).

```sh
./autogen.sh
./configure
make
sudo make install
```

Build requirements: [MLton](http://mlton.org) (with `mllex` and `mlyacc`),
autoconf/automake/libtool, OpenSSL, and ICU; database support additionally
needs the client headers for PostgreSQL, MySQL, and/or SQLite. If
`./configure` fails with `Permission denied`, the executable bits were lost
during extraction (common when unpacking on Windows before moving into WSL) —
run `sh ./autogen.sh` / `sh ./configure`, or re-extract inside your UNIX
environment.

## Distribution Packages (a word of caution)

Ur/Web is **no longer packaged in current Debian and Ubuntu releases**
(`apt-get install urweb` will not work; the package was dropped when its
build dependencies became unsatisfiable on several architectures). The
Homebrew formula installs the 20200209 release, which no longer matches
current `demo/` sources and predates the fixes on this branch — prefer the
Nix or source builds above.

# For More Detail

See [the reference manual](http://www.impredicative.com/ur/manual.pdf).
Links to packages for other platforms also appear on [the project home page](http://www.impredicative.com/ur/).
