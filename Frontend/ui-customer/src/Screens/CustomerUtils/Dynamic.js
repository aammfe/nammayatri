export const dynamicImport = function (func) {
    return function (onError, onSuccess) {
        if (document.getElementById("customerUtil")) {
            console.log("dynamic import function " + func + " already loaded");
            import(/* webpackChunkName: "customerUtil" */"./../Screens.CustomerUtils.Flow").then(module => {
                console.log("onSuccess import " + func);
                onSuccess(module[func]);
            }
            ).catch(e => console.error("error in dynamicImport " + func, e));

            return function (cancelError, onCancelerError, onCancelerSuccess) {
                onCancelerSuccess();
            };
        } else {
            const headID = document.getElementsByTagName("head")[0];
            const newScript = document.createElement("script");
            newScript.type = "text/javascript";
            newScript.id = "customerUtil";

            newScript.onload = function () {
                console.log("dynamic import file customerUtils " + func);
                import(/* webpackChunkName: "customerUtil" */"./../Screens.CustomerUtils.Flow").then(module => {
                    console.log("onSuccess import " + func);
                    onSuccess(module[func]);
                }
                ).catch(e => console.error("error in dynamicImport " + func, e));

                return function (cancelError, onCancelerError, onCancelerSuccess) {
                    onCancelerSuccess();
                };
            };
            newScript.innerHTML = JBridge.loadFileInDUI('1.index_bundle.js');
            console.log("bundle added to innerHTML");
            headID.appendChild(newScript);
            newScript.onload();
        }
    };
};