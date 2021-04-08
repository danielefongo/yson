defmodule Yson.Schema.GraphQLTest do
  use ExUnit.Case
  require Yson.Schema.GraphQL
  import Yson.Schema.GraphQL
  require Yson.Macro.Arg
  import Yson.Macro.Arg
  import Function, only: [identity: 1]

  defmodule Sample do
    use Yson.Schema.GraphQL

    query :sample do
      arg :user do
        arg(:email, :string)
        arg(:age, :integer)
      end
    end

    root do
      reference(:user)
      reference(:data)
      reference(:natural_person)
      reference(:legal_person)
    end

    map :user, resolver: &Sample.user/1 do
      value(:email)
    end

    interface :legal_person do
      value(:company_name)
    end

    map :data do
      value(:some_data)
    end

    interface :natural_person do
      value(:first_name)
      value(:second_name)
    end

    def user(data), do: data
  end

  test "generate description" do
    description = Sample.describe()

    assert description.object == :sample

    assert description.body == %{
             sample: %{
               user: %{email: nil},
               data: %{some_data: nil},
               natural_person: [
                 first_name: nil,
                 second_name: nil
               ],
               legal_person: [company_name: nil]
             }
           }

    assert description.arguments == %{
             user: %{
               email: :string,
               age: :integer
             }
           }
  end

  test "generate resolvers" do
    assert Sample.resolvers() == %{
             sample:
               {&identity/1,
                %{
                  company_name: &identity/1,
                  first_name: &identity/1,
                  second_name: &identity/1,
                  user: {&Yson.GraphQLTest.Sample.user/1, %{email: &identity/1}},
                  data: {&identity/1, %{some_data: &identity/1}}
                }}
           }
  end
end
