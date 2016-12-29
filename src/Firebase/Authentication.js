'use strict';

var auth = require('firebase/auth');

exports.googleAuthProvider = function () {
  return new auth.GoogleAuthProvider();
};

exports.currentUserImpl = function (just) {
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


