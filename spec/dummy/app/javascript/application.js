import "@hotwired/turbo-rails"
import { Application } from "@hotwired/stimulus"

const application = Application.start()
application.debug = true
window.Stimulus = application

import "bootstrap"

import { registerMpiControllers } from "mpi_design_system"
registerMpiControllers(application)
