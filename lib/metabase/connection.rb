# frozen_string_literal: true

require 'faraday'
require 'metabase/error'

module Metabase
  module Connection
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
      headers = params.delete(:headers)
      query_params = params.delete(:query_params) || {}
      query_params[:format_rows] = params.delete(:format_rows)

      response = connection.public_send(method, path, params) do |request|
        request.headers['X-Metabase-Session'] = @token if @token
        headers&.each_pair { |k, v| request.headers[k] = v }
        request.params = query_params.compact
      end

      error = Error.from_response(response)
      raise error if error

      response.body
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
