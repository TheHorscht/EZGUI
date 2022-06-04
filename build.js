const fs = require('fs');
const AdmZip = require('adm-zip');
const path = require('path');
const minimatch = require("minimatch");
const pjson = require('./package.json');
const exec = require('child_process').exec;

let preview = false;

const args = process.argv.slice(2);
args.forEach(val => {
  if(val == '--preview') {
    preview = true;
  }
});

function execute(command, callback){
  exec(command, function(error, stdout, stderr){ callback(stdout); });
};

async function getGitTag() {
  return new Promise((resolve, reject) => {
    exec("git describe --tags", (error, stdout, stderr) => {
      resolve(stdout.replace(/[\r\n]*$/, ''));
    });
  });
}

// Config
const out_dir = __dirname + '/dist';
const name = path.basename(__dirname);
const version = pjson.version;
const root_folder = __dirname;
const ignore_list = [
  '**/node_modules',
  '**/.*',
  'www/*',
  '*.json',
  '*.js',
  'dist',
  'env.lua',
  '*.md',
  'unit_test.lua',
  'unit_tests.lua',
  'xxx.lua',
];
// Config end

const scriptName = path.basename(__filename);
ignore_list.push(scriptName);

function is_dir(path) {
  try {
    var stat = fs.lstatSync(path);
    return stat.isDirectory();
  } catch (e) {
    // lstatSync throws an error if path doesn't exist
    return false;
  }
}

const replacingFuncs = {
  ["changelog.txt"](content, version) {
    return version + ':\n' + content
  },
  ["EZGUI.lua"](content, version) {
    return `-- ${version}\n\n` + content
  },
};
const zip = new AdmZip();
const addFiles = (item, gitTag) => {
  if(ignore_list.every(ignore_entry => !minimatch(item, ignore_entry))) {
    if(is_dir(__dirname + '/' + item)) {
      fs.readdirSync(__dirname + '/' + item).forEach(entry => {
        const child_item = `${item}/${entry}`;
        addFiles(child_item);
      });
    } else {
      const folderName = item.substr(0, item.lastIndexOf('/'));
      if(preview) {
        console.log(item);
      } else {
        let content = fs.readFileSync(`${__dirname}/${item}`);
        content = replacingFuncs[item]?.(content, gitTag) || content;
        zip.addFile(`${name}/${item}`, content);
      }
    }
  }
};

(async () => {
  const gitTag = await getGitTag();
  fs.readdirSync(root_folder).forEach(entry => {
    addFiles(entry, gitTag);
  });
  if(!preview) {
    if (!fs.existsSync(out_dir)) {
      fs.mkdirSync(out_dir);
    }
    zip.writeZip(`${out_dir}/${name}_${gitTag}.zip`);
  }
})()
