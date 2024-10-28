// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "./application"
import SelectController from "./select_controller";

application.register("select", SelectController);