# frozen_string_literal: true

module Monday
  # Defines the HTTP request methods.
  class Request
    # Performs a POST request
    def self.post(uri, query, headers)
      proxy_params = [Monday.config.proxy_address, Monday.config.proxy_port]
      http = Net::HTTP.new(uri.host, uri.port, *proxy_params)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri.request_uri, headers)

      request.body = {
        "query" => query
      }.to_json

      http.request(request)
    end
  end
end
