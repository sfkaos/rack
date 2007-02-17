require 'test/spec'
require 'stringio'

require 'rack/testrequest'
require 'rack/request'

context "Rack::Request" do
  specify "wraps the rack variables" do
    req = Rack::Request.new(TestRequest.env({}))

    req.body.should.respond_to? :gets
    req.scheme.should.equal "http"
    req.method.should.equal "GET"
    req.script_name.should.equal ""
    req.path_info.should.equal "/"
    req.host.should.equal "example.org"
    req.port.should.equal 8080
  end

  specify "can figure out the correct host" do
    req = Rack::Request.new(TestRequest.env({"HTTP_HOST" => "www2.example.org"}))
    req.host.should.equal "www2.example.org"
  end

  specify "can parse the query string" do
    req = Rack::Request.new(TestRequest.env("QUERY_STRING"=>"foo=bar&quux=bla"))
    req.GET.should.equal "foo" => "bar", "quux" => "bla"
    req.POST.should.be.empty
    req.params.should.equal "foo" => "bar", "quux" => "bla"
  end

  specify "can parse POST data" do
    req = Rack::Request.new(TestRequest.env("QUERY_STRING"=>"foo=quux",
                              "rack.input" => StringIO.new("foo=bar&quux=bla")))
    req.GET.should.equal "foo" => "quux"
    req.POST.should.equal "foo" => "bar", "quux" => "bla"
    req.params.should.equal "foo" => "bar", "quux" => "bla"
  end

  specify "can figure out if called via XHR" do
    req = Rack::Request.new(TestRequest.env({}))
    req.should.not.be.xhr

    req = Rack::Request.new(TestRequest.env("HTTP_X_REQUESTED_WITH" => "XMLHttpRequest"))
    req.should.be.xhr
  end

  specify "can parse cookies" do
    req = Rack::Request.new(TestRequest.env({"HTTP_COOKIE" => "foo=bar;quux=h&m"}))
    req.cookies.should.equal "foo" => "bar", "quux" => "h&m"
  end
end