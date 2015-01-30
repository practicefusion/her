require "spec_helper"

describe Her::Middleware::SnakeCaseParser do
  subject { described_class.new }

  context "with valid JSON body" do
    let(:body) { "{\"root\": {\"fooBar\": {\"bazQux\" : 1} }, \"errors\": [{\"strawMan\": 2}], \"metadata\": 3}" }

    it "parses :body key as json in the env hash" do
      env = { :body => body }
      subject.on_complete(env)
      env[:body].tap do |json|
        json[:data].should == { 'root' => { 'foo_bar' => { 'baz_qux' => 1 } } }
        json[:errors].should == [{ 'straw_man' => 2 }]
        json[:metadata].should == 3
      end
    end
  end
end
