module TDnet
  class Client
    include TDnet::Request

    attr_reader :logger

    def initialize(options = {})
      @logger ||= options[:logger] || TDnet::Logger.default
    end

    def feeds(date_or_url = Date.today, options = {})
      path = case date_or_url
               when Date
                 page = options.delete :page
                 path(date_or_url, page || 0)
               else
                 date_or_url
             end
      resp = agent.get path, options
      return unless resp.success?
      resp_ = resp.to_hash
      TDnet::Response::Feed.new(resp_[:body], resp.env.url)
    end
  end
end
