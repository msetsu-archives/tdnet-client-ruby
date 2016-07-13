# tdnet-client-ruby

Simple scraper for www.release.tdnet.info

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tdnet-client'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tdnet-client

## Usage

```ruby

client = TDnet::Client.new

feeds = client.feeds # Auto pagenated responses
feeds.count
# => 100
feeds.meta[:date].to_s
# => "2016-07-13"
feeds.each.to_a.last[:code]
# => "12345"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ka2n/tdnet-client-ruby.

