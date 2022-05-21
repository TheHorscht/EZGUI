const bool = typeof true;
const string = typeof "";
const number = typeof 0;
const loop_expression = "loop expression";
const color = "RGB(A) Hex Color #FFFFFF(FF)";
const direction = "horizontal | vertical";
const align_horizontal = "left | center | right";
const align_vertical = "top | center | bottom";

module.exports = {
  // DOM Elements
  elements: [
    {
      name: "DOMElement (All Elements)",
      description: "Every element is of this type and holds some common functionality.",
      attributes: [{
        name: "forEach",
        values: [
          [loop_expression]
        ],
        codeBlocks: [
          `
local data_context = {
  fruit_basket = { "Apple", "Banana", "Tomato" }
}
`,`
<Text forEach="fruit in fruit_basket">{{ fruit }}</Text>
`, `
<Text>Apple</Text>
<Text>Banana</Text>
<Text>Tomato</Text>
`
        ],
        description: `Allows you to repeat the rendering of an element for each item in a table. Example:<1:lua><2:xml>Result:<3:xml>`
      }]
    },
    {
      name: "Layout",
      description: "Responsible for positioning items, either horizontally or vertically (set by the CSS property ^direction)",
      attributes: [{
        name: "debug",
        values: [
          [bool]
        ],
        description: "Renders a debug overlay for padding and content"
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
      description: "Specifies horizontal alignment of items in a ^Layout when ^direction is vertical.",
    },
    {
      name: "align_items_vertical",
      values: [
        { types: [align_vertical] },
      ],
      description: "Specifies vertical alignment of items in a ^Layout when ^direction is horizontal.",
    },
    {
      name: "border",
      values: [
        { types: [bool] },
      ],
      description: "Toggles border rendering for certain elements like ^Layout and ^Button.",
    },
    {
      name: "color",
      values: [
        { types: [color] },
      ],
      description: "Colors an element, does not work properly with ^Image, especially alpha does not work at all on ^Image.",
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
