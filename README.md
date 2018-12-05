# re-logger

Simple logger library for [Reason](https://reasonml.github.io)/[BuckleScript](https://bucklescript.github.io) apps.

## Installation

```shell
# yarn
yarn add @cca-io/re-logger

# or npm
npm install @cca-io/re-logger
```

Then add re-logger to the dependencies in your `bsconfig.json`, e.g.:

```
{
  "name": "my-app",
  ...
  "bs-dependencies": ["reason-react", "@cca-io/re-logger"],
  ...
}
```

This library uses the namespace `ReLogger` to avoid conflicts if there is already a `Logger` module in your project. If that is not the case, you may want to open the `ReLogger` module globally in your `bsconfig.json`:

```
{
  "name": "my-app",
  ...
  "bs-dependencies": ["reason-react", "@cca-io/re-logger"],
  ...
  "bsc-flags": ["-bs-super-errors", "-open ReLogger"],
  ...
}
```

## Usage

Example:

```reason
open ReLogger; /* unless you already opened it globally in bsconfig.json */

module Log = (val Logger.make(__MODULE__));

Log.info("Starting");

/* ... */

Log.error2("Startup error", error);
```

The actual logger implementation is pluggable, so it can be swapped out e.g. for usage with React Native:

```reason
Logger.setLoggerImpl((module MyNativeLoggerImpl));
```
