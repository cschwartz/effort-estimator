require 'rails_helper'

RSpec.describe "EstimationOptions", type: :request do
  let(:user) { create(:user) }
  let(:turbo_stream_headers) { { "Accept" => "text/vnd.turbo-stream.html" } }
  let(:turbo_stream_content_type) { "text/vnd.turbo-stream.html" }

  before do
    sign_in user
  end

  describe "GET /estimation_options" do
    it "returns a successful response" do
      get estimation_options_path
      expect(response).to be_successful
    end
  end

  describe "GET /estimation_options/:id" do
    let(:estimation_option) { create(:estimation_option, title: "Fibonacci") }

    it "returns a successful response" do
      get estimation_option_path(estimation_option)
      expect(response).to be_successful
    end
  end

  describe "GET /estimation_options/new" do
    it "returns a successful response" do
      get new_estimation_option_path
      expect(response).to be_successful
    end
  end

  describe "POST /estimation_options" do
    context "with valid parameters" do
      let(:valid_attributes) { { title: "Fibonacci" } }

      it "creates a new estimation option" do
        expect {
          post estimation_options_path, params: { estimation_option: valid_attributes }
        }.to change(EstimationOption, :count).by(1)
      end

      it "redirects to the estimation options index" do
        post estimation_options_path, params: { estimation_option: valid_attributes }
        expect(response).to redirect_to(estimation_options_path)
      end

      it "sets a success notice" do
        post estimation_options_path, params: { estimation_option: valid_attributes }
        expect(flash[:notice]).to eq("Estimation option was successfully created.")
      end

      context "with turbo_stream format" do
        it "responds with turbo_stream" do
          post estimation_options_path, params: { estimation_option: valid_attributes }, headers: turbo_stream_headers
          expect(response.media_type).to eq(turbo_stream_content_type)
          expect(response).to have_http_status(:ok)
        end

        it "sets flash.now notice" do
          post estimation_options_path, params: { estimation_option: valid_attributes }, headers: turbo_stream_headers
          expect(flash.now[:notice]).to eq("Estimation option was successfully created.")
        end
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { title: "" } }

      it "does not create a new estimation option" do
        expect {
          post estimation_options_path, params: { estimation_option: invalid_attributes }
        }.not_to change(EstimationOption, :count)
      end

      it "returns unprocessable content status" do
        post estimation_options_path, params: { estimation_option: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "GET /estimation_options/:id/edit" do
    let(:estimation_option) { create(:estimation_option) }

    it "returns a successful response" do
      get edit_estimation_option_path(estimation_option)
      expect(response).to be_successful
    end
  end

  describe "PATCH /estimation_options/:id" do
    let(:estimation_option) { create(:estimation_option, title: "Old Title") }

    context "with valid parameters" do
      let(:new_attributes) { { title: "New Title" } }

      it "updates the estimation option" do
        patch estimation_option_path(estimation_option), params: { estimation_option: new_attributes }
        estimation_option.reload
        expect(estimation_option.title).to eq("New Title")
      end

      it "redirects to the estimation options index" do
        patch estimation_option_path(estimation_option), params: { estimation_option: new_attributes }
        expect(response).to redirect_to(estimation_options_path)
      end

      it "sets a success notice" do
        patch estimation_option_path(estimation_option), params: { estimation_option: new_attributes }
        expect(flash[:notice]).to eq("Estimation option was successfully updated.")
      end

      context "with turbo_stream format" do
        it "responds with turbo_stream" do
          patch estimation_option_path(estimation_option), params: { estimation_option: new_attributes }, headers: turbo_stream_headers
          expect(response.media_type).to eq(turbo_stream_content_type)
          expect(response).to have_http_status(:ok)
        end

        it "sets flash.now notice" do
          patch estimation_option_path(estimation_option), params: { estimation_option: new_attributes }, headers: turbo_stream_headers
          expect(flash.now[:notice]).to eq("Estimation option was successfully updated.")
        end
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { title: "" } }

      it "returns unprocessable content status" do
        patch estimation_option_path(estimation_option), params: { estimation_option: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /estimation_options/:id" do
    let!(:estimation_option) { create(:estimation_option) }

    it "destroys the estimation option" do
      expect {
        delete estimation_option_path(estimation_option)
      }.to change(EstimationOption, :count).by(-1)
    end

    it "redirects to the estimation options index" do
      delete estimation_option_path(estimation_option)
      expect(response).to redirect_to(estimation_options_path)
    end

    it "sets a success notice" do
      delete estimation_option_path(estimation_option)
      expect(flash[:notice]).to eq("Estimation option was successfully deleted.")
    end

    context "with turbo_stream format" do
      it "responds with turbo_stream" do
        delete estimation_option_path(estimation_option), headers: turbo_stream_headers
        expect(response.media_type).to eq(turbo_stream_content_type)
        expect(response).to have_http_status(:ok)
      end

      it "sets flash.now notice" do
        delete estimation_option_path(estimation_option), headers: turbo_stream_headers
        expect(flash.now[:notice]).to eq("Estimation option was successfully deleted.")
      end
    end
  end
end
