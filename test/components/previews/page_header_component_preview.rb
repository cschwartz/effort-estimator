# frozen_string_literal: true

# @label Page Header
class PageHeaderComponentPreview < ViewComponent::Preview
  # @label With Class
  def with_class
    render PageHeaderComponent.new(Project)
  end

  # @label With String
  def with_string
    render PageHeaderComponent.new("Custom Title")
  end

  # @label With Persisted Record
  def with_persisted_record
    project = Project.new(id: 1, title: "Sample Project")
    project.define_singleton_method(:persisted?) { true }
    render PageHeaderComponent.new(project)
  end

  # @label With New Record
  def with_new_record
    project = Project.new(title: "Sample Project")
    render PageHeaderComponent.new(project)
  end

  # @label With Create Action
  def with_create_action; end

  # @label With Custom Label Create Action
  def with_custom_label_create; end

  # @label With Edit and Delete Actions
  def with_edit_and_delete; end

  # @label With Custom Confirm Message
  def with_custom_confirm; end
end
