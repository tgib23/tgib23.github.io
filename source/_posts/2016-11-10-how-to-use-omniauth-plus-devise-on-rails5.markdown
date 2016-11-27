---
layout: post
title: "How to use Omniauth + Devise on Rails5 from scratch"
date: 2016-11-10 00:11:23 +0900
comments: true
categories: [oauth, omniauth, devise, rails5, facebook]
---

This post is no-brainer step by step memo to use omniauth and devise on rails5 for setting up oauth webapp with facebook.
Rails 5.0.0.1, ruby 2.3.0, devise 4.2.0, omniauth 1.3.1, omniauth-facebook 4.0.0 are used.

### 0. env & requiement
```
$ ruby -v
ruby 2.3.0p0 (2015-12-25 revision 53290) [x86_64-darwin15]

$ rails -v
Rails 5.0.0.1
```
Obtain facebook AppID and AppSecret from https://developers.facebook.com/
### 1. initial steps
create rails app
```
$ rails new omniauth && cd omniauth
```

modify Gemfile and add devise and omniauth
```
$ git diff
 diff --git a/Gemfile b/Gemfile
index 4aa8f6b..1d0e2d4 100644
--- a/Gemfile
+++ b/Gemfile
@@ -46,3 +46,6 @@ end

 # Windows does not include zoneinfo files, so bundle the tzinfo-data gem
 gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
+gem 'devise'
+gem 'omniauth'
+gem 'omniauth-facebook'

$ bundle install
$ gem list | grep devise
devise (4.2.0)
$ gem list | grep omniauth
omniauth (1.3.1)
omniauth-facebook (4.0.0)
omniauth-oauth (1.1.0)
omniauth-oauth2 (1.4.0)
$ rails g devise:install
```

If thor-0.19.2 causes error here, just uninstall thor-0.19.2 and use thor-0.19.1
```
gem 'omniauth'
gem 'omniauth-facebook'
+gem 'thor', '0.19.1'

$ bundle update
$ gem uninstall thor -v 0.19.2

```

### 2. create User model & set facebook AppID and AppSecret
Create User model and add omniauth
```
$ rails g devise User
$ rails generate model User name:string email:string
$ rails generate migration AddOmniauthToUsers provider:index uid:index
$ rake db:migrate
```
set facebook AppID and AppSecret
```
$ emacs config/initializers/devise.rb
+  config.omniauth :facebook, "APP_ID", "APP_SECRET"
```
modify app/models/user.rb and set omniauth module
```
$ git diff
diff --git a/app/models/user.rb b/app/models/user.rb
index b2091f9..288823c 100644
--- a/app/models/user.rb
+++ b/app/models/user.rb
@@ -2,5 +2,5 @@ class User < ApplicationRecord
   # Include default devise modules. Others available are:
   # :confirmable, :lockable, :timeoutable and :omniauthable
   devise :database_authenticatable, :registerable,
-         :recoverable, :rememberable, :trackable, :validatable
+         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:facebook]
```

set path config/routes.rb and confirm
```
$ git diff
diff --git a/config/routes.rb b/config/routes.rb
index 2f790f8..e88fb06 100644
--- a/config/routes.rb
+++ b/config/routes.rb
@@ -1,4 +1,4 @@
 Rails.application.routes.draw do
-  devise_for :users
   # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
+  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
 end

$ rake routes
                          Prefix Verb     URI Pattern                             Controller#Action
                new_user_session GET      /users/sign_in(.:format)                devise/sessions#new
                    user_session POST     /users/sign_in(.:format)                devise/sessions#create
            destroy_user_session DELETE   /users/sign_out(.:format)               devise/sessions#destroy
user_facebook_omniauth_authorize GET|POST /users/auth/facebook(.:format)          users/omniauth_callbacks#passthru
 user_facebook_omniauth_callback GET|POST /users/auth/facebook/callback(.:format) users/omniauth_callbacks#facebook
                   user_password POST     /users/password(.:format)               devise/passwords#create
               new_user_password GET      /users/password/new(.:format)           devise/passwords#new
              edit_user_password GET      /users/password/edit(.:format)          devise/passwords#edit
                                 PATCH    /users/password(.:format)               devise/passwords#update
                                 PUT      /users/password(.:format)               devise/passwords#update
        cancel_user_registration GET      /users/cancel(.:format)                 devise/registrations#cancel
               user_registration POST     /users(.:format)                        devise/registrations#create
           new_user_registration GET      /users/sign_up(.:format)                devise/registrations#new
          edit_user_registration GET      /users/edit(.:format)                   devise/registrations#edit
                                 PATCH    /users(.:format)                        devise/registrations#update
                                 PUT      /users(.:format)                        devise/registrations#update
                                 DELETE   /users(.:format)                        devise/registrations#destroy
```

