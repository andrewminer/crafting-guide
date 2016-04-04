(function() {
    "use strict";

    function t(t) {
        return "function" == typeof t || "object" == typeof t && null !== t
    }

    function e(t) {
        return "function" == typeof t
    }

    function n(t) {
        return "object" == typeof t && null !== t
    }

    function r(t) {
        U = t
    }

    function o(t) {
        J = t
    }

    function s() {
        return function() {
            process.nextTick(f)
        }
    }

    function i() {
        return function() {
            R(f)
        }
    }

    function u() {
        var t = 0,
            e = new z(f),
            n = document.createTextNode("");
        return e.observe(n, {
            characterData: !0
        }),
        function() {
            n.data = t = ++t % 2
        }
    }

    function a() {
        var t = new MessageChannel;
        return t.port1.onmessage = f,
        function() {
            t.port2.postMessage(0)
        }
    }

    function c() {
        return function() {
            setTimeout(f, 1)
        }
    }

    function f() {
        for (var t = 0; X > t; t += 2) {
            var e = V[t],
                n = V[t + 1];
            e(n), V[t] = void 0, V[t + 1] = void 0
        }
        X = 0
    }

    function l() {
        try {
            var t = require,
                e = t("vertx");
            return R = e.runOnLoop || e.runOnContext, i()
        } catch (t) {
            return c()
        }
    }

    function p() {}

    function d() {
        return new TypeError("You cannot resolve a promise with itself")
    }

    function h() {
        return new TypeError("A promises callback cannot return that same promise.")
    }

    function v(t) {
        try {
            return t.then
        } catch (t) {
            return et.error = t, et
        }
    }

    function _(t, e, n, r) {
        try {
            t.call(e, n, r)
        } catch (t) {
            return t
        }
    }

    function m(t, e, n) {
        J(function(t) {
            var r = !1,
                o = _(n, e, function(n) {
                    r || (r = !0, e !== n ? w(t, n) : j(t, n))
                }, function(e) {
                    r || (r = !0, x(t, e))
                }, "Settle: " + (t._label || " unknown promise"));
            !r && o && (r = !0, x(t, o))
        }, t)
    }

    function y(t, e) {
        e._state === $ ? j(t, e._result) : e._state === tt ? x(t, e._result) : A(e, void 0, function(e) {
            w(t, e)
        }, function(e) {
            x(t, e)
        })
    }

    function g(t, n) {
        if (n.constructor === t.constructor) y(t, n);
        else {
            var r = v(n);
            r === et ? x(t, et.error) : void 0 === r ? j(t, n) : e(r) ? m(t, n, r) : j(t, n)
        }
    }

    function w(e, n) {
        e === n ? x(e, d()) : t(n) ? g(e, n) : j(e, n)
    }

    function b(t) {
        t._onerror && t._onerror(t._result), E(t)
    }

    function j(t, e) {
        t._state === Z && (t._result = e, t._state = $, 0 !== t._subscribers.length && J(E, t))
    }

    function x(t, e) {
        t._state === Z && (t._state = tt, t._result = e, J(b, t))
    }

    function A(t, e, n, r) {
        var o = t._subscribers,
            s = o.length;
        t._onerror = null, o[s] = e, o[s + $] = n, o[s + tt] = r, 0 === s && t._state && J(E, t)
    }

    function E(t) {
        var e = t._subscribers,
            n = t._state;
        if (0 !== e.length) {
            for (var r, o, s = t._result, i = 0; i < e.length; i += 3) r = e[i], o = e[i + n], r ? L(n, r, o, s) : o(s);
            t._subscribers.length = 0
        }
    }

    function T() {
        this.error = null
    }

    function S(t, e) {
        try {
            return t(e)
        } catch (t) {
            return nt.error = t, nt
        }
    }

    function L(t, n, r, o) {
        var s, i, u, a, c = e(r);
        if (c) {
            if (s = S(r, o), s === nt ? (a = !0, i = s.error, s = null) : u = !0, n === s) return void x(n, h())
        } else s = o, u = !0;
        n._state !== Z || (c && u ? w(n, s) : a ? x(n, i) : t === $ ? j(n, s) : t === tt && x(n, s))
    }

    function P(t, e) {
        try {
            e(function(e) {
                w(t, e)
            }, function(e) {
                x(t, e)
            })
        } catch (e) {
            x(t, e)
        }
    }

    function O(t, e) {
        var n = this;
        n._instanceConstructor = t, n.promise = new t(p), n._validateInput(e) ? (n._input = e, n.length = e.length, n._remaining = e.length, n._init(), 0 === n.length ? j(n.promise, n._result) : (n.length = n.length || 0, n._enumerate(), 0 === n._remaining && j(n.promise, n._result))) : x(n.promise, n._validationError())
    }

    function M(t) {
        return new rt(this, t).promise
    }

    function C(t) {
        function e(t) {
            w(o, t)
        }

        function n(t) {
            x(o, t)
        }
        var r = this,
            o = new r(p);
        if (!N(t)) return x(o, new TypeError("You must pass an array to race.")), o;
        for (var s = t.length, i = 0; o._state === Z && s > i; i++) A(r.resolve(t[i]), void 0, e, n);
        return o
    }

    function F(t) {
        var e = this;
        if (t && "object" == typeof t && t.constructor === e) return t;
        var n = new e(p);
        return w(n, t), n
    }

    function I(t) {
        var e = this,
            n = new e(p);
        return x(n, t), n
    }

    function q() {
        throw new TypeError("You must pass a resolver function as the first argument to the promise constructor")
    }

    function k() {
        throw new TypeError("Failed to construct 'Promise': Please use the 'new' operator, this object constructor cannot be called as a function.")
    }

    function B(t) {
        this._id = at++, this._state = void 0, this._result = void 0, this._subscribers = [], p !== t && (e(t) || q(), this instanceof B || k(), P(this, t))
    }

    function D() {
        var t;
        if ("undefined" != typeof global) t = global;
        else if ("undefined" != typeof self) t = self;
        else try {
            t = Function("return this")()
        } catch (t) {
            throw new Error("polyfill failed because global object is unavailable in this environment")
        }
        var e = t.Promise;
        (!e || "[object Promise]" !== Object.prototype.toString.call(e.resolve()) || e.cast) && (t.Promise = ct)
    }
    var H;
    H = Array.isArray ? Array.isArray : function(t) {
        return "[object Array]" === Object.prototype.toString.call(t)
    };
    var R, U, Y, N = H,
        X = 0,
        J = ({}.toString, function(t, e) {
            V[X] = t, V[X + 1] = e, X += 2, 2 === X && (U ? U(f) : Y())
        }),
        K = "undefined" != typeof window ? window : void 0,
        W = K || {}, z = W.MutationObserver || W.WebKitMutationObserver,
        G = "undefined" != typeof process && "[object process]" === {}.toString.call(process),
        Q = "undefined" != typeof Uint8ClampedArray && "undefined" != typeof importScripts && "undefined" != typeof MessageChannel,
        V = new Array(1e3);
    Y = G ? s() : z ? u() : Q ? a() : void 0 === K && "function" == typeof require ? l() : c();
    var Z = void 0,
        $ = 1,
        tt = 2,
        et = new T,
        nt = new T;
    O.prototype._validateInput = function(t) {
        return N(t)
    }, O.prototype._validationError = function() {
        return new Error("Array Methods must be provided an Array")
    }, O.prototype._init = function() {
        this._result = new Array(this.length)
    };
    var rt = O;
    O.prototype._enumerate = function() {
        for (var t = this, e = t.length, n = t.promise, r = t._input, o = 0; n._state === Z && e > o; o++) t._eachEntry(r[o], o)
    }, O.prototype._eachEntry = function(t, e) {
        var r = this,
            o = r._instanceConstructor;
        n(t) ? t.constructor === o && t._state !== Z ? (t._onerror = null, r._settledAt(t._state, e, t._result)) : r._willSettleAt(o.resolve(t), e) : (r._remaining--, r._result[e] = t)
    }, O.prototype._settledAt = function(t, e, n) {
        var r = this,
            o = r.promise;
        o._state === Z && (r._remaining--, t === tt ? x(o, n) : r._result[e] = n), 0 === r._remaining && j(o, r._result)
    }, O.prototype._willSettleAt = function(t, e) {
        var n = this;
        A(t, void 0, function(t) {
            n._settledAt($, e, t)
        }, function(t) {
            n._settledAt(tt, e, t)
        })
    };
    var ot = M,
        st = C,
        it = F,
        ut = I,
        at = 0,
        ct = B;
    B.all = ot, B.race = st, B.resolve = it, B.reject = ut, B._setScheduler = r, B._setAsap = o, B._asap = J, B.prototype = {
        constructor: B,
        then: function(t, e) {
            var n = this,
                r = n._state;
            if (r === $ && !t || r === tt && !e) return this;
            var o = new this.constructor(p),
                s = n._result;
            if (r) {
                var i = arguments[r - 1];
                J(function() {
                    L(r, o, i, s)
                })
            } else A(n, o, t, e);
            return o
        },
        catch: function(t) {
            return this.then(null, t)
        }
    };
    var ft = D,
        lt = {
            Promise: ct,
            polyfill: ft
        };
    "function" == typeof define && define.amd ? define(function() {
        return lt
    }) : "undefined" != typeof module && module.exports ? module.exports = lt : "undefined" != typeof this && (this.ES6Promise = lt), ft()
}).call(this);

