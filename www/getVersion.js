const exec = require('child_process').exec;

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

module.exports = getGitTag;
