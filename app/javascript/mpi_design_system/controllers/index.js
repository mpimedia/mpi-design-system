import TagInputController from "./tag_input_controller"

export function registerMpiControllers(application) {
  application.register("mpi--tag-input", TagInputController)
}

export { TagInputController }
