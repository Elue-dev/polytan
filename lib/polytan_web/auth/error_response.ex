defmodule PolytanWeb.Auth.ErrorResponse.Unauthorized do
  defexception message: "unauthorized", plug_status: 401
end

defmodule PolytanWeb.Auth.ErrorResponse.Forbidden do
  defexception message: "forbidden", plug_status: 403
end

defmodule PolytanWeb.Auth.ErrorResponse.NotFound do
  defexception message: "not found", plug_status: 404
end
