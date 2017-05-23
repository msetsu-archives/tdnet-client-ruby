module TDnet
  module Request
    def request(method, path, data, options = {})
    end

    def agent
      @agent ||= Faraday.new(:url => 'https://www.release.tdnet.info/') do |faraday|
        faraday.request  :url_encoded             # form-encode POST params
        faraday.response :raise_error
        faraday.response :logger, logger if logger
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
    end

    def path(date, page = 0)
      date_param = date.strftime('%Y%m%d')
      page_param = "%03d" % (page+1)
      "/inbs/I_list_#{page_param}_#{date_param}.html"
    end
  end
end