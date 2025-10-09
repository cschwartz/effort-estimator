require "rails_helper"

RSpec.describe "Parameters", type: :request do
  let(:user) { create(:user) }
  let(:turbo_stream_headers) { { "Accept" => "text/vnd.turbo-stream.html" } }
  let(:turbo_stream_content_type) { "text/vnd.turbo-stream.html" }
  let(:project) { create(:project) }

  before do
    sign_in user
  end

  describe "GET /projects/:project_id/parameters" do
    it "returns a successful response" do
      get project_parameters_path(project)
      expect(response).to be_successful
    end
  end

  describe "GET /projects/:project_id/parameters/:id" do
    let(:parameter) { create(:parameter, project: project) }

    it "returns a successful response" do
      get project_parameter_path(project, parameter)
      expect(response).to be_successful
    end
  end

  describe "GET /projects/:project_id/parameters/new" do
    it "returns a successful response" do
      get new_project_parameter_path(project)
      expect(response).to be_successful
    end
  end

  describe "POST /projects/:project_id/parameters" do
    context "with valid parameters" do
      let(:valid_attributes) { { title: "Team Size" } }

      it "creates a new parameter" do
        expect {
          post project_parameters_path(project), params: { parameter: valid_attributes }
        }.to change(Parameter, :count).by(1)
      end

      it "redirects to the parameters index" do
        post project_parameters_path(project), params: { parameter: valid_attributes }
        expect(response).to redirect_to(project_parameters_path(project))
      end

      it "sets a success notice" do
        post project_parameters_path(project), params: { parameter: valid_attributes }
        expect(flash[:notice]).to eq("Parameter was successfully created.")
      end

      context "with turbo_stream format" do
        it "responds with turbo_stream" do
          post project_parameters_path(project), params: { parameter: valid_attributes }, headers: turbo_stream_headers
          expect(response.media_type).to eq(turbo_stream_content_type)
          expect(response).to have_http_status(:ok)
        end

        it "sets flash.now notice" do
          post project_parameters_path(project), params: { parameter: valid_attributes }, headers: turbo_stream_headers
          expect(flash.now[:notice]).to eq("Parameter was successfully created.")
        end
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { title: "" } }

      it "does not create a new parameter" do
        expect {
          post project_parameters_path(project), params: { parameter: invalid_attributes }
        }.not_to change(Parameter, :count)
      end

      it "returns unprocessable content status" do
        post project_parameters_path(project), params: { parameter: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "GET /projects/:project_id/parameters/:id/edit" do
    let(:parameter) { create(:parameter, project: project) }

    it "returns a successful response" do
      get edit_project_parameter_path(project, parameter)
      expect(response).to be_successful
    end
  end

  describe "PATCH /projects/:project_id/parameters/:id" do
    let(:parameter) { create(:parameter, project: project, title: "Original Title") }

    context "with valid parameters" do
      let(:new_attributes) { { title: "Updated Title" } }

      it "updates the parameter" do
        patch project_parameter_path(project, parameter), params: { parameter: new_attributes }
        parameter.reload
        expect(parameter.title).to eq("Updated Title")
      end

      it "redirects to the parameters index" do
        patch project_parameter_path(project, parameter), params: { parameter: new_attributes }
        expect(response).to redirect_to(project_parameters_path(project))
      end

      it "sets a success notice" do
        patch project_parameter_path(project, parameter), params: { parameter: new_attributes }
        expect(flash[:notice]).to eq("Parameter was successfully updated.")
      end

      context "with turbo_stream format" do
        it "responds with turbo_stream" do
          patch project_parameter_path(project, parameter), params: { parameter: new_attributes }, headers: turbo_stream_headers
          expect(response.media_type).to eq(turbo_stream_content_type)
          expect(response).to have_http_status(:ok)
        end

        it "sets flash.now notice" do
          patch project_parameter_path(project, parameter), params: { parameter: new_attributes }, headers: turbo_stream_headers
          expect(flash.now[:notice]).to eq("Parameter was successfully updated.")
        end
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { title: "" } }

      it "does not update the parameter" do
        patch project_parameter_path(project, parameter), params: { parameter: invalid_attributes }
        parameter.reload
        expect(parameter.title).to eq("Original Title")
      end

      it "returns unprocessable content status" do
        patch project_parameter_path(project, parameter), params: { parameter: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /projects/:project_id/parameters/:id" do
    let!(:parameter) { create(:parameter, project: project) }

    it "destroys the parameter" do
      expect {
        delete project_parameter_path(project, parameter)
      }.to change(Parameter, :count).by(-1)
    end

    it "redirects to the parameters index" do
      delete project_parameter_path(project, parameter)
      expect(response).to redirect_to(project_parameters_path(project))
    end

    it "sets a success notice" do
      delete project_parameter_path(project, parameter)
      expect(flash[:notice]).to eq("Parameter was successfully deleted.")
    end

    context "with turbo_stream format" do
      it "responds with turbo_stream" do
        delete project_parameter_path(project, parameter), headers: turbo_stream_headers
        expect(response.media_type).to eq(turbo_stream_content_type)
        expect(response).to have_http_status(:ok)
      end

      it "sets flash.now notice" do
        delete project_parameter_path(project, parameter), headers: turbo_stream_headers
        expect(flash.now[:notice]).to eq("Parameter was successfully deleted.")
      end
    end
  end
end
