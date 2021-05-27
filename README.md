# rescript-logger

Simple logger library for [ReScript](https://rescript-lang.org/) apps.

## Design Goals

1. Do not require a PPX, but still provide a way to include the module name in the log output.
2. Pluggable logger implementation so that code shared between e.g. React and React Native can use a platform-specific implementation.

## Installation

```shell
# yarn
yarn add @cca-io/rescript-logger

# or npm
npm install @cca-io/rescript-logger
```

Then add rescript-logger to the dependencies in your `bsconfig.json`, e.g.:

```
{
  "name": "my-app",
  ...
  "bs-dependencies": ["@rescript/react", "@cca-io/rescript-logger"],
  ...
}
```

## Usage

Example:

```rescript
module Log = unpack(ResLogger.make(__MODULE__))

Log.info("Starting")

// ...

Log.error2("Startup error", error)
```

The actual logger implementation is pluggable, so it can be swapped out e.g. for usage with React Native:

```rescript
ResLogger.setLoggerImpl(module(MyNativeLoggerImpl))
```
