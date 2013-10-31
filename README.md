No lifeguard on duty! Work in progress! 
---
---

# Spree Mitch Buchannon [![Build Status](https://travis-ci.org/Willianvdv/spree_mitch_buchannon.png?branch=master)](https://travis-ci.org/Willianvdv/spree_mitch_buchannon)

The Spree Mitch Buchannon modules saves orders. It's looking for unpaid orders and rescues them by sending a payment reminder to the customer. It also keeps the ~~sea~~ backend clean by canceling unpaid orders after x days.

## Compatiblity

I've created this gem for a Spree 1.3 store. But I will add support for 2.x stores soon!

## Installation

1) Add spree_mitch_buchannon to your Gemfile

```
gem 'spree_mitch_buchannon', github: 'Willianvdv/spree_mitch_buchannon'
```

2) Bundle it

```
$ bundle install
```

3) Install the migrations

```
$ bundle exec rake railties:install:migrations FROM=spree_wishlist
```

4) Migrate

```
$ bundle exec rake db:migrate
```


## Usage
Lets send some reminder emails!

### The manual way

To send reminder emails, just run:

```
$ bundle exec rake mitch:send_reminder_emails
```

To cancel unpaid orders:

```
$ bundle exec rake mitch:cancel_unpaid_orders
```


### In production

I recommend using [whenever](https://github.com/javan/whenever). Follow their instructions to install. Add this rule to `your_shop/config/schedule.rb`

```
every :hour do
  rake "mitch:send_reminder_emails"
end

every :hour do
  rake "mitch:cancel_unpaid_orders"
end
```



## Running the tests

First create the Spree test app:

```
$ bundle exec rake test_app
```

After that you can run the tests by doing:

```
$ bundle exec rspec
```