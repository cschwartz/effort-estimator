require 'rails_helper'

RSpec.describe "Categories", type: :request do
  let(:turbo_stream_headers) { { "Accept" => "text/vnd.turbo-stream.html" } }
  let(:turbo_stream_content_type) { "text/vnd.turbo-stream.html" }
  let(:project) { create(:project) }

  describe "GET /projects/:project_id/categories" do
    it "returns a successful response" do
      get project_categories_path(project)
      expect(response).to be_successful
    end
  end

  describe "GET /projects/:project_id/categories/:id" do
    let(:category) { create(:category, project: project) }

    it "returns a successful response" do
      get project_category_path(project, category)
      expect(response).to be_successful
    end
  end

  describe "GET /projects/:project_id/categories/new" do
    it "returns a successful response" do
      get new_project_category_path(project)
      expect(response).to be_successful
    end
  end

  describe "POST /projects/:project_id/categories" do
    context "with valid parameters" do
      let(:valid_attributes) { { title: "New Category", category_type: "scaled" } }

      it "creates a new category" do
        expect {
          post project_categories_path(project), params: { category: valid_attributes }
        }.to change(Category, :count).by(1)
      end

      it "redirects to the categories index" do
        post project_categories_path(project), params: { category: valid_attributes }
        expect(response).to redirect_to(project_categories_path(project))
      end

      it "sets a success notice" do
        post project_categories_path(project), params: { category: valid_attributes }
        expect(flash[:notice]).to eq("Category was successfully created.")
      end

      context "with turbo_stream format" do
        it "responds with turbo_stream" do
          post project_categories_path(project), params: { category: valid_attributes }, headers: turbo_stream_headers
          expect(response.media_type).to eq(turbo_stream_content_type)
          expect(response).to have_http_status(:ok)
        end

        it "sets flash.now notice" do
          post project_categories_path(project), params: { category: valid_attributes }, headers: turbo_stream_headers
          expect(flash.now[:notice]).to eq("Category was successfully created.")
        end
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { title: "" } }

      it "does not create a new category" do
        expect {
          post project_categories_path(project), params: { category: invalid_attributes }
        }.not_to change(Category, :count)
      end

      it "returns unprocessable content status" do
        post project_categories_path(project), params: { category: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "GET /projects/:project_id/categories/:id/edit" do
    let(:category) { create(:category, project: project) }

    it "returns a successful response" do
      get edit_project_category_path(project, category)
      expect(response).to be_successful
    end
  end

  describe "PATCH /projects/:project_id/categories/:id" do
    let(:category) { create(:category, project: project, title: "Original Title") }

    context "with valid parameters" do
      let(:new_attributes) { { title: "Updated Title", category_type: "absolute" } }

      it "updates the category" do
        patch project_category_path(project, category), params: { category: new_attributes }
        category.reload
        expect(category.title).to eq("Updated Title")
        expect(category.category_type).to eq("absolute")
      end

      it "redirects to the categories index" do
        patch project_category_path(project, category), params: { category: new_attributes }
        expect(response).to redirect_to(project_categories_path(project))
      end

      it "sets a success notice" do
        patch project_category_path(project, category), params: { category: new_attributes }
        expect(flash[:notice]).to eq("Category was successfully updated.")
      end

      context "with turbo_stream format" do
        it "responds with turbo_stream" do
          patch project_category_path(project, category), params: { category: new_attributes }, headers: turbo_stream_headers
          expect(response.media_type).to eq(turbo_stream_content_type)
          expect(response).to have_http_status(:ok)
        end

        it "sets flash.now notice" do
          patch project_category_path(project, category), params: { category: new_attributes }, headers: turbo_stream_headers
          expect(flash.now[:notice]).to eq("Category was successfully updated.")
        end
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { title: "" } }

      it "does not update the category" do
        patch project_category_path(project, category), params: { category: invalid_attributes }
        category.reload
        expect(category.title).to eq("Original Title")
      end

      it "returns unprocessable content status" do
        patch project_category_path(project, category), params: { category: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /projects/:project_id/categories/:id" do
    let!(:category) { create(:category, project: project) }

    it "destroys the category" do
      expect {
        delete project_category_path(project, category)
      }.to change(Category, :count).by(-1)
    end

    it "redirects to the categories index" do
      delete project_category_path(project, category)
      expect(response).to redirect_to(project_categories_path(project))
    end

    it "sets a success notice" do
      delete project_category_path(project, category)
      expect(flash[:notice]).to eq("Category was successfully deleted.")
    end

    context "with turbo_stream format" do
      it "responds with turbo_stream" do
        delete project_category_path(project, category), headers: turbo_stream_headers
        expect(response.media_type).to eq(turbo_stream_content_type)
        expect(response).to have_http_status(:ok)
      end

      it "sets flash.now notice" do
        delete project_category_path(project, category), headers: turbo_stream_headers
        expect(flash.now[:notice]).to eq("Category was successfully deleted.")
      end
    end
  end
end
