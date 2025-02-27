defmodule Domoapi.Schema do
    defmacro __using__(_) do
      quote do
        use Ecto.Schema
        @primary_key {:id, Ecto.UUID, autogenerate: true}
        @foreign_key_type Ecto.UUID
      end
    end
  end