'use strict';

var firebase = require('firebase/app');
var auth = require('firebase/auth');
var db = require('firebase/database');

exports.appInit = function (config) {
  return function () {
    return firebase.initializeApp(config);
  };
};

exports.getCurrentUserImpl = function (just) {
  return function (nothing) {
    return function (app) {
      return function () {
        var user = app.auth().currentUser;
        if (user) {
          return just(user);
        } else {
          return nothing;
        }
      };
    };
  };
};

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

exports.googleAuthProvider = function () {
  return new auth.GoogleAuthProvider();
};

exports.signInWithRedirect = function (app) {
  return function (provider) {
    return function () {
      app.auth().signInWithRedirect(provider);
    };
  };
};

exports.signInWithPopup = function (app) {
  return function (provider) {
    return function () {
      app.auth().signInWithPopup(provider);
    };
  };
};

exports.signOut = function (app) {
  return function () {
    app.auth().signOut();
  };
};

// Database and Reference API

exports.getDatabase = function (app) {
  return function () {
    return app.database();
  };
};

exports.getRootRef = function (database) {
  return function () {
    return database.ref();
  };
};

exports.ref = function (database) {
  return function (path) {
    return function () {
      return database.ref();
    };
  };
}

exports.child = function (path) {
  return function (ref) {
    return function () {
      return ref.child(path);
    };
  };
};

exports.onImpl = function (ref) {
  return function (cb) {
    return function (eb) {
      return function () {
        var callback = function (value) {
          cb(value)();
        };
        var error = function (err) {
          eb(err)();
        };
        return ref.on('value', callback, error);
      };
    };
  };
};
