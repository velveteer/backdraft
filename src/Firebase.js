'use strict';

var firebase = require('firebase/app');
var auth = require('firebase/auth');
var db = require('firebase/database');

exports.appInit = function (config) {
  return function () {
    return firebase.initializeApp(config);
  };
}

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
}

exports.onAuthStateChangedImpl = function (just) {
  return function (nothing) {
    return function (app) {
      return function (callback) {
        return function () {
          return app.auth().onAuthStateChanged(function (user) {
            if (user) {
              return callback(just(user))();
            } else {
              return callback(nothing)();
            }
          });
        };
      };
    };
  };
}

exports.googleAuthProvider = function () {
  return new auth.GoogleAuthProvider();
}

exports.signInWithRedirect = function (app) {
  return function (provider) {
    return function () {
      app.auth().signInWithRedirect(provider);
    };
  };
}

exports.signInWithPopup = function (app) {
  return function (provider) {
    return function () {
      app.auth().signInWithPopup(provider);
    };
  };
}

exports.signOut = function (app) {
  return function () {
    app.auth().signOut();
  };
}
