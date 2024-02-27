defmodule ElixirApiJwtWeb.Router do
  use ElixirApiJwtWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ElixirApiJwtWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ElixirApiJwtWeb do
    pipe_through :browser

    get "/", PageController, :home
    resources "/accounts", AccountController, except: [:new, :edit]
  end

  scope "/api", ElixirApiJwtWeb do
    pipe_through :api
    post "/accounts/register", AccountController, :create
    post "/accounts/sign_in", AccountController, :sign_in
    patch "/accounts/reset_password", AccountController, :reset_password
  end

  # Other scopes may use custom stacks.
  # scope "/api", ElixirApiJwtWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:elixir_api_jwt, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ElixirApiJwtWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
