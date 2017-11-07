class RmApiService
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
      response = http.send(verb, uri, *args, headers)
      Response.new(response)
    end
  end

  def request_multi(pending)
    responses = {}

    pending.each do |key, args|
      res = request(*args)
      responses[key] = res
      break unless res.ok?
    end

    Responses.new(responses)
  end

  private

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

  class Response
    def initialize(res)
      @res = res
    end

    def ok?
      @res.message === 'OK'
    end

    def code
      @res.code
    end

    def data
      @data ||= Map JSON.parse(@res.body)
    rescue
      nil
    end

    def errors
      return [] if ok?
      data.Errors.map { |err| { title: err.Message } }
    rescue
      [{ title: "Unhandled Error" }]
    end
  end

  class Responses
    def initialize(responses)
      @responses = responses.values
      responses.each do |key, res|
        define_singleton_method(key) { res }
      end
    end

    # Only the last response might not be OK since we break on
    # the first unsuccessful requests above in `request_multi`. So the
    # following methods simply return the data from the last response.

    def ok?
      @responses.last.ok?
    end

    def code
      @responses.last.code
    end

    def errors
      @responses.last.errors
    end
  end
end
