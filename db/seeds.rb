require 'factory_bot_rails'

project = FactoryBot.create(:project, name: "Test project")

project.views << FactoryBot.build(:view, name: "Example view 1", main_form_container: FactoryBot.build(:container))

main_form_container = project.views[0].main_form_container

main_form_container.elements << FactoryBot.build(:element, position: 0, elementable: FactoryBot.build(:numeric_input))
main_form_container.elements << FactoryBot.build(:element, position: 1, elementable: FactoryBot.build(:container))
main_form_container.elements << FactoryBot.build(:element, position: 2, elementable: FactoryBot.build(:text_input))

nested_container = main_form_container.element_list[1]

nested_container.elements << FactoryBot.build(:element, position: 0, elementable: FactoryBot.build(:numeric_input))
nested_container.elements << FactoryBot.build(:element, position: 1, elementable: FactoryBot.build(:option_input, :colors))

view = project.views[0]

query1 = view.queries.create({})
query1.query_histories.create({
  comment: "First",
  config_version: 1,
  content: {
    sql: "SELECT * FROM users WHERE age > {{age}};"
  }
})

query2 = view.queries.create({})
query2.query_histories.create({
  comment: "First",
  config_version: 1,
  content: {
    sql: "SELECT * FROM posts WHERE updated_at > '2017-02-04';"
  }
})
