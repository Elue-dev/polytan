defmodule PolytanWeb.Auth.Guardian do
  use Guardian, otp_app: :polytan

  alias Polytan.Context.Account.Users
  alias Polytan.Schema.Accounts.User
  alias PolytanWeb.Auth.TokenBlacklistProcess

  def subject_for_token(%{id: id}, _claims), do: {:ok, to_string(id)}
  def subject_for_token(_, _), do: {:error, :no_id_provided}

  def build_claims(claims, %User{token_version: version}, _opts) do
    {:ok, Map.put(claims, "tv", version)}
  end

  def resource_from_claims(%{"sub" => id, "jti" => jti, "tv" => token_version}) do
    case Users.get_user(id) do
      nil ->
        {:error, :user_not_found}

      user ->
        cond do
          user.token_version != token_version -> {:error, :token_revoked}
          TokenBlacklistProcess.revoked?(jti) -> {:error, :token_revoked}
          true -> {:ok, user}
        end
    end
  end

  def resource_from_claims(%{"sub" => id}) do
    case Users.get_user(id) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  def resource_from_claims(_claims), do: {:error, :no_id_provided}

  def create_token(user, type) do
    jti = Ecto.UUID.generate()

    case encode_and_sign(user, %{}, token_options(type, jti)) do
      {:ok, token, _claims} ->
        {:ok, token}

      {:error, reason} ->
        {:error, reason}
    end
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

  defp token_options(type, jti) do
    case type do
      :access -> [token_type: "access", ttl: {1, :day}, jti: jti]
      :reset -> [token_type: "reset", ttl: {15, :minute}, jti: jti]
      :admin -> [token_type: "admin", ttl: {90, :day}, jti: jti]
      _ -> [token_type: "access", ttl: {2, :hour}, jti: jti]
    end
  end
end
