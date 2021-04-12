defmodule Yson.Json.SchemaTest do
  use ExUnit.Case
  import Function, only: [identity: 1]

  defmodule Sample do
    use Yson.Json.Schema

    root resolver: &Sample.root/1 do
      value(:foo)
      reference(:sample)
    end

    map :sample do
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
    def root(data), do: data
  end

  test "generate description" do
    description = Sample.describe()

    assert description == %{
             foo: nil,
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
  end

  test "generate resolvers" do
    assert Sample.resolvers() ==
             {
               &Yson.Json.SchemaTest.Sample.root/1,
               %{
                 foo: &identity/1,
                 sample:
                   {&identity/1,
                    %{
                      company_name: &identity/1,
                      first_name: &identity/1,
                      second_name: &identity/1,
                      user: {&Yson.Json.SchemaTest.Sample.user/1, %{email: &identity/1}},
                      data: {&identity/1, %{some_data: &identity/1}}
                    }}
               }
             }
  end
end
