# frozen_string_literal: true

require "uri"
require "net/http"
require "json"

require_relative "configuration"
require_relative "request"
require_relative "response"
require_relative "resources"
require_relative "util"
require_relative "error"

module Monday
  # Client executes requests against the monday.com's API and
  # allows a user to mutate and retrieve resources.
  class Client
    JSON_CONTENT_TYPE = "application/json"
    private_constant :JSON_CONTENT_TYPE

    attr_reader :config

    def initialize(config_args = {})
      @config = configure(config_args)
      Resources.initialize(self)
    end

    def make_request(body)
      response = Request.post(uri, proxy_params, body, request_headers)

      handle_response(Response.new(response))
    end

    private

    def configure(config_args)
      return Monday.config if config_args.empty?

      Configuration.new(**config_args)
    end

    def uri
      URI(@config.host)
    end

    def proxy_params
      [@config.proxy_address, @config.proxy_port]
    end

    def request_headers
      {
        "Content-Type": "application/json",
        Authorization: @config.token
      }
    end

    def handle_response(response)
      return response if response.success?

      raise_errors(response)
    end

    def raise_errors(response)
      raise default_exception(response) unless successful_response?(response.status)

      raise response_exception(response)
    end

    def response_exception(response)
      error_code = response.body["error_code"]

      return Error.new(response: response) if error_code.nil?

      exception_klass, code = Util.response_error_exceptions_mapping(error_code)
      exception_klass.new(message: error_code, response: response, code: code)
    end

    def default_exception(response)
      Util.status_code_exceptions_mapping(response.status).new(response: response)
    end

    def successful_response?(status)
      (200..299).cover?(status)
    end
  end
end
