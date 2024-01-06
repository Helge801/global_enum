defmodule GlobalEnum do
  @moduledoc """
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
  ```
  Users.create(%{
    role: :admin
  })
  ```
  ### Preferred
  ```
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
  ```
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
  ```
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

  ```
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
  ```
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
  """

  defmacro __using__(_) do
    quote do
      import GlobalEnum
      require GlobalEnum.Build
    end
  end

  @doc """
    generates new enum

    ```
    defmodule MySchema do
      import Ecto.Schema
      import #{__MODULE__}

      enum(:status, values: [:alive, :well])

      schema "my_table" do
        field :status, Ecto.Enum, values: @statuses
      end
    end
    ```
    Would compile to:
    ```
    defmodule MySchema do
      import Ecto.Schema

      @type status_enum_value :: :alive | :well

      @status_alive :alive
      @status_well :well

      @statuses [
        @status_alive,
        @status_well
      ]

      schema "my_table" do
        field :status, Ecto.Enum, values: @statuses
      end

      def status_alive(), do: @status_alive
      def status_well(), do: @status_well
      def statuses(), do: @statuses
    end
    ```
    ### Now you have public functions that can be used to access the enum values
    from other modules to ensure your enums are in sync and types for specs and dialyzer

    ```
    %{
      status: MySchema.status_well()
    }
    ```
  """
  defmacro enum(name, values) do
    meta = [line: __CALLER__.line]

    quote bind_quoted: [values: values, name: name, global: __MODULE__, meta: meta] do
      # assign meta to module attribute to avoid passing it around while building the enum.
      Module.put_attribute(__MODULE__, :ge_meta, meta)

      # It is important that each form of the Enum be assigned to a module
      # attribute so that an enum can be accessed within the same module during
      # compilation
      Module.put_attribute(__MODULE__, :"#{name}_enum", GlobalEnum.Build.format_enum(values))
      GlobalEnum.Build.copy_transform_attribute(:"#{name}_enum", :"#{name}_dumped", &Keyword.values/1)
      GlobalEnum.Build.copy_transform_attribute(:"#{name}_enum", :"#{name}_mapping", &Map.new/1)
      GlobalEnum.Build.copy_transform_attribute(:"#{name}_enum", name, &Keyword.keys/1)
      # Defines as separate module attribute for each dump value of the enum
      GlobalEnum.Build.define_dump_value_attributes(name)
      # Defines as separate module attribute for each value of the enum
      GlobalEnum.Build.define_value_attributes(name)

      # Since the generated enum functions are not macros, they cannot be used
      # for comparison in guards. In order to make the enums usable within
      # pattern matches guards are explicitly defined.
      #
      # Defines a separate guard for each values
      GlobalEnum.Build.define_value_guards(name)
      # Defines a guard for any value
      GlobalEnum.Build.define_values_guard(name)

      GlobalEnum.Build.define_enum_value_type(name)

      GlobalEnum.Build.define_dump_value_functions(name)
      GlobalEnum.Build.define_dump_values_function(name)
      GlobalEnum.Build.define_enum_function(name)
      GlobalEnum.Build.define_mapping_function(name)
      GlobalEnum.Build.define_value_functions(name)
      GlobalEnum.Build.define_values_function(name)
    end
  end
end
