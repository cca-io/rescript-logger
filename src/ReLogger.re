type level =
  | Debug
  | Info
  | Warn
  | Error;

module type LoggerImpl = {
  let log: (level, string) => unit;
  let log2: (level, string, 'a) => unit;
};

module DefaultImpl: LoggerImpl = {
  [@bs.val] [@bs.scope "process.env"] external nodeEnv: string = "NODE_ENV";
  [@bs.send] external padStart: (string, int, string) => string = "padStart";

  let prependDate = message => {
    let now = Js.Date.make();

    let hours = now->Js.Date.getHours->Js.Float.toString->padStart(2, "0");
    let minutes =
      now->Js.Date.getMinutes->Js.Float.toString->padStart(2, "0");
    let seconds =
      now->Js.Date.getSeconds->Js.Float.toString->padStart(2, "0");

    {j|$(hours):$(minutes):$(seconds) $(message)|j};
  };

  let log = (level: level, msg: string) => {
    let msg = msg->prependDate;

    switch (level) {
    | Debug =>
      if (nodeEnv === "development") {
        Js.log(msg);
      }
    | Info => Js.Console.info(msg)
    | Warn => Js.Console.warn(msg)
    | Error => Js.Console.error(msg)
    };
  };

  let log2 = (level: level, msg: string, obj: 'a) => {
    let msg = msg->prependDate;

    switch (level) {
    | Debug =>
      if (nodeEnv === "development") {
        Js.log2(msg, obj);
      }
    | Info => Js.Console.info2(msg, obj)
    | Warn => Js.Console.warn2(msg, obj)
    | Error => Js.Console.error2(msg, obj)
    };
  };
};

let loggerImpl: ref(module LoggerImpl) =
  ref((module DefaultImpl): (module LoggerImpl));

let setLoggerImpl = (impl: (module LoggerImpl)) => loggerImpl := impl;

module type Log = {
  let debug: string => unit;
  let info: string => unit;
  let warn: string => unit;
  let error: string => unit;

  let debug2: (string, 'a) => unit;
  let info2: (string, 'a) => unit;
  let warn2: (string, 'a) => unit;
  let error2: (string, 'a) => unit;
};

let make = (moduleName: string): (module Log) =>
  (module
   {
     let moduleNamePrefix = "[" ++ moduleName ++ "] ";
     let prependModuleName = message => moduleNamePrefix ++ message;

     let debug = message => {
       let (module I) = loggerImpl^;
       I.log(Debug, message->prependModuleName);
     };

     let info = message => {
       let (module I) = loggerImpl^;
       I.log(Info, message->prependModuleName);
     };

     let warn = message => {
       let (module I) = loggerImpl^;
       I.log(Warn, message->prependModuleName);
     };

     let error = message => {
       let (module I) = loggerImpl^;
       I.log(Warn, message->prependModuleName);
     };

     let debug2 = (message, obj) => {
       let (module I) = loggerImpl^;
       I.log2(Debug, message->prependModuleName, obj);
     };

     let info2 = (message, obj) => {
       let (module I) = loggerImpl^;
       I.log2(Info, message->prependModuleName, obj);
     };

     let warn2 = (message, obj) => {
       let (module I) = loggerImpl^;
       I.log2(Warn, message->prependModuleName, obj);
     };

     let error2 = (message, obj) => {
       let (module I) = loggerImpl^;
       I.log2(Warn, message->prependModuleName, obj);
     };
   });