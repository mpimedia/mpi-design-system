# Design Review Checklist

Use this checklist when reviewing designs in the **In Review** column on the project board.

## Visual Consistency

- [ ] Uses colors from the established token palette (no arbitrary hex values)
- [ ] Typography follows the type scale defined in tokens
- [ ] Spacing is consistent with the spacing tokens
- [ ] Visual style is compatible with existing approved components

## Bootstrap 5 Alignment

- [ ] Uses standard Bootstrap classes where possible
- [ ] Custom styles are documented and justified
- [ ] Responsive behavior uses Bootstrap's grid and breakpoint system
- [ ] No unnecessary overrides of Bootstrap defaults

## Functionality

- [ ] All required states are defined (default, hover, active, disabled, loading)
- [ ] Variants are clearly documented (sizes, colors, orientations)
- [ ] Edge cases are considered (empty states, overflow text, extreme data)
- [ ] Interactive behaviors are specified

## Accessibility

- [ ] Meets WCAG 2.1 AA color contrast requirements
- [ ] Keyboard navigation is defined
- [ ] ARIA roles and attributes are specified
- [ ] Screen reader behavior is documented
- [ ] Focus states are visible

## Cross-App Compatibility

- [ ] Works within the layout patterns of target app(s)
- [ ] Doesn't conflict with existing app-specific styles
- [ ] Can be implemented as a ViewComponent
- [ ] Stimulus controller needs (if any) are identified

## Documentation Quality

- [ ] Component spec follows the template in CONTRIBUTING.md
- [ ] When to use / when not to use is clear
- [ ] ERB/ViewComponent example is provided
- [ ] Visual reference image is included

## Review Outcomes

After review, comment on the issue with one of:

- **Approved** — Ready for implementation. Move to **Approved** column.
- **Changes requested** — Specific feedback provided. Move back to **In Design**.
- **Needs discussion** — Questions about scope, approach, or priority. Tag relevant people.
