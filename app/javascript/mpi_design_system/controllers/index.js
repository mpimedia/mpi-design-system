import TagInputController from "./tag_input_controller"

export function registerMpiControllers(application) {
  application.register("tag-input", TagInputController)
}

export { TagInputController }
