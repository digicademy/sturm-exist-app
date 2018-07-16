/*
 * @license Hyphenopoly_Loader 2.2.0-devel - client side hyphenation
 *  ©2018  Mathias Nater, Zürich (mathiasnater at gmail dot com)
 *  https://github.com/mnater/Hyphenopoly
 *
 *  Released under the MIT license
 *  http://mnater.github.io/Hyphenopoly/LICENSE
 */

(function H9YL() {
    "use strict";
    const d = document;
    const H = Hyphenopoly;

    /**
     * Create Object without standard Object-prototype
     * @returns {Object} empty object
     */
    function empty() {
        return Object.create(null);
    }

    if (H.cacheFeatureTests && sessionStorage.getItem("Hyphenopoly_Loader")) {
        H.clientFeat = JSON.parse(sessionStorage.getItem("Hyphenopoly_Loader"));
    } else {
        H.clientFeat = {
            "langs": empty(),
            "polyfill": false,
            "wasm": null
        };
    }

    (function config() {
        // Set defaults for paths and setup
        if (H.paths) {
            if (!H.paths.patterndir) {
                H.paths.patterndir = "../Hyphenopoly/patterns/";
            }
            if (!H.paths.maindir) {
                H.paths.maindir = "../Hyphenopoly/";
            }
        } else {
            H.paths = {
                "maindir": "../Hyphenopoly/",
                "patterndir": "../Hyphenopoly/patterns/"
            };
        }
        if (H.setup) {
            if (!H.setup.classnames) {
                H.setup.classnames = {"hyphenate": {}};
            }
            if (!H.setup.timeout) {
                H.setup.timeout = 1000;
            }
        } else {
            H.setup = {
                "classnames": {"hyphenate": {}},
                "timeout": 1000
            };
        }
    }());

    (function setupEvents() {
        // Events known to the system
        const definedEvents = empty();
        // Default events, execution deferred to Hyphenopoly.js
        const deferred = [];

        /*
         * Eegister for custom event handlers, where event is not yet defined
         * these events will be correctly registered in Hyphenopoly.js
         */
        const tempRegister = [];

        /**
         * Create Event Object
         * @param {string} name The Name of the event
         * @param {function} defFunc The default method of the event
         * @param {boolean} cancellable Is the default cancellable
         * @returns {undefined}
         */
        function define(name, defFunc, cancellable) {
            definedEvents[name] = {
                "cancellable": cancellable,
                "default": defFunc,
                "register": []
            };
        }

        define(
            "timeout",
            function def(e) {
                d.documentElement.style.visibility = "visible";
                window.console.info(
                    "Hyphenopolys 'FOUHC'-prevention timed out after %dms",
                    e.delay
                );
            },
            false
        );

        define(
            "error",
            function def(e) {
                window.console.error(e.msg);
            },
            true
        );

        define(
            "contentLoaded",
            function def(e) {
                deferred.push({
                    "data": e,
                    "name": "contentLoaded"
                });
            },
            false
        );

        define(
            "engineLoaded",
            function def(e) {
                deferred.push({
                    "data": e,
                    "name": "engineLoaded"
                });
            },
            false
        );

        define(
            "hpbLoaded",
            function def(e) {
                deferred.push({
                    "data": e,
                    "name": "hpbLoaded"
                });
            },
            false
        );

        /**
         * Dispatch error <name> with arguments <data>
         * @param {string} name The name of the event
         * @param {Object|undefined} data Data of the event
         * @returns {undefined}
         */
        function dispatch(name, data) {
            if (!data) {
                data = empty();
            }
            let defaultHasRun = false;
            definedEvents[name].register.forEach(function call(currentHandler) {
                let defaultPrevented = false;
                data.preventDefault = function preventDefault() {
                    if (definedEvents[name].cancellable) {
                        defaultPrevented = true;
                    }
                };
                currentHandler(data);
                if (!defaultPrevented &&
                    !defaultHasRun &&
                    definedEvents[name].default) {
                    definedEvents[name].default(data);
                    defaultHasRun = true;
                }
            });
            if (!defaultHasRun && definedEvents[name].default) {
                definedEvents[name].default(data);
            }
        }

        /**
         * Add EventListender <handler> to event <name>
         * @param {string} name The name of the event
         * @param {function} handler Function to register
         * @param {boolean} defer If the registration is deferred
         * @returns {undefined}
         */
        function addListener(name, handler, defer) {
            if (definedEvents[name]) {
                definedEvents[name].register.push(handler);
            } else if (defer) {
                tempRegister.push({
                    "handler": handler,
                    "name": name
                });
            } else {
                H.events.dispatch(
                    "error",
                    {"msg": `unknown Event "${name}" discarded`}
                );
            }
        }

        if (H.handleEvent) {
            Object.keys(H.handleEvent).forEach(function add(name) {
                addListener(name, H.handleEvent[name], true);
            });
        }

        H.events = empty();
        H.events.deferred = deferred;
        H.events.tempRegister = tempRegister;
        H.events.dispatch = dispatch;
        H.events.define = define;
        H.events.addListener = addListener;
    }());

    (function featureTestWasm() {
        /* eslint-disable max-len, no-magic-numbers, no-prototype-builtins */
        /**
         * Feature test for wasm
         * @returns {boolean} support
         */
        function runWasmTest() {
            /*
             * This is the original test, without webkit workaround
             * if (typeof WebAssembly === "object" && typeof WebAssembly.instantiate === "function") {
             *     const module = new WebAssembly.Module(Uint8Array.from([0, 97, 115, 109, 1, 0, 0, 0]));
             *     if (WebAssembly.Module.prototype.isPrototypeOf(module)) {
             *         return WebAssembly.Instance.prototype.isPrototypeOf(new WebAssembly.Instance(module));
             *     }
             * }
             * return false;
             */

            // Wasm feature test with iOS bug detection (https://bugs.webkit.org/show_bug.cgi?id=181781)
            if (typeof WebAssembly === "object" && typeof WebAssembly.instantiate === "function") {
                const module = new WebAssembly.Module(Uint8Array.from([0, 97, 115, 109, 1, 0, 0, 0, 1, 6, 1, 96, 1, 127, 1, 127, 3, 2, 1, 0, 5, 3, 1, 0, 1, 7, 8, 1, 4, 116, 101, 115, 116, 0, 0, 10, 16, 1, 14, 0, 32, 0, 65, 1, 54, 2, 0, 32, 0, 40, 2, 0, 11]));
                if (WebAssembly.Module.prototype.isPrototypeOf(module)) {
                    const inst = new WebAssembly.Instance(module);
                    return WebAssembly.Instance.prototype.isPrototypeOf(inst) && (inst.exports.test(4) !== 0);
                }
            }
            return false;
        }
        /* eslint-enable max-len, no-magic-numbers, no-prototype-builtins */
        if (H.clientFeat.wasm === null) {
            H.clientFeat.wasm = runWasmTest();
        }
    }());

    const scriptLoader = (function scriptLoader() {
        const loadedScripts = empty();

        /**
         * Load script by adding <script>-tag
         * @param {string} path Where the script is stored
         * @param {string} filename Filename of the script
         * @returns {undefined}
         */
        function loadScript(path, filename) {
            if (!loadedScripts[filename]) {
                const script = d.createElement("script");
                loadedScripts[filename] = true;
                script.src = path + filename;
                if (filename === "hyphenEngine.asm.js") {
                    script.addEventListener("load", function listener() {
                        H.events.dispatch("engineLoaded", {"msg": "asm"});
                    });
                }
                d.head.appendChild(script);
            }
        }
        return loadScript;
    }());

    const binLoader = (function binLoader() {
        const loadedBins = empty();

        /**
         * Get bin file using fetch
         * @param {string} path Where the script is stored
         * @param {string} fne Filename of the script with extension
         * @param {Object} msg Message
         * @returns {undefined}
         */
        function fetchBinary(path, fne, msg) {
            if (!loadedBins[fne]) {
                loadedBins[fne] = true;
                fetch(path + fne).then(
                    function resolve(response) {
                        if (response.ok) {
                            const name = fne.slice(0, fne.lastIndexOf("."));
                            if (name === "hyphenEngine") {
                                H.binaries[name] = response.arrayBuffer().then(
                                    function getModule(buf) {
                                        return new WebAssembly.Module(buf);
                                    }
                                );
                            } else {
                                H.binaries[name] = response.arrayBuffer();
                            }
                            H.events.dispatch(msg[0], {"msg": msg[1]});
                        }
                    }
                );
            }
        }

        /**
         * Get bin file using XHR
         * @param {string} path Where the script is stored
         * @param {string} fne Filename of the script with extension
         * @param {Object} msg Message
         * @returns {undefined}
         */
        function requestBinary(path, fne, msg) {
            if (!loadedBins[fne]) {
                loadedBins[fne] = true;
                const xhr = new XMLHttpRequest();
                xhr.open("GET", path + fne);
                xhr.onload = function onload() {
                    const name = fne.slice(0, fne.lastIndexOf("."));
                    H.binaries[name] = xhr.response;
                    H.events.dispatch(msg[0], {"msg": msg[1]});
                };
                xhr.responseType = "arraybuffer";
                xhr.send();
            }
        }

        return (H.clientFeat.wasm)
            ? fetchBinary
            : requestBinary;
    }());

    /**
     * Allocate memory for (w)asm
     * @param {string} lang Language
     * @returns {undefined}
     */
    function allocateMemory(lang) {
        let wasmPages = 0;
        switch (lang) {
        case "nl":
            wasmPages = 41;
            break;
        case "de":
            wasmPages = 75;
            break;
        case "nb-no":
            wasmPages = 92;
            break;
        case "hu":
            wasmPages = 207;
            break;
        default:
            wasmPages = 32;
        }
        if (!H.specMems) {
            H.specMems = empty();
        }
        if (H.clientFeat.wasm) {
            H.specMems[lang] = new WebAssembly.Memory({
                "initial": wasmPages,
                "maximum": 256
            });
        } else {
            /* eslint-disable no-bitwise */
            /**
             * Polyfill Math.log2
             * @param {number} x argument
             * @return {number} Log2(x)
             */
            Math.log2 = Math.log2 || function polyfillLog2(x) {
                return Math.log(x) * Math.LOG2E;
            };

            const asmPages = (2 << Math.floor(Math.log2(wasmPages))) * 65536;
            /* eslint-enable no-bitwise */
            H.specMems[lang] = new ArrayBuffer(asmPages);
        }
    }

    /**
     * Load all ressources for a required <lang>
     * @param {string} lang The language
     * @returns {undefined}
     */
    function loadRessources(lang) {
        if (!H.binaries) {
            H.binaries = empty();
        }
        scriptLoader(H.paths.maindir, "Hyphenopoly.js");
        if (H.clientFeat.wasm) {
            binLoader(
                H.paths.maindir,
                "hyphenEngine.wasm",
                ["engineLoaded", "wasm"]
            );
        } else {
            scriptLoader(H.paths.maindir, "hyphenEngine.asm.js");
        }
        binLoader(H.paths.patterndir, `${lang}.hpb`, ["hpbLoaded", lang]);
        allocateMemory(lang);
    }

    (function featureTestCSSHHyphenation() {
        const tester = (function tester() {
            let fakeBody = null;

            /**
             * Create and append div with CSS-hyphenated word
             * @param {string} lang Language
             * @returns {undefined}
             */
            function createTest(lang) {
                if (H.clientFeat.langs[lang]) {
                    return;
                }
                if (!fakeBody) {
                    fakeBody = d.createElement("body");
                }
                const testDiv = d.createElement("div");
                testDiv.lang = lang;
                testDiv.id = lang;
                testDiv.style.cssText = "visibility:hidden;-moz-hyphens:auto;-webkit-hyphens:auto;-ms-hyphens:auto;hyphens:auto;width:48px;font-size:12px;line-height:12px;border:none;padding:0;word-wrap:normal";
                testDiv.appendChild(d.createTextNode(H.require[lang]));
                fakeBody.appendChild(testDiv);
            }

            /**
             * Append fakeBody with tests to target (document)
             * @param {Object} target Where to append fakeBody
             * @returns {Object|null} The body element or null, if no tests
             */
            function appendTests(target) {
                if (fakeBody) {
                    target.appendChild(fakeBody);
                    return fakeBody;
                }
                return null;
            }

            /**
             * Remove fakeBody
             * @returns {undefined}
             */
            function clearTests() {
                if (fakeBody) {
                    fakeBody.parentNode.removeChild(fakeBody);
                }
            }
            return {
                "appendTests": appendTests,
                "clearTests": clearTests,
                "createTest": createTest
            };
        }());

        /**
         * Checks if hyphens (ev.prefixed) is set to auto for the element.
         * @param {Object} elm - the element
         * @returns {Boolean} result of the check
         */
        function checkCSSHyphensSupport(elm) {
            return (elm.style.hyphens === "auto" ||
                elm.style.webkitHyphens === "auto" ||
                elm.style.msHyphens === "auto" ||
                elm.style["-moz-hyphens"] === "auto");
        }

        Object.keys(H.require).forEach(function doReqLangs(lang) {
            if (H.require[lang] === "FORCEHYPHENOPOLY") {
                H.clientFeat.polyfill = true;
                H.clientFeat.langs[lang] = "H9Y";
                loadRessources(lang);
            } else if (
                H.clientFeat.langs[lang] &&
                H.clientFeat.langs[lang] === "H9Y"
            ) {
                loadRessources(lang);
            } else {
                tester.createTest(lang);
            }
        });
        const testContainer = tester.appendTests(d.documentElement);
        if (testContainer !== null) {
            Object.keys(H.require).forEach(function checkReqLangs(lang) {
                if (H.require[lang] !== "FORCEHYPHENOPOLY") {
                    const el = d.getElementById(lang);
                    if (checkCSSHyphensSupport(el) && el.offsetHeight > 12) {
                        H.clientFeat.polyfill = H.clientFeat.polyfill || false;
                        H.clientFeat.langs[lang] = "CSS";
                    } else {
                        H.clientFeat.polyfill = true;
                        H.clientFeat.langs[lang] = "H9Y";
                        loadRessources(lang);
                    }
                }
            });
            tester.clearTests();
        }
    }());

    (function run() {
        if (H.clientFeat.polyfill) {
            d.documentElement.style.visibility = "hidden";

            H.setup.timeOutHandler = window.setTimeout(function timedOut() {
                d.documentElement.style.visibility = "visible";
                H.events.dispatch("timeout", {"delay": H.setup.timeout});
            }, H.setup.timeout);
            d.addEventListener(
                "DOMContentLoaded",
                function DCL() {
                    H.events.dispatch("contentLoaded", {"msg": ["contentLoaded"]});
                },
                {
                    "once": true,
                    "passive": true
                }
            );
        } else {
            window.Hyphenopoly = null;
        }
    }());

    if (H.cacheFeatureTests) {
        sessionStorage.setItem("Hyphenopoly_Loader", JSON.stringify(H.clientFeat));
    }
}());
