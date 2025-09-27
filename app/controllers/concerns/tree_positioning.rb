module TreePositioning
  extend ActiveSupport::Concern

  def update_tree_position(node, roots, new_position, new_parent_id, find_parent_node)
    updated_node = if new_parent_id.blank?
      move_to_root_position(node, roots, new_position)
    else
      new_parent = find_parent_node.call(new_parent_id)
      move_to_parent_position(node, new_parent, new_position)
    end

    not updated_node.nil?
  end

  private

  def move_to_root_position(node, nodes, position)
    root_siblings = nodes.roots.where.not(id: node.id).order(:position)

    if root_siblings.empty?
      node.tap { |n| n.update(parent: nil, position: 0) }
    else
      insert_at_position(node, root_siblings, position)
    end
  end

  def move_to_parent_position(node, new_parent, position)
    siblings = new_parent.children.where.not(id: node.id).order(:position)

    if siblings.empty?
      new_parent.append_child(node)
    else
      insert_at_position(node, siblings, position)
    end
  end

  def insert_at_position(node, siblings, position)
    if position < siblings.count
      siblings[position].prepend_sibling(node)
    else
      siblings.last.append_sibling(node)
    end
  end
end
