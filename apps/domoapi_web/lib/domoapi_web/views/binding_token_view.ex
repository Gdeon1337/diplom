defmodule DomoapiWeb.BindingTokenView do
  use DomoapiWeb, :view
  alias DomoapiWeb.BindingTokenView

  def render("index.json", %{binding_token: binding_token}) do
    %{data: render_many(binding_token, BindingTokenView, "binding_token.json")}
  end

  def render("show.json", %{binding_token: binding_token}) do
    %{data: render_one(binding_token, BindingTokenView, "binding_token.json")}
  end

  def render("binding_token.json", %{binding_token: binding_token}) do
    %{id: binding_token.id,
      time_to_live: binding_token.time_to_live}
  end
end
