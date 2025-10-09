# frozen_string_literal: true

module Layout
  # @label Form View
  class FormViewComponentPreview < ViewComponent::Preview
    # @label New Project Form
    def new_project
      project = Project.new(title: "", description: "")
      render Layout::FormViewComponent.new(record: project) do
        <<~HTML.html_safe
          <div class="card bg-base-100">
            <div class="card-body">
              <p class="text-sm text-gray-600">Form partial would render here with project fields</p>
              <div class="form-control">
                <label class="label"><span class="label-text">Title</span></label>
                <input type="text" class="input input-bordered" placeholder="Project title" />
              </div>
              <div class="form-control">
                <label class="label"><span class="label-text">Description</span></label>
                <textarea class="textarea textarea-bordered" placeholder="Project description"></textarea>
              </div>
              <div class="flex gap-2">
                <button class="btn btn-primary">Create Project</button>
                <a href="/projects" class="btn">Cancel</a>
              </div>
            </div>
          </div>
        HTML
      end
    end

    # @label Edit Project Form
    def edit_project
      project = create_project(1, "Existing Project")
      render Layout::FormViewComponent.new(record: project) do
        <<~HTML.html_safe
          <div class="card bg-base-100">
            <div class="card-body">
              <p class="text-sm text-gray-600">Form partial would render here with project fields</p>
              <div class="form-control">
                <label class="label"><span class="label-text">Title</span></label>
                <input type="text" class="input input-bordered" value="Existing Project" />
              </div>
              <div class="form-control">
                <label class="label"><span class="label-text">Description</span></label>
                <textarea class="textarea textarea-bordered">Sample description</textarea>
              </div>
              <div class="flex gap-2">
                <button class="btn btn-primary">Update Project</button>
                <a href="/projects/1" class="btn">Cancel</a>
              </div>
            </div>
          </div>
        HTML
      end
    end

    # @label New Category Form (Nested)
    def new_category
      project = create_project(1, "Sample Project")
      category = Category.new(title: "", category_type: "scaled", project: project)

      render Layout::FormViewComponent.new(record: category, parent_resources: [ project ]) do
        <<~HTML.html_safe
          <div class="card bg-base-100">
            <div class="card-body">
              <p class="text-sm text-gray-600">Form partial would render here with category fields</p>
              <div class="form-control">
                <label class="label"><span class="label-text">Title</span></label>
                <input type="text" class="input input-bordered" placeholder="Category title" />
              </div>
              <div class="form-control">
                <label class="label"><span class="label-text">Type</span></label>
                <select class="select select-bordered">
                  <option>Scaled</option>
                  <option>Absolute</option>
                </select>
              </div>
              <div class="flex gap-2">
                <button class="btn btn-primary">Create Category</button>
                <a href="/projects/1/categories" class="btn">Cancel</a>
              </div>
            </div>
          </div>
        HTML
      end
    end

    private

    def create_project(id, title)
      project = Project.new(id: id, title: title, description: "Description for #{title}")
      project.define_singleton_method(:persisted?) { true }
      project.define_singleton_method(:created_at) { Time.current }
      project.define_singleton_method(:updated_at) { Time.current }
      project
    end
  end
end
