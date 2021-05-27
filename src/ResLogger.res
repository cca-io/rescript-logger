type level =
  | Debug
  | Info
  | Warn
  | Error

module type LoggerImpl = {
  let log: (. level, string) => unit
  let log2: (. level, string, 'a) => unit
}

module DefaultImpl: LoggerImpl = {
  @val @scope("process.env") external nodeEnv: string = "NODE_ENV"
  @send external padStart: (string, int, string) => string = "padStart"

  let prependDate = message => {
    let now = Js.Date.make()

    let hours = now->Js.Date.getHours->Js.Float.toString->padStart(2, "0")
    let minutes = now->Js.Date.getMinutes->Js.Float.toString->padStart(2, "0")
    let seconds = now->Js.Date.getSeconds->Js.Float.toString->padStart(2, "0")

    `${hours}:${minutes}:${seconds} ${message}`
  }

  let log = (. level: level, msg: string) => {
    let msg = msg->prependDate

    switch level {
    | Debug =>
      if nodeEnv === "development" {
        Js.log(msg)
      }
    | Info => Js.Console.info(msg)
    | Warn => Js.Console.warn(msg)
    | Error => Js.Console.error(msg)
    }
  }

  let log2 = (. level: level, msg: string, obj: 'a) => {
    let msg = msg->prependDate

    switch level {
    | Debug =>
      if nodeEnv === "development" {
        Js.log2(msg, obj)
      }
    | Info => Js.Console.info2(msg, obj)
    | Warn => Js.Console.warn2(msg, obj)
    | Error => Js.Console.error2(msg, obj)
    }
  }
}

let loggerImpl: ref<module(LoggerImpl)> = ref(module(DefaultImpl: LoggerImpl))

let setLoggerImpl = (impl: module(LoggerImpl)) => loggerImpl := impl

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

let make = (moduleName: string): module(Logger) =>
  module(
    {
      let prefix = `[${moduleName}] `
      let prependModuleName = message => prefix ++ message

      let debug = message => {
        let module(I) = loggerImpl.contents
        I.log(. Debug, message->prependModuleName)
      }

      let info = message => {
        let module(I) = loggerImpl.contents
        I.log(. Info, message->prependModuleName)
      }

      let warn = message => {
        let module(I) = loggerImpl.contents
        I.log(. Warn, message->prependModuleName)
      }

      let error = message => {
        let module(I) = loggerImpl.contents
        I.log(. Error, message->prependModuleName)
      }

      let debug2 = (message, obj) => {
        let module(I) = loggerImpl.contents
        I.log2(. Debug, message->prependModuleName, obj)
      }

      let info2 = (message, obj) => {
        let module(I) = loggerImpl.contents
        I.log2(. Info, message->prependModuleName, obj)
      }

      let warn2 = (message, obj) => {
        let module(I) = loggerImpl.contents
        I.log2(. Warn, message->prependModuleName, obj)
      }

      let error2 = (message, obj) => {
        let module(I) = loggerImpl.contents
        I.log2(. Error, message->prependModuleName, obj)
      }
    }
  )
