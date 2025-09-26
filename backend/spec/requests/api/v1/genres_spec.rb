require 'rails_helper'

RSpec.describe "Api::V1::Genres", type: :request do
  describe "GET /show" do
    it "returns http success" do
      get "/api/v1/genres/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /index" do
    it "returns http success" do
      get "/api/v1/genres/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/api/v1/genres/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/api/v1/genres/destroy"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /search_artist" do
    it "returns http success" do
      get "/api/v1/genres/search_artist"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /search_album" do
    it "returns http success" do
      get "/api/v1/genres/search_album"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /search_music" do
    it "returns http success" do
      get "/api/v1/genres/search_music"
      expect(response).to have_http_status(:success)
    end
  end

end
