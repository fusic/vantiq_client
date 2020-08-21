require 'vantiq_client/version'
require 'json'


module VantiqClient
  class Error < StandardError; end

  def initialize(faraday_client: nil, vantiq_url)
    @faraday_client = faraday_client || Faraday.new(url: "https://#{vantiq_url}")
  end

  def create(model_alias, recodes)
    res = @faraday_client.post do |req|
      http_headers(req)
      req.url(model_alias.to_s)
      req.body = recodes.to_json
    end
    JSON.parse(res.body)
  end

  def update(model_alias, id, diff)
    res = @faraday_client.put do |req|
      http_headers(req)
      req.url("#{model_alias}?where={\"id\":#{id}}")
      req.body = diff.to_json
    end
    JSON.parse(res.body)
  end

  def delete(model_alias, id)
    res = @faraday_client.delete do |req|
      http_headers(req)
      req.url("#{model_alias}?where={\"id\":#{id}}")
    end
    JSON.parse(res.body)
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
