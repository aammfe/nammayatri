require("regenerator-runtime/runtime");

// This will make sure init() is called. It will make available JBridge and Android variables
require("presto-ui");
require('core-js');
window.session_id = guid();
window.version = __VERSION__;
console.warn("Hello World");
loadConfig();

var jpConsumingBackpress = {
  event: "jp_consuming_backpress",
  payload: { jp_consuming_backpress: true }
}
JBridge.runInJuspayBrowser("onEvent", JSON.stringify(jpConsumingBackpress), "");

window.isObject = function (object) {
  return (typeof object == "object");
}
window.manualEventsName = ["onBackPressedEvent", "onNetworkChange", "onResume", "onPause", "onKeyboardHeightChange"];

setInterval(function () { JBridge.submitAllLogs(); }, 10000);

var isUndefined = function (val) {
  return (typeof val == "undefined");
}

var logger = function()
{
    var oldConsoleLog = null;
    var pub = {};

    pub.enableLogger =  function enableLogger() 
                        {
                            if(oldConsoleLog == null)
                                return;

                            window['console']['log'] = oldConsoleLog;
                        };

    pub.disableLogger = function disableLogger()
                        {
                            oldConsoleLog = console.log;
                            window['console']['log'] = function() {};
                        };

    return pub;
}();



function setManualEvents(eventName, callbackFunction) {
  window[eventName] = (!isUndefined(window[eventName])) ? window[eventName] : {};
  if (!isUndefined(window.__dui_screen)) {
    window[eventName][window.__dui_screen] = callbackFunction;
    if ((!isUndefined(window.__currScreenName.value0)) && (window.__dui_screen != window.__currScreenName.value0)) {
      console.warn("window.__currScreenName is varying from window.__currScreenName");
    }
  } else {
    console.error("Please set value to __dui_screen --shouldn't come here");
  }
}

window.setManualEvents = setManualEvents;

function guid() {
  function s4() {
    return Math.floor((1 + Math.random()) * 0x10000)
      .toString(16)
      .substring(1);
  }
  return s4() + s4() + '-' + s4() + '-' + s4() + '-' +
    s4() + '-' + s4() + s4() + s4();
}

window.__FN_INDEX = 0;
window.__PROXY_FN = top.__PROXY_FN || {};

if (!window.__OS) {
  var getOS = function () { //taken from getOS() in presto-ui
    var userAgent = navigator.userAgent;
    if (!userAgent) return console.error(new Error("UserAgent is null"));
    if (userAgent.indexOf("Android") != -1 && userAgent.indexOf("Version") != -1) return "ANDROID";
    if (userAgent.indexOf("iPhone") != -1 && userAgent.indexOf("Version") == -1) return "IOS";
    return "WEB";
  }
  window.__OS = getOS();
}

var purescript = require("./output/Main");

window.onMerchantEvent = function (event, payload) {
  console = top.console;
  console.log(payload);
  var clientPaylod = JSON.parse(payload);
  if (event == "initiate") {
    let payload = {
      event: "initiate_result"
      , service: "in.juspay.becknui"
      , payload: { status: "SUCCESS" }
      , error: false
      , errorMessage: ""
      , errorCode: ""
    }
    if (clientPaylod.payload.clientId == "open-kochi") {
      window.merchantID = "YATRIPARTNER"
    } else if(clientPaylod.payload.clientId == "jatrisaathiprovider" || clientPaylod.payload.clientId == "jatrisaathidriver"){
      window.merchantID = "JATRISAATHIDRIVER"
    }else {
      window.merchantID = clientPaylod.payload.clientId.toUpperCase();
    }
    console.log(window.merchantID);
    var header = {"x-client-id" : "nammayatri"};
    JBridge.setAnalyticsHeader(JSON.stringify(header));
    JBridge.runInJuspayBrowser("onEvent", JSON.stringify(payload), null)
  } else if (event == "process") {
    window.__payload.sdkVersion = "2.0.1"
    console.warn("Process called");
    var parsedPayload = JSON.parse(payload);
    if (parsedPayload && parsedPayload.payload && parsedPayload.payload.action == "showPopup" && parsedPayload.payload.id && parsedPayload.payload.popType){
      window.callPopUp(parsedPayload.payload.popType, parsedPayload.payload.entityPayload);
    }
    else {
      window.__payload = parsedPayload;
      console.log("window Payload: ", window.__payload);
      var jpConsumingBackpress = {
        event: "jp_consuming_backpress",
        payload: { jp_consuming_backpress: true }
      }
      JBridge.runInJuspayBrowser("onEvent", JSON.stringify(jpConsumingBackpress), "");
      // var purescript = require("./output/Main");
      purescript.main();
    }
  } else {
    console.error("unknown event: ", event);
  }
}

