defmodule Polytan.Core.Password do
  @moduledoc false

  @spec hash(binary) :: binary
  defdelegate hash(password), to: Argon2, as: :hash_pwd_salt

  @spec validate(binary, binary) :: boolean
  defdelegate validate(password, hash), to: Argon2, as: :verify_pass
end
