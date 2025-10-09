require 'rails_helper'

RSpec.describe "Efforts", type: :request do
  let(:user) { create(:user) }
  let(:turbo_stream_headers) { { "Accept" => "text/vnd.turbo-stream.html" } }
  let(:turbo_stream_content_type) { "text/vnd.turbo-stream.html" }
  let(:project) { create(:project) }

  before do
    sign_in user
  end

  describe "GET /projects/:project_id/efforts" do
    it "returns a successful response" do
      get project_efforts_path(project)
      expect(response).to be_successful
    end
  end

  describe "GET /projects/:project_id/efforts/new" do
    it "returns a successful response" do
      get new_project_effort_path(project)
      expect(response).to be_successful
    end
  end

  describe "GET /projects/:project_id/efforts/:id" do
    let(:effort) { create(:effort, project: project) }

    it "returns a successful response" do
      get project_effort_path(project, effort)
      expect(response).to be_successful
    end
  end

  describe "POST /projects/:project_id/efforts" do
    context "with valid parameters" do
      let(:valid_attributes) { { title: "New Effort", description: "An effort" } }

      it "creates a new effort" do
        expect {
          post project_efforts_path(project), params: { effort: valid_attributes }
        }.to change(Effort, :count).by(1)
      end

      it "redirects to the efforts index" do
        post project_efforts_path(project), params: { effort: valid_attributes }
        expect(response).to redirect_to(project_efforts_path(project))
      end

      it "sets a success notice" do
        post project_efforts_path(project), params: { effort: valid_attributes }
        expect(flash[:notice]).to eq("Effort was successfully created.")
      end

      context "with turbo_stream format" do
        it "responds with turbo_stream" do
          post project_efforts_path(project), params: { effort: valid_attributes }, headers: turbo_stream_headers
          expect(response.media_type).to eq(turbo_stream_content_type)
          expect(response).to have_http_status(:ok)
        end

        it "sets flash.now notice" do
          post project_efforts_path(project), params: { effort: valid_attributes }, headers: turbo_stream_headers
          expect(flash.now[:notice]).to eq("Effort was successfully created.")
        end
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { title: "" } }

      it "does not create a new effort" do
        expect {
          post project_efforts_path(project), params: { effort: invalid_attributes }
        }.not_to change(Effort, :count)
      end

      it "returns unprocessable content status" do
        post project_efforts_path(project), params: { effort: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "GET /projects/:project_id/efforts/:id/edit" do
    let(:effort) { create(:effort, project: project) }

    it "returns a successful response" do
      get edit_project_effort_path(project, effort)
      expect(response).to be_successful
    end
  end

  describe "PATCH /projects/:project_id/efforts/:id" do
    let(:effort) { create(:effort, project: project, title: "Original Title") }

    context "with valid parameters" do
      let(:new_attributes) { { title: "Updated Title", description: "Updated description" } }

      it "updates the effort" do
        patch project_effort_path(project, effort), params: { effort: new_attributes }
        effort.reload
        expect(effort.title).to eq("Updated Title")
        expect(effort.description).to eq("Updated description")
      end

      it "redirects to the efforts index" do
        patch project_effort_path(project, effort), params: { effort: new_attributes }
        expect(response).to redirect_to(project_efforts_path(project))
      end

      it "sets a success notice" do
        patch project_effort_path(project, effort), params: { effort: new_attributes }
        expect(flash[:notice]).to eq("Effort was successfully updated.")
      end

      context "with turbo_stream format" do
        it "responds with turbo_stream" do
          patch project_effort_path(project, effort), params: { effort: new_attributes }, headers: turbo_stream_headers
          expect(response.media_type).to eq(turbo_stream_content_type)
          expect(response).to have_http_status(:ok)
        end

        it "sets flash.now notice" do
          patch project_effort_path(project, effort), params: { effort: new_attributes }, headers: turbo_stream_headers
          expect(flash.now[:notice]).to eq("Effort was successfully updated.")
        end
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { title: "" } }

      it "does not update the effort" do
        patch project_effort_path(project, effort), params: { effort: invalid_attributes }
        effort.reload
        expect(effort.title).to eq("Original Title")
      end

      it "returns unprocessable content status" do
        patch project_effort_path(project, effort), params: { effort: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /projects/:project_id/efforts/:id" do
    let!(:effort) { create(:effort, project: project) }

    it "destroys the effort" do
      expect {
        delete project_effort_path(project, effort)
      }.to change(Effort, :count).by(-1)
    end

    it "redirects to the efforts index" do
      delete project_effort_path(project, effort)
      expect(response).to redirect_to(project_efforts_path(project))
    end

    it "sets a success notice" do
      delete project_effort_path(project, effort)
      expect(flash[:notice]).to eq("Effort was successfully deleted.")
    end

    context "with turbo_stream format" do
      it "responds with turbo_stream" do
        delete project_effort_path(project, effort), headers: turbo_stream_headers
        expect(response.media_type).to eq(turbo_stream_content_type)
        expect(response).to have_http_status(:ok)
      end

      it "sets flash.now notice" do
        delete project_effort_path(project, effort), headers: turbo_stream_headers
        expect(flash.now[:notice]).to eq("Effort was successfully deleted.")
      end
    end
  end
end
