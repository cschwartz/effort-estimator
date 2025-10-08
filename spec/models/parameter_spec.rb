# frozen_string_literal: true

require "rails_helper"

RSpec.describe Parameter, type: :model do
  let(:project) { Project.create!(title: "Test Project") }

  describe "associations" do
    it "belongs to project" do
      parameter = Parameter.new(project: project, title: "Test Parameter")
      expect(parameter.project).to eq(project)
    end
  end

  describe "validations" do
    it "requires a title" do
      parameter = Parameter.new(project: project, title: nil)
      expect(parameter).not_to be_valid
      expect(parameter.errors[:title]).to include("can't be blank")
    end

    it "requires unique title within project scope" do
      Parameter.create!(project: project, title: "Team Size")
      duplicate = Parameter.new(project: project, title: "Team Size")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:title]).to include("has already been taken")
    end

    it "allows duplicate title across different projects" do
      other_project = Project.create!(title: "Other Project")
      Parameter.create!(project: project, title: "Team Size")
      duplicate = Parameter.new(project: other_project, title: "Team Size")
      expect(duplicate).to be_valid
    end
  end

  describe "dependent destroy" do
    it "is destroyed when project is destroyed" do
      parameter = Parameter.create!(project: project, title: "Test Parameter")

      expect { project.destroy }.to change(Parameter, :count).by(-1)
    end
  end
end