var emailjs = new function() {
        var t = this;
        this.version = "0.1", this.secure = !0, this.server = "api.emailjs.com", this.init = function(e, n, r) {
            t.user_id = e, "undefined" != typeof n && (t.server = n), "undefined" != typeof r && (t.secure = r)
        }, this.send = function(e, n, r, o) {
            var s = t.secure ? "https:" : "http:",
                i = [s, "", t.server, "api/v1.0/email/send"].join("/");
            if (document.getElementById("g-recaptcha-response")) var u = document.getElementById("g-recaptcha-response").value || null;
            return new Promise(function(s, a) {
                var c = new XMLHttpRequest;
                c.open("POST", i), c.setRequestHeader("Content-Type", "application/json;charset=UTF-8"), c.onload = function() {
                    200 == this.status ? s({
                        status: c.status,
                        text: c.responseText
                    }) : a({
                        status: c.status,
                        text: c.responseText
                    })
                }, c.onerror = function() {
                    a({
                        status: c.status,
                        text: c.responseText
                    })
                }, u && (r["g-recaptcha-response"] = u);
                var f = {
                    user_id: o || t.user_id,
                    service_id: e,
                    template_id: n,
                    template_params: r
                };
                c.send(JSON.stringify(f))
            })
        }, this.sendForm = function(e, n, r, o) {
            var s = null,
                i = null;
            if ("undefined" != typeof o && o) i = o;
            else {
                if ("undefined" == typeof t.user_id || !t.user_id) throw "Error. User ID not found.";
                i = t.user_id
            } if ("undefined" == typeof r || !r) throw "Error. Form id/object not found.";
            if ("string" == typeof r) s = document.getElementById(r);
            else {
                if ("object" != typeof r) throw "Error. invalid form type";
                s = r
            }
            s.classList.remove("emailjs-sending"), s.classList.remove("emailjs-success"), s.classList.remove("emailjs-error");
            var u = t.secure ? "https:" : "http:",
                a = [u, "", t.server, "api/v1.0/email/send-form"].join("/");
            return new Promise(function(t, r) {
                s.classList.add("emailjs-sending");
                var o = new XMLHttpRequest;
                o.open("POST", a, !0), o.onload = function() {
                    s.classList.remove("emailjs-sending"), 200 == this.status ? (s.classList.add("emailjs-success"), t({
                        status: o.status,
                        text: o.responseText
                    })) : (s.classList.add("emailjs-error"), r({
                        status: o.status,
                        text: o.responseText
                    }))
                }, o.onerror = function() {
                    s.classList.add("emailjs-error"), r({
                        status: o.status,
                        text: o.responseText
                    })
                };
                var u = new FormData(s);
                u.append("user_id", i), u.append("service_id", e), u.append("template_id", n), o.send(u)
            })
        }
    };

module.exports = emailjs