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

  readme2 = "# Member data

  These queries are all related to site member data. It has some global form inputs and also per-query. Some queries don't have inputs (they just use the global ones)."

  project.views << FactoryBot.build(:view, readme: readme_text, name: "Example view 1", container: FactoryBot.build(:container))
  project.views << FactoryBot.build(:view, readme: readme2, name: "Member data", container: FactoryBot.build(:container))

  container = project.views[0].container

  container.elements << FactoryBot.build(:element, position: 0, label: "Age", elementable: FactoryBot.build(:numeric_input), description: "Enter your age, it will be used to calculate your estimated height and weight.")
  container.elements << FactoryBot.build(:element, position: 1, elementable: FactoryBot.build(:container))
  container.elements << FactoryBot.build(:element, position: 2, label: "Message", elementable: FactoryBot.build(:text_input, placeholder: "I'm here to say my true feelings"))

  nested_container = container.element_list[1]

  nested_container.elements << FactoryBot.build(:element, position: 0, label: "Height", elementable: FactoryBot.build(:numeric_input, placeholder: "175cm"))
  nested_container.elements << FactoryBot.build(:element, position: 1, label: "Favorite color", elementable: FactoryBot.build(:option_input, :colors), description: "This is necessary to know about your personality.")
  nested_container.elements << FactoryBot.build(:element, position: 2, elementable: FactoryBot.build(:container, is_active: "data => data['dummy_element-2']['dummy_element-5'] == 1"))

  nested_container2 = nested_container.element_list[2]

  nested_container2.elements << FactoryBot.build(:element, position: 0, label: "Sickest math number", elementable: FactoryBot.build(:option_input, :numbers))

  view = project.views[0]
  view2 = project.views[1]

  view2.container.elements << FactoryBot.build(:element, position: 0, label: "Member ID", elementable: FactoryBot.build(:numeric_input, :decimal, :required, placeholder: 1234), description: "ID of member to perform all queries on.")

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

  query3 = view2.queries.create({})

  query4 = view2.queries.create({})
  query4.container = FactoryBot.build(:container)
  query4.container.elements << FactoryBot.build(:element, position: 0, label: "Max member age", elementable: FactoryBot.build(:numeric_input, :integer))
  query4.save!


end
