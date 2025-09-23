require 'rails_helper'

RSpec.describe EffortsController, type: :controller do
  let(:project) { create(:project) }
  let(:effort) { create(:effort, project: project, title: "Original Title") }

  describe '#update' do
    before do
      allow(Project).to receive(:find).with(project.id.to_s).and_return(project)
      allow(project.efforts).to receive(:find).with(effort.id.to_s).and_return(effort)
    end

    context 'with valid parameters' do
      let(:valid_params) { { project_id: project.id, id: effort.id, effort: { title: "Updated Title" } } }

      it 'updates the effort and redirects on success' do
        expect(effort).to receive(:update).with(ActionController::Parameters.new(title: "Updated Title").permit(:title, :description, :parent_id, :position)).and_return(true)

        put :update, params: valid_params

        expect(response).to redirect_to(project_efforts_path(project))
        expect(flash[:notice]).to eq("Effort was successfully updated.")
      end

      it 'handles tree positioning parameters' do
        parent = create(:effort, project: project)
        tree_params = { project_id: project.id, id: effort.id, effort: { parent_id: parent.id, position: 1 } }

        expect(controller).to receive(:update_tree_position).with(effort, project.efforts, 1, parent.id.to_s, anything).and_return(true)
        allow(project.efforts).to receive(:find).with(parent.id.to_s).and_return(parent)

        put :update, params: tree_params

        expect(response).to redirect_to(project_efforts_path(project))
      end
    end


    context 'successful turbo stream requests' do
      let(:valid_params) { { project_id: project.id, id: effort.id, effort: { title: "Updated Title" } } }

      it 'responds with turbo stream on successful update' do
        expect(effort).to receive(:update).and_return(true)

        put :update, params: valid_params, format: :turbo_stream

        expect(response).to have_http_status(:ok)
        expect(flash.now[:notice]).to eq("Effort was successfully updated.")
      end
    end
  end
end
