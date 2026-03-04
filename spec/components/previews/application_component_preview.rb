# Base preview class for all MPI Design System component previews.
# Individual component previews should inherit from this class.
#
# Example:
#   class Admin::Badge::ComponentPreview < ApplicationComponentPreview
#     def default
#       render Admin::Badge::Component.new(label: "New", color: :primary)
#     end
#   end
class ApplicationComponentPreview < ViewComponent::Preview
end
