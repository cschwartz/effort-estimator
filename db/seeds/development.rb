password = "password"

%w[alice bob].each do |name|
  email = "#{ name }@example.com"
  unless User.find_by(email: email)
    user = User.new(
        email: email,
        password: password,
        password_confirmation: password
    )
    user.save!
  end
end

EstimationOption.find_or_create_by(title: "Fibonacci") do |option|
  [ 1, 2, 3, 5, 8, 13 ].each do |value|
    option.estimation_option_values.build(value: value)
  end
end

project = Project.find_or_create_by(title: "Software Development Project", description: "Web application")

Effort.find_or_create_by(
    title: "Frontend Development",
    description: "UI components",
    project: project
)
backend_effort = Effort.find_or_create_by(
    title: "Backend Development",
    description: "API services",
    project: project
)
Effort.find_or_create_by(
    title: "User Authentication",
    description: "Login system",
    parent: backend_effort,
    project: project
)

Category.find_or_create_by(title: "Test", category_type: :scaled, project: project)
Category.find_or_create_by(title: "Implementation", category_type: :absolute, project: project)

Parameter.find_or_create_by(title: "User Stories", project: project)
