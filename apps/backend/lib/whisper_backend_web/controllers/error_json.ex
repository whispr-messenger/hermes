defmodule WhisperBackendWeb.ErrorJSON do
  @moduledoc """
  This module is invoked by your endpoint in case of errors on JSON requests.

  See config/config.exs.
  """

  # If you want to customize a particular status code,
  # you may add your own clauses, such as:
  #
  # def render("500.json", _assigns) do
  #   %{errors: %{detail: "Internal Server Error"}}
  # end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.json" becomes
  # "Not Found".
  def render(template, _assigns) when is_binary(template) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end

  # Render errors from a changeset
  def render("error.json", %{changeset: changeset}) do
    %{errors: translate_errors(changeset)}
  end

  # Render a custom error message
  def render("error.json", %{message: message}) do
    %{errors: %{detail: message}}
  end

  # Translate all errors from a changeset
  defp translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
  end

  # Translate an individual error
  defp translate_error({msg, opts}) do
    # Because the error messages we show in our forms and APIs
    # are defined inside Ecto, we need to translate them dynamically.
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end
end
