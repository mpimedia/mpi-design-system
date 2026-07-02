Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  mount MpiDesignSystem::Engine => "/mpi_design_system"

  # Demo page exercised by the tag_input browser (Selenium) feature spec — it
  # renders a real MpiDesignSystem::Admin::TagInput::Component so Stimulus boots.
  get "tag_input_demo" => "tag_input_demo#show"

  if Rails.env.development?
    mount Lookbook::Engine, at: "/lookbook"
    root to: redirect("/lookbook")
  end
end
