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
pkey = WebPush::Utils.generate_vapid_pkey
vapid_private_key = Base64.urlsafe_encode64(pkey.private_key.to_bn.to_s(2)).delete('=')
vapid_public_key = Base64.urlsafe_encode64(pkey.public_key.to_bn.to_s(2)).delete('=')
```

```js
serviceWorker.pushManager.subscribe({
  userVisibleOnly: true,
  applicationServerKey: 'VAPID Public key(ArrayBuffer, Uint8Array or ...)',
}).then((subscription) => { ... })
```

See https://developer.mozilla.org/en/docs/Web/API/PushManager/subscribe and https://github.com/miyucy/miyucy.github.io/blob/master/push.js

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

## Know issue

For some reason web push didn't work in the Firefox if you're using ruby < 2.3.3

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/miyucy/web_push.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
