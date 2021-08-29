require 'active_support/concern'

module DelegateSearchable
  extend ActiveSupport::Concern

  # Sequence is:
  # Company -> Project -> View -> Query -> QueryExecution
  # Also, it's assumed that at least the ID linking to the previous element exists.

  included do
    scope :in_company, lambda { |company|
      join_table_for(:company).where('company_id = ?', company)
    }

    scope :in_project, lambda { |project|
      join_table_for(:project).where('project_id = ?', project)
    }
  end

  module ClassMethods
    def join_table_for(scope)
      raise if allowed_scopes.exclude?(scope)
      raise "Scope required is the same as the self class. Just use '.where' to make queries (no need to use associations)." if scope == self_snake_sym

      models = necessary_models(scope)
      classes = models.map { |c| symbol_to_class(c) }
      tables = classes.map(&:arel_table)
      tables = [arel_table] + tables

      singular = {
        queries: :query,
        projects: :project,
        companies: :company,
        query_executions: :query_execution,
        views: :view
      }

      joins = []

      (tables.count - 1).times do |i|
        first = tables[i]
        second = tables[i + 1]
        foreign_key = "#{singular[second.name.to_sym]}_id".to_sym
        joins << first.join(second, Arel::Nodes::OuterJoin).on(second[:id].eq(first[foreign_key])).join_sources
      end
      self.joins(joins)
    end

    def self_snake_sym
      to_s.underscore.to_sym
    end

    def necessary_models(scope)
      return [] if model_has_association?(self_snake_sym, scope)

      path = path_to_scope(scope, self_snake_sym)
      path.delete self_snake_sym
      path.reverse!

      necessary = []

      path.each do |model|
        necessary << model
        break if model_has_association?(model, scope)
      end
      necessary
    end

    def path_to_scope(from, to)
      from_idx = allowed_scopes.find_index(from)
      to_idx = allowed_scopes.find_index(to)
      raise if from_idx > to_idx
      allowed_scopes[from_idx..to_idx]
    end

    def model_has_association?(model, scope)
      instance = symbol_to_class(model).new
      instance.respond_to?("#{scope}_id")
    end

    def symbol_to_class(scope)
      idx = allowed_scopes.find_index(scope)
      sequence[idx]
    end

    def sequence
      [Company, Project, View, Query, QueryExecution]
    end

    # All classes but as symbols in snake_case.
    def allowed_scopes
      sequence.map(&:to_s).map(&:underscore).map(&:to_sym)
    end
  end
end
