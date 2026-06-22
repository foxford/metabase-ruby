# frozen_string_literal: true

require 'faraday'
require 'metabase/error'

module Metabase
  module Connection
    QUERY_PARAM_METHODS = %i[get delete head].freeze

    def get(path, **params)
      request(:get, path, params)
    end

    def post(path, **params)
      request(:post, path, params)
    end

    def put(path, **params)
      request(:put, path, params)
    end

    def delete(path, **params)
      request(:delete, path, params)
    end

    def head(path, **params)
      request(:head, path, params)
    end

    private

    def request(method, path, params)
      headers = request_headers(params.delete(:headers))
      query_params = params.delete(:query_params) || {}

      response = connection.public_send(method, path) do |request|
        request.headers.update(headers)

        if query_param_method?(method)
          configure_query_request(request, params, query_params)
        else
          configure_body_request(request, params, query_params)
        end
      end

      error = Error.from_response(response)
      raise error if error

      response.body
    end

    def request_headers(headers)
      { 'X-Metabase-Session' => @token }.compact.merge(headers || {})
    end

    def configure_query_request(request, params, query_params)
      request.params.update(params.merge(query_params.compact))
    end

    def configure_body_request(request, params, query_params)
      query_params = query_params.compact
      request.params.update(query_params) if query_params.any?

      body = params.compact
      request.body = body if body.any?
    end

    def query_param_method?(method)
      QUERY_PARAM_METHODS.include?(method)
    end

    def connection
      @connection ||= Faraday.new(url: @url) do |c|
        c.request :json
        c.response :json
        c.request :url_encoded
        c.adapter Faraday.default_adapter
        c.headers['User-Agent'] =
          "MetabaseRuby/#{VERSION} (#{RUBY_ENGINE}#{RUBY_VERSION})"
      end
    end
  end
end
