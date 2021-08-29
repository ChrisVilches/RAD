require 'rails_helper'

RSpec.describe QueryExecution, type: :model do
  describe '.nil_params_to_empty_array' do
    let(:query_execution) { build :query_execution }
    subject { query_execution }
    context 'saving a nil param' do
      before { subject.global_params = nil }
      before { subject.query_params = nil }
      before { subject.validate }
      it { is_expected.to be_valid }
      it { expect(subject.global_params).to eq [] }
      it { expect(subject.query_params).to eq [] }
    end
    context 'saving a non-nil param' do
      before { subject.global_params = [{ path: ['a'], value: 1 }] }
      before { subject.query_params = [{ path: ['b'], value: 2 }] }
      before { subject.validate }
      it { is_expected.to be_valid }
      it { expect(subject.global_params).to eq [{ 'path' => ['a'], 'value' => 1 }] }
      it { expect(subject.query_params).to eq [{ 'path' => ['b'], 'value' => 2 }] }
    end
  end

  describe '.validate_params' do
    let(:query) { create :query }
    let(:query_execution) { build :query_execution, global_params: params_to_validate, query_params: params_to_validate }
    let(:enqueue_service) { QueryServices::EnqueueService.new(create(:user), create(:connection)) }
    let(:query_history) { create :query_history, query: query }
    shared_examples 'validate_params does not throw error' do
      it {
        expect(described_class.params_valid?(params_to_validate)).to be true
      }

      it {
        expect {
          QueryServices::SqlBuilderService.build_sql(query_history, params_to_validate, params_to_validate)
        }.to raise_error QueryErrors::NoSqlPresentError
      }

      it { expect(query_execution).to be_valid }

      it {
        expect {
          enqueue_service.enqueue(query, query_history, params_to_validate, params_to_validate, false) # Last parameter as false means "Don't execute it."
        }.to_not raise_error
      }
    end

    shared_examples 'validate_params throws error' do
      it { expect(described_class.params_valid?(params_to_validate)).to be false }

      it {
        expect {
          QueryServices::SqlBuilderService.build_sql(query_history, params_to_validate, params_to_validate)
        }.to raise_error QueryErrors::IncorrectParamsFormatError
      }

      it { expect(query_execution).to_not be_valid }

      it {
        expect {
          enqueue_service.enqueue(query, query_history, params_to_validate, params_to_validate, false) # Last parameter as false means "Don't execute it."
        }.to raise_error ActiveRecord::RecordInvalid
      }
    end

    context 'nil params' do
      let(:params_to_validate) { nil }
      it { expect(described_class.params_valid?(params_to_validate)).to be false }

      it {
        expect {
          QueryServices::SqlBuilderService.build_sql(query_history, params_to_validate, params_to_validate)
        }.to raise_error QueryErrors::IncorrectParamsFormatError
      }

      # This one is an exception, because nil does get converted to [] (correct value)
      # during before_validations of this model.
      it { expect(query_execution).to be_valid }

      it {
        expect {
          enqueue_service.enqueue(query, query_history, params_to_validate, params_to_validate, false) # Last parameter as false means "Don't execute it."
        }.to_not raise_error
      }
    end

    context 'empty array' do
      let(:params_to_validate) { [] }
      it_behaves_like 'validate_params does not throw error'
    end

    context 'number' do
      let(:params_to_validate) { 5 }
      it_behaves_like 'validate_params throws error'
    end

    context 'array' do
      context 'item is number' do
        let(:params_to_validate) { [5] }
        it_behaves_like 'validate_params throws error'
      end

      context 'item is number' do
        let(:params_to_validate) { [5] }
        it_behaves_like 'validate_params throws error'
      end

      context 'item is string' do
        let(:params_to_validate) { ['string'] }
        it_behaves_like 'validate_params throws error'
      end

      context 'items are mixed value types' do
        let(:params_to_validate) { ['string', 5, {}, true] }
        it_behaves_like 'validate_params throws error'
      end

      context 'has hash but path has string value' do
        let(:params_to_validate) { [{ path: 'string' }] }
        it_behaves_like 'validate_params throws error'
      end

      context 'has hash but path has number value' do
        let(:params_to_validate) { [{ path: 5 }] }
        it_behaves_like 'validate_params throws error'
      end

      context 'has hash with empty array path' do
        let(:params_to_validate) { [{ path: [], value: 5 }] }
        it_behaves_like 'validate_params throws error'
      end

      context 'has hash with numbers as path' do
        let(:params_to_validate) { [{ path: ['', 5], value: 5 }] }
        it_behaves_like 'validate_params throws error'
      end

      context 'has hash with empty paths' do
        let(:params_to_validate) { [{ path: ['', ''], value: 5 }] }
        it_behaves_like 'validate_params throws error'
      end

      context 'has hash with only value' do
        let(:params_to_validate) { [{ value: 5 }] }
        it_behaves_like 'validate_params throws error'
      end

      context 'has hash with string array path, but with unsupported regex' do
        let(:params_to_validate) { [{ value: 5 }] }
        it_behaves_like 'validate_params throws error'
      end

      context 'has hash with correct path and value' do
        let(:params_to_validate) { [{ path: %w[a b c], value: 5 }] }
        it_behaves_like 'validate_params does not throw error'
      end
    end
  end
end
