const Handlebars = require("handlebars");
const ghpages = require("gh-pages");
// const runeData = require("./runeData");
const elementData = require("./elementData");
// const potionBonusData = require("./potionBonusData");
const fs = require("fs-extra");
let template = fs.readFileSync("template.html").toString();
template = template.toString();
const compiled = Handlebars.compile(template);
if (!fs.existsSync("generated")){
  fs.mkdirSync("generated");
}
// if (!fs.existsSync("generated/assets")){
//   fs.mkdirSync("generated/assets");
// }
// if (!fs.existsSync("assets")){
//   fs.mkdirSync("assets");
// }
fs.copyFileSync("style.css", "generated/style.css");
fs.copyFileSync("script.js", "generated/script.js");
// fs.copySync("assets", "generated/assets");

Handlebars.registerHelper('description', function (str) {
  // str = str.replace(/<css>(.+?(?=<\/css>))<\/css>/g, `<a href="#css_$1" class="cssAttributeLink">$1</a>`)
  // str = str.replace(/\^(.+?(?=[^_a-zA-Z0-9]))/g, `<a href="#css_$1" class="cssAttributeLink">$1</a>`)
  str = str.replace(/\^([_a-zA-Z0-9]+)/g, `<a href="#$1">$1</a>`)
  str = str.replace(/@(.+?(?=[^a-zA-Z0-9]))/g, `<span class="highlight">$1</span>`)
  str = str.replace(/\n/g, `<br>`)
  return new Handlebars.SafeString(str);
})

Handlebars.registerHelper('concat', function (arr) {
  return arr.join(", ");
})

require("./getVersion.js")().then(version => {
  version = version.match(/v[0-9]+\.[0-9]+\.[0-9]+/g);
  elementData.version = (version ?? [""])[0];
  fs.writeFileSync("generated/index.html", compiled(elementData));
  if(process.argv[2] == "--upload") {
    ghpages.publish("generated", err => {
      if(err) {
        console.error(err);
      }
    });
  }
})
