EDITOR_CMD = '/opt/local/bin/mvim -c"au VimLeave * !open -a Google\ Chrome" -f'

%w[rubygems sinatra].each {|l| require l }

get '/' do
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
end

post '/' do
puts "in post"
  tempfile = Tempfile.new("text-aid-server")
puts tempfile.to_s
  request.body.rewind
puts "body:",request.body
str = request.body.read[0..100]
puts "body:","-----",str,"-----"
request.body.rewind
  tempfile.print request.body.read
  tempfile.flush
puts "#{EDITOR_CMD} #{tempfile.path}"
puts \
  `#{EDITOR_CMD} #{tempfile.path}`
  tempfile.open
  body = tempfile.read.chomp
puts "body:","-----",body,"-----"
  tempfile.close!
  [200, { 'Content-Type' => 'text/plain' }, body]
end
