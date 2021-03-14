defmodule Graphy.WalkerTest do
  use ExUnit.Case
  alias Graphy.Walker

  def reverse_text(data), do: String.reverse(data)
  def collapse_name(%{name: name, surname: surname}), do: %{full_name: "#{name} #{surname}"}

  test "walk shallow" do
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

    assert Walker.walk(resolvers, data) == expected_data
  end

  test "walk deep" do
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

    assert Walker.walk(resolvers, data) == expected_data
  end

  test "walk recasing" do
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

    assert Walker.walk(resolvers, data) == expected_data
  end

  test "walk combining resolvers" do
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

    assert Walker.walk(resolvers, data) == expected_data
  end

  test "walk ignoring missing fields" do
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

    assert Walker.walk(resolvers, data) == expected_data
  end

  test "walk parsing root lists" do
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

    assert Walker.walk(resolvers, data) == expected_data
  end

  test "walk parsing nested simple lists" do
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

    assert Walker.walk(resolvers, data) == data
  end

  test "walk parsing nested complex lists" do
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

    assert Walker.walk(resolvers, data) == data
  end
end
