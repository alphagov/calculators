require 'spec_helper'

describe ChildBenefitTaxController do

  describe "GET 'landing'" do
    it "returns http success" do
      get 'landing'
      response.should be_success
    end
  end

end
