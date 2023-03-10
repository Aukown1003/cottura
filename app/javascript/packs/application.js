// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

import "jquery"
import "popper.js"
import "bootstrap"
import "../stylesheets/application" 

import '@fortawesome/fontawesome-free/js/all'
import "../stylesheets/header"
import "../stylesheets/top"
import "../stylesheets/recipe_index"
import "../stylesheets/recipe_show"
import "../stylesheets/recipe_new"
import "../stylesheets/sign_in_sign_up"
import "../stylesheets/user_show"
import "../stylesheets/bootstrap5"
import "../stylesheets/admin"

Rails.start()
Turbolinks.start()
ActiveStorage.start()

import Raty from "raty.js"
window.raty = function(elem,opt) {
  let raty =  new Raty(elem,opt)
  raty.init();
  return raty;
}