### 3. create Callback
```
$ mkdir app/Controller/users
$ emacs app/controllers/users/omniauth_callbacks_controller.rb
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    callback_from :facebook
  end

  def twitter
    callback_from :twitter
  end

  private

  def callback_from(provider)
    provider = provider.to_s

    @user = User.find_for_oauth(request.env['omniauth.auth'])

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end
end
```

### 4. add account setting methods to User model

```
$ git diff
diff --git a/app/models/user.rb b/app/models/user.rb
index 288823c..bd060ad 100644
--- a/app/models/user.rb
+++ b/app/models/user.rb
@@ -3,4 +3,33 @@ class User < ApplicationRecord
   # :confirmable, :lockable, :timeoutable and :omniauthable
   devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:facebook]
+
+  def self.find_for_oauth(auth)
+    user = User.where(uid: auth.uid, provider: auth.provider).first
+
+    unless user
+      user = User.create(
+        uid:      auth.uid,
+        provider: auth.provider,
+        email:    User.dummy_email(auth),
+        password: Devise.friendly_token[0, 20]
+      )
+    end
+
+    user
+  end
+
+  def self.new_with_session(params, session)
+   super.tap do |user|
+     if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
+       user.email = data["email"] if user.email.blank?
+     end
+   end
+  end
+
+  private
+
+  def self.dummy_email(auth)
+    "#{auth.uid}-#{auth.provider}@example.com"
+  end
 end
```

### 5. make view

welcome/home is signin portal. home/index tells you if you are signed in or not.

```
$ rails g controller Welcome home
$ rails g controller Home index
```

modify layout
```
$ git diff
diff --git a/app/views/layouts/application.html.erb b/app/views/layouts/application.html.erb
index e164e1b..30f4849 100644
--- a/app/views/layouts/application.html.erb
+++ b/app/views/layouts/application.html.erb
@@ -9,6 +9,18 @@
   </head>

   <body>
+    <div id="notify">
+      <p class="notice"><%= notice %></p>
+      <p class="alert"><%= alert %></p>
+    </div>
+    <div id="user-info">
+      <% if user_signed_in? %>
+        <%#= current_user.name %>
+        [<%= link_to 'Sign out', destroy_user_session_path, method: :delete  %>]
+      <% else %>
+        <%= link_to "Sign in with Facebook", user_facebook_omniauth_authorize_path %>
+      <% end %>
+    </div>
     <%= yield %>
   </body>
 </html>

```

### 6. set root view
add root path and user_root

```
$ git diff
diff --git a/config/routes.rb b/config/routes.rb
index 189c56f..d936a40 100644
--- a/config/routes.rb
+++ b/config/routes.rb
@@ -3,6 +3,9 @@ Rails.application.routes.draw do

   get 'welcome/home'

+  get "home", to: "home#index", as: "user_root"
+  root 'home#index'
+
   # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
   devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
 end

```

### 7. insert authenticate_user! method to welcome/home 
```
$ git diff
diff --git a/app/controllers/welcome_controller.rb b/app/controllers/welcome_controller.rb
index 1467f18..52bd4fb 100644
--- a/app/controllers/welcome_controller.rb
+++ b/app/controllers/welcome_controller.rb
@@ -1,4 +1,5 @@
 class WelcomeController < ApplicationController
+  before_action :authenticate_user!
   def home
   end
 end
```

"before_action :authenticate_user!" will make the login view automatically.

### 8. boot and check if webapp works
```
$ rails s
```

and go check http://localhost:3000/welcome/home .
Click "Sign in with Facebook" and check if it works.


