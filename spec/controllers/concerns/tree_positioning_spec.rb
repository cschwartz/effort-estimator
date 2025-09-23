require 'rails_helper'

RSpec.describe TreePositioning, type: :controller do
  controller(ApplicationController) do
    include TreePositioning

    def test_update_tree_position(node, roots, new_position, new_parent_id, find_parent_node)
      update_tree_position(node, roots, new_position, new_parent_id, find_parent_node)
    end
  end

  let(:project) { create(:project) }
  let(:node) { create(:effort, project: project) }
  let(:find_parent_node) { ->(parent_id) { project.efforts.find(parent_id) } }

  describe '#update_tree_position' do
    context 'when moving to root position' do
      let!(:root1) { create(:effort, project: project, parent: nil, position: 0) }
      let!(:root2) { create(:effort, project: project, parent: nil, position: 1) }

      it 'moves node to first root position' do
        result = controller.test_update_tree_position(node, project.efforts, 0, nil, find_parent_node)

        [ node, root1, root2 ].each(&:reload)
        roots_in_order = project.efforts.roots.order(:position)

        expect(result).to be true
        expect(node.parent).to be_nil
        expect(roots_in_order).to eq([ node, root1, root2 ])
      end

      it 'moves node to middle root position' do
        result = controller.test_update_tree_position(node, project.efforts, 1, nil, find_parent_node)

        [ node, root1, root2 ].each(&:reload)
        roots_in_order = project.efforts.roots.order(:position)

        expect(result).to be true
        expect(node.parent).to be_nil
        expect(roots_in_order).to eq([ root1, node, root2 ])
      end

      it 'moves node to last root position' do
        result = controller.test_update_tree_position(node, project.efforts, 2, nil, find_parent_node)

        [ node, root1, root2 ].each(&:reload)
        roots_in_order = project.efforts.roots.order(:position)

        expect(result).to be true
        expect(node.parent).to be_nil
        expect(roots_in_order).to eq([ root1, root2, node ])
      end
    end

    context 'when moving to parent position' do
      let(:parent) { create(:effort, project: project) }

      it 'moves node to become child of parent' do
        result = controller.test_update_tree_position(node, project.efforts, 0, parent.id, find_parent_node)

        node.reload

        expect(result).to be true
        expect(node.parent).to eq(parent)
      end

      context 'when parent has existing children' do
        let!(:sibling1) { create(:effort, project: project, parent: parent, position: 0) }
        let!(:sibling2) { create(:effort, project: project, parent: parent, position: 1) }

        it 'moves node to first position among siblings' do
          result = controller.test_update_tree_position(node, project.efforts, 0, parent.id, find_parent_node)

          [ node, sibling1, sibling2 ].each(&:reload)
          children_in_order = parent.children.order(:position)

          expect(result).to be true
          expect(node.parent).to eq(parent)
          expect(children_in_order).to eq([ node, sibling1, sibling2 ])
        end

        it 'moves node to middle position among siblings' do
          result = controller.test_update_tree_position(node, project.efforts, 1, parent.id, find_parent_node)

          [ node, sibling1, sibling2 ].each(&:reload)
          children_in_order = parent.children.order(:position)

          expect(result).to be true
          expect(node.parent).to eq(parent)
          expect(children_in_order).to eq([ sibling1, node, sibling2 ])
        end

        it 'moves node to last position among siblings' do
          result = controller.test_update_tree_position(node, project.efforts, 2, parent.id, find_parent_node)

          [ node, sibling1, sibling2 ].each(&:reload)
          children_in_order = parent.children.order(:position)

          expect(result).to be true
          expect(node.parent).to eq(parent)
          expect(children_in_order).to eq([ sibling1, sibling2, node ])
        end
      end
    end

    context 'when parent lookup fails' do
      it 'returns false for invalid parent id' do
        expect {
          controller.test_update_tree_position(node, project.efforts, 0, 99999, find_parent_node)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
