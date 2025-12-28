defmodule PolytanWeb.Auth.Guardian do
  use Guardian, otp_app: :polytan

  alias Polytan.Context.Account.{Users}
  alias Polytan.Core.Password

  def subject_for_token(%{id: id}, _claims), do: {:ok, to_string(id)}
  def subject_for_token(_, _), do: {:error, :no_id_provided}

  def resource_from_claims(%{"sub" => id}) do
    case Users.get_user(id) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  def resource_from_claims(_claims), do: {:error, :no_id_provided}

  def create_token(user, type) do
    {:ok, token, _claims} = encode_and_sign(user, %{}, token_options(type))
    {:ok, token}
  end

  def verify_user_token(token) do
    case decode_and_verify(token, %{}) do
      {:ok, claims} ->
        case resource_from_claims(claims) do
          {:ok, user} -> {:ok, user}
          {:error, _} -> :error
        end

      {:error, _} ->
        :error
    end
  end

  def validate_password(password, hash) do
    Password.validate(password, hash)
  end

  defp token_options(type) do
    case type do
      :access -> [token_type: "access", ttl: {1, :day}]
      :reset -> [token_type: "reset", ttl: {15, :minute}]
      :admin -> [token_type: "admin", ttl: {90, :day}]
      _ -> [token_type: "access", ttl: {2, :hour}]
    end
  end
end
