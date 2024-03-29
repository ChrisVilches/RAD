require 'factory_bot_rails'

ActiveRecord::Base.transaction do

  u1 = FactoryBot.create(:user)
  u2 = FactoryBot.create(:user)
  u3 = FactoryBot.create(:user)
  u4 = FactoryBot.create(:user)
  u5 = FactoryBot.create(:user)
  u6 = FactoryBot.create(:user)
  u7 = FactoryBot.create(:user)

  company = FactoryBot.create(:company, url: "felo", name: "Felo K.K. フェロ株式会社")

  company.users << u1

  project = FactoryBot.create(:project, name: "Test project", company: company)
  project.users << u1
  pp = project.project_participations.first
  pp.develop_permission = true
  pp.save

  readme_text = "# Instructions

  In order to use this view, you might want to consider the following things:

  1. This is just a demo.
  2. It's still bugged and being developed.
  3. The inputs don't mean anything, it's just for testing.
  4. Type \"I love you\" in \"Message\" to make a container appear (query 1).
  5. Choose white as favorite color and type 777 in \"Type some number\" to make a container appear (query 2).

  Remember that *this text is also just for testing markdown*.

  おやすみなさい〜
  "

  readme2 = "# Member data

  These queries are all related to site member data. It has some global form inputs and also per-query. Some queries don't have inputs (they just use the global ones)."

  project.views << FactoryBot.build(:view, readme: readme_text, name: "Example view 1", container: FactoryBot.build(:container))
  project.views << FactoryBot.build(:view, readme: readme2, name: "Member data", container: FactoryBot.build(:container))
  project.views << FactoryBot.build(:view, published: false, readme: "This is a hidden view.", name: "Another view", container: FactoryBot.build(:container))

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

  query1 = view.queries.create({ name: "Ring ding dong" })
  query1.description = "Description for query 1."
  query1.container = FactoryBot.build(:container)
  query1.container.elements << FactoryBot.build(:element, position: 0, elementable: FactoryBot.build(:container, is_active: "(data, global) => global['dummy_element-3'] == \"I love you\""))
  nested_container_query1 = query1.container.element_list[0]
  nested_container_query1.elements << FactoryBot.build(:element, position: 0, label: "The value", elementable: FactoryBot.build(:numeric_input, :integer))
  query1.save!
  query1.query_histories.create({
    comment: "First",
    config_version: 1,
    content: {
      sql: "SELECT * FROM users WHERE age > {{age}};"
    }
  })

  query2 = view.queries.create({ name: "Boom shakalaka" })
  query2.description = "Description for query 2."
  query2.container = FactoryBot.build(:container)
  query2.container.elements << FactoryBot.build(:element, position: 0, label: "Type some number", elementable: FactoryBot.build(:numeric_input, :integer, :required))
  query2.container.elements << FactoryBot.build(:element, position: 1, elementable: FactoryBot.build(:container, is_active: "(data, global) => global['dummy_element-2']['dummy_element-5'] == 2 && data['dummy_element-11'] == 777"))
  nested_container_query2 = query2.container.element_list[1]
  nested_container_query2.elements << FactoryBot.build(:element, position: 0, label: "The value", elementable: FactoryBot.build(:numeric_input, :integer))

  query2.save!
  query2.query_histories.create({
    comment: "First",
    config_version: 1,
    content: {
      sql: "insert into users (name, age) values ('aa', 7); update users set age = age+1 where id > {{dummy_element-11}}; SELECT * FROM users WHERE id > {{dummy_element-11}};"
    }
  })

  view.queries.create({ name: "Hiddenだよ", description: "Description for hidden query 3.", published: false })

  query3 = view2.queries.create({ name: "Hello" })

  query4 = view2.queries.create({ name: "Bonabana" })
  query4.container = FactoryBot.build(:container)
  query4.container.elements << FactoryBot.build(:element, position: 0, label: "Max member age", elementable: FactoryBot.build(:numeric_input, :integer))
  query4.save!


end
