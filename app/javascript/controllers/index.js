// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "./application"
import SelectController from "./select_controller";
import EmployeeSelectController from "./employee_select_controller";
import ToggleController from "./toggle_controller";
import PopoverController from "./popover_controller";
import ImageValidationController from "./image_validation_controller";
import FormValidationController from "./form_validation_controller";

application.register("select", SelectController);
application.register("employee_select", EmployeeSelectController);
application.register("toggle", ToggleController);
application.register("popover", PopoverController);
application.register("image-validation", ImageValidationController);
application.register("form-validation", FormValidationController);
