#require 'rack/request'

# Rack middleware to decode a `Transfer-Encoding: chunked` HTTP request.
#
# USAGE NOTE:
#
# Some HTTP servers (Webrick and Unicorn/Rabinbows/Zbatery) already decode the
# chunked stream, but they leave the 'Transfer-Encoding' header and don't bother
# to add a 'Content-Length' header, which causes rails ActionDispatch::Request
# to not parse the whole request body.
#
# If you are using Webrick or Unicorn/Rainbows/Zbatery, pass a `decoded_upstream`
# option when adding this to the middleware chain like so:
#
#     config.middleware.insert_before 'Rack::Runtime', "ChunkedTransferDecoder", decoded_upstream: true
#
# See: https://github.com/rails/rails/issues/15079
#
# Other servers (Thin and Puma) completely fail to handle the request body in
# other ways:  Thin only reads the first TCP packet (truncating the remaining request)
# and Puma gives an empty body.
# This middleware cannot fix these problems.
#
class ChunkedTransferDecoder

  TRANSFER_ENCODING = 'HTTP_TRANSFER_ENCODING'
  CHUNKED_TRANSFER_ENCODING = 'chunked'

  def initialize app, opts
    @app = app
    @decoded_upstream = opts[:decoded_upstream] || false
  end

  def call env
    #req = Rack::Request.new env

    if is_chunked_encoding?(env) #and (req.post? or req.put? or req.patch?)
      stream = env["rack.input"]
      stream.rewind if stream.respond_to?(:rewind)
      encoded = stream.read
      encoded.force_encoding(Encoding::BINARY)

      if @decoded_upstream
        decoded = encoded
      else
        #puts "ENCODED ----------- #{encoded}"
        decoded = self.class.reassemble_chunks encoded
        #puts "DECODED ----------- #{decoded}"
      end

      env['CONTENT_LENGTH'] = decoded.size
      env['RAW_POST_DATA'] = decoded
      env["rack.input"] = StringIO.new(decoded)
      env.delete TRANSFER_ENCODING
    end
    return @app.call env
  end

  def is_chunked_encoding? env
    env[TRANSFER_ENCODING] == CHUNKED_TRANSFER_ENCODING
  end

  # Reassemble HTTP chunked transfer data
  # Doc: http://en.wikipedia.org/wiki/Chunked_transfer_encoding
  # Here's an example http://twistedmatrix.com/trac/browser/tags/releases/twisted-8.2.0/twisted/web/http.py#L1206
  def self.reassemble_chunks raw_data
    reassembled_data = ""
    position = 0

    while position < raw_data.size
      end_of_chunk_size = raw_data.index "\r\n", position
      if end_of_chunk_size.nil?
        STDERR.puts "no chunk found after position #{position}"
        STDERR.puts "raw data: #{raw_data}"
        reassembled_data << raw_data[position..-1]
        break
      end
      chunk_size = raw_data[position..(end_of_chunk_size-1)].to_i 16 # chunk size represented in hex
      # TODO ensure next two characters are "\r\n"
      position = end_of_chunk_size + 2
      end_of_content = position + chunk_size
      chunk = raw_data[position..end_of_content-1]
      reassembled_data << chunk
      position += chunk.size + 2
      # TODO ensure next two characters are "\r\n"
    end
    reassembled_data
  end

end
