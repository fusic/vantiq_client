require 'vantiq_client/version'
require 'json'

module VantiqClient
  class Error < StandardError; end

  def initialize(faraday_client: nil, vantiq_url)
    @faraday_client = faraday_client || Faraday.new(url: "https://#{vantiq_url}")
  end

  def index(model_alias)
    res = @faraday_client.get do |req|
      http_headers(req)
      req.url(model_alias.to_s)
    end
    res
  end

  def show(model_alias, id)
    res = @faraday_client.get do |req|
      http_headers(req)
      req.url("#{model_alias}?where={\"id\":#{id}}")
    end
    res
  end

  def create(model_alias, recodes, vantiq_token)
    res = @faraday_client.post do |req|
      http_headers(req, vantiq_token)
      req.url(model_alias.to_s)
      req.body = recodes.to_json
    end
    res
  end

  def update(model_alias, id, diff, vantiq_token)
    res = @faraday_client.put do |req|
      http_headers(req, vantiq_token)
      req.url("#{model_alias}?where={\"id\":#{id}}")
      req.body = diff.to_json
    end
    res
  end

  def delete(model_alias, id, vantiq_token)
    res = @faraday_client.delete do |req|
      http_headers(req, vantiq_token)
      req.url("#{model_alias}?where={\"id\":#{id}}")
    end
    res
  end

  private

  def http_headers(req, vantiq_token)
    [
      ['Authorization', "Bearer #{vantiq_token}"],
      ['Content-Type', 'application/json']
    ].each do |key, val|
      req.headers[key] = val
    end
  end
end
