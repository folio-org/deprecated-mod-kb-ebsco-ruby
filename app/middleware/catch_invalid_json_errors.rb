class CatchInvalidJsonErrors
  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      @app.call(env)
    rescue ActionDispatch::Http::Parameters::ParseError => error
      if env['CONTENT_TYPE'] == 'application/vnd.api+json'
        error_output = "JSON submitted is invalid"
        return [
          400, { "Content-Type" => "application/vnd.api+json" },
          [ { status: 400, error: error_output }.to_json ]
        ]
      else
        super(env)
      end
    end
  end
end