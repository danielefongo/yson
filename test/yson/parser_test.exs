defmodule Yson.ParserTest do
  use ExUnit.Case
  alias Yson.Parser

  def reverse_text(data), do: String.reverse(data)
  def collapse_name(%{name: name, surname: surname}), do: %{full_name: "#{name} #{surname}"}

  @identity_resolver {Function, :identity}
  @reverse_text_resolver {Yson.ParserTest, :reverse_text}
  @collapse_name_resolver {Yson.ParserTest, :collapse_name}

  test "parse shallow" do
    resolvers = [
      sample:
        {@identity_resolver, [name: @reverse_text_resolver, surname: @reverse_text_resolver]}
    ]

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
    resolvers = [
      sample:
        {@identity_resolver,
         [
           user:
             {@identity_resolver, [name: @reverse_text_resolver, surname: @reverse_text_resolver]}
         ]}
    ]

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
    resolvers = [
      sample: {@identity_resolver, [full_name: @identity_resolver]}
    ]

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
    resolvers = [
      sample: {@identity_resolver, [fullName: @identity_resolver]}
    ]

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
    resolvers = [
      sample: {@identity_resolver, [fullName: @identity_resolver]}
    ]

    data = %{
      sample: %{
        fullName: "name"
      }
    }

    assert Parser.parse(resolvers, data, :no_case) == data
  end

  test "raise error when parsing with wrong case" do
    resolvers = [sample: {@identity_resolver}]
    data = %{sample: "foo"}

    assert_raise(RuntimeError, fn ->
      Parser.parse(resolvers, data, :wrong_case) == data
    end)
  end

  test "parse combining resolvers" do
    resolvers = [
      sample:
        {@collapse_name_resolver, [name: @reverse_text_resolver, surname: @reverse_text_resolver]}
    ]

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
    resolvers = [
      sample:
        {@identity_resolver,
         [
           company_name: @identity_resolver,
           name: @identity_resolver,
           surname: @identity_resolver
         ]}
    ]

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
    resolvers = [
      sample:
        {@identity_resolver,
         [
           name: @identity_resolver
         ]}
    ]

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
    resolvers = [
      sample:
        {@identity_resolver,
         [
           name: @identity_resolver,
           surname: @identity_resolver
         ]}
    ]

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
    resolvers = [
      sample:
        {@identity_resolver,
         [
           name: @identity_resolver
         ]}
    ]

    data = %{
      sample: %{
        name: ["a", "b"]
      }
    }

    assert Parser.parse(resolvers, data) == data
  end

  test "parse parsing nested complex lists" do
    resolvers = [
      sample:
        {@identity_resolver,
         [
           users:
             {@identity_resolver,
              [
                name: @identity_resolver,
                surname: @identity_resolver
              ]}
         ]}
    ]

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
