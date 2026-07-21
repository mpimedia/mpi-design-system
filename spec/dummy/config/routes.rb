Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  mount MpiDesignSystem::Engine => "/mpi_design_system"

  # Demo page exercised by the tag_input browser (Selenium) feature spec — it
  # renders a real MpiDesignSystem::Admin::TagInput::Component so Stimulus boots.
  get "tag_input_demo" => "tag_input_demo#show"

  # Demo page exercised by the batch-actions browser feature spec — renders a real
  # MpiDesignSystem::Admin::TableForIndex with batch: true so the mpi--batch-actions
  # Stimulus controller boots and drives the checkbox/action-button state.
  get "batch_actions_demo" => "batch_actions_demo#show"

  # Demo page exercised by the contrast browser feature spec — renders the four
  # components fixed by #130 against real compiled Bootstrap, so the spec can read
  # COMPUTED colours and prove the cascade resolves as intended.
  get "contrast_demo" => "contrast_demo#show"

  if Rails.env.development?
    mount Lookbook::Engine, at: "/lookbook"
    root to: redirect("/lookbook")
  end
end
