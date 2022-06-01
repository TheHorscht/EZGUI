const bool = typeof true;
const string = typeof "";
const number = typeof 0;
const func = "function";
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
local ezgui_object = {
  data = {
    fruit_basket = { "Apple", "Banana", "Tomato" }
  }
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
      description: "Responsible for positioning items, either horizontally or vertically (set by the CSS property ^direction).",
      attributes: [{
        name: "debug",
        values: [
          [bool]
        ],
        description: "Renders a debug overlay for padding and content."
      }]
    },
    {
      name: "Button",
      attributes: [{
        name: "@click",
        values: [ [func] ],
      }],
      description: "A text button. Its padding will be included in the clickable area.",
    },
    {
      name: "Image",
      attributes: [{
        name: "scaleX",
        values: [ [number] ],
      },{
        name: "scaleY",
        values: [ [number] ],
      },
      {
        name: "@click",
        values: [ [func] ],
      }],
      description: "Renders an image. You can scale it using scaleX and scaleY attributes and add an @click listener to use it as an ImageButton.",
    },
    {
      name: "Slider",
      attributes: [{
        name: "min",
        values: [ [number] ],
      },{
        name: "max",
        values: [ [number] ],
      },
      {
        name: "precision",
        values: [ [number] ],
        description: "Number of digits to show after the decimal point."
      }],
      description: "A slider :)",
    },
    {
      name: "Text",
      description: "Self explanatory, really.",
    },
    {
      name: "Input",
      description: "An input element for entering text, is kinda buggy but there's nothing I can do about that, it's part of the Noita GUI API.",
      attributes: [{
        name: "max_length",
        values: [
          [number]
        ],
        description: "Maximum number of allowed characters"
      },
      {
        name: "allowed_characters",
        values: [
          [string]
        ],
        description: "Example: 0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
      }]
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
      name: "align_self_horizontal",
      values: [
        { types: [align_horizontal] },
      ],
      description: "Similar to the 'text-align' (real) CSS property. Only works when ^width is being set and is greater than the content width.",
    },
    {
      name: "align_self_vertical",
      values: [
        { types: [align_vertical] },
      ],
      description: "Similar to the 'text-align' (real) CSS property, but vertical. Only works when ^height is being set and is greater than the content height.",
    },
    {
      name: "border",
      values: [
        { types: [bool] },
      ],
      description: "Renders a border around an element.",
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
