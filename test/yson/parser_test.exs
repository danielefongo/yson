defmodule Yson.ParserTest do
  use ExUnit.Case
  alias Yson.Parser
  import Function, only: [identity: 1]

  def reverse_text(data), do: String.reverse(data)
  def collapse_name(%{name: name, surname: surname}), do: %{full_name: "#{name} #{surname}"}

  test "parse shallow" do
    resolvers = %{
      sample: {&identity/1, %{name: &reverse_text/1, surname: &reverse_text/1}}
    }

    data = %{
      sample: %{
        name: "name",
        surname: "surname"
      }
    }

    expected_data = %{
      sample: %{
        name: "eman",
        surname: "emanrus"
      }
    }

    assert Parser.parse(resolvers, data) == expected_data
  end

  test "parse deep" do
    resolvers = %{
      sample:
        {&identity/1,
         %{
           user: {&identity/1, %{name: &reverse_text/1, surname: &reverse_text/1}}
         }}
    }

    data = %{
      sample: %{
        user: %{
          name: "name",
          surname: "surname"
        }
      }
    }

    expected_data = %{
      sample: %{
        user: %{
          name: "eman",
          surname: "emanrus"
        }
      }
    }

    assert Parser.parse(resolvers, data) == expected_data
  end

  test "parse recasing to snake case" do
    resolvers = %{
      sample: {&identity/1, %{full_name: &identity/1}}
    }

    data = %{
      sample: %{
        fullName: "name"
      }
    }

    expected_data = %{
      sample: %{
        full_name: "name"
      }
    }

    assert Parser.parse(resolvers, data, :snake) == expected_data
  end

  test "parse recasing to camel case" do
    resolvers = %{
      sample: {&identity/1, %{fullName: &identity/1}}
    }

    data = %{
      sample: %{
        full_name: "name"
      }
    }

    expected_data = %{
      sample: %{
        fullName: "name"
      }
    }

    assert Parser.parse(resolvers, data, :camel) == expected_data
  end

  test "parse without recasing" do
    resolvers = %{
      sample: {&identity/1, %{fullName: &identity/1}}
    }

    data = %{
      sample: %{
        fullName: "name"
      }
    }

    assert Parser.parse(resolvers, data, :no_case) == data
  end

  test "raise error when parsing with wrong case" do
    resolvers = %{sample: {&identity/1}}
    data = %{sample: "foo"}

    assert_raise(RuntimeError, fn ->
      Parser.parse(resolvers, data, :wrong_case) == data
    end)
  end

  test "parse combining resolvers" do
    resolvers = %{
      sample: {&collapse_name/1, %{name: &reverse_text/1, surname: &reverse_text/1}}
    }

    data = %{
      sample: %{
        name: "name",
        surname: "surname"
      }
    }

    expected_data = %{
      sample: %{
        full_name: "eman emanrus"
      }
    }

    assert Parser.parse(resolvers, data) == expected_data
  end

  test "parse ignoring missing fields" do
    resolvers = %{
      sample:
        {&identity/1,
         %{
           company_name: &identity/1,
           name: &identity/1,
           surname: &identity/1
         }}
    }

    data = %{
      sample: %{
        name: "name",
        surname: "surname"
      }
    }

    expected_data = %{
      sample: %{
        name: "name",
        surname: "surname"
      }
    }

    assert Parser.parse(resolvers, data) == expected_data
  end

  test "parse ignoring extra fields" do
    resolvers = %{
      sample:
        {&identity/1,
         %{
           name: &identity/1
         }}
    }

    data = %{
      sample: %{
        name: "name",
        extra: "should be ignored"
      },
      extra: "should be ignored"
    }

    expected_data = %{
      sample: %{
        name: "name"
      }
    }

    assert Parser.parse(resolvers, data) == expected_data
  end

  test "parse parsing root lists" do
    resolvers = %{
      sample:
        {&identity/1,
         %{
           name: &identity/1,
           surname: &identity/1
         }}
    }

    data = %{
      sample: [
        %{name: "name", surname: "surname"},
        %{name: "another_name", surname: "another_surname"}
      ]
    }

    expected_data = %{
      sample: [
        %{name: "name", surname: "surname"},
        %{name: "another_name", surname: "another_surname"}
      ]
    }

    assert Parser.parse(resolvers, data) == expected_data
  end

  test "parse parsing nested simple lists" do
    resolvers = %{
      sample:
        {&identity/1,
         %{
           name: &identity/1
         }}
    }

    data = %{
      sample: %{
        name: ["a", "b"]
      }
    }

    assert Parser.parse(resolvers, data) == data
  end

  test "parse parsing nested complex lists" do
    resolvers = %{
      sample:
        {&identity/1,
         %{
           users:
             {&identity/1,
              %{
                name: &identity/1,
                surname: &identity/1
              }}
         }}
    }

    data = %{
      sample: %{
        users: [
          %{name: "name", surname: "surname"},
          %{name: "another_name", surname: "another_surname"}
        ]
      }
    }

    assert Parser.parse(resolvers, data) == data
  end
end
