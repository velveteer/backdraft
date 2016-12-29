'use strict';

var firebase = require('firebase/app');
var db = require('firebase/database');

exports.app = function (config) {
  return function () {
    return firebase.initializeApp(config);
  };
};

// Database and Reference API

exports.database = function (app) {
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
