require 'rails_helper'

RSpec.describe "Projects", type: :request do
  let(:turbo_stream_headers) { { "Accept" => "text/vnd.turbo-stream.html" } }
  let(:turbo_stream_content_type) { "text/vnd.turbo-stream.html" }

  describe "GET /projects" do
    it "returns a successful response" do
      get projects_path
      expect(response).to be_successful
    end
  end

  describe "GET /projects/:id" do
    let(:project) { create(:project, title: "Test Project") }

    it "returns a successful response" do
      get project_path(project)
      expect(response).to be_successful
    end
  end

  describe "GET /projects/new" do
    it "returns a successful response" do
      get new_project_path
      expect(response).to be_successful
    end
  end

  describe "POST /projects" do
    context "with valid parameters" do
      let(:valid_attributes) { { title: "New Project", description: "A great project" } }

      it "creates a new project" do
        expect {
          post projects_path, params: { project: valid_attributes }
        }.to change(Project, :count).by(1)
      end

      it "redirects to the projects index" do
        post projects_path, params: { project: valid_attributes }
        expect(response).to redirect_to(projects_path)
      end

      it "sets a success notice" do
        post projects_path, params: { project: valid_attributes }
        expect(flash[:notice]).to eq("Project was successfully created.")
      end

      context "with turbo_stream format" do
        it "responds with turbo_stream" do
          post projects_path, params: { project: valid_attributes }, headers: turbo_stream_headers
          expect(response.media_type).to eq(turbo_stream_content_type)
          expect(response).to have_http_status(:ok)
        end

        it "sets flash.now notice" do
          post projects_path, params: { project: valid_attributes }, headers: turbo_stream_headers
          expect(flash.now[:notice]).to eq("Project was successfully created.")
        end
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { title: "" } }

      it "does not create a new project" do
        expect {
          post projects_path, params: { project: invalid_attributes }
        }.not_to change(Project, :count)
      end

      it "returns unprocessable content status" do
        post projects_path, params: { project: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "GET /projects/:id/edit" do
    let(:project) { create(:project, title: "Edit Me") }

    it "returns a successful response" do
      get edit_project_path(project)
      expect(response).to be_successful
    end
  end

  describe "PATCH /projects/:id" do
    let(:project) { create(:project, title: "Original Title") }

    context "with valid parameters" do
      let(:new_attributes) { { title: "Updated Title", description: "Updated description" } }

      it "updates the project" do
        patch project_path(project), params: { project: new_attributes }
        project.reload
        expect(project.title).to eq("Updated Title")
        expect(project.description).to eq("Updated description")
      end

      it "redirects to the projects index" do
        patch project_path(project), params: { project: new_attributes }
        expect(response).to redirect_to(projects_path)
      end

      it "sets a success notice" do
        patch project_path(project), params: { project: new_attributes }
        expect(flash[:notice]).to eq("Project was successfully updated.")
      end

      context "with turbo_stream format" do
        it "responds with turbo_stream" do
          patch project_path(project), params: { project: new_attributes }, headers: turbo_stream_headers
          expect(response.media_type).to eq(turbo_stream_content_type)
          expect(response).to have_http_status(:ok)
        end

        it "sets flash.now notice" do
          patch project_path(project), params: { project: new_attributes }, headers: turbo_stream_headers
          expect(flash.now[:notice]).to eq("Project was successfully updated.")
        end
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { title: "" } }

      it "does not update the project" do
        patch project_path(project), params: { project: invalid_attributes }
        project.reload
        expect(project.title).to eq("Original Title")
      end

      it "returns unprocessable content status" do
        patch project_path(project), params: { project: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /projects/:id" do
    let!(:project) { create(:project, title: "To Be Deleted") }

    it "destroys the project" do
      expect {
        delete project_path(project)
      }.to change(Project, :count).by(-1)
    end

    it "redirects to the projects index" do
      delete project_path(project)
      expect(response).to redirect_to(projects_path)
    end

    it "sets a success notice" do
      delete project_path(project)
      expect(flash[:notice]).to eq("Project was successfully deleted.")
    end

    context "with turbo_stream format" do
      it "responds with turbo_stream" do
        delete project_path(project), headers: turbo_stream_headers
        expect(response.media_type).to eq(turbo_stream_content_type)
        expect(response).to have_http_status(:ok)
      end

      it "sets flash.now notice" do
        delete project_path(project), headers: turbo_stream_headers
        expect(flash.now[:notice]).to eq("Project was successfully deleted.")
      end
    end
  end
end
