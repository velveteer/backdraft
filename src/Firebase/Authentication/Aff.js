'use strict';

exports.onAuthStateChangedImpl = function (just) {
  return function (nothing) {
    return function (app) {
      return function (callback) {
        return function (errback) {
          return function () {
            return app.auth().onAuthStateChanged(function (user) {
              if (user) {
                return callback(just(user))();
              } else {
                return callback(nothing)();
              }
            }, function (err) {
              return errback(err)();
            });
          };
        };
      };
    };
  };
};

exports.signInWithRedirect = function (app) {
  return function (provider) {
    return function () {
      app.auth().signInWithRedirect(provider);
    };
  };
};

exports.signInWithPopupImpl = function (app) {
  return function (provider) {
    return function (cb) {
      return function (eb) {
        return function () {
          app.auth().signInWithPopup(provider)
            .then(function (result) {
              return cb(result.user)();
            })
            .catch(function (err) {
              return eb(err)();
            });
        };
      };
    };
  };
};

exports.signOutImpl = function (app) {
  return function (cb) {
    return function (eb) {
      return function () {
        return app.auth().signOut();
      };
    };
  };
};

