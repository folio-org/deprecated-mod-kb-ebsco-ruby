class RmApiService
  attr_reader :response, :errors

  def initialize(params)
    @base_url = params[:base_url]
    @customer_id = params[:customer_id]
    @api_key = params[:api_key]
  end

  def request(verb, path, body = nil)
    uri = uri_for(path)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    http.start do
      args = [body].compact
      @response = http.send(verb, uri, *args, headers)

      if @response.message === 'OK'
        success!
      else
        fail!
      end
    end
  end

  private

  def success!
    @errors = []
    Map JSON.parse(@response.body)
  rescue
    return true
  end

  def fail!
    data = Map JSON.parse(@response.body)
    @errors = data.Errors.map { |err| { title: err.Message } }
  rescue
    @errors = [{ title: "Unhandled Error" }]
  ensure
    return false
  end

  def uri_for(path)
    URI(
      "%{base}/rm/rmaccounts/%{customer_id}/%{path}" % {
        base: @base_url,
        customer_id: @customer_id,
        path: path
      }
    )
  end

  def headers
    {
      "X-Api-Key" => @api_key,
      "Content-Type" => 'application/json',
      "Accept" => 'application/json'
    }
  end
end
