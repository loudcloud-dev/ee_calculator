// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "./application"
import SelectController from "./select_controller";
import ToggleController from "./toggle_controller";
import PopoverController from "./popover_controller";

application.register("select", SelectController);
application.register("toggle", ToggleController);
application.register("popover", PopoverController);