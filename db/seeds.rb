require 'factory_bot_rails'

ActiveRecord::Base.transaction do

  project = FactoryBot.create(:project, name: "Test project")

  readme_text = "# Instructions

  In order to use this view, you might want to consider the following things:

  1. This is just a demo.
  2. It's still bugged and being developed.
  3. The inputs don't mean anything, it's just for testing.

  Remember that *this text is also just for testing markdown*.

  おやすみなさい〜
  "

  project.views << FactoryBot.build(:view, readme: readme_text, name: "Example view 1", main_form_container: FactoryBot.build(:container))

  main_form_container = project.views[0].main_form_container

  main_form_container.elements << FactoryBot.build(:element, position: 0, label: "Age", elementable: FactoryBot.build(:numeric_input), description: "Enter your age, it will be used to calculate your estimated height and weight.")
  main_form_container.elements << FactoryBot.build(:element, position: 1, elementable: FactoryBot.build(:container))
  main_form_container.elements << FactoryBot.build(:element, position: 2, label: "Message", elementable: FactoryBot.build(:text_input, placeholder: "I'm here to say my true feelings"))

  nested_container = main_form_container.element_list[1]

  nested_container.elements << FactoryBot.build(:element, position: 0, label: "Height", elementable: FactoryBot.build(:numeric_input, placeholder: "175cm"))
  nested_container.elements << FactoryBot.build(:element, position: 1, label: "Favorite color", elementable: FactoryBot.build(:option_input, :colors), description: "This is necessary to know about your personality.")
  nested_container.elements << FactoryBot.build(:element, position: 2, elementable: FactoryBot.build(:container, is_active: "data => data['dummy_element-2']['dummy_element-5'] == 1"))

  nested_container2 = nested_container.element_list[2]

  nested_container2.elements << FactoryBot.build(:element, position: 0, label: "Sickest math number", elementable: FactoryBot.build(:option_input, :numbers))

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

end
