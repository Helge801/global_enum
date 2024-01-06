# GlobalEnum

The aim of `GlobalEnum` is to speed up development and prevent bugs by
generating well documented, and well spec-ed functions that lean into the use
of tools like dialyzer, IDE's pop-up docs, and autocomplete.

## Auto Complete
Since GlobalEnum defines a separate function for each enum value you get
immediate feedback through auto complete about the available values which can
significantly improve development speed and accuracy.

![Screenshot of VsCode auto completing a lint of code starting with Cars.models_](https://github.com/Helge801/global_enum_doc_assets/blob/master/autocomplete_roles.png?raw=true)

In fact it is suggested to always use these functions in place of tha values
themselves which guarantees the values you are using actually belong to the
enum.

### Not preferred
``` elixir
Users.create(%{
  role: :admin
})
```
### Preferred
``` elixir
Users.create(%{
  role: UserEnums.roles_admin()
})
```

## Function Documentation
All generated functions have generated docs as well.
These docs will always contain the actual return values of each function.
This means you will never need to navigate to where the enum is declared to be
reminded of it's values. Instead just hover over functions in your IDE

![Screenshot of VsCode function docs on hover using ElixirLs for a dump_value](https://github.com/Helge801/global_enum_doc_assets/blob/master/hoverdoc_roles_admin_dumped.png?raw=true)
![Screenshot of VsCode function docs on hover using ElixirLs for enum values](https://github.com/Helge801/global_enum_doc_assets/blob/master/hoverdoc_roles_enum.png?raw=true)

## Type Safety
`GlobalEnum` can be used across you application to guarantee type safety of your Enums.

For example:
If you have an application that uses Graphql with Absinthe, Ecto for it's
"ORM", and generated Typescript for the frontend, you could guarantee type
safety for your enum across the entire app.

Here is how it would look:
``` elixir
# lib/my_app/users/user_enums.ex
use GlobalEnum

enum :roles, [:admin, :user]

# lib/my_app/users/user.ex
use Ecto.Schema
alias MyApp.Users.UserEnums

schema "users" do
  ...
  field :role, Ecto.Enum, values: UserEnums.roles_enum()
  ...
end

# lib/my_app_web/schema.ex
use Absinthe.Schema
alias MyApp.Users.UserEnums

...
enum user_roles, values: UserEnums.roles()
...
```

In the above example Ecto would enforce that only true enum values could be
written to the database, while Absinthe would ensure that only true enum
values could be used in the GQL schema, Your generated TypeScript would enforce
the use of only true Enum values on the front-end and all of these locations
would be using a single source of truth in `lib/my_app/users/user_enums.ex`

## Types and Specs
Types and specs are also generated to ensure that type safety can be enforces
before runtime using Dialyzer

In our previous example we showed how type safety can be enforces at all
points of IO but what about within the Elixir application?

This can be enforced using types, specs and dialyzer.

Every generated function has detailed `@spec`s attached, but types are
also provided for further enum enforcement.

### using types for ecto schemas (or structs):
``` elixir
defmodule MyApp.Users.User do
  use Ecto.Schema
  alias MyApp.Users.UserEnums

  @type t :: %__MODULE__{
    role: UserEnums.roles_enum_value() | nil
  }
  schema "users" do
    ...
    field :role, Ecto.Enum, values: UserEnums.roles_enum()
    ...
  end

end
```

With the addition of the `role` field in the `t` type declaration Dialyser
will enforce that the struct can only carry true enum values.

### using types functions:

for example, in the users context module:

``` elixir
defmodule MyApp.Users do
  ...
  @spec get_by_role(role :: UserEnums.roles_enum_value()) :: [User.t()]
  def get_by_role(role) do
    User
    |> where([u], u.roles == ^role)
    |> Repo.all()
  end
  ...
end
```

In the above example, Dialyzer would enforce that only true enum values be used before runtime.

NOTE:
_Typespecs and types are only as good as how they are used. If types become
obscured from Dialyzer through convoluted or un spec-ed code then these guarantees will be lost_

## Guards
Guards are also generated for your enum if you want enforce your enums even more rigidly

### Using a guard for a specific value
``` elixir
defmodule MyApp.Users do
  ...
  def get_by_role(role) when UserEnums.is_roles_enum_value(role) do
    User
    |> where([u], u.roles == ^role)
    |> Repo.all()
  end
  ...
end
```

### Using a guard for specific value
```
defmodule MyApp.Permissions do
  ...
  def is_admin(%User{role: role}) when UserEnums.is_roles_admin(role), do: true
  def is_admin(%User{}), do: false
  ...
end
```

Even the guards and types have generated docs to make their exact functionality easy referenced
![Screenshot of VsCode function docs on hover for guard](https://github.com/Helge801/global_enum_doc_assets/blob/master/hoverdoc_roles_admin_guard.png?raw=true)
![Screenshot of VsCode function docs on hover for type](https://github.com/Helge801/global_enum_doc_assets/blob/master/hoverdoc_roles_enum_value.png?raw=true)


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `global_enum` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:global_enum, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/global_enum>.
