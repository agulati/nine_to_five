class SquareSpaceClient

  def self.get_orders(before: nil, after: nil)
    response = client.get(route: "orders", args: args)
    JSON.parse(response.body)["result"] || []
  rescue => e
    []
  end

  def self.client
    @@client ||= new
  end

  def initialize
    @url      = ENV["SQUARESPACE_URL"]
    @api_key  = ENV["SQUARESPACE_API_KEY"]
  end

  def get(route:, params:, headers: {})
    send_request(:get, route, params, headers)
  end

  private

  def send_request(method, route, parameters, headers, body={})
    response = connection.send(method) do |req|
      req.headers["Content-Type"] = "application/json" if method.eql?("post")

      parameters.each { |k,v| req.params["#{k}"] = v } if parameters.any?
      headers.each { |k,v| req.headers["#{k}"] = v } if headers.any?

      req.headers["Authorization"] = "Bearer #{@api_key}"
      req.url "/1.0/commerce/#{route}"
      req.body = body unless body.empty?
    end
  end

  def connection
    @connection ||= Faraday.new(url: @url) do |faraday|
      faraday.request  :url_encoded
      faraday.adapter  Faraday.default_adapter
    end
  end
end
