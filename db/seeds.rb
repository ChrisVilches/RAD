# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

project = Project.create(name: "Test project")
view = project.views.create(name: "Example view 1")
query = view.queries.create({})
query.query_histories.create({
  comment: "First",
  config_version: 1,
  content: {
    sql: "SELECT * FROM users WHERE age > {{age}};",
    inputs: {
      age: {
        type: "numerical",
        label: "Age",
        help: "This is the age of the character",
        default: 15,
        nullable: false,
        min: 1,
        max: 90
      }
    }
  }

})
