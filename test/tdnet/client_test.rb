require 'test_helper'

class TDnet::ClientTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::TDnet::VERSION
  end

  def test_feed
    conn = stubbed_conn('/inbs/I_list_010_20160729.html', test_resource('I_list_010_20160729.html'))
    client = TDnet::Client.new
    client.stub :agent, conn do
      feeds = client.feeds(Date.new(2016, 7, 29), page: 9)
      refute_nil feeds

      assert_equal 100, feeds.count
      assert_equal 10, feeds.meta[:max_page]

      feed = feeds.each.to_a[0]
      assert_equal '64730', feed[:code]
      assert_equal '平成29年3月期 第1四半期決算短信〔日本基準〕（連結）', feed[:title]
      assert_equal Time.new(2016, 7, 29, 13, 20, 0, 32400), feed[:time]
      assert_equal 'https://www.release.tdnet.info/inbs/140120160716451864.pdf', feed[:pdf]
      assert_equal 'https://www.release.tdnet.info/inbs/081220160716451864.zip', feed[:xbrl]
      assert_equal false, feed[:changed]
      assert_equal false, feed[:deleted]

      changed_feed = feeds.each.to_a[7]
      assert_equal  '平成29年3月期　第1四半期決算短信〔日本基準〕（連結）', changed_feed[:title]
      assert_equal  true, changed_feed[:changed]
    end
  end

  def test_feed_by_url
    conn = stubbed_conn('/inbs/I_list_010_20160729.html', test_resource('I_list_010_20160729.html'))
    client = TDnet::Client.new
    client.stub :agent, conn do
      feeds = client.feeds('https://www.release.tdnet.info/inbs/I_list_010_20160729.html')
      refute_nil feeds
      assert_equal 100, feeds.count
    end
  end

  def test_deleted_feed
    conn = stubbed_conn('/inbs/I_list_001_20160711.html', test_resource('I_list_001_20160711.html'))
    client = TDnet::Client.new
    client.stub :agent, conn do
      feeds = client.feeds(Date.new(2016, 7, 11), page: 0)
      refute_nil feeds
      assert_equal  true, feeds.each.to_a[23][:deleted]
    end
  end

  def test_no_entry_day
    conn = stubbed_conn('/inbs/I_list_001_20160709.html', test_resource('I_list_001_20160709.html'))
    client = TDnet::Client.new
    client.stub :agent, conn do
      feeds = client.feeds(Date.new(2016, 7, 9), page: 0)
      refute_nil feeds
      assert_equal 0, feeds.meta[:max_page]
      assert_equal 0, feeds.meta[:page]
    end
  end

  protected

  def stubbed_conn(path, file)
    Faraday.new(url: 'https://www.release.tdnet.info/') do |builder|
      builder.request  :url_encoded
      builder.response :logger
      builder.adapter  :test do |stubs|
        stubs.get(path) do
          [ 200, {}, File.open(file)]
        end
      end
    end
  end
end
