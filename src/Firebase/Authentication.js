'use strict';

var auth = require('firebase/auth');

exports.googleAuthProvider = function () {
  return new auth.GoogleAuthProvider();
};

exports.twitterAuthProvider = function () {
  return new auth.TwitterAuthProvider();
};

exports.githubAuthProvider = function () {
  return new auth.GithubAuthProvider();
};

exports.facebookAuthProvider = function () {
  return new auth.FacebookAuthProvider();
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


