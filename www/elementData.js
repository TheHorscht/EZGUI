const bool = typeof true;
const string = typeof "";
const number = typeof 0;
const direction = "horizontal | vertical";
const align_horizontal = "left | center | right";
const align_vertical = "top | center | bottom";

module.exports = {
  // DOM Elements
  elements: [
    {
      name: "Layout",
      description: "Responsible for positioning items, either horizontally or vertically (set by the CSS property ^direction)",
      attributes: [{
        name: "debug",
        values: [
          [bool]
        ],
        description: "Renders a debug overlay for padding and content"
      },{
        name: "some_other_attribute",
        values: [
          [string]
        ],
        description: "Whatever"
      }]
    },
    {
      name: "Button",
      description: "Despite it's name it only supports text right now.",
    },
    {
      name: "Image",
      description: "Can you guess what this does?",
    },
    {
      name: "Slider",
      description: "I think you know what a slider is.",
    },
    {
      name: "Text",
      description: "Self explanatory, really.",
    },
  ],
  // CSS Properties
  cssProperties: [
    {
      name: "align_items_horizontal",
      values: [
        { types: [align_horizontal] },
      ],
      description: "Specifies horizontal alignment of items in a Layout when ^direction is vertical.",
    },
    {
      name: "align_items_vertical",
      values: [
        { types: [align_vertical] },
      ],
      description: "Specifies vertical alignment of items in a Layout when ^direction is horizontal.",
    },
    {
      name: "padding",
      values: [
        { types: [number], description: "Shortcut for setting ^padding_left, ^padding_top, ^padding_right, ^padding_bottom" },
        { types: [number, number], description: "Shortcut for ^padding_left + ^padding_right, ^padding_top + ^padding_bottom" },
        { types: [number, number, number], description: "Shortcut for ^padding_top, ^padding_left + ^padding_right, ^padding_bottom" },
        { types: [number, number, number, number], description: "Shortcut for ^padding_top, ^padding_right, ^padding_bottom, ^padding_left" },
      ],
      description: "Distance from the inside of the border of an element to the contents of it.",
    },
    {
      name: "padding_left",
      values: [
        { types: [number] },
      ],
      description: "See ^padding.",
    },
    {
      name: "padding_top",
      values: [
        { types: [number] },
      ],
      description: "See ^padding.",
    },
    {
      name: "padding_right",
      values: [
        { types: [number] },
      ],
      description: "See ^padding.",
    },
    {
      name: "padding_bottom",
      values: [
        { types: [number] },
      ],
      description: "See ^padding.",
    },
    {
      name: "margin",
      values: [
        { types: [number], description: "Shortcut for all sides" },
        { types: [number, number], description: "Shortcut for left/right and top/bottom" },
        { types: [number, number, number], description: "Shortcut for top, sides, bottom" },
        { types: [number, number, number, number], description: "Shortcut for top, right, bottom, left" },
      ],
      description: "Distance from the outside of the border of an element to the containing element.",
    },
    {
      name: "margin_left",
      values: [
        { types: [number] },
      ],
      description: "See ^margin.",
    },
    {
      name: "margin_top",
      values: [
        { types: [number] },
      ],
      description: "See ^margin.",
    },
    {
      name: "margin_right",
      values: [
        { types: [number] },
      ],
      description: "See ^margin.",
    },
    {
      name: "margin_bottom",
      values: [
        { types: [number] },
      ],
      description: "See ^margin.",
    },
    {
      name: "direction",
      values: [
        { types: [direction], description: "Effect depends on the element." },
      ],
      description: "For layouts it determines the direction in which items are laid out.",
    },
  ],
}
