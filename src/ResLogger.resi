type level =
  | Debug
  | Info
  | Warn
  | Error

module type LoggerImpl = {
  let log: (. level, string) => unit
  let log2: (. level, string, 'a) => unit
}

module DefaultImpl: LoggerImpl

let setLoggerImpl: module(LoggerImpl) => unit

module type Logger = {
  let debug: string => unit
  let info: string => unit
  let warn: string => unit
  let error: string => unit
  let debug2: (string, 'a) => unit
  let info2: (string, 'a) => unit
  let warn2: (string, 'a) => unit
  let error2: (string, 'a) => unit
}

let make: string => module(Logger)
