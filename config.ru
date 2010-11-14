EDITOR_CMD = '/opt/local/bin/mvim -c"au VimLeave * !open -a Google\ Chrome" -f'

%w[rubygems rack].each {|l| require l }

class TextAidServer
  def call(env)
    case env["REQUEST_METHOD"]
    when "GET"
      [
        200,
        { 'Content-Type' => 'text/plain' },
        <<STR
Server is up and running.  To use it, issue a POST request with the file to edit as the content body.

{
#{env.keys.collect {|k| "  \"#{k}\" => #{env[k].inspect}" }.join("\n")}
}
STR
      ]
    when "POST"
      tempfile = Tempfile.new("text-aid-server")
      tempfile.print env["rack.input"].read
      tempfile.flush
      `#{EDITOR_CMD} #{tempfile.path}`
      tempfile.open
      body = tempfile.read.chomp
      tempfile.close!
      [200, { 'Content-Type' => 'text/plain' }, body]
    end
  end

end

run TextAidServer.new

# vim: set filetype=ruby:
