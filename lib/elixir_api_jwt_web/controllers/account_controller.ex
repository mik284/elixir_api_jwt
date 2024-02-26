defmodule ElixirApiJwtWeb.AccountController do
  use ElixirApiJwtWeb, :controller

  alias ElixirApiJwt.Guardian
  alias ElixirApiJwt.Accounts
  alias ElixirApiJwt.Accounts.Account

  action_fallback ElixirApiJwtWeb.FallbackController

  def index(conn, _params) do
    accounts = Accounts.list_accounts()
    render(conn, :index, accounts: accounts)
  end

  def create(conn, %{"account" => account_params}) do
    # with {:ok, %Account{} = account} <- Accounts.create_account(account_params) do
    #   conn
    #   |> put_status(:created)
    #   |> put_resp_header("location", ~p"/api/accounts/#{account}")
    #   |> render(:show, account: account)
    # end

    with {:ok, %Account{} = account} <- Accounts.create_account(account_params),
         {:ok, token, _full_claims} <- Guardian.encode_and_sign(account) do
      conn
      |> put_status(:created)
      |> render("account_token.json", account: account, token: token)
    end
  end

  def show(conn, %{"id" => id}) do
    account = Accounts.get_account!(id)
    render(conn, :show, account: account)
  end

  def update(conn, %{"id" => id, "account" => account_params}) do
    account = Accounts.get_account!(id)

    with {:ok, %Account{} = account} <- Accounts.update_account(account, account_params) do
      render(conn, :show, account: account)
    end
  end

  def delete(conn, %{"id" => id}) do
    account = Accounts.get_account!(id)

    with {:ok, %Account{}} <- Accounts.delete_account(account) do
      send_resp(conn, :no_content, "")
    end
  end

  # We check if the user exists and if the password is the same, then we render the user’s id, email and token.
  def sign_in(conn, %{"account" => %{"email" => email, "hash_password" => hash_password}}) do
    case ElixirApiJwt.Guardian.authenticate(email, hash_password) do
      {:ok, account, token} ->
        conn
        |> put_status(:ok)
        |> render("account_token.json", account: account, token: token)

      {:error, _reason} ->
        conn
        |> put_status(:unauthorized)
        |> render("error.json", error: "invalid credentials")
    end
  end
end
