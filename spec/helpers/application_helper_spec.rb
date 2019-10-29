require "spec_helper"

describe ApplicationHelper, type: :helper do
  describe "#step" do
    it "generates the html for a step" do
      expect(helper.step(1, "Blah")).to eq("<span class=\"step step-1\">Blah</span>")
    end
  end

  describe "#current_path_without_query_string" do
    it "returns the path of the current request" do
      allow(helper).to receive(:request).and_return(ActionDispatch::TestRequest.new("PATH_INFO" => "/foo/bar"))
      assert_equal "/foo/bar", helper.current_path_without_query_string
    end

    it "returns the path of the current request stripping off any query string parameters" do
      allow(helper).to receive(:request).and_return(ActionDispatch::TestRequest.new("PATH_INFO" => "/foo/bar", "QUERY_STRING" => "ham=jam&spam=gram"))
      assert_equal "/foo/bar", helper.current_path_without_query_string
    end
  end
end
