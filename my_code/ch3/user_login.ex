defmodule Login do
  
  def extract_user(user) do
    case Enum.filter(["email", "login", "password"], fn key -> not Map.has_key?(user, String.to_atom(key)) end) do
      [] -> {:ok, user}
      missing_fields -> {:error, Enum.map(missing_fields, &("#{&1} was missing"))}
    end
  end

  
  # def extract_user(user) do
  #   Enum.filter(["login", "email", "password"], fn field -> field not in Map.keys(user) end)
  #   |> extract_user_output() 
  # end
  #
  # defp extract_user_output([])


  def extract_user_old(user) do
    with {:ok, login} <- validate_login(user),
         {:ok, email} <- validate_email(user),
         {:ok, password} <- validate_password(user) do
            {:ok, %{login: login, email: email, password: password}}
         end
  end

  def validate_login(%{login: login_info}), do: {:ok, login_info}
  def validate_login(_), do: {:error, "Missing login"}

  def validate_email(%{email: email_info}), do: {:ok, email_info}
  def validata_email(_), do: {:error, "Missing email"}
  
  def validate_password(%{password: password_info}), do: {:ok, password_info}
  def validate_password(_), do: {:error, "Missing password"}
end

