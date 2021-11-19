---
layout: post
title: "Add twitter login with Omniauth + Devise on Rails5"
slug: add-twitter-login-with-omniauth-plus-devise-on-rails5
date: 2017-01-09 15:15:27 +0900
comments: true
tags: [devise, omniauth, rails5, twitter]
---

This post follows previous post [How to use Omniauth + Devise on Rails5 from scratch](http://tgib23.github.io/blog/2016/11/10/how-to-use-omniauth-plus-devise-on-rails5/), which is about how to setup facebook login.
This post shows how to additionally setup twitter login. You can get APP ID and APP SECRET from [here](https://apps.twitter.com/).

### 1. initial step
add omniauth-twitter in Gemfile
```bash
$ diff --git a/Gemfile b/Gemfile
index de3f792..271a916 100644
--- a/Gemfile
+++ b/Gemfile
@@ -56,3 +56,4 @@ gem 'devise'
 gem 'omniauth'
 gem 'omniauth-facebook'
 gem 'dotenv-rails'
+gem 'omniauth-twitter'

$ bundle install

$ gem list | grep omniauth
omniauth (1.3.1)
omniauth-facebook (4.0.0)
omniauth-oauth (1.1.0)
omniauth-oauth2 (1.4.0)
omniauth-twitter (1.2.1)
```

### 2. add Twitter configuration

set Twitter AppID and AppSecret
```bash
$ emacs config/initializers/devise.rb
  config.omniauth :facebook, ENV['FACEBOOK_API'], ENV['FACEBOOK_KEY']
+  config.omniauth :twitter,  ENV['TWITTER_API'],  ENV['TWITTER_KEY']

$ emacs .env
...
FACEBOOK_API="FACEBOOK_APP_ID"
FACEBOOK_KEY="FACEBOOK_APP_SECRET"
+TWITTER_API="TWITTER_APP_ID"
+TWITTER_KEY="TWITTER_APP_SECRET"

$ git diff app/models/user.rb
diff --git a/app/models/user.rb b/app/models/user.rb
index 52d48be..f62d358 100644
--- a/app/models/user.rb
+++ b/app/models/user.rb
@@ -2,7 +2,7 @@ class User < ApplicationRecord
   # Include default devise modules. Others available are:
   # :confirmable, :lockable, :timeoutable and :omniauthable
   devise :database_authenticatable, :registerable,
-         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:facebook]
+         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:facebook, :twitter]

```


### 3. modify view to allow twitter login
```bash
$ diff --git a/app/views/layouts/application.html.erb b/app/views/layouts/application.html.erb
index a9c6fde..d970abf 100644
--- a/app/views/layouts/application.html.erb
+++ b/app/views/layouts/application.html.erb
@@ -19,6 +19,8 @@
         [<%= link_to 'Sign out', destroy_user_session_path, method: :delete  %>]
       <% else %>
         <%= link_to "Sign in with Facebook", user_facebook_omniauth_authorize_path %>
+        <br>
+        <%= link_to "Sign in with Twitter", user_twitter_omniauth_authorize_path %>
       <% end %>
     </div>
```

Then, restart rails

Here are the [total diff files](https://github.com/tgib23/douzou_chan2/pull/2/files)


