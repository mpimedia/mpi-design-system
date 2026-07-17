import TagInputController from "./tag_input_controller"
import BatchActionsController from "./batch_actions_controller"

export function registerMpiControllers(application) {
  application.register("mpi--tag-input", TagInputController)
  application.register("mpi--batch-actions", BatchActionsController)
}

export { TagInputController, BatchActionsController }
