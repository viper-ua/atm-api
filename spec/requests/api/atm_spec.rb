require 'rails_helper'

RSpec.describe "/api/v1", type: :request do
  before do
    ATMOne::Data.class_variable_set(:@@atm, nil)
  end

  describe "GET /check" do
    it "returns available notes" do
      get '/api/v1/check'
      expect(response).to have_http_status(200)
      expect(parsed_response).to eq({ "1" => 0, "2" => 0, "5" => 0, "10" => 0, "25" => 0, "50" => 0 })
    end
  end

  describe "POST /load" do
    context 'valid params' do
      it "loads notes to ATM" do
        post '/api/v1/load', params: '{ "stack": { "1": 2, "2": 5, "10": 7, "25": 3, "50": 1 }}', headers: { "CONTENT_TYPE" => "application/json" }
        expect(response).to have_http_status(200)
        expect(parsed_response).to eq({ "stack" => { "1" => 2, "2" => 5, "5" => 0, "10" => 7, "25" => 3, "50" => 1 }, "status" => "OK" })
      end

      it "saves notes" do
        post '/api/v1/load', params: '{ "stack": { "1": 2, "2": 5, "10": 7, "25": 3, "50": 1 }}', headers: { "CONTENT_TYPE" => "application/json" }
        get '/api/v1/check'
        expect(parsed_response).to eq({ "1" => 2, "2" => 5, "5" => 0, "10" => 7, "25" => 3, "50" => 1 })
      end
    end

    context 'invalid params' do
      it "handles amount of a string type" do
        post '/api/v1/load', params: '{ "stack": { "1": "2" }}', headers: { "CONTENT_TYPE" => "application/json" }
        expect(response).to have_http_status(200)
        expect(parsed_response).to eq({ "stack" => {"1"=>2, "2"=>0, "5"=>0, "10"=>0, "25"=>0, "50"=>0}, "status" => "OK" })
      end

      it "handles stack of invalid type" do
        post '/api/v1/load', params: '{ "stack": "INVALID" }', headers: { "CONTENT_TYPE" => "application/json" }
        expect(response).to have_http_status(400)
        expect(parsed_response).to eq({ "error" => "stack is invalid" })
      end

      it "does not change stack when present invalid notes" do
        post '/api/v1/load', params: '{ "stack": { "1": -2, "4": 3, "5": 1.5 }}', headers: { "CONTENT_TYPE" => "application/json" }
        get '/api/v1/check'
        expect(parsed_response).to eq({ "1" => 0, "2" => 0, "5" => 0, "10" => 0, "25" => 0, "50" => 0 })
      end
    end
  end

  describe "POST /withdraw" do
    context "enough notes" do
      it "withdraws requested amount" do
        post '/api/v1/load', params: '{ "stack": { "1": 2, "2": 5, "10": 7, "25": 3, "50": 1 }}', headers: { "CONTENT_TYPE" => "application/json" }
        post '/api/v1/withdraw', params: { amount: 150 }
        expect(response).to have_http_status(200)
        expect(parsed_response).to eq({ "set" => { "50" => 1, "25" => 3, "10" => 2, "2" => 2, "1" => 1 }, "status" => "OK" })
      end

      it "withdraws requested amount when a note of greater dignity is not applicable" do
        post '/api/v1/load', params: '{ "stack": { "2": 3, "5": 1 }}', headers: { "CONTENT_TYPE" => "application/json" }
        post '/api/v1/withdraw', params: { amount: 6 }
        expect(response).to have_http_status(200)
        expect(parsed_response).to eq({ "set" => { "2" => 3 }, "status" => "OK" })
      end
    end

    context "not enough notes" do
      it "responds with error message" do
        post '/api/v1/load', params: '{ "stack": { "1": 2, "2": 5, "10": 7, "25": 3, "50": 1 }}', headers: { "CONTENT_TYPE" => "application/json" }
        post '/api/v1/withdraw', params: { amount: 300 }
        expect(response).to have_http_status(200)
        expect(parsed_response).to eq("status" => "Not enough notes to withdraw")
      end

      it "doesn't change stack" do
        post '/api/v1/load', params: '{ "stack": { "1": 2, "2": 5, "10": 7, "25": 3, "50": 1 }}', headers: { "CONTENT_TYPE" => "application/json" }
        post '/api/v1/withdraw', params: { amount: 300 }
        get '/api/v1/check'
        expect(parsed_response).to eq({ "1" => 2, "2" => 5, "5" => 0, "10" => 7, "25" => 3, "50" => 1 })
      end
    end
  end
end
