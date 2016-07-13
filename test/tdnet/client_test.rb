require 'test_helper'

class TDnet::ClientTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::TDnet::VERSION
  end

  def test_feed
    conn = Faraday.new do |builder|
      builder.request  :url_encoded
      builder.response :logger
      builder.adapter  :test do |stubs|
        stubs.get('/inbs/I_list_001_20160713.html') do
          [ 200, {}, File.open(test_resource('I_list_001_20160713.html'))]
        end
      end
    end

    client = TDnet::Client.new
    client.stub :agent, conn do
      feeds = client.feeds(Date.new(2016, 7, 13), page: 0)
      refute_nil feeds
      assert_equal 100, feeds.count

      feed = feeds.each.to_a.last
      refute_nil feed
      assert_equal '24620', feed[:code]
      assert_equal Time.new(2016, 7, 13, 15, 0, 0, '+09:00'), feed[:time]
    end
  end
end
