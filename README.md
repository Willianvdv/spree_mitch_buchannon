No lifeguard on duty! Work in progress! 
---
---

# Spree Mitch Bucannon

The Spree Mitch Bucannon modules saves orders. It's looking for unpaid orders and rescues them by sending a payment reminder to the customer. It also keeps the ~~sea~~ backend clean by canceling unpaid orders after x days.


## Installation

Add spree_mitch_bucannon to your Gemfile

`gem 'spree_mitch_bucannon', github: 'Willianvdv/spree_mitch_bucannon'`


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