window.callUICallback = function () {
  var args = (arguments.length === 1 ? [arguments[0]] : Array.apply(null, arguments));
  var fName = args[0]
  var functionArgs = args.slice(1)

  try {
    window.__PROXY_FN[fName].call(null, ...functionArgs);
  } catch (err) {
    console.error(err)
  }
}

window.onResumeListeners = [];

window.onPause = function () {
  console.error("onEvent onPause");
  if (JBridge.pauseMediaPlayer) {
    JBridge.pauseMediaPlayer();
  }
}

window.onResume = function () {
  console.error("onEvent onResume");
  if (window.onResumeListeners && Array.isArray(window.onResumeListeners)) {
    for (let i = 0; i < window.onResumeListeners.length;i++) {
      window.onResumeListeners[i].call();
    }
  }
}
window.onActivityResult = function () {
  console.log(arguments)
}

window.onBackPressed = function () {
  if (window.eventListeners && window.eventListeners["onBackPressed"] && window.enableBackpress) {
    window.eventListeners["onBackPressed"]()();
  }
}

window.callPopUp = function(type, entityPayload){
  if ((type == "LOCATION_DISABLED") || ( type == "INTERNET_ACTION" )){
    purescript.onConnectivityEvent(type)();
  } else if(type == "NEW_RIDE_AVAILABLE"){
    purescript.mainAllocationPop(type)(entityPayload)();}
  else{
    purescript.main(); 
  }
}

window.activityResultListeners = {}
window.eventListeners = {}

window.listenForActivityResult = function (requestCode, callback) {
  window.activityResultListeners[requestCode] = callback;
}
window.onActivityResult = function (requestCode, resultCode, bundle) {
  if (window.activityResultListeners[requestCode]) {
    window.activityResultListeners[requestCode](resultCode, bundle);
    window.activityResultListeners[requestCode] = undefined;
  }
}

window["onEvent'"] = function (event, args) {
  console.log(event, args);
  if (event == "onBackPressed") {
    // var purescript = require("./output/Main");
    purescript.onEvent(event)();
  } else if (event == "onPause") {
    window.onPause();
  } else if (event == "onResume") {
    window.onResume();
  } else if (event == "onDestroy") {
    if (JBridge.onDestroy){
      JBridge.onDestroy();
    }
  }
}

function disableConsoleLogs() {
  window.console["log"] = function () { };
  window.console["error"] = function () { };
  window.console["warn"] = function () { };
}



if (typeof window.JOS != "undefined") {
  window.JOS.addEventListener("onEvent'")();
  window.JOS.addEventListener("onMerchantEvent")();
  window.JOS.addEventListener("onActivityResult")();
  console.error("Calling action DUI_READY");
  JOS.emitEvent("java")("onEvent")(JSON.stringify({ action: "DUI_READY", event: "initiate",service : JOS.self }))()();
} else {
  console.error("JOS not present")
}

var sessionInfo = JSON.parse(JBridge.getDeviceInfo())
if(sessionInfo.package_name.includes("debug")){
  logger.enableLogger();
}else{
  logger.disableLogger();
}

function loadConfig() {
  if (window.appConfig) {
    return;
  }
  const headID = document.getElementsByTagName("head")[0];
  console.log(headID)
  const newScript = document.createElement("script");
  newScript.type = "text/javascript";
  newScript.id = "ny-customer-configuration";
  newScript.innerHTML = window.JBridge.loadFileInDUI("v1-configuration.js");
  headID.appendChild(newScript);
  try {
      const merchantConfig = (
          function(){
              try {
                  return JSON.parse(window.getMerchantConfig());
              } catch(e){
                  return "{}";
              }
          }
      )();
      // console.log(merchantConfig)
      // window.appConfig = mergeDeep(defaultConfig, merchantConfig);
      window.appConfig = merchantConfig;
  } catch(e){
      console.error("config parse/merge failed", e);
      // window.appConfig = defaultConfig;
  }
}