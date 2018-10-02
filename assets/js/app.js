const { Elm } = require("../apps/Main.elm");

var app = Elm.Main.init({
  flags: {
    user: window.appContext.user
  }
});

