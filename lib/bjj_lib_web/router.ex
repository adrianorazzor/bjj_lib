defmodule BjjLibWeb.Router do
  use BjjLibWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {BjjLibWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BjjLibWeb do
    pipe_through :browser

    # Main page using LiveView
    live "/", VideosLive.Index, :index

    # Video-related routes
    live "/videos/new", VideosLive.Index, :new
    live "/videos/:id/edit", VideosLive.Index, :edit
    live "/videos/:id", VideosLive.Index, :show

    # Tag-related routes
    live "/tags", TagsLive.Index, :index
    live "/tags/new", TagsLive.Index, :new
    live "/tags/:id/edit", TagsLive.Index, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", BjjLibWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:bjj_lib, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: BjjLibWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
