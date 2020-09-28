require 'cgi'

module WabSarvar
  class Request
    attr_reader :method, :path, :version, :headers, :body, :params

    def initialize(request = "")
      parse(request)
    end

    def parse(request)
      @method, @path, @version = request.lines[0].split

      @headers = {}
      @body = ''

      query_string = @path.split('?')[1].to_s
      @params = CGI::parse(query_string)

      mode = :headers
      request.lines[1..-1].each do |line|
        next mode = :body if line == "\r\n"

        if mode == :headers
          header, value = line.split
          add_header(header, value)
        else
          add_body(line)
        end
      end
    end

    def add_body(line)
      @body += line
    end

    def add_header(header, value)
      header = normalize(header)
      @headers[header] = value
    end

    def normalize(header)
      header.gsub(":", "").downcase.to_sym
    end
  end
end
