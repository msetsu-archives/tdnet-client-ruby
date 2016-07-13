module TDnet
  class Client
    include TDnet::Request

    attr_reader :logger

    def initialize(options = {})
      @logger ||= options[:logger] || TDnet::Logger.default
    end

    def feeds(date = Date.today, options = {})
      page = options.delete :page
      resp = agent.get path(date, page || 0), options
      return unless resp.success?
      resp_ = resp.to_hash
      TDnet::Response::Feed.new(resp_[:body], resp_[:url].to_s)
    end
  end
end
