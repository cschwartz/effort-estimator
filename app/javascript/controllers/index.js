// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
import Reveal from "@stimulus-components/reveal"

eagerLoadControllersFrom("controllers", application)

application.register("reveal", Reveal)
