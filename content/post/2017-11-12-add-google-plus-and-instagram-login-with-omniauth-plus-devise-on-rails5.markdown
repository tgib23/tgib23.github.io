---
layout: post
title: "Add Google Plus and Instagram Login with Omniauth + Devise on Rails5"
slug: add-google-plus-and-instagram-login-with-omniauth-plus-devise-on-rails5
date: 2017-11-12 16:23:58 +0900
comments: true
tags: [devise, google plus, instagram, oauth, omniauth, rails5]
---

This post shows how to implement google plus and instagram login with omniauth and devise on rails5.
This change totally depends on my previous implementation for [facebook](http://tgib23.github.io/blog/2016/11/10/how-to-use-omniauth-plus-devise-on-rails5/) and [twitter](http://tgib23.github.io/blog/2017/01/09/add-twitter-login-with-omniauth-plus-devise-on-rails5/), so if you are new to implement this, you should look at those posts first.
I write about google plus first, then add instagram login later.

# Implement Google Plus Login

### 0. Get Google APP ID and SECRET
You can get CLIENT ID and CLIENT_SECRET from [here](code.google.com/apis/console).
If you are building on local machine, you should add "http://localhost:3000/users/auth/google_oauth2/callback" to Authorized Redirect URI.

### 1. initial step
add omniauth-google-oauth2 to Gemfile
```bash
 gem 'omniauth-twitter'
+gem 'omniauth-google-oauth2'
 gem 'geocoder'

$ bundle install

$ gem list | grep omniauth
omniauth (1.3.1)
omniauth-facebook (4.0.0)
omniauth-google-oauth2 (0.5.2)
omniauth-instagram (1.2.0)
omniauth-oauth (1.1.0)
omniauth-oauth2 (1.4.0)
```


### 2. add Google Plus configuration

Set Google Client ID and Client Secret.
Because I use "dotenv-rails", I use ENV vars.
```bash
$ emacs config/initializers/devise.rb
  config.omniauth :facebook, ENV['FACEBOOK_API'], ENV['FACEBOOK_KEY']
  config.omniauth :twitter,  ENV['TWITTER_API'],  ENV['TWITTER_KEY']
+  config.omniauth :google_oauth2,  ENV['GOOGLE_CLIENT_ID'],  ENV['GOOGLE_CLIENT_SECRET']

$ emacs .env
FACEBOOK_API="xxxxxxxxxx"
FACEBOOK_KEY="xxxxxxxxxxxxxx"
TWITTER_API="xxxxxxxxxxxxx"
TWITTER_KEY="xxxxxxxxxxxxx"
+ GOOGLE_CLIENT_ID="xxxxxxxxxxxxxxxx"
+ GOOGLE_CLIENT_SECRET="xxxxxxxxxxxxxxxxx"

$ git diff app/models/user.rb
diff --git a/app/models/user.rb b/app/models/user.rb
index 52d48be..f62d358 100644
--- a/app/models/user.rb
+++ b/app/models/user.rb
@@ -2,7 +2,7 @@ class User < ApplicationRecord
   # Include default devise modules. Others available are:
   # :confirmable, :lockable, :timeoutable and :omniauthable
   devise :database_authenticatable, :registerable,
-         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:facebook, :twitter]
+         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:facebook, :twitter, :google_oauth2]

```



### 3. modify view to allow google plus login

Add link for google plus login.

```bash
diff --git a/app/views/layouts/application.html.erb b/app/views/layouts/application.html.erb
--- a/app/views/layouts/application.html.erb
+++ b/app/views/layouts/application.html.erb
@@ -19,6 +19,8 @@
         [<%= link_to 'Sign out', destroy_user_session_path, method: :delete  %>]
       <% else %>
         <%= link_to "Sign in with Facebook", user_facebook_omniauth_authorize_path %>
         <br>
         <%= link_to "Sign in with Twitter", user_twitter_omniauth_authorize_path %>
+        <br>
+        <%= link_to "Sign in with Google Plus", user_google_oauth2_omniauth_authorize_path %>
       <% end %>
     </div>
```


### 4. Delete except info

Because I met "ActionDispatch::Cookies::CookieOverflow (ActionDispatch::Cookies::CookieOverflow):" error, I modified omniauth_callback_controller as follows.
This will eliminate extra fields from cookie.

```ruby
-      session["devise.#{provider}_data"] = request.env["omniauth.auth"]
+      session["devise.#{provider}_data"] = request.env["omniauth.auth"].except("extra")
```


Here are the [total diff files](https://github.com/tgib23/douzou_chan2/pull/137/files) for adding google plus login.
Notice that I use semantic-ui, so the changes on the code is not the same as this blog.

# Implement Instagram Login

The changes are the same as Google Plus Login.
Get Instagram client id and client secret from [here](https://www.instagram.com/developer/)

### 1. initial step
add omniauth-instagram in Gemfile

```bash
$ diff --git a/Gemfile b/Gemfile
--- a/Gemfile
+++ b/Gemfile
gem 'omniauth-google-oauth2'
+ gem 'omniauth-instagram'
gem 'geocoder'

$ bundle install

$ gem list | grep omniauth
omniauth (1.3.1)
omniauth-facebook (4.0.0)
omniauth-google-oauth2 (0.5.2)
omniauth-instagram (1.2.0)
omniauth-oauth (1.1.0)
omniauth-oauth2 (1.4.0)
omniauth-twitter (1.2.1)
```

### 2. add Instagram configuration

```bash

$ emacs config/initializers/devise.rb
  config.omniauth :facebook,       ENV['FACEBOOK_API'],          ENV['FACEBOOK_KEY']
  config.omniauth :twitter,        ENV['TWITTER_API'],           ENV['TWITTER_KEY']
  config.omniauth :google_oauth2,  ENV['GOOGLE_CLIENT_ID'],      ENV['GOOGLE_CLIENT_SECRET']
+  config.omniauth :instagram,      ENV['INSTAGRAM_CLIENT_ID'],   ENV['INSTAGRAM_CLIENT_SECRET']



$ emacs .env
...
GOOGLE_CLIENT_ID="xxxxxxxxxxx"
GOOGLE_CLIENT_SECRET="xxxxxxxxxx"
+INSTAGRAM_CLIENT_ID="xxxxxxxxxxxxxxxx"
+INSTAGRAM_CLIENT_SECRET="xxxxxxxxxxxx"

$ git diff app/models/user.rb

diff --git a/app/models/user.rb b/app/models/user.rb
index 52d48be..f62d358 100644
--- a/app/models/user.rb
+++ b/app/models/user.rb
@@ -2,7 +2,7 @@ class User < ApplicationRecord
   # Include default devise modules. Others available are:
   # :confirmable, :lockable, :timeoutable and :omniauthable
   devise :database_authenticatable, :registerable,
-         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:facebook, :twitter, :google_oauth2]
+         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:facebook, :twitter, :google_oauth2, :instagram]

```

### 3. modify view to allow instagram login

```bash
diff --git a/app/views/layouts/application.html.erb b/app/views/layouts/application.html.erb
index a9c6fde..d970abf 100644
--- a/app/views/layouts/application.html.erb
+++ b/app/views/layouts/application.html.erb
@@ -19,6 +19,8 @@
         [<%= link_to 'Sign out', destroy_user_session_path, method: :delete  %>]
       <% else %>
         <%= link_to "Sign in with Facebook", user_facebook_omniauth_authorize_path %>
        <br>
        <%= link_to "Sign in with Twitter", user_twitter_omniauth_authorize_path %>
        <br>
        <%= link_to "Sign in with Google Plus", user_google_oauth2_omniauth_authorize_path %>
+         <br>
+         <%= link_to "Sign in with Instagram", user_instagram_omniauth_authorize_path %>
       <% end %>
     </div>
```

Then, restart rails

Here are the [total diff files](https://github.com/tgib23/douzou_chan2/pull/138/files) for adding instagram login.


