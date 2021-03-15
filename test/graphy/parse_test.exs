defmodule Graphy.ParserTest do
  use ExUnit.Case
  alias Graphy.Parser

  def reverse_text(data), do: String.reverse(data)
  def collapse_name(%{name: name, surname: surname}), do: %{full_name: "#{name} #{surname}"}

  test "parse shallow" do
    resolvers = %{
      sample: {&Graphy.void_resolver/1, %{name: &reverse_text/1, surname: &reverse_text/1}}
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
        {&Graphy.void_resolver/1,
         %{
           user: {&Graphy.void_resolver/1, %{name: &reverse_text/1, surname: &reverse_text/1}}
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

  test "parse recasing" do
    resolvers = %{
      sample: {&Graphy.void_resolver/1, %{full_name: &Graphy.void_resolver/1}}
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

    assert Parser.parse(resolvers, data) == expected_data
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
        {&Graphy.void_resolver/1,
         %{
           company_name: &Graphy.void_resolver/1,
           name: &Graphy.void_resolver/1,
           surname: &Graphy.void_resolver/1
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

  test "parse parsing root lists" do
    resolvers = %{
      sample:
        {&Graphy.void_resolver/1,
         %{
           name: &Graphy.void_resolver/1,
           surname: &Graphy.void_resolver/1
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
        {&Graphy.void_resolver/1,
         %{
           name: &Graphy.void_resolver/1
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
        {&Graphy.void_resolver/1,
         %{
           users:
             {&Graphy.void_resolver/1,
              %{
                name: &Graphy.void_resolver/1,
                surname: &Graphy.void_resolver/1
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
