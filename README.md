# WebPush

Similar to https://github.com/web-push-libs/web-push

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'web_push'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install web_push

## Usage

```ruby
subscription = {
  endpoint: 'https://example.com/...',
  keys: {
    p256dh: 'URL-Safe Base64 String',
    auth: 'URL-Safe Base64 String',
  }
}
webpush = WebPush.new subscription
webpush.set_vapid_details('mailto:sender@example.com',
                          'VAPID Public key(URL-Safe Base64 String)',
                          'VAPID Private key(URL-Safe Base64 String)')
webpush.send_notification("Payload String")
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/miyucy/web_push.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